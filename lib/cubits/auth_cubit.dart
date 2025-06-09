import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_project/services/interfaces/auth_provider_interface.dart';
import 'package:flutter/foundation.dart';

part 'auth_state.dart';

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
        final errorMessage = _authProvider.error ?? 'Login failed';
        debugPrint('Login failed: $errorMessage');
        emit(AuthError(errorMessage));
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
        final errorMessage = _authProvider.error ?? 'Registration failed';
        emit(AuthError(errorMessage));
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