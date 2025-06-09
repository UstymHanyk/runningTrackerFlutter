import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'qr_scanner_state.dart';

class QRScannerCubit extends Cubit<QRScannerState> {
  QRScannerCubit() : super(QRScannerInitial());

  void startScanning() {
    emit(QRScannerScanning());
  }

  void processQRCode(
    String qrData, 
    Map<String, String>? Function(String) parseCredentials,
  ) {
    emit(QRScannerProcessing());
    
    try {
      final credentials = parseCredentials(qrData);
      
      if (credentials != null && 
          credentials.containsKey('username') && 
          credentials.containsKey('password')) {
        final username = credentials['username'];
        final password = credentials['password'];
        
        if (username != null && password != null) {
          emit(QRScannerCredentialsFound(
            username: username,
            password: password,
          ));
        } else {
          emit(const QRScannerError(
            'Invalid QR Code: Missing username or password.',
          ));
        }
      } else {
        emit(const QRScannerError(
          'Invalid QR Code: QR code does not contain valid credentials.',
        ));
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