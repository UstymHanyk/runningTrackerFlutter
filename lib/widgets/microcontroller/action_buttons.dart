import 'package:flutter/material.dart';
import 'package:my_project/theme/app_colors.dart';

class FetchDataButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const FetchDataButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
      label: Text(isLoading ? 'Fetching...' : 'Fetch Device Data'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

class ScanQRButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ScanQRButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.qr_code_scanner),
      label: const Text('Scan QR for Credentials'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surfaceSecondary,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

class UpdateSerialButton extends StatelessWidget {
  final bool hasStoredCredentials;
  final VoidCallback onPressed;

  const UpdateSerialButton({
    super.key,
    required this.hasStoredCredentials,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: hasStoredCredentials ? onPressed : null,
      icon: const Icon(Icons.edit),
      label: const Text('Update Serial Number'),
      style: ElevatedButton.styleFrom(
        backgroundColor: hasStoredCredentials 
            ? AppColors.surfaceSecondary 
            : AppColors.surfaceSecondary.withAlpha((0.5 * 255).round()),
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

class ClearDataButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ClearDataButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.delete_forever, color: Colors.red),
      label: const Text(
        'Clear All Data',
        style: TextStyle(color: Colors.red),
      ),
    );
  }
} 