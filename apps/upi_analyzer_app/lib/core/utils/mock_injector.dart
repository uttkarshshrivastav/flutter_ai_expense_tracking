// import '../database/database_helper.dart';

// class MockInjector {
//   final DatabaseHelper _databaseHelper;

//   MockInjector({DatabaseHelper? databaseHelper})
//     : _databaseHelper = databaseHelper ?? DatabaseHelper();

//   Future<void> ensureDemoData() async {
//     final transactionCount = await _databaseHelper.getTransactionCount();
//     final rawMessageCount = await _databaseHelper.getRawMessageCount();

//     if (rawMessageCount == 0) {
//       await injectMockNotifications();
//     }

//     if (transactionCount == 0) {
//       await injectDemoTransactions();
//     }
//   }

//   Future<void> resetAndSeedDemoData() async {
//     await _databaseHelper.clearDemoData();
//     await injectMockNotifications();
//     await injectDemoTransactions();
//   }

//   Future<void> injectMockNotifications() async {
//     final now = DateTime.now();
//     final notifications = [
//       'Paid Rs.450 to Swiggy via GPay from A/c 1234',
//       'Paid Rs.320 to Zomato via PhonePe UPI ref 884412',
//       'Debit Rs.1299.99 at Amazon using Paytm wallet',
//       'Paid Rs.750 for Uber ride through Google Pay',
//       'Credited Rs.5000 salary from ACME Pvt Ltd to Account No 9876543210',
//       'Payment of Rs.340 successful to IRCTC via Paytm',
//       'Rs.1200 spent at BigBasket through PhonePe',
//       'Received Rs.850 from Priya via GPay priya@okaxis',
//       'Debit Rs.699 for Netflix subscription ending in 4567',
//       'Paid Rs.2500 to Rent Owner via UPI owner@ybl',
//     ];

//     for (var index = 0; index < notifications.length; index++) {
//       await _databaseHelper.insertRawMessage({
//         'id': 'demo_raw_$index',
//         'raw_body': notifications[index],
//         'sanitized_body': '',
//         'timestamp': now
//             .subtract(Duration(hours: index * 7 + 1))
//             .millisecondsSinceEpoch,
//         'status': 'pending',
//       });
//     }
//   }

//   Future<void> injectDemoTransactions() async {
//     final now = DateTime.now();
//     const transactions = [
//       _DemoTransaction('Swiggy', 'Food', 450, 'GPay', 0.94, 1, 'expense'),
//       _DemoTransaction('Zomato', 'Food', 320, 'PhonePe', 0.88, 2, 'expense'),
//       _DemoTransaction(
//         'Amazon',
//         'Shopping',
//         1299.99,
//         'Paytm',
//         0.91,
//         4,
//         'expense',
//       ),
//       _DemoTransaction('Uber', 'Travel', 750, 'Google Pay', 0.82, 6, 'expense'),
//       _DemoTransaction(
//         'ACME Pvt Ltd',
//         'Salary',
//         5000,
//         'BHIM UPI',
//         0.97,
//         7,
//         'income',
//       ),
//       _DemoTransaction('IRCTC', 'Travel', 340, 'Paytm', 0.79, 9, 'expense'),
//       _DemoTransaction(
//         'BigBasket',
//         'Groceries',
//         1200,
//         'PhonePe',
//         0.86,
//         11,
//         'expense',
//       ),
//       _DemoTransaction('Priya', 'Transfer', 850, 'GPay', 0.58, 13, 'income'),
//       _DemoTransaction(
//         'Netflix',
//         'Subscriptions',
//         699,
//         'UPI',
//         0.55,
//         15,
//         'expense',
//       ),
//       _DemoTransaction(
//         'Rent Owner',
//         'Housing',
//         2500,
//         'UPI',
//         0.76,
//         18,
//         'expense',
//       ),
//       _DemoTransaction(
//         'Tata Power',
//         'Utilities',
//         1420,
//         'PhonePe',
//         0.83,
//         21,
//         'expense',
//       ),
//       _DemoTransaction(
//         'Apollo Pharmacy',
//         'Healthcare',
//         615,
//         'GPay',
//         0.62,
//         24,
//         'expense',
//       ),
//     ];

//     for (var index = 0; index < transactions.length; index++) {
//       final transaction = transactions[index];
//       final timestamp = now
//           .subtract(Duration(days: transaction.daysAgo))
//           .millisecondsSinceEpoch;

//       await _databaseHelper.insertRawMessage({
//         'id': 'demo_parsed_raw_$index',
//         'raw_body':
//             '${transaction.transactionType} Rs.${transaction.amount.toStringAsFixed(2)} ${transaction.merchant}',
//         'sanitized_body':
//             '${transaction.transactionType} Rs.${transaction.amount.toStringAsFixed(2)} ${transaction.merchant}',
//         'timestamp': timestamp,
//         'status': 'processed',
//       });

//       await _databaseHelper.insertTransaction({
//         'transaction_id': 'demo_txn_$index',
//         'raw_message_id': 'demo_parsed_raw_$index',
//         'amount': transaction.amount,
//         'currency': 'INR',
//         'transaction_type': transaction.transactionType,
//         'provider': transaction.provider,
//         'merchant': transaction.merchant,
//         'category': transaction.category,
//         'confidence': transaction.confidence,
//         'timestamp': timestamp,
//       });
//     }
//   }
// }

// class _DemoTransaction {
//   const _DemoTransaction(
//     this.merchant,
//     this.category,
//     this.amount,
//     this.provider,
//     this.confidence,
//     this.daysAgo,
//     this.transactionType,
//   );

//   final String merchant;
//   final String category;
//   final double amount;
//   final String provider;
//   final double confidence;
//   final int daysAgo;
//   final String transactionType;
// }



import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class MockInjector {
  final DatabaseHelper _databaseHelper;

  MockInjector({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  Future<void> ensureDemoData() async {
    final transactionCount = await _databaseHelper.getTransactionCount();
    final rawMessageCount = await _databaseHelper.getRawMessageCount();

    if (rawMessageCount == 0) {
      await injectMockNotifications();
    }

    if (transactionCount == 0) {
      await injectDemoTransactions();
    }
  }

  Future<void> resetAndSeedDemoData() async {
    await _databaseHelper.clearDemoData();
    await injectMockNotifications();
    await injectDemoTransactions();
  }

  Future<void> injectMockNotifications() async {
    final now = DateTime.now();
    final notifications = [
      'Paid Rs.450 to Swiggy via GPay from A/c 1234',
      'Paid Rs.320 to Zomato via PhonePe UPI ref 884412',
      'Debit Rs.1299.99 at Amazon using Paytm wallet',
      'Paid Rs.750 for Uber ride through Google Pay',
      'Credited Rs.5000 salary from ACME Pvt Ltd to Account No 9876543210',
      'Payment of Rs.340 successful to IRCTC via Paytm',
      'Rs.1200 spent at BigBasket through PhonePe',
      'Received Rs.850 from Priya via GPay priya@okaxis',
      'Debit Rs.699 for Netflix subscription ending in 4567',
      'Paid Rs.2500 to Rent Owner via UPI owner@ybl',
    ];

    for (var index = 0; index < notifications.length; index++) {
      await _databaseHelper.insertRawMessage({
        'id': 'demo_raw_$index',
        'raw_body': notifications[index],
        'sanitized_body': '',
        'timestamp': now.subtract(Duration(hours: index * 7 + 1)).millisecondsSinceEpoch,
        'status': 'pending',
      });
    }
  }

  Future<void> injectDemoTransactions() async {
    final now = DateTime.now();
    const transactions = [
      _DemoTransaction('Swiggy', 'Food', 450, 'GPay', 0.94, 1, 'expense'),
      _DemoTransaction('Zomato', 'Food', 320, 'PhonePe', 0.88, 2, 'expense'),
      _DemoTransaction('Amazon', 'Shopping', 1299.99, 'Paytm', 0.91, 4, 'expense'),
      _DemoTransaction('Uber', 'Travel', 750, 'Google Pay', 0.82, 6, 'expense'),
      _DemoTransaction('ACME Pvt Ltd', 'Salary', 5000, 'BHIM UPI', 0.97, 7, 'income'),
      _DemoTransaction('IRCTC', 'Travel', 340, 'Paytm', 0.79, 9, 'expense'),
      _DemoTransaction('BigBasket', 'Groceries', 1200, 'PhonePe', 0.86, 11, 'expense'),
      _DemoTransaction('Priya', 'Transfer', 850, 'GPay', 0.58, 13, 'income'),
      _DemoTransaction('Netflix', 'Subscriptions', 699, 'UPI', 0.55, 15, 'expense'),
      _DemoTransaction('Rent Owner', 'Housing', 2500, 'UPI', 0.76, 18, 'expense'),
      _DemoTransaction('Tata Power', 'Utilities', 1420, 'PhonePe', 0.83, 21, 'expense'),
      _DemoTransaction('Apollo Pharmacy', 'Healthcare', 615, 'GPay', 0.62, 24, 'expense'),
    ];

    for (var index = 0; index < transactions.length; index++) {
      final transaction = transactions[index];
      final timestamp = now.subtract(Duration(days: transaction.daysAgo)).millisecondsSinceEpoch;

      await _databaseHelper.insertRawMessage({
        'id': 'demo_parsed_raw_$index',
        'raw_body': '${transaction.transactionType} Rs.${transaction.amount.toStringAsFixed(2)} ${transaction.merchant}',
        'sanitized_body': '${transaction.transactionType} Rs.${transaction.amount.toStringAsFixed(2)} ${transaction.merchant}',
        'timestamp': timestamp,
        'status': 'processed',
      });

      await _databaseHelper.insertTransaction({
        'transaction_id': 'demo_txn_$index',
        'raw_message_id': 'demo_parsed_raw_$index',
        'amount': transaction.amount,
        'currency': 'INR',
        'transaction_type': transaction.transactionType,
        'provider': transaction.provider,
        'merchant': transaction.merchant,
        'category': transaction.category,
        'confidence': transaction.confidence,
        'timestamp': timestamp,
      });
    }
  }
}

class _DemoTransaction {
  const _DemoTransaction(this.merchant, this.category, this.amount, this.provider, this.confidence, this.daysAgo, this.transactionType);
  final String merchant;
  final String category;
  final double amount;
  final String provider;
  final double confidence;
  final int daysAgo;
  final String transactionType;
}