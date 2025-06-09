import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/theme/app_colors.dart';
import 'package:my_project/cubits/microcontroller_cubit.dart';
import 'package:my_project/screens/qr_scanner_screen.dart';
import 'package:my_project/widgets/microcontroller/action_buttons.dart';
import 'package:my_project/widgets/microcontroller/serial_input_dialog.dart';
import 'package:my_project/widgets/dialogs/app_dialogs.dart';

class MicrocontrollerScreenWidgets {
  static Widget buildLoadingState() {
    return const Center(
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
    );
  }

  static Widget buildActionButtons(
    BuildContext context, 
    MicrocontrollerLoaded state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FetchDataButton(
          isLoading: false,
          onPressed: () => context.read<MicrocontrollerCubit>()
              .fetchCurrentSerialNumber(),
        ),
        const SizedBox(height: 12),
        ScanQRButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QRScannerScreen(),
            ),
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

  static Widget buildClearDataButton(BuildContext context) {
    return ClearDataButton(
      onPressed: () => AppDialogs.showConfirmation(
        context: context,
        title: 'Clear All Data',
        message: 'This will remove all stored credentials and configuration. '
            'Are you sure?',
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

  static Widget buildRetryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.read<MicrocontrollerCubit>().initialize(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textPrimary,
      ),
      child: const Text('Retry'),
    );
  }

  static Widget buildUnknownState(BuildContext context, String stateType) {
    return Center(
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
            'Unknown state: $stateType',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          buildRetryButton(context),
        ],
      ),
    );
  }

  static void _showSerialInputDialog(
    BuildContext context, 
    MicrocontrollerLoaded state,
  ) {
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