import 'package:flutter/material.dart';
import 'package:my_project/theme/app_colors.dart';

class CurrentRunDisplay extends StatelessWidget {
  final double currentDistance;
  final int? currentHeartRate;

  const CurrentRunDisplay({
    super.key,
    required this.currentDistance,
    this.currentHeartRate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'CURRENT RUN',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${currentDistance.toStringAsFixed(1)} km',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Display Live Heart Rate if available and run is active
        if (currentDistance > 0 && currentHeartRate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              '$currentHeartRate bpm',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.accent,
              ),
            ),
          ),
      ],
    );
  }
} 