import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/models/run.dart';
import 'package:my_project/cubits/run_cubit.dart';
import 'package:my_project/widgets/run_list_item/run_title_field.dart';

class RunTrailingActions extends StatelessWidget {
  final RunState state;
  final Run run;
  final SaveEditCallback onSave;
  final VoidCallback onDelete;

  const RunTrailingActions({
    super.key,
    required this.state,
    required this.run,
    required this.onSave,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (state is RunEditing) {
      return SizedBox(
        width: 100,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              tooltip: 'Save',
              onPressed: () => onSave(context, (state as RunEditing).currentName, run),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: 'Cancel',
              onPressed: () => context.read<RunCubit>().cancelEditing(),
            ),
          ],
        ),
      );
    }

    if (state is RunSaving) {
      return const SizedBox(
        width: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      width: 100,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white70),
            tooltip: 'Edit Run',
            onPressed: () => context.read<RunCubit>().startEditing(),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            tooltip: 'Delete Run',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
} 