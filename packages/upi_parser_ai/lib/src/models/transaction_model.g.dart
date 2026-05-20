
part of 'transaction_model.dart';

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      transactionType: json['transactionType'] as String,
      provider: json['provider'] as String,
      merchant: json['merchant'] as String,
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'currency': instance.currency,
      'transactionType': instance.transactionType,
      'provider': instance.provider,
      'merchant': instance.merchant,
      'category': instance.category,
      'confidence': instance.confidence,
    };
