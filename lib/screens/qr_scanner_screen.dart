import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_project/theme/app_colors.dart';
import 'package:my_project/cubits/qr_scanner_cubit.dart';
import 'package:my_project/cubits/microcontroller_cubit.dart';
import 'package:my_project/widgets/qr_scanner/scanner_overlay.dart';
import 'package:my_project/widgets/qr_scanner/serial_config_dialog.dart';
import 'package:my_project/widgets/dialogs/app_dialogs.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraController = MobileScannerController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surfacePrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<QRScannerCubit, QRScannerState>(
            listener: (context, state) {
              if (state is QRScannerCredentialsFound) {
                _showSerialConfigDialog(context, state.username, state.password);
              } else if (state is QRScannerError) {
                AppDialogs.showError(
                  context: context,
                  title: 'Error',
                  message: state.message,
                  onOk: () => context.read<QRScannerCubit>().reset(),
                );
              } else if (state is QRScannerSuccess) {
                AppDialogs.showSuccess(
                  context: context,
                  title: 'Success!',
                  message: state.message,
                  onOk: () => Navigator.of(context).pop(),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<QRScannerCubit, QRScannerState>(
          builder: (context, state) {
            return Stack(
              children: [
                // Camera view
                MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) => _onQRCodeDetected(context, capture, cameraController),
                ),
                
                // Overlay with scanning guide
                const ScannerOverlay(),
                
                // Instructions at the bottom
                const ScannerInstructions(),
                
                // Processing indicator
                if (state is QRScannerProcessing)
                  const ProcessingIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }

  void _onQRCodeDetected(BuildContext context, BarcodeCapture capture, MobileScannerController controller) {
    final cubit = context.read<QRScannerCubit>();
    
    // Prevent multiple processing
    if (cubit.state is QRScannerProcessing) return;
    
    final barcode = capture.barcodes.first;
    final rawValue = barcode.rawValue;
    
    if (rawValue == null || rawValue.isEmpty) return;
    
    // Get the microcontroller service's parse function
    final microcontrollerCubit = context.read<MicrocontrollerCubit>();
    
    cubit.processQRCode(rawValue, microcontrollerCubit.parseQRCredentials);
  }

  void _showSerialConfigDialog(BuildContext context, String username, String password) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<MicrocontrollerCubit>()),
            BlocProvider.value(value: context.read<QRScannerCubit>()),
          ],
          child: SerialConfigDialog(
            username: username,
            password: password,
          ),
        );
      },
    );
  }
} 