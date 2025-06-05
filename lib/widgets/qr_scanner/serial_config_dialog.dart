import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/theme/app_colors.dart';
import 'package:my_project/cubits/microcontroller_cubit.dart';
import 'package:my_project/widgets/dialogs/app_dialogs.dart';

class SerialConfigDialog extends StatefulWidget {
  final String username;
  final String password;

  const SerialConfigDialog({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<SerialConfigDialog> createState() => _SerialConfigDialogState();
}

class _SerialConfigDialogState extends State<SerialConfigDialog> {
  late final TextEditingController _serialController;

  @override
  void initState() {
    super.initState();
    _serialController = TextEditingController();
  }

  @override
  void dispose() {
    _serialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfacePrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Configure Device',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Credentials scanned successfully!',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Username: ${widget.username}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter Serial Number:',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _serialController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter device serial number',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.surfaceSecondary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.accent),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        BlocConsumer<MicrocontrollerCubit, MicrocontrollerState>(
          listener: (context, state) {
            if (state is MicrocontrollerLoaded) {
              Navigator.of(context).pop(); // Close config dialog
              AppDialogs.showSuccess(
                context: context,
                title: 'Success!',
                message: 'Device configured successfully.\nSerial number: ${_serialController.text.trim()}',
                onOk: () => Navigator.of(context).pop(), // Go back to previous screen
              );
            } else if (state is MicrocontrollerError) {
              Navigator.of(context).pop(); // Close config dialog
              AppDialogs.showError(
                context: context,
                title: 'Error',
                message: state.message,
              );
            }
          },
          builder: (context, state) {
            return ElevatedButton(
              onPressed: state is MicrocontrollerLoading
                  ? null
                  : () async {
                      final serialNumber = _serialController.text.trim();
                      if (serialNumber.isEmpty) {
                        AppDialogs.showError(
                          context: context,
                          title: 'Error',
                          message: 'Serial number cannot be empty.',
                        );
                        return;
                      }

                      // Capture cubit reference before async operations
                      final cubit = context.read<MicrocontrollerCubit>();
                      
                      // First save credentials, then update serial number
                      await cubit.saveCredentials(widget.username, widget.password);
                      
                      // If credentials were saved successfully, update serial number
                      if (cubit.state is! MicrocontrollerError) {
                        await cubit.updateSerialNumber(serialNumber);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
              ),
              child: state is MicrocontrollerLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            );
          },
        ),
      ],
    );
  }
} 