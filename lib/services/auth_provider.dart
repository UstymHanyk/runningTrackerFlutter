import 'package:flutter/material.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/repositories/interfaces/user_repository_interface.dart';
import 'package:my_project/repositories/user_repository.dart';
import 'package:my_project/services/interfaces/auth_provider_interface.dart';
import 'package:my_project/services/secure_storage_service.dart';
import 'package:my_project/services/connectivity_service.dart';

class AuthProvider extends ChangeNotifier implements AuthProviderInterface {
  final UserRepositoryInterface _userRepository = UserRepository();
  final SecureStorageService _secureStorage = SecureStorageService();
  final ConnectivityService? _connectivityService;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _hasNetworkConnection = true;

  @override
  User? get currentUser => _currentUser;
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get error => _error;
  
  @override
  bool get isLoggedIn => _currentUser != null;
  
  bool get hasNetworkConnection => _hasNetworkConnection;

  AuthProvider({ConnectivityService? connectivityService}) 
      : _connectivityService = connectivityService {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Check connectivity
      _hasNetworkConnection = _connectivityService?.isConnected ?? true;
      
      // Try to load user from secure storage first
      final storedCredentials = await _secureStorage.getUserCredentials();
      final isStoredLoggedIn = await _secureStorage.isUserLoggedIn();
      
      if (isStoredLoggedIn && storedCredentials['email'] != null) {
        _currentUser = User(
          email: storedCredentials['email']!,
          password: storedCredentials['password']!,
          name: storedCredentials['name']!,
        );
        
        // If no network, allow offline access but show warning
        if (!_hasNetworkConnection) {
          _error = 'No internet connection - Limited functionality';
        }
      } else {
        // Fallback to repository check
        final isLoggedIn = await _userRepository.isLoggedIn();
        if (isLoggedIn) {
          _currentUser = await _userRepository.getCurrentUser();
        }
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
        
        // Save to secure storage
        await _secureStorage.saveUserCredentials(email, password, name);
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
        
        // Save to secure storage for future auto-login
        await _secureStorage.saveUserCredentials(
          email, 
          password, 
          _currentUser?.name ?? ''
        );
        
        // Show connectivity warning if offline
        if (_connectivityService?.isConnected == false) {
          _error = 'No internet connection - Limited functionality';
        }
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

  Future<bool> loginWithStoredCredentials() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final storedCredentials = await _secureStorage.getUserCredentials();
      final isStoredLoggedIn = await _secureStorage.isUserLoggedIn();
      
      if (!isStoredLoggedIn || storedCredentials['email'] == null) {
        return false; // No error message for this case
      }
      
      // Try to login with stored credentials
      final email = storedCredentials['email'];
      final passwordFromStore = storedCredentials['password'];
      
      if (email == null) {
        debugPrint('Auto-login failed: Stored email is unexpectedly null.');
        await _secureStorage.clearUserData();
        return false;
      }
      if (passwordFromStore == null) {
        debugPrint('Auto-login failed: Stored password is null.');
        await _secureStorage.clearUserData();
        return false;
      }
      
      final result = await _userRepository.login(email, passwordFromStore);
      
      if (result) {
        _currentUser = User(
          email: email,
          password: passwordFromStore,
          name: storedCredentials['name'] ?? '',
        );
        
        // Show connectivity warning if offline
        if (_connectivityService?.isConnected == false) {
          _error = 'No internet connection - Limited functionality';
        }
        
        return true;
      } else {
        // Clear invalid stored credentials if login failed
        debugPrint('Auto-login failed: _userRepository.login returned false. Clearing stored credentials.');
        await _secureStorage.clearUserData();
        return false;
      }
    } catch (e) {
      debugPrint('Auto-login error: $e. Clearing stored credentials.');
      await _secureStorage.clearUserData();
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
      // Clear all user data
      await Future.wait([
        _userRepository.logout(),
        _secureStorage.clearUserData(),
      ]);
      
      _currentUser = null;
      _error = null;
      
      debugPrint('Logout completed successfully');
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
      debugPrint('Logout error: $e');
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
        // Update secure storage
        await _secureStorage.updateUserName(name);
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

  void updateConnectivityStatus(bool isConnected) {
    _hasNetworkConnection = isConnected;
    
    if (!isConnected && _currentUser != null) {
      _error = 'Connection lost - Limited functionality';
    } else if (isConnected && _error == 'Connection lost - Limited functionality') {
      _error = null;
    }
    
    notifyListeners();
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