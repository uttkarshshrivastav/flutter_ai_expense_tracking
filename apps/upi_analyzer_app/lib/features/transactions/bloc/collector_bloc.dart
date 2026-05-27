import 'package:bloc/bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../repository/sms_repository.dart';

/// Events for the CollectorBloc
abstract class CollectorEvent {}

/// Event to check and request permissions
class CheckPermissions extends CollectorEvent {}

/// Event to start the 10-day historical sync
class StartHistoricalSync extends CollectorEvent {}

/// Event to indicate that permissions have been granted
class PermissionsGranted extends CollectorEvent {}

/// Event to indicate that permissions have been denied
class PermissionsDenied extends CollectorEvent {}

/// States for the CollectorBloc
abstract class CollectorState {}

/// Initial state before any checks
class CollectorInitial extends CollectorState {}

/// State when checking permissions
class CollectorCheckingPermissions extends CollectorState {}

/// State when permissions have been granted
class CollectorPermissionsGranted extends CollectorState {}

/// State when permissions have been denied
class CollectorPermissionsDenied extends CollectorState {}

/// State when historical sync is in progress
class CollectorSyncingHistorical extends CollectorState {}

/// State when historical sync is complete
class CollectorHistoricalSyncComplete extends CollectorState {}

/// State when an error occurred
class CollectorError extends CollectorState {
  final String message;

  CollectorError(this.message);
}

/// Bloc that manages permission states and triggers the 10-Day Historical Sync
class CollectorBloc extends Bloc<CollectorEvent, CollectorState> {
  final SmsRepository _smsRepository;

  CollectorBloc({SmsRepository? smsRepository})
    : _smsRepository = smsRepository ?? SmsRepository(),
      super(CollectorInitial()) {
    on<CheckPermissions>(_onCheckPermissions);
    on<StartHistoricalSync>(_onStartHistoricalSync);
  }

  Future<void> _onCheckPermissions(
    CheckPermissions event,
    Emitter<CollectorState> emit,
  ) async {
    emit(CollectorCheckingPermissions());

    final status = await Permission.sms.status;

    if (status.isGranted) {
      emit(CollectorPermissionsGranted());
      add(StartHistoricalSync());
    } else if (status.isDenied) {
      final result = await Permission.sms.request();
      if (result.isGranted) {
        emit(CollectorPermissionsGranted());
        add(StartHistoricalSync());
      } else {
        emit(CollectorPermissionsDenied());
      }
    } else {
      // Handle other cases (permanently denied, etc.)
      emit(CollectorPermissionsDenied());
    }
  }

  Future<void> _onStartHistoricalSync(
    StartHistoricalSync event,
    Emitter<CollectorState> emit,
  ) async {
    emit(CollectorSyncingHistorical());

    try {
      await _smsRepository.performTenDayHistoricalSync();
      emit(CollectorHistoricalSyncComplete());
    } catch (e) {
      emit(CollectorError('Failed to perform historical sync: $e'));
    }
  }
}
