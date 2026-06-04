import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:upi_parser_ai/upi_parser_ai.dart';

import '../../../../core/database/database_helper.dart';

class InsightRepository {
  InsightRepository({
    DatabaseHelper? databaseHelper,
    required GroqClient groqClient,
  }) : _databaseHelper = databaseHelper ?? DatabaseHelper(),
       _groqClient = groqClient;

  final DatabaseHelper _databaseHelper;
  final GroqClient _groqClient;

  Future<String> generateInsightSummary() async {
    final monthlyExpenses = await _databaseHelper.getMonthlyExpenses();
    final categoryDistribution = await _databaseHelper
        .getCategoryDistribution();
    final topMerchants = await _databaseHelper.getTopMerchants();

    final buffer = StringBuffer('Financial Summary for Current Month:\n\n');

    buffer.writeln('Daily Expenses:');
    for (final row in monthlyExpenses) {
      buffer.writeln('Day ${row['day']}: INR ${_money(row['total'])}');
    }

    buffer.writeln('\nExpenses by Category:');
    for (final row in categoryDistribution) {
      buffer.writeln('${row['category']}: INR ${_money(row['total'])}');
    }

    buffer.writeln('\nTop 5 Merchants by Spending:');
    for (final row in topMerchants) {
      buffer.writeln('${row['merchant']}: INR ${_money(row['total'])}');
    }

    return buffer.toString();
  }

  Future<String> fetchAiAdvice() async {
    if (_groqClient.apiKey.trim().isEmpty) {
      return _fallbackAdvice();
    }

    final summary = await generateInsightSummary();
    final requestBody = {
      'model': 'mixtral-8x7b-32768',
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a helpful financial advisor. Provide 2 short, concise actionable budget suggestions.',
        },
        {'role': 'user', 'content': summary},
      ],
      'temperature': 0.7,
      'max_tokens': 180,
    };

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_groqClient.apiKey}',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode != 200) return _fallbackAdvice();

      final responseData = json.decode(response.body) as Map<String, dynamic>;
      final content =
          responseData['choices']?[0]['message']?['content'] as String?;
      return content?.trim().isNotEmpty == true
          ? content!.trim()
          : _fallbackAdvice();
    } catch (_) {
      return _fallbackAdvice();
    }
  }

  String _fallbackAdvice() {
    return '1. Cap food delivery spend this week and move one meal to groceries.\n'
        '2. Review subscription and travel charges before the next billing cycle.';
  }

  String _money(Object? value) {
    final amount = (value as num?)?.toDouble() ?? 0;
    return amount.toStringAsFixed(2);
  }
}
