import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubits/main_screen_cubit.dart';
import 'package:my_project/theme/app_colors.dart';

class RunInputSection extends StatefulWidget {
  final double currentDistance;
  final bool isLoading;
  final String? error;

  const RunInputSection({
    super.key,
    required this.currentDistance,
    required this.isLoading,
    this.error,
  });

  @override
  State<RunInputSection> createState() => _RunInputSectionState();
}

class _RunInputSectionState extends State<RunInputSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainScreenCubit, MainScreenState>(
      listener: (context, state) {
        if (state is MainScreenLoaded) {
          _controller.text = state.runName;
        } else if (state is MainScreenRunSaved) {
          _controller.clear();
          FocusScope.of(context).unfocus();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Column(
        children: [
          TextField(
            controller: _controller,
            onChanged: (value) {
              context.read<MainScreenCubit>().updateRunName(value);
            },
            decoration: const InputDecoration(
              labelText: "Enter run name (optional)",
              hintText: 'e.g., Morning Jog',
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: widget.currentDistance <= 0 || widget.isLoading
                ? null
                : () => context.read<MainScreenCubit>().saveRun(),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.currentDistance > 0 
                  ? AppColors.accent 
                  : AppColors.surfaceSecondary,
              foregroundColor: AppColors.textPrimary,
            ),
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Save Current Run"),
          ),
          if (widget.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                widget.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
} 