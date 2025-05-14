import 'package:flutter/material.dart';
import 'package:my_project/models/run.dart';
import 'package:my_project/services/run_provider.dart';
import 'package:provider/provider.dart';

class RunListItem extends StatefulWidget {
  final Map<String, dynamic> runData;
  final int index;
  final VoidCallback onDelete;
  final String runId;

  const RunListItem({
    super.key,
    required this.runData,
    required this.index,
    required this.onDelete,
    required this.runId,
  });

  @override
  State<RunListItem> createState() => _RunListItemState();
}

class _RunListItemState extends State<RunListItem> {
  bool _isEditing = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final String runName = widget.runData['name']?.isNotEmpty ?? false 
        ? widget.runData['name'] 
        : 'Unnamed Run';
    _nameController = TextEditingController(text: runName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      final String runName = widget.runData['name']?.isNotEmpty ?? false 
          ? widget.runData['name'] 
          : 'Unnamed Run';
      _nameController.text = runName;
      _isEditing = false;
    });
  }

  void _saveEdit() {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      _nameController.text = 'Unnamed Run';
      return;
    }

    setState(() {
      _isEditing = false;
    });

    final runProvider = Provider.of<RunProvider>(context, listen: false);
    final runToUpdate = runProvider.runs.firstWhere(
      (run) => run.id == widget.runId,
      orElse: () => Run(
        id: widget.runId,
        name: _nameController.text,
        distance: widget.runData['distance'] ?? 0.0,
        date: DateTime.now(),
      ),
    );
    
    final updatedRun = runToUpdate.copyWith(name: newName);
    runProvider.updateRun(updatedRun);
  }

  @override
  Widget build(BuildContext context) {
    final double runDistance = widget.runData['distance'] ?? 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100),
              child: Text(
                "${widget.index + 1}", 
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)
              ),
            ),
            title: _isEditing 
              ? TextField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Run Name',
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  ),
                  onSubmitted: (_) => _saveEdit(),
                )
              : Text(
                  _nameController.text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
            subtitle: Text(
              '${runDistance.toStringAsFixed(1)} km',
            ),
            trailing: _isEditing
              ? SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        tooltip: 'Save',
                        onPressed: _saveEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        tooltip: 'Cancel',
                        onPressed: _cancelEditing,
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  width: 100,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        tooltip: 'Edit Run',
                        onPressed: _startEditing,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                        tooltip: 'Delete Run',
                        onPressed: widget.onDelete,
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }
} 