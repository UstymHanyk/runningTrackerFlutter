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
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Limited functionality - No internet connection',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 