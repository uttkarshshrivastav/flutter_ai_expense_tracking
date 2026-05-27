import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:upi_parser_ai/upi_parser_ai.dart';

/// Repository for handling SMS-related operations including historical sync.
class SmsRepository {
  static const MethodChannel _channel = MethodChannel(
    'com.example.upi_analyzer_app/sms',
  );

  /// Performs the 10-Day Historical Sync by querying the device's SMS inbox
  /// for financial messages from the last 10 days and storing them in the database.
  ///
  /// This method requires the READ_SMS permission to be granted.
  Future<void> performTenDayHistoricalSync() async {
    try {
      // Calculate the timestamp for 10 days ago
      final tenDaysAgo = DateTime.now()
          .subtract(const Duration(days: 10))
          .millisecondsSinceEpoch;

      // Known financial sender IDs to filter for
      const financialSenders = [
        'HDFC',
        'SBI',
        'PAYTM',
        'ICICI',
        'KOTAK',
        'AXIS',
        'YES',
      ];

      // Query SMS via platform channel
      final List<Map<String, dynamic>> financialMessages =
          await _queryFinancialSms(tenDaysAgo, financialSenders);

      // Insert each financial message into the raw_messages table
      for (final message in financialMessages) {
        // Sanitize the message body to remove PII
        final sanitizedBody = PiiSanitizer.sanitize(message['body'] as String);

        await _insertRawMessage({
          'id': message['id'],
          'raw_body': message['body'],
          'sanitized_body': sanitizedBody,
          'timestamp': message['timestamp'],
          'status': 'pending',
        });
      }
    } catch (e) {
      debugPrint('Error performing 10-day historical sync: $e');
      rethrow;
    }
  }

  /// Queries the device's SMS inbox for financial messages via platform channel.
  Future<List<Map<String, dynamic>>> _queryFinancialSms(
    int sinceTimestamp,
    List<String> financialSenders,
  ) async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'queryFinancialSms',
        {
          'sinceTimestamp': sinceTimestamp,
          'financialSenders': financialSenders,
        },
      );
      return result
          .map((dynamic item) => Map<String, dynamic>.from(item))
          .toList();
    } on PlatformException catch (e) {
      throw Exception('Failed to query SMS: ${e.message}');
    }
  }

  /// Inserts a raw message into the database via platform channel.
  Future<void> _insertRawMessage(Map<String, dynamic> rawMessage) async {
    try {
      await _channel.invokeMethod('insertRawMessage', {
        'rawMessage': rawMessage,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to insert raw message: ${e.message}');
    }
  }
}
