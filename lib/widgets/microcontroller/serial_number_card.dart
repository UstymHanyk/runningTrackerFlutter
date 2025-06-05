import 'package:flutter/material.dart';
import 'package:my_project/theme/app_colors.dart';

class SerialNumberCard extends StatelessWidget {
  final String? currentSerialNumber;

  const SerialNumberCard({
    super.key,
    this.currentSerialNumber,
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
            const Text(
              'Current Serial Number',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.accent.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withAlpha((0.3 * 255).round())),
              ),
              child: Text(
                currentSerialNumber ?? 'Not fetched',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 