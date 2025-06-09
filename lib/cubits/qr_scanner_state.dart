part of 'qr_scanner_cubit.dart';

abstract class QRScannerState extends Equatable {
  const QRScannerState();

  @override
  List<Object?> get props => [];
}

class QRScannerInitial extends QRScannerState {}

class QRScannerScanning extends QRScannerState {}

class QRScannerProcessing extends QRScannerState {}

class QRScannerCredentialsFound extends QRScannerState {
  final String username;
  final String password;

  const QRScannerCredentialsFound({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}

class QRScannerError extends QRScannerState {
  final String message;

  const QRScannerError(this.message);

  @override
  List<Object> get props => [message];
}

class QRScannerSuccess extends QRScannerState {
  final String message;

  const QRScannerSuccess(this.message);

  @override
  List<Object> get props => [message];
} 