import 'dart:io';

import 'package:upi_parser_ai/upi_parser_ai.dart';

Future<void> main() async {
  final rawMessage = 'Paid Rs.450 to Swiggy via GPay from A/c 1234 user@okaxis';
  final sanitizedMessage = PiiSanitizer.sanitize(rawMessage);

  print('Raw: $rawMessage');
  print('Sanitized: $sanitizedMessage');

  final apiKey = Platform.environment['GROQ_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    print('Set GROQ_API_KEY to run the Groq parsing example.');
    return;
  }

  final client = GroqClient(apiKey: apiKey);
  try {
    final transaction = await client.parseTransaction(sanitizedMessage);
    print('Parsed transaction: ${transaction.toJson()}');
  } on LlmParsingException catch (error) {
    print('LLM parsing failed safely: $error');
  }
}
