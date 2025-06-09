part of 'heart_rate_cubit.dart';

abstract class HeartRateState extends Equatable {
  const HeartRateState();

  @override
  List<Object?> get props => [];
}

class HeartRateInitial extends HeartRateState {}

class HeartRateConnecting extends HeartRateState {}

class HeartRateConnected extends HeartRateState {
  final double currentHeartRate;
  final String connectionStatus;
  final String deviceStatus;

  const HeartRateConnected({
    required this.currentHeartRate,
    required this.connectionStatus,
    required this.deviceStatus,
  });

  @override
  List<Object> get props => [currentHeartRate, connectionStatus, deviceStatus];

  HeartRateConnected copyWith({
    double? currentHeartRate,
    String? connectionStatus,
    String? deviceStatus,
  }) {
    return HeartRateConnected(
      currentHeartRate: currentHeartRate ?? this.currentHeartRate,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      deviceStatus: deviceStatus ?? this.deviceStatus,
    );
  }
}

class HeartRateDisconnected extends HeartRateState {
  final String reason;

  const HeartRateDisconnected(this.reason);

  @override
  List<Object> get props => [reason];
}

class HeartRateError extends HeartRateState {
  final String message;

  const HeartRateError(this.message);

  @override
  List<Object> get props => [message];
}

class HeartRateNoConnection extends HeartRateState {} 