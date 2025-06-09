import 'package:flutter/material.dart';

class ConnectivityBanner extends StatelessWidget {
  final bool isConnected;

  const ConnectivityBanner({
    super.key,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    if (isConnected) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No internet connection detected',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 