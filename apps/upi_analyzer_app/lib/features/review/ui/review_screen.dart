import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/mock_injector.dart';
import '../../transactions/bloc/transaction_crud_bloc.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('Review Transactions'),
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              actions: [
                IconButton(
  onPressed: () async {
    // 1. Show a loading indicator or print statement (optional but helpful)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Resetting Demo Data...')),
    );

    // 2. Pass the DatabaseHelper singleton to MockInjector
    await MockInjector(databaseHelper: DatabaseHelper()).resetAndSeedDemoData();
    
    // 3. Trigger the BLoC to rebuild your UI with the fresh data
    if (context.mounted) {
      context.read<TransactionCrudBloc>().add(ReloadTransactions());
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data Reset Complete!')),
      );
    }
  },
  icon: const Icon(Icons.refresh, color: Colors.black87),
),
              ],
            ),
            BlocBuilder<TransactionCrudBloc, TransactionCrudState>(
              builder: (context, state) {
                if (state is TransactionCrudLoading ||
                    state is TransactionCrudInitial) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is TransactionCrudError) {
                  return SliverFillRemaining(
                    child: Center(child: Text(state.message)),
                  );
                }

                final transactions = state is TransactionCrudSuccess
                    ? state.transactions
                    : <Map<String, dynamic>>[];

                if (transactions.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No transactions yet')),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index.isOdd) {
                      return const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFEEEEEE),
                      );
                    }
                    return _TransactionRow(
                      transaction: transactions[index ~/ 2],
                    );
                  }, childCount: transactions.length * 2 - 1),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final Map<String, dynamic> transaction;

  @override
  Widget build(BuildContext context) {
    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0;
    final confidence = (transaction['confidence'] as num?)?.toDouble() ?? 0;
    final needsReview = confidence < 0.60;
    final type = transaction['transaction_type'] as String? ?? 'expense';
    final amountPrefix = type == 'income' ? '+' : '-';

    return InkWell(
      onTap: () => _showEditSheet(context, transaction),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$amountPrefix Rs.${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    transaction['merchant'] as String? ?? 'Unknown',
                    style: const TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${transaction['category'] ?? 'Other'} - ${transaction['provider'] ?? 'Unknown'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            if (needsReview)
              Text(
                'Review Required',
                style: TextStyle(
                  color: Colors.deepOrange[300],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, Map<String, dynamic> transaction) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      elevation: 0,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _EditTransactionSheet(transaction: transaction),
    );
  }
}

class _EditTransactionSheet extends StatefulWidget {
  const _EditTransactionSheet({required this.transaction});

  final Map<String, dynamic> transaction;

  @override
  State<_EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<_EditTransactionSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _merchantController;
  late final TextEditingController _categoryController;
  late String _transactionType;

  @override
  void initState() {
    super.initState();
    final amount = (widget.transaction['amount'] as num?)?.toDouble() ?? 0;
    _amountController = TextEditingController(text: amount.toStringAsFixed(2));
    _merchantController = TextEditingController(
      text: widget.transaction['merchant'] as String? ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.transaction['category'] as String? ?? '',
    );
    _transactionType =
        widget.transaction['transaction_type'] as String? ?? 'expense';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 28),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Transaction',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Amount',
                prefixText: 'Rs. ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _merchantController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Merchant',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Category',
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _transactionType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Type',
              ),
              items: const [
                DropdownMenuItem(value: 'expense', child: Text('Expense')),
                DropdownMenuItem(value: 'income', child: Text('Income')),
                DropdownMenuItem(value: 'refund', child: Text('Refund')),
                DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                DropdownMenuItem(value: 'failed', child: Text('Failed')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _transactionType = value);
              },
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F4A4A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final bloc = context.read<TransactionCrudBloc>();
    final messenger = ScaffoldMessenger.of(context);
    await DatabaseHelper().updateTransaction({
      'transaction_id': widget.transaction['transaction_id'],
      'amount': amount,
      'merchant': _merchantController.text.trim().isEmpty
          ? 'Unknown'
          : _merchantController.text.trim(),
      'category': _categoryController.text.trim().isEmpty
          ? 'Other'
          : _categoryController.text.trim(),
      'transaction_type': _transactionType,
    });

    if (!mounted) return;
    Navigator.of(context).pop();
    bloc.add(ReloadTransactions());
    messenger.showSnackBar(const SnackBar(content: Text('Transaction saved')));
  }
}
