import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/models/run.dart';
import 'package:my_project/cubits/run_cubit.dart';
import 'package:my_project/widgets/run_list_item/run_list_item_content.dart';

class RunListItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RunCubit(runObject),
      child: RunListItemContent(
        index: index,
        onDelete: onDelete,
      ),
    );
  }
} 