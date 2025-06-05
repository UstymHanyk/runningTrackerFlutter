import 'package:flutter/material.dart';

class HeartRateDisplayCard extends StatelessWidget {
  final double heartRate;

  const HeartRateDisplayCard({
    super.key,
    required this.heartRate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Heart Rate',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  heartRate.toInt().toString(),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: _getHeartRateColor(heartRate),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'BPM',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getHeartRateStatus(heartRate),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _getHeartRateColor(heartRate),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHeartRateColor(double heartRate) {
    if (heartRate == 0) return Colors.grey;
    if (heartRate < 60) return Colors.blue;
    if (heartRate <= 100) return Colors.green;
    if (heartRate <= 150) return Colors.orange;
    return Colors.red;
  }

  String _getHeartRateStatus(double heartRate) {
    if (heartRate == 0) return 'No data';
    if (heartRate < 60) return 'Low';
    if (heartRate <= 100) return 'Normal';
    if (heartRate <= 150) return 'Elevated';
    return 'High';
  }
} 