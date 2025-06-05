import 'package:flutter/material.dart';
import 'package:my_project/theme/app_colors.dart';

class ConfigurationStatusCard extends StatelessWidget {
  final bool isConfigured;
  final bool hasStoredCredentials;
  final String? storedUsername;

  const ConfigurationStatusCard({
    super.key,
    required this.isConfigured,
    required this.hasStoredCredentials,
    this.storedUsername,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surfacePrimary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConfigured ? Icons.check_circle : Icons.warning,
                  color: isConfigured ? Colors.green : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Configuration Status',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StatusRow(
              label: 'Credentials',
              value: hasStoredCredentials ? 'Stored' : 'Not configured',
              isValid: hasStoredCredentials,
            ),
            const SizedBox(height: 8),
            StatusRow(
              label: 'Username',
              value: storedUsername ?? 'N/A',
              isValid: storedUsername != null,
            ),
          ],
        ),
      ),
    );
  }
}

class StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isValid;

  const StatusRow({
    super.key,
    required this.label,
    required this.value,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check : Icons.close,
          color: isValid ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
} 