import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_project/services/interfaces/auth_provider_interface.dart';
import 'package:my_project/services/interfaces/run_provider_interface.dart';

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final bool isEditing;
  final String name;
  final String email;

  const ProfileLoaded({
    required this.isEditing,
    required this.name,
    required this.email,
  });

  @override
  List<Object> get props => [isEditing, name, email];

  ProfileLoaded copyWith({
    bool? isEditing,
    String? name,
    String? email,
  }) {
    return ProfileLoaded(
      isEditing: isEditing ?? this.isEditing,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final String message;

  const ProfileUpdateSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit
class ProfileCubit extends Cubit<ProfileState> {
  final AuthProviderInterface _authProvider;
  final RunProviderInterface _runProvider;

  ProfileCubit(this._authProvider, this._runProvider) : super(ProfileInitial());

  void initialize() {
    if (_authProvider.currentUser == null) {
      emit(const ProfileError('Not logged in'));
      return;
    }

    // Update run provider for current user
    _runProvider.checkUserAndReload(_authProvider.currentUser?.email);

    emit(ProfileLoaded(
      isEditing: false,
      name: _authProvider.currentUser!.name,
      email: _authProvider.currentUser!.email,
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
        emit(ProfileLoaded(
          isEditing: false,
          name: _authProvider.currentUser!.name,
          email: _authProvider.currentUser!.email,
        ));
        emit(const ProfileUpdateSuccess('Profile updated successfully'));
        
        // After showing success, return to loaded state
        Future.delayed(const Duration(seconds: 2), () {
          if (_authProvider.currentUser != null) {
            emit(ProfileLoaded(
              isEditing: false,
              name: _authProvider.currentUser!.name,
              email: _authProvider.currentUser!.email,
            ));
          }
        });
      } else {
        emit(ProfileError(_authProvider.error ?? 'Failed to update profile'));
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