import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// States
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

// Cubit
class QRScannerCubit extends Cubit<QRScannerState> {
  QRScannerCubit() : super(QRScannerInitial());

  void startScanning() {
    emit(QRScannerScanning());
  }

  void processQRCode(String qrData, Map<String, String>? Function(String) parseCredentials) {
    emit(QRScannerProcessing());
    
    try {
      final credentials = parseCredentials(qrData);
      
      if (credentials != null && credentials.containsKey('username') && credentials.containsKey('password')) {
        emit(QRScannerCredentialsFound(
          username: credentials['username']!,
          password: credentials['password']!,
        ));
      } else {
        emit(const QRScannerError('Invalid QR Code: QR code does not contain valid credentials.'));
      }
    } catch (e) {
      emit(QRScannerError('Failed to process QR code: $e'));
    }
  }

  void showError(String message) {
    emit(QRScannerError(message));
  }

  void showSuccess(String message) {
    emit(QRScannerSuccess(message));
  }

  void reset() {
    emit(QRScannerInitial());
  }
} 