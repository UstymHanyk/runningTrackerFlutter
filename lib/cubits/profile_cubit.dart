import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_project/services/interfaces/auth_provider_interface.dart';
import 'package:my_project/services/interfaces/run_provider_interface.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthProviderInterface _authProvider;
  final RunProviderInterface _runProvider;

  ProfileCubit(this._authProvider, this._runProvider) : super(ProfileInitial());

  void initialize() {
    final currentUser = _authProvider.currentUser;
    if (currentUser == null) {
      emit(const ProfileError('Not logged in'));
      return;
    }

    // Update run provider for current user
    _runProvider.checkUserAndReload(currentUser.email);

    emit(ProfileLoaded(
      isEditing: false,
      name: currentUser.name,
      email: currentUser.email,
    ));
  }

  void startEditing() {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(isEditing: true));
    }
  }

  void cancelEditing() {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(currentState.copyWith(isEditing: false));
    }
  }

  Future<void> updateProfile(String newName) async {
    emit(ProfileUpdating());
    try {
      final success = await _authProvider.updateUserProfile(newName);
      
      if (success) {
        final currentUser = _authProvider.currentUser;
        if (currentUser != null) {
          emit(ProfileLoaded(
            isEditing: false,
            name: currentUser.name,
            email: currentUser.email,
          ));
          emit(const ProfileUpdateSuccess('Profile updated successfully'));
          
          // After showing success, return to loaded state
          Future.delayed(const Duration(seconds: 2), () {
            final user = _authProvider.currentUser;
            if (user != null) {
              emit(ProfileLoaded(
                isEditing: false,
                name: user.name,
                email: user.email,
              ));
            }
          });
        } else {
          emit(const ProfileError('User session lost'));
        }
      } else {
        final errorMessage = _authProvider.error ?? 'Failed to update profile';
        emit(ProfileError(errorMessage));
      }
    } catch (e) {
      emit(ProfileError('Update error: $e'));
    }
  }

  Future<void> logout() async {
    try {
      await _authProvider.logout();
      emit(ProfileInitial());
    } catch (e) {
      emit(ProfileError('Logout error: $e'));
    }
  }
} 