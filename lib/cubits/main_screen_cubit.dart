import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_project/services/interfaces/auth_provider_interface.dart';
import 'package:my_project/services/interfaces/run_provider_interface.dart';

part 'main_screen_state.dart';

class MainScreenCubit extends Cubit<MainScreenState> {
  final AuthProviderInterface _authProvider;
  final RunProviderInterface _runProvider;

  MainScreenCubit(this._authProvider, this._runProvider) : super(MainScreenInitial());

  void initialize() {
    emit(const MainScreenLoaded(runName: ''));
    _updateRunsForCurrentUser();
  }

  void _updateRunsForCurrentUser() {
    final userEmail = _authProvider.currentUser?.email;
    if (userEmail != null) {
      _runProvider.checkUserAndReload(userEmail);
    }
  }

  void updateRunName(String runName) {
    if (state is MainScreenLoaded) {
      final currentState = state as MainScreenLoaded;
      emit(currentState.copyWith(runName: runName));
    }
  }

  void clearRunName() {
    if (state is MainScreenLoaded) {
      final currentState = state as MainScreenLoaded;
      emit(currentState.copyWith(runName: ''));
    }
  }

  Future<void> saveRun() async {
    if (state is! MainScreenLoaded) return;
    
    final currentState = state as MainScreenLoaded;
    
    if (_runProvider.currentDistance <= 0) {
      emit(const MainScreenError('No distance recorded'));
      return;
    }

    emit(MainScreenSavingRun());
    
    try {
      _runProvider.saveRun(currentState.runName.trim());
      emit(const MainScreenRunSaved('Run saved successfully'));
      
      // Return to loaded state with cleared run name
      Future.delayed(const Duration(seconds: 1), () {
        emit(const MainScreenLoaded(runName: ''));
      });
    } catch (e) {
      emit(MainScreenError('Failed to save run: $e'));
    }
  }

  Future<void> logout() async {
    emit(MainScreenLoggingOut());
    
    try {
      await _authProvider.logout().timeout(
        const Duration(seconds: 5),
      );
      emit(MainScreenLogoutSuccess());
    } catch (e) {
      emit(MainScreenError('Logout error: $e'));
      // Still emit success after brief delay to allow navigation
      Future.delayed(const Duration(seconds: 1), () {
        emit(MainScreenLogoutSuccess());
      });
    }
  }

  void clearError() {
    if (state is MainScreenError) {
      emit(const MainScreenLoaded(runName: ''));
    }
  }
} 