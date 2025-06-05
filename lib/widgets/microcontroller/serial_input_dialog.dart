import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/theme/app_colors.dart';
import 'package:my_project/cubits/microcontroller_cubit.dart';
import 'package:my_project/widgets/dialogs/app_dialogs.dart';

class SerialInputDialog extends StatefulWidget {
  final String? initialSerial;
  final bool hasStoredCredentials;

  const SerialInputDialog({
    super.key,
    this.initialSerial,
    required this.hasStoredCredentials,
  });

  @override
  State<SerialInputDialog> createState() => _SerialInputDialogState();
}

class _SerialInputDialogState extends State<SerialInputDialog> {
  late final TextEditingController _serialController;

  @override
  void initState() {
    super.initState();
    _serialController = TextEditingController(text: widget.initialSerial ?? '');
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
        'Update Serial Number',
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
          if (!widget.hasStoredCredentials) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No credentials stored. Please scan QR code first.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Text(
            'Enter new serial number:',
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
              Navigator.of(context).pop();
              AppDialogs.showSuccess(
                context: context,
                title: 'Success!',
                message: 'Serial number updated successfully.\nNew serial: ${_serialController.text.trim()}',
              );
            } else if (state is MicrocontrollerError) {
              Navigator.of(context).pop();
              AppDialogs.showError(
                context: context,
                title: 'Error',
                message: state.message,
              );
            }
          },
          builder: (context, state) {
            return ElevatedButton(
              onPressed: (!widget.hasStoredCredentials || state is MicrocontrollerLoading)
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

                      context.read<MicrocontrollerCubit>().updateSerialNumber(serialNumber);
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
                  : const Text('Update'),
            );
          },
        ),
      ],
    );
  }
} 