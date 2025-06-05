import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/theme/app_colors.dart';
import 'package:my_project/cubits/microcontroller_cubit.dart';
import 'package:my_project/screens/qr_scanner_screen.dart';
import 'package:my_project/widgets/microcontroller/configuration_status_card.dart';
import 'package:my_project/widgets/microcontroller/serial_number_card.dart';
import 'package:my_project/widgets/microcontroller/error_card.dart';
import 'package:my_project/widgets/microcontroller/action_buttons.dart';
import 'package:my_project/widgets/microcontroller/serial_input_dialog.dart';
import 'package:my_project/widgets/dialogs/app_dialogs.dart';

class MicrocontrollerScreen extends StatelessWidget {
  const MicrocontrollerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Capture cubit reference to avoid BuildContext async gap warnings
    final cubit = context.read<MicrocontrollerCubit>();
    
    // Ensure initialization happens immediately - try multiple approaches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('Post-frame callback - Current state: ${cubit.state.runtimeType}');
      if (cubit.state is MicrocontrollerInitial) {
        debugPrint('Force initializing from build method');
        cubit.initialize();
      }
    });

    // Also try immediate initialization as a fallback
    Future.microtask(() {
      try {
        if (cubit.state is MicrocontrollerInitial) {
          debugPrint('Microtask initialization triggered');
          cubit.initialize();
        }
      } catch (e) {
        debugPrint('Microtask initialization error: $e');
      }
    });
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Device Configuration',
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
      body: BlocConsumer<MicrocontrollerCubit, MicrocontrollerState>(
        listener: (context, state) {
          // Initialize when first loaded
          if (state is MicrocontrollerInitial) {
            debugPrint('Triggering initialization from MicrocontrollerInitial state');
            // Capture cubit reference to avoid BuildContext async gap warning
            final cubit = context.read<MicrocontrollerCubit>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              cubit.initialize();
            });
          }
        },
        builder: (context, state) {
          // Debug: debugPrint current state
          debugPrint('MicrocontrollerScreen state: ${state.runtimeType}');
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state is MicrocontrollerLoaded) ...[
                  ConfigurationStatusCard(
                    isConfigured: state.isConfigured,
                    hasStoredCredentials: state.hasStoredCredentials,
                    storedUsername: state.storedUsername,
                  ),
                  const SizedBox(height: 16),
                  SerialNumberCard(currentSerialNumber: state.currentSerialNumber),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, state),
                  const Spacer(),
                  if (state.hasStoredCredentials) _buildClearDataButton(context),
                ] else if (state is MicrocontrollerLoading || state is MicrocontrollerInitial) ...[
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading device configuration...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (state is MicrocontrollerError) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ErrorCard(error: state.message),
                      const SizedBox(height: 16),
                      _buildRetryButton(context),
                    ],
                  ),
                ] else ...[
                  // Fallback for any unhandled states
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Unknown state: ${state.runtimeType}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRetryButton(context),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, MicrocontrollerLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FetchDataButton(
          isLoading: false, // Loading state is handled at the cubit level
          onPressed: () => context.read<MicrocontrollerCubit>().fetchCurrentSerialNumber(),
        ),
        const SizedBox(height: 12),
        ScanQRButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QRScannerScreen()),
          ),
        ),
        const SizedBox(height: 12),
        UpdateSerialButton(
          hasStoredCredentials: state.hasStoredCredentials,
          onPressed: () => _showSerialInputDialog(context, state),
        ),
      ],
    );
  }

  Widget _buildClearDataButton(BuildContext context) {
    return ClearDataButton(
      onPressed: () => AppDialogs.showConfirmation(
        context: context,
        title: 'Clear All Data',
        message: 'This will remove all stored credentials and configuration. Are you sure?',
        onConfirm: () {
          context.read<MicrocontrollerCubit>().clearStoredData();
          AppDialogs.showSuccess(
            context: context,
            title: 'Cleared',
            message: 'All data has been cleared.',
          );
        },
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.read<MicrocontrollerCubit>().initialize(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textPrimary,
      ),
      child: const Text('Retry'),
    );
  }

  void _showSerialInputDialog(BuildContext context, MicrocontrollerLoaded state) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider.value(
          value: context.read<MicrocontrollerCubit>(),
          child: SerialInputDialog(
            initialSerial: state.currentSerialNumber,
            hasStoredCredentials: state.hasStoredCredentials,
          ),
        );
      },
    );
  }
} 