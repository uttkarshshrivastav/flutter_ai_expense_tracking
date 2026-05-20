import 'dart:convert';

import 'package:http/http.dart' as http;

import 'llm_parsing_exception.dart';
import 'models/transaction_model.dart';

class GroqClient {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const Set<String> _allowedTypes = {
    'expense',
    'income',
    'refund',
    'transfer',
    'failed',
  };

  final String apiKey;

  GroqClient({required this.apiKey});

  Future<TransactionModel> parseTransaction(String sanitizedMessage) async {
    if (apiKey.trim().isEmpty) {
      throw LlmParsingException('Groq API key is empty');
    }

    final requestBody = {
      'model': 'mixtral-8x7b-32768',
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a financial transaction parser. Return only one valid JSON object with fields: amount number, currency string default INR, transactionType one of expense/income/refund/transfer/failed, provider string, merchant string, category string, confidence number from 0 to 1.',
        },
        {'role': 'user', 'content': sanitizedMessage},
      ],
      'temperature': 0.1,
      'max_tokens': 500,
      'response_format': {'type': 'json_object'},
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode != 200) {
        throw LlmParsingException(
          'Groq API request failed with status: ${response.statusCode}',
          response.body,
        );
      }

      final responseData = json.decode(response.body) as Map<String, dynamic>;
      final content =
          responseData['choices']?[0]['message']?['content'] as String?;

      if (content == null || content.trim().isEmpty) {
        throw LlmParsingException(
          'Empty response from Groq API',
          response.body,
        );
      }

      final decoded = json.decode(content);
      if (decoded is! Map<String, dynamic>) {
        throw LlmParsingException(
          'Groq response was not a JSON object',
          decoded,
        );
      }

      final model = TransactionModel.fromJson(decoded);
      _validate(model);
      return model;
    } on FormatException catch (error) {
      throw LlmParsingException('Groq returned invalid JSON', error);
    } on LlmParsingException {
      rethrow;
    } catch (error) {
      throw LlmParsingException(
        'Error communicating with Groq API: $error',
        error,
      );
    }
  }

  void _validate(TransactionModel model) {
    if (model.amount < 0) {
      throw LlmParsingException(
        'Invalid negative transaction amount',
        model.toJson(),
      );
    }
    if (!_allowedTypes.contains(model.transactionType)) {
      throw LlmParsingException(
        'Invalid transactionType: ${model.transactionType}',
        model.toJson(),
      );
    }
    if (model.confidence < 0 || model.confidence > 1) {
      throw LlmParsingException('Invalid confidence value', model.toJson());
    }
    if (model.provider.trim().isEmpty ||
        model.merchant.trim().isEmpty ||
        model.category.trim().isEmpty) {
      throw LlmParsingException(
        'Required transaction fields were empty',
        model.toJson(),
      );
    }
  }
}
