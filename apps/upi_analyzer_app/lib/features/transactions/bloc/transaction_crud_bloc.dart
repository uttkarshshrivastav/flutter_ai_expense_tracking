import 'package:bloc/bloc.dart';
import '../../../core/database/database_helper.dart';

/// Events for the TransactionCrudBloc
abstract class TransactionCrudEvent {}

/// Event to load transactions
class LoadTransactions extends TransactionCrudEvent {}

/// Event to reload transactions (e.g., after new transactions are added)
class ReloadTransactions extends TransactionCrudEvent {}

/// States for the TransactionCrudBloc
abstract class TransactionCrudState {}

/// Initial state before any transactions are loaded
class TransactionCrudInitial extends TransactionCrudState {}

/// State when transactions are being loaded
class TransactionCrudLoading extends TransactionCrudState {}

/// State when transactions have been successfully loaded
class TransactionCrudSuccess extends TransactionCrudState {
  final List<Map<String, dynamic>> transactions;

  TransactionCrudSuccess(this.transactions);
}

/// State when an error occurred while loading transactions
class TransactionCrudError extends TransactionCrudState {
  final String message;

  TransactionCrudError(this.message);
}

/// Bloc that handles fetching parsed transactions for the UI
class TransactionCrudBloc
    extends Bloc<TransactionCrudEvent, TransactionCrudState> {
  final DatabaseHelper _databaseHelper;

  TransactionCrudBloc({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper(),
      super(TransactionCrudInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<ReloadTransactions>(_onReloadTransactions);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionCrudState> emit,
  ) async {
    emit(TransactionCrudLoading());

    try {
      final transactions = await _databaseHelper.getTransactions();
      emit(TransactionCrudSuccess(transactions));
    } catch (e) {
      emit(TransactionCrudError('Failed to load transactions: $e'));
    }
  }

  Future<void> _onReloadTransactions(
    ReloadTransactions event,
    Emitter<TransactionCrudState> emit,
  ) async {
    emit(TransactionCrudLoading());

    try {
      final transactions = await _databaseHelper.getTransactions();
      emit(TransactionCrudSuccess(transactions));
    } catch (e) {
      emit(TransactionCrudError('Failed to reload transactions: $e'));
    }
  }
}
