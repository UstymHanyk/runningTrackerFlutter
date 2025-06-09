part of 'run_cubit.dart';

abstract class RunState extends Equatable {
  const RunState();

  @override
  List<Object?> get props => [];
}

class RunInitial extends RunState {}

class RunEditing extends RunState {
  final String currentName;

  const RunEditing(this.currentName);

  @override
  List<Object> get props => [currentName];
}

class RunSaving extends RunState {}

class RunLoaded extends RunState {
  final Run run;

  const RunLoaded(this.run);

  @override
  List<Object> get props => [run];
}

class RunError extends RunState {
  final String message;

  const RunError(this.message);

  @override
  List<Object> get props => [message];
} 