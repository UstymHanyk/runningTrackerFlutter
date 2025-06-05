import 'package:flutter/material.dart';
import 'package:my_project/models/run.dart';
import 'package:my_project/theme/app_colors.dart';
import 'package:my_project/widgets/run_list_item/run_list_item.dart';

class RunHistorySection extends StatelessWidget {
  final List<Run> runs;
  final bool isLoading;
  final Function(String) onDeleteRun;

  const RunHistorySection({
    super.key,
    required this.runs,
    required this.isLoading,
    required this.onDeleteRun,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const Divider(),
          const Text(
            "RUN HISTORY",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : runs.isEmpty
                    ? const Center(
                        child: Text(
                          'No runs saved yet.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: runs.length,
                        itemBuilder: (context, index) {
                          final run = runs[index];
                          return RunListItem(
                            key: ValueKey(run.id),
                            runObject: run,
                            index: index,
                            onDelete: () => onDeleteRun(run.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 