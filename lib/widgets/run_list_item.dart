import 'package:flutter/material.dart';
import 'package:my_project/models/run.dart';
import 'package:my_project/services/interfaces/run_provider_interface.dart';
import 'package:provider/provider.dart';

class RunListItem extends StatefulWidget {
  final Run runObject;
  final int index;
  final VoidCallback onDelete;

  const RunListItem({
    super.key,
    required this.runObject,
    required this.index,
    required this.onDelete,
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
    _nameController = TextEditingController(text: widget.runObject.name);
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
      _nameController.text = widget.runObject.name;
      _isEditing = false;
    });
  }

  void _saveEdit() {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      _nameController.text = widget.runObject.name;
      setState(() {
        _isEditing = false;
      });
      return;
    }

    final runProvider = Provider.of<RunProviderInterface>(context, listen: false);
    final updatedRun = widget.runObject.copyWith(name: newName);
    
    runProvider.updateRun(updatedRun).then((success) {
      if (!mounted) return;

      if (success) {
        setState(() {
          _isEditing = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update run name')),
        );
        _nameController.text = widget.runObject.name;
        setState(() {
            _isEditing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String heartRateSummary = 'No HR data';
    if (widget.runObject.heartRateData.isNotEmpty) {
      double avgHr = widget.runObject.heartRateData.reduce((a, b) => a + b) / widget.runObject.heartRateData.length;
      heartRateSummary = 'Avg HR: ${avgHr.toStringAsFixed(0)} bpm';
    }

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
                  widget.runObject.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.runObject.distance.toStringAsFixed(1)} km',
                ),
                if (widget.runObject.heartRateData.isNotEmpty)
                  Text(
                    heartRateSummary,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha((255 * 0.8).round())),
                  ),
              ],
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