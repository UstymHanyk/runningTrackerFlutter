import 'package:flutter/material.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/repositories/interfaces/user_repository_interface.dart';
import 'package:my_project/repositories/user_repository.dart';
import 'package:my_project/services/interfaces/auth_provider_interface.dart';

class AuthProvider extends ChangeNotifier implements AuthProviderInterface {
  final UserRepositoryInterface _userRepository = UserRepository();
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  @override
  User? get currentUser => _currentUser;
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get error => _error;
  
  @override
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final isLoggedIn = await _userRepository.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _userRepository.getCurrentUser();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      if (!_isValidEmail(email)) {
        _error = 'Please enter a valid email address';
        return false;
      }
      
      if (!_isValidName(name)) {
        _error = 'Name should not contain numbers or special characters';
        return false;
      }
      
      if (password.length < 6) {
        _error = 'Password must be at least 6 characters long';
        return false;
      }
      
      final user = User(
        email: email,
        password: password,
        name: name,
      );
      
      final result = await _userRepository.registerUser(user);
      
      if (result) {
        _currentUser = user;
        await _userRepository.login(email, password);
      } else {
        _error = 'User with this email already exists';
      }
      
      return result;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _userRepository.login(email, password);
      
      if (result) {
        _currentUser = await _userRepository.getCurrentUser();
      } else {
        _error = 'Invalid email or password';
      }
      
      return result;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _userRepository.logout();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<bool> updateUserProfile(String name) async {
    if (_currentUser == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Validate name
      if (!_isValidName(name)) {
        _error = 'Name should not contain numbers or special characters';
        return false;
      }
      
      final updatedUser = _currentUser!.copyWith(name: name);
      final result = await _userRepository.saveUser(updatedUser);
      
      if (result) {
        _currentUser = updatedUser;
      } else {
        _error = 'Failed to update profile';
      }
      
      return result;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegex.hasMatch(email);
  }
  
  bool _isValidName(String name) {
    final RegExp nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    return nameRegex.hasMatch(name);
  }
} 