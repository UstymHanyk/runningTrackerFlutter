import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/models/run.dart';
import 'package:my_project/services/interfaces/run_provider_interface.dart';
import 'package:my_project/cubits/run_cubit.dart';
import 'package:my_project/widgets/run_list_item/run_title_field.dart';
import 'package:my_project/widgets/run_list_item/run_trailing_actions.dart';
import 'package:provider/provider.dart';

class RunListItemContent extends StatelessWidget {
  final int index;
  final VoidCallback onDelete;

  const RunListItemContent({
    super.key,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RunCubit, RunState>(
      listener: (context, state) {
        if (state is RunError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final run = _getCurrentRun(state);
        final heartRateSummary = _getHeartRateSummary(run);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(100),
              child: Text(
                "${index + 1}",
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            title: RunTitleField(state: state, run: run, onSave: _saveEdit),
            subtitle: _buildSubtitle(run, heartRateSummary),
            trailing: RunTrailingActions(
              state: state,
              run: run,
              onSave: _saveEdit,
              onDelete: onDelete,
            ),
          ),
        );
      },
    );
  }

  Run _getCurrentRun(RunState state) {
    if (state is RunLoaded) return state.run;
    return Run(
      id: '',
      name: '',
      distance: 0.0,
      date: DateTime.now(),
      heartRateData: const [],
    );
  }

  String _getHeartRateSummary(Run run) {
    if (run.heartRateData.isEmpty) return 'No HR data';
    final avgHr = run.heartRateData.reduce((a, b) => a + b) / run.heartRateData.length;
    return 'Avg HR: ${avgHr.toStringAsFixed(0)} bpm';
  }

  Widget _buildSubtitle(Run run, String heartRateSummary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${run.distance.toStringAsFixed(1)} km'),
        if (run.heartRateData.isNotEmpty)
          Text(
            heartRateSummary,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
      ],
    );
  }

  void _saveEdit(BuildContext context, String newName, Run originalRun) {
    final runProvider = Provider.of<RunProviderInterface>(context, listen: false);
    
    context.read<RunCubit>().saveEdit(
      newName,
      originalRun,
      (updatedRun) => runProvider.updateRun(updatedRun),
    );
  }
} 