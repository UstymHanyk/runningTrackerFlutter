import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubits/heart_rate_cubit.dart';

class ActionButtons extends StatelessWidget {
  final bool isConnected;
  final bool hasConnectivity;

  const ActionButtons({
    super.key,
    required this.isConnected,
    required this.hasConnectivity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: hasConnectivity && !isConnected
                ? () => context.read<HeartRateCubit>().connect()
                : null,
            icon: const Icon(Icons.refresh),
            label: const Text('Reconnect'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isConnected
                ? () => context.read<HeartRateCubit>().disconnect()
                : null,
            icon: const Icon(Icons.stop),
            label: const Text('Disconnect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
} 