part of 'main_screen_cubit.dart';

abstract class MainScreenState extends Equatable {
  const MainScreenState();

  @override
  List<Object?> get props => [];
}

class MainScreenInitial extends MainScreenState {}

class MainScreenLoaded extends MainScreenState {
  final String runName;

  const MainScreenLoaded({required this.runName});

  @override
  List<Object> get props => [runName];

  MainScreenLoaded copyWith({String? runName}) {
    return MainScreenLoaded(
      runName: runName ?? this.runName,
    );
  }
}

class MainScreenSavingRun extends MainScreenState {}

class MainScreenRunSaved extends MainScreenState {
  final String message;

  const MainScreenRunSaved(this.message);

  @override
  List<Object> get props => [message];
}

class MainScreenLoggingOut extends MainScreenState {}

class MainScreenLogoutSuccess extends MainScreenState {}

class MainScreenError extends MainScreenState {
  final String message;

  const MainScreenError(this.message);

  @override
  List<Object> get props => [message];
} 