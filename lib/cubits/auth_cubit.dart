import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_project/services/interfaces/auth_provider_interface.dart';
import 'package:flutter/foundation.dart';

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;

  const AuthSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class AuthAutoLoginCheck extends AuthState {}

// Cubit
class AuthCubit extends Cubit<AuthState> {
  final AuthProviderInterface _authProvider;

  AuthCubit(this._authProvider) : super(AuthInitial());

  Future<void> checkAutoLogin() async {
    emit(AuthAutoLoginCheck());
    try {
      if (_authProvider.isLoggedIn) {
        emit(const AuthSuccess('Already logged in'));
        return;
      }

      final success = await _authProvider.loginWithStoredCredentials();
      if (success && _authProvider.isLoggedIn) {
        emit(const AuthSuccess('Auto-login successful'));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      debugPrint('Auto-login failed: $e');
      emit(AuthInitial());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      debugPrint('Attempting login with email: $email');
      
      final success = await _authProvider.login(email, password);
      
      debugPrint('Login result: $success');
      
      if (success) {
        debugPrint('Login successful');
        emit(const AuthSuccess('Login successful'));
      } else {
        debugPrint('Login failed: ${_authProvider.error}');
        emit(AuthError(_authProvider.error ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthError('Login error: $e'));
    }
  }

  Future<void> register(String email, String password, String name) async {
    emit(AuthLoading());
    try {
      final success = await _authProvider.register(email, password, name);
      
      if (success) {
        emit(const AuthSuccess('Registration successful'));
      } else {
        emit(AuthError(_authProvider.error ?? 'Registration failed'));
      }
    } catch (e) {
      emit(AuthError('Registration error: $e'));
    }
  }

  void clearError() {
    if (state is AuthError) {
      emit(AuthInitial());
    }
  }
} 