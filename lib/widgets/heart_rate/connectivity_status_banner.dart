import 'package:flutter/material.dart';

class ConnectivityStatusBanner extends StatelessWidget {
  final bool isConnected;

  const ConnectivityStatusBanner({
    super.key,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    if (isConnected) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.red.shade100,
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Text(
            'No internet connection',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 