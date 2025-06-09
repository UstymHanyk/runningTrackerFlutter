part of 'microcontroller_cubit.dart';

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