import 'package:flutter/material.dart';
import 'package:my_project/models/run.dart';
import 'package:my_project/cubits/run_cubit.dart';

typedef SaveEditCallback = void Function(BuildContext context, String newName, Run originalRun);

class RunTitleField extends StatefulWidget {
  final RunState state;
  final Run run;
  final SaveEditCallback onSave;

  const RunTitleField({
    super.key,
    required this.state,
    required this.run,
    required this.onSave,
  });

  @override
  State<RunTitleField> createState() => _RunTitleFieldState();
}

class _RunTitleFieldState extends State<RunTitleField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.state is RunEditing 
        ? (widget.state as RunEditing).currentName 
        : widget.run.name;
    _controller = TextEditingController(text: initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state is RunEditing) {
      return TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Run Name',
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        ),
        onSubmitted: (newName) => widget.onSave(context, newName, widget.run),
      );
    }
    
    return Text(
      widget.run.name,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }
} 