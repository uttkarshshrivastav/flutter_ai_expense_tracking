import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

/// Model representing a financial transaction parsed from UPI/SMS messages.
@JsonSerializable()
class TransactionModel {
  /// The amount of the transaction.
  final double amount;

  /// The currency of the transaction (default: 'INR').
  final String currency;

  /// The type of transaction: expense, income, refund, transfer, or failed.
  final String transactionType;

  /// The payment provider/service used (e.g., 'GPay', 'PhonePe', 'Paytm').
  final String provider;

  /// The merchant or recipient name.
  final String merchant;

  /// The category of the transaction (e.g., 'Food', 'Travel', 'Utilities').
  final String category;

  /// Confidence score of the parsing (0.0 to 1.0).
  final double confidence;

  /// Constructor for TransactionModel.
  TransactionModel({
    required this.amount,
    this.currency = 'INR',
    required this.transactionType,
    required this.provider,
    required this.merchant,
    required this.category,
    required this.confidence,
  });

  /// Factory method to create a TransactionModel from JSON.
  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  /// Converts the TransactionModel to JSON.
  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}
