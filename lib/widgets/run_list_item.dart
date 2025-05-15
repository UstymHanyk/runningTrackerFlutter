import 'package:flutter/material.dart';

class RunListItem extends StatelessWidget {
  final Map<String, dynamic> runData;
  final int index;
  final VoidCallback onDelete;

  const RunListItem({
    super.key,
    required this.runData,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String runName = runData['name']?.isNotEmpty ?? false ? runData['name'] : 'Unnamed Run';
    final double runDistance = runData['distance'] ?? 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100),
            child: Text("${index + 1}", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        ),
        title: Text(
          runName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${runDistance.toStringAsFixed(1)} km',
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
          tooltip: 'Delete Run',
          onPressed: onDelete,
        ),
      ),
    );
  }
} 