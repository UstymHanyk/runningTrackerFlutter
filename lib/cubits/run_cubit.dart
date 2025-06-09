import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_project/models/run.dart';

part 'run_state.dart';

class RunCubit extends Cubit<RunState> {
  final Run _originalRun;
  
  RunCubit(Run initialRun) : _originalRun = initialRun, super(RunLoaded(initialRun));

  void startEditing() {
    if (state is RunLoaded) {
      final currentRun = (state as RunLoaded).run;
      emit(RunEditing(currentRun.name));
    }
  }

  void cancelEditing() {
    if (state is RunEditing) {
      // Return to the loaded state with the current run
      emit(RunLoaded(_getCurrentRun()));
    }
  }

  Run _getCurrentRun() {
    if (state is RunLoaded) {
      return (state as RunLoaded).run;
    }
    return _originalRun;
  }

  Future<void> saveEdit(String newName, Run originalRun, Future<bool> Function(Run) updateFunction) async {
    if (newName.trim().isEmpty) {
      emit(RunLoaded(originalRun));
      return;
    }

    emit(RunSaving());
    
    try {
      final updatedRun = originalRun.copyWith(name: newName.trim());
      final success = await updateFunction(updatedRun);
      
      if (success) {
        emit(RunLoaded(updatedRun));
      } else {
        emit(const RunError('Failed to update run name'));
        // Return to original state after error
        Future.delayed(const Duration(seconds: 2), () {
          emit(RunLoaded(originalRun));
        });
      }
    } catch (e) {
      emit(RunError('Failed to update run: $e'));
      // Return to original state after error
      Future.delayed(const Duration(seconds: 2), () {
        emit(RunLoaded(originalRun));
      });
    }
  }

  void updateRun(Run newRun) {
    emit(RunLoaded(newRun));
  }
} 