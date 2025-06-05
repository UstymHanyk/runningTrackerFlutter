import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_project/services/microcontroller_service.dart';
import 'package:flutter/foundation.dart';

// States
abstract class MicrocontrollerState extends Equatable {
  const MicrocontrollerState();

  @override
  List<Object?> get props => [];
}

class MicrocontrollerInitial extends MicrocontrollerState {}

class MicrocontrollerLoading extends MicrocontrollerState {}

class MicrocontrollerLoaded extends MicrocontrollerState {
  final String? currentSerialNumber;
  final String? storedUsername;
  final bool hasStoredCredentials;
  final bool isConfigured;

  const MicrocontrollerLoaded({
    this.currentSerialNumber,
    this.storedUsername,
    required this.hasStoredCredentials,
    required this.isConfigured,
  });

  @override
  List<Object?> get props => [
        currentSerialNumber,
        storedUsername,
        hasStoredCredentials,
        isConfigured,
      ];

  MicrocontrollerLoaded copyWith({
    String? currentSerialNumber,
    String? storedUsername,
    bool? hasStoredCredentials,
    bool? isConfigured,
  }) {
    return MicrocontrollerLoaded(
      currentSerialNumber: currentSerialNumber ?? this.currentSerialNumber,
      storedUsername: storedUsername ?? this.storedUsername,
      hasStoredCredentials: hasStoredCredentials ?? this.hasStoredCredentials,
      isConfigured: isConfigured ?? this.isConfigured,
    );
  }
}

class MicrocontrollerError extends MicrocontrollerState {
  final String message;

  const MicrocontrollerError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class MicrocontrollerCubit extends Cubit<MicrocontrollerState> {
  final MicrocontrollerService _service;

  MicrocontrollerCubit(this._service) : super(MicrocontrollerInitial());

  Future<void> initialize() async {
    debugPrint('MicrocontrollerCubit: Starting initialization...');
    emit(MicrocontrollerLoading());
    try {
      debugPrint('MicrocontrollerCubit: Fetching current serial number...');
      await _service.fetchCurrentSerialNumber();
      debugPrint('MicrocontrollerCubit: Fetch completed, emitting loaded state...');
      _emitLoadedState();
      debugPrint('MicrocontrollerCubit: Initialization complete!');
    } catch (e) {
      debugPrint('MicrocontrollerCubit: Initialization failed: $e');
      emit(MicrocontrollerError('Failed to initialize: $e'));
    }
  }

  Future<void> fetchCurrentSerialNumber() async {
    emit(MicrocontrollerLoading());
    try {
      await _service.fetchCurrentSerialNumber();
      _emitLoadedState();
    } catch (e) {
      emit(MicrocontrollerError(_service.error ?? 'Failed to fetch serial number'));
    }
  }

  Future<void> updateSerialNumber(String serialNumber) async {
    emit(MicrocontrollerLoading());
    try {
      final success = await _service.updateSerialNumber(serialNumber);
      if (success) {
        _emitLoadedState();
      } else {
        emit(MicrocontrollerError(_service.error ?? 'Failed to update serial number'));
      }
    } catch (e) {
      emit(MicrocontrollerError('Failed to update serial number: $e'));
    }
  }

  Future<void> saveCredentials(String username, String password) async {
    emit(MicrocontrollerLoading());
    try {
      await _service.saveCredentials(username, password);
      if (_service.error != null) {
        emit(MicrocontrollerError(_service.error!));
      } else {
        _emitLoadedState();
      }
    } catch (e) {
      emit(MicrocontrollerError('Failed to save credentials: $e'));
    }
  }

  Future<void> clearStoredData() async {
    emit(MicrocontrollerLoading());
    try {
      await _service.clearStoredData();
      _emitLoadedState();
    } catch (e) {
      emit(MicrocontrollerError('Failed to clear data: $e'));
    }
  }

  Map<String, String>? parseQRCredentials(String qrData) {
    return _service.parseQRCredentials(qrData);
  }

  void _emitLoadedState() {
    debugPrint(' MicrocontrollerCubit: Emitting loaded state with:');
    debugPrint('   - Serial: ${_service.currentSerialNumber}');
    debugPrint('   - Username: ${_service.storedUsername}');
    debugPrint('   - Has Credentials: ${_service.hasStoredCredentials}');
    debugPrint('   - Is Configured: ${_service.isConfigured}');
    
    emit(MicrocontrollerLoaded(
      currentSerialNumber: _service.currentSerialNumber,
      storedUsername: _service.storedUsername,
      hasStoredCredentials: _service.hasStoredCredentials,
      isConfigured: _service.isConfigured,
    ));
  }
} 