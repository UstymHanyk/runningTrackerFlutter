import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for stored data
  static const String _userEmailKey = 'user_email';
  static const String _userPasswordKey = 'user_password';
  static const String _userNameKey = 'user_name';
  static const String _authTokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';

  // Timeout duration for operations
  static const Duration _operationTimeout = Duration(seconds: 10);

  // User authentication methods
  Future<void> saveUserCredentials(String email, String password, String name) async {
    try {
      await Future.wait([
        _storage.write(key: _userEmailKey, value: email),
        _storage.write(key: _userPasswordKey, value: password),
        _storage.write(key: _userNameKey, value: name),
        _storage.write(key: _isLoggedInKey, value: 'true'),
      ]).timeout(_operationTimeout);
      
      debugPrint('User credentials saved securely');
    } catch (e) {
      debugPrint('Error saving user credentials: $e');
      rethrow;
    }
  }

  Future<Map<String, String?>> getUserCredentials() async {
    try {
      final results = await Future.wait([
        _storage.read(key: _userEmailKey),
        _storage.read(key: _userPasswordKey),
        _storage.read(key: _userNameKey),
      ]).timeout(_operationTimeout);
      
      return {
        'email': results[0],
        'password': results[1],
        'name': results[2],
      };
    } catch (e) {
      debugPrint('Error reading user credentials: $e');
      return {
        'email': null,
        'password': null,
        'name': null,
      };
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      final isLoggedIn = await _storage.read(key: _isLoggedInKey).timeout(_operationTimeout);
      return isLoggedIn == 'true';
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: _authTokenKey, value: token).timeout(_operationTimeout);
      debugPrint('Auth token saved securely');
    } catch (e) {
      debugPrint('Error saving auth token: $e');
      rethrow;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _authTokenKey).timeout(_operationTimeout);
    } catch (e) {
      debugPrint('Error reading auth token: $e');
      return null;
    }
  }

  Future<void> updateUserName(String name) async {
    try {
      await _storage.write(key: _userNameKey, value: name).timeout(_operationTimeout);
      debugPrint('User name updated securely');
    } catch (e) {
      debugPrint('Error updating user name: $e');
      rethrow;
    }
  }

  Future<void> clearUserData() async {
    try {
      await Future.wait([
        _storage.delete(key: _userEmailKey),
        _storage.delete(key: _userPasswordKey),
        _storage.delete(key: _userNameKey),
        _storage.delete(key: _authTokenKey),
        _storage.write(key: _isLoggedInKey, value: 'false'),
      ]).timeout(_operationTimeout);
      
      debugPrint('User data cleared from secure storage');
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      // Don't rethrow here - we want logout to continue even if this fails
    }
  }

  Future<void> clearAllData() async {
    try {
      await _storage.deleteAll().timeout(_operationTimeout);
      debugPrint('All secure storage data cleared');
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      rethrow;
    }
  }
} 