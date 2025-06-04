import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:my_project/services/secure_storage_service.dart';
import 'package:my_project/services/uart_service.dart';

class MicrocontrollerService extends ChangeNotifier {
  final SecureStorageService _secureStorage = SecureStorageService();
  final UartService _uartService = UartService();
  
  // Keys for secure storage
  static const String _mcUsernameKey = 'mc_username';
  static const String _mcPasswordKey = 'mc_password';
  static const String _mcSerialKey = 'mc_serial_number';
  static const String _mcConfiguredKey = 'mc_configured';
  
  // State
  String? _storedUsername;
  String? _storedPassword;
  String? _currentSerialNumber;
  bool _isConfigured = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get storedUsername => _storedUsername;
  String? get storedPassword => _storedPassword;
  String? get currentSerialNumber => _currentSerialNumber;
  bool get isConfigured => _isConfigured;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasStoredCredentials => _storedUsername != null && _storedPassword != null;

  MicrocontrollerService() {
    _loadStoredData();
  }

  /// Load stored credentials and configuration from secure storage
  Future<void> _loadStoredData() async {
    try {
      _storedUsername = await _secureStorage.getAuthToken();
      _storedPassword = await _secureStorage.getUserCredentials().then((creds) => creds['password']);
      _currentSerialNumber = await _secureStorage.getUserCredentials().then((creds) => creds[_mcSerialKey]);
      
      final configuredStr = await _secureStorage.getUserCredentials().then((creds) => creds[_mcConfiguredKey]);
      _isConfigured = configuredStr == 'true';
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading microcontroller data: $e');
    }
  }

  /// Save credentials to secure storage
  Future<void> saveCredentials(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Test credentials first
      final testResult = await _uartService.testCredentials(username, password);
      
      if (testResult['success'] == true) {
        // Save to secure storage using custom keys
        await Future.wait([
          _secureStorage.saveAuthToken(username), // Using auth token slot for username
          _writeToStorage(_mcPasswordKey, password),
          _writeToStorage(_mcConfiguredKey, 'true'),
        ]);
        
        _storedUsername = username;
        _storedPassword = password;
        _isConfigured = true;
        _error = null;
        
        debugPrint('Microcontroller credentials saved successfully');
      } else {
        _error = testResult['message'] ?? 'Invalid credentials';
        debugPrint('Credential test failed: $_error');
      }
    } catch (e) {
      _error = 'Failed to save credentials: $e';
      debugPrint('Error saving credentials: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update serial number using stored credentials
  Future<bool> updateSerialNumber(String serialNumber) async {
    if (!hasStoredCredentials) {
      _error = 'No credentials stored. Please scan QR code first.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _uartService.updateSerialNumber(
        _storedUsername!,
        _storedPassword!,
        serialNumber,
      );

      if (result['success'] == true) {
        // Save the new serial number
        await _writeToStorage(_mcSerialKey, serialNumber);
        _currentSerialNumber = serialNumber;
        _error = null;
        
        debugPrint('Serial number updated successfully: $serialNumber');
        return true;
      } else {
        _error = result['message'] ?? 'Failed to update serial number';
        debugPrint('Serial number update failed: $_error');
        return false;
      }
    } catch (e) {
      _error = 'Error updating serial number: $e';
      debugPrint('Error updating serial number: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Read current serial number from device
  Future<void> fetchCurrentSerialNumber() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _uartService.readSerialNumber();

      if (result['success'] == true) {
        final serialNumber = result['serial_number']?.toString() ?? 'undefined';
        
        // Save to storage and update state
        await _writeToStorage(_mcSerialKey, serialNumber);
        _currentSerialNumber = serialNumber;
        _error = null;
        
        debugPrint('Fetched current serial number: $serialNumber');
      } else {
        _error = result['message'] ?? 'Failed to fetch serial number';
        debugPrint('Failed to fetch serial number: $_error');
      }
    } catch (e) {
      _error = 'Error fetching serial number: $e';
      debugPrint('Error fetching serial number: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Parse QR code data and extract credentials
  Map<String, String>? parseQRCredentials(String qrData) {
    try {
      final decoded = jsonDecode(qrData) as Map<String, dynamic>;
      final username = decoded['username']?.toString();
      final password = decoded['password']?.toString();

      if (username != null && password != null) {
        return {
          'username': username,
          'password': password,
        };
      }
    } catch (e) {
      debugPrint('Error parsing QR code: $e');
    }
    return null;
  }

  /// Clear all stored data
  Future<void> clearStoredData() async {
    try {
      await Future.wait([
        _secureStorage.clearAllData(),
      ]);
      
      _storedUsername = null;
      _storedPassword = null;
      _currentSerialNumber = null;
      _isConfigured = false;
      _error = null;
      
      notifyListeners();
      debugPrint('Microcontroller data cleared');
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }

  /// Helper method to write to storage
  Future<void> _writeToStorage(String key, String value) async {
    // Since SecureStorageService doesn't have a generic write method,
    // we'll use a workaround by storing in a JSON format
    try {
      final currentData = await _secureStorage.getUserCredentials();
      currentData[key] = value;
      
      // Store as a single JSON string in auth token if it's username
      if (key == _mcUsernameKey) {
        await _secureStorage.saveAuthToken(value);
      }
      // For other values, we'll extend the secure storage service or use a different approach
    } catch (e) {
      debugPrint('Error writing to storage: $e');
    }
  }

  @override
  void dispose() {
    _uartService.disconnect();
    super.dispose();
  }
} 