import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:upi_parser_ai/upi_parser_ai.dart';

import '../../../../core/database/database_helper.dart';

abstract class TransactionParserEvent {}

class StartParsing extends TransactionParserEvent {}

abstract class TransactionParserState {}

class TransactionParserInitial extends TransactionParserState {}

class TransactionParserParsing extends TransactionParserState {
  TransactionParserParsing({
    required this.pendingCount,
    required this.processedCount,
    required this.failedParsingCount,
    required this.networkFailedCount,
  });

  final int pendingCount;
  final int processedCount;
  final int failedParsingCount;
  final int networkFailedCount;
}

class TransactionParserComplete extends TransactionParserState {
  TransactionParserComplete({
    required this.processedCount,
    required this.failedParsingCount,
    required this.networkFailedCount,
  });

  final int processedCount;
  final int failedParsingCount;
  final int networkFailedCount;
}

class TransactionParserBloc
    extends Bloc<TransactionParserEvent, TransactionParserState> {
  TransactionParserBloc({
    DatabaseHelper? databaseHelper,
    required GroqClient groqClient,
    this.useOfflineParser = false,
  }) : _databaseHelper = databaseHelper ?? DatabaseHelper(),
       _groqClient = groqClient,
       super(TransactionParserInitial()) {
    on<StartParsing>(_onStartParsing);
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(StartParsing()),
    );
  }

  final DatabaseHelper _databaseHelper;
  final GroqClient _groqClient;
  final bool useOfflineParser;

  Timer? _pollingTimer;
  bool _isProcessing = false;

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }

  Future<void> _onStartParsing(
    StartParsing event,
    Emitter<TransactionParserState> emit,
  ) async {
    if (_isProcessing) return;
    _isProcessing = true;

    var processedCount = 0;
    var failedParsingCount = 0;
    var networkFailedCount = 0;

    try {
      while (true) {
        final pendingMessages = await _databaseHelper.getRawMessagesByStatus(
          'pending',
        );

        emit(
          TransactionParserParsing(
            pendingCount: pendingMessages.length,
            processedCount: processedCount,
            failedParsingCount: failedParsingCount,
            networkFailedCount: networkFailedCount,
          ),
        );

        if (pendingMessages.isEmpty) break;

        final batch = pendingMessages.take(min(5, pendingMessages.length));
        var handledInBatch = 0;
        for (final message in batch) {
          final messageId = message['id'] as String;
          final rawBody = message['raw_body'] as String;
          final sanitizedBody = PiiSanitizer.sanitize(rawBody);

          try {
            final transaction = useOfflineParser
                ? _parseOffline(sanitizedBody)
                : await _groqClient.parseTransaction(sanitizedBody);

            await _databaseHelper.insertTransaction({
              'transaction_id': 'parsed_$messageId',
              'raw_message_id': messageId,
              'amount': transaction.amount,
              'currency': transaction.currency,
              'transaction_type': transaction.transactionType,
              'provider': transaction.provider,
              'merchant': transaction.merchant,
              'category': transaction.category,
              'confidence': transaction.confidence,
              'timestamp': message['timestamp'],
            });

            await _databaseHelper.updateRawMessage({
              'id': messageId,
              'status': 'processed',
              'sanitized_body': sanitizedBody,
            });
            processedCount++;
            handledInBatch++;
          } on LlmParsingException catch (error) {
            if (_isLikelyNetworkFailure(error)) {
              networkFailedCount++;
            } else {
              await _databaseHelper.updateRawMessage({
                'id': messageId,
                'status': 'failed_parsing',
                'sanitized_body': sanitizedBody,
              });
              failedParsingCount++;
              handledInBatch++;
            }
          } catch (_) {
            networkFailedCount++;
          }

          emit(
            TransactionParserParsing(
              pendingCount: max(0, pendingMessages.length - handledInBatch),
              processedCount: processedCount,
              failedParsingCount: failedParsingCount,
              networkFailedCount: networkFailedCount,
            ),
          );

          if (!useOfflineParser) {
            await Future<void>.delayed(const Duration(seconds: 10));
          }
        }

        if (pendingMessages.length <= batch.length) break;
      }

      emit(
        TransactionParserComplete(
          processedCount: processedCount,
          failedParsingCount: failedParsingCount,
          networkFailedCount: networkFailedCount,
        ),
      );
    } finally {
      _isProcessing = false;
    }
  }

  bool _isLikelyNetworkFailure(LlmParsingException error) {
    final message = error.message.toLowerCase();
    return message.contains('api request failed') ||
        message.contains('communicating') ||
        message.contains('empty response');
  }

  TransactionModel _parseOffline(String message) {
    final lower = message.toLowerCase();
    final amountMatch = RegExp(
      r'(?:rs\.?|inr)\s*([0-9,]+(?:\.\d+)?)',
    ).firstMatch(lower);
    final amount =
        double.tryParse(amountMatch?.group(1)?.replaceAll(',', '') ?? '') ?? 0;

    final transactionType =
        lower.contains('received') ||
            lower.contains('credited') ||
            lower.contains('salary')
        ? 'income'
        : lower.contains('refund')
        ? 'refund'
        : lower.contains('failed')
        ? 'failed'
        : lower.contains('transfer')
        ? 'transfer'
        : 'expense';

    final merchant = _extractMerchant(message);
    final provider = _extractProvider(lower);
    final category = _categorize(merchant, lower, transactionType);
    final confidence = merchant == 'Unknown' || amount == 0 ? 0.52 : 0.82;

    return TransactionModel(
      amount: amount,
      currency: 'INR',
      transactionType: transactionType,
      provider: provider,
      merchant: merchant,
      category: category,
      confidence: confidence,
    );
  }

  String _extractProvider(String lower) {
    if (lower.contains('phonepe')) {
      return 'PhonePe';
    }
    if (lower.contains('paytm')) {
      return 'Paytm';
    }
    if (lower.contains('gpay') || lower.contains('google pay')) {
      return 'Google Pay';
    }
    if (lower.contains('bhim')) {
      return 'BHIM UPI';
    }
    if (lower.contains('upi')) {
      return 'UPI';
    }
    return 'Unknown';
  }

  String _extractMerchant(String message) {
    final patterns = [
      RegExp(
        r'\bto\s+([^@,.-]+?)(?:\s+via|\s+through|\s+from|\s+upi|\s*$)',
        caseSensitive: false,
      ),
      RegExp(
        r'\bat\s+([^@,.-]+?)(?:\s+using|\s+via|\s*$)',
        caseSensitive: false,
      ),
      RegExp(
        r'\bfor\s+([^@,.-]+?)(?:\s+via|\s+through|\s*$)',
        caseSensitive: false,
      ),
      RegExp(
        r'\bfrom\s+([^@,.-]+?)(?:\s+via|\s+to|\s*$)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      final value = match?.group(1)?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return 'Unknown';
  }

  String _categorize(String merchant, String lower, String transactionType) {
    if (transactionType == 'income') {
      return 'Income';
    }
    final value = '${merchant.toLowerCase()} $lower';
    if (value.contains('swiggy') || value.contains('zomato')) {
      return 'Food';
    }
    if (value.contains('bigbasket')) {
      return 'Groceries';
    }
    if (value.contains('uber') || value.contains('irctc')) {
      return 'Travel';
    }
    if (value.contains('amazon')) {
      return 'Shopping';
    }
    if (value.contains('netflix')) {
      return 'Subscriptions';
    }
    if (value.contains('rent')) {
      return 'Housing';
    }
    if (value.contains('power') || value.contains('electric')) {
      return 'Utilities';
    }
    if (value.contains('pharmacy') || value.contains('medical')) {
      return 'Healthcare';
    }
    return 'Other';
  }
}
