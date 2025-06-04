import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService extends ChangeNotifier {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = false;
  String _connectionType = 'None';
  
  bool get isConnected => _isConnected;
  String get connectionType => _connectionType;

  ConnectivityService() {
    _init();
  }

  void _init() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    try {
      final List<ConnectivityResult> connectivityResults = await Connectivity().checkConnectivity();
      _updateConnectionStatus(connectivityResults);
    } catch (e) {
      debugPrint('Error checking initial connectivity: $e');
      _isConnected = false;
      _connectionType = 'Error';
      notifyListeners();
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      _isConnected = false;
      _connectionType = 'None';
    } else {
      _isConnected = true;
      if (results.contains(ConnectivityResult.wifi)) {
        _connectionType = 'WiFi';
      } else if (results.contains(ConnectivityResult.mobile)) {
        _connectionType = 'Mobile';
      } else if (results.contains(ConnectivityResult.ethernet)) {
        _connectionType = 'Ethernet';
      } else {
        _connectionType = 'Other';
      }
    }
    
    debugPrint('Connectivity status: $_connectionType (Connected: $_isConnected)');
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
} 