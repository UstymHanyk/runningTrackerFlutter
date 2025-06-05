import 'package:flutter/material.dart';

class ConnectionStatusCard extends StatelessWidget {
  final bool isConnected;
  final String connectionStatus;
  final String deviceStatus;

  const ConnectionStatusCard({
    super.key,
    required this.isConnected,
    required this.connectionStatus,
    required this.deviceStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isConnected ? Icons.check_circle : Icons.error,
                  color: isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(connectionStatus),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Device Status: $deviceStatus',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
} 