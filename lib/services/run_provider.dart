import 'dart:async'; // Added for Timer
import 'package:flutter/material.dart';
import 'package:my_project/models/run.dart';
import 'package:my_project/repositories/interfaces/run_repository_interface.dart';
import 'package:my_project/repositories/run_repository.dart';
import 'package:my_project/services/interfaces/run_provider_interface.dart';
import 'package:my_project/services/mqtt_service.dart';

class RunProvider extends ChangeNotifier implements RunProviderInterface {
  final RunRepositoryInterface _runRepository = RunRepository();
  List<Run> _runs = [];
  bool _isLoading = false;
  String? _error;
  double _currentDistance = 0;
  String? _currentUserEmail;

  // MQTT Heart rate integration
  int? _currentHeartRate;
  final List<int> _currentRunHeartRateData = [];
  MqttService? _mqttService;
  StreamSubscription? _mqttHeartRateSubscription;
  Timer? _heartRateDataTimer;

  @override
  List<Run> get runs => List.unmodifiable(_runs);
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get error => _error;
  
  @override
  double get currentDistance => _currentDistance;

  @override
  int? get currentHeartRate => _currentHeartRate;

  RunProvider() {
    loadRuns();
    _initializeMqtt();
  }

  void _initializeMqtt() {
    _mqttService = MqttService();
    _mqttService!.addListener(_onMqttDataUpdate);
    
    // Try to connect to MQTT broker
    _mqttService!.connect().catchError((error) {
      debugPrint('Failed to connect to MQTT broker: $error');
    });
  }

  @override
  Future<void> updateMqttConfiguration() async {
    if (_mqttService != null) {
      await _mqttService!.updateConfiguration();
    }
  }

  void _onMqttDataUpdate() {
    if (_mqttService != null && _mqttService!.isConnected) {
      final newHeartRate = _mqttService!.currentHeartRate.toInt();
      
      // Only update if we have a valid heart rate and distance > 0
      if (newHeartRate > 0 && _currentDistance > 0) {
        _currentHeartRate = newHeartRate;
        
        // Add to current run data every time we get new data
        _currentRunHeartRateData.add(_currentHeartRate!);
        notifyListeners();
        
        debugPrint('Updated heart rate from MQTT: $_currentHeartRate bpm');
      }
    }
  }

  void _startHeartRateDataCollection() {
    // Clear previous data when starting a new run
    _currentRunHeartRateData.clear();
    _currentHeartRate = null;
    
    // Start periodic data collection timer
    _heartRateDataTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_mqttService != null && _mqttService!.isConnected && _currentDistance > 0) {
        final heartRate = _mqttService!.currentHeartRate.toInt();
        if (heartRate > 0) {
          _currentHeartRate = heartRate;
          _currentRunHeartRateData.add(heartRate);
          notifyListeners();
        }
      } else if (_currentDistance <= 0) {
        // Stop collecting if distance becomes 0
        _stopHeartRateDataCollection();
      }
    });
    
    debugPrint('Started MQTT heart rate data collection');
  }

  void _stopHeartRateDataCollection() {
    _heartRateDataTimer?.cancel();
    _heartRateDataTimer = null;
    debugPrint('Stopped heart rate data collection');
  }

  @override
  void dispose() {
    _heartRateDataTimer?.cancel();
    _mqttHeartRateSubscription?.cancel();
    _mqttService?.removeListener(_onMqttDataUpdate);
    _mqttService?.dispose();
    super.dispose();
  }

  @override
  Future<void> checkUserAndReload(String? newUserEmail) async {
    if (_isLoading && _currentUserEmail == newUserEmail && _runs.isNotEmpty) return;

    bool userChanged = _currentUserEmail != newUserEmail;
    _currentUserEmail = newUserEmail;

    if (userChanged) {
      resetCurrentDistance();
      _runs = [];
      notifyListeners();
      await loadRuns();
    } else if (_runs.isEmpty && !_isLoading) {
      await loadRuns();
    }
  }

  @override
  Future<void> loadRuns() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    if (_runs.isEmpty) {
        notifyListeners();
    }
    
    try {
      _runs = await _runRepository.getAllRuns(userEmail: _currentUserEmail);
    } catch (e) {
      _error = e.toString();
      _runs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void updateCurrentDistance(double distance) {
    bool wasZero = _currentDistance == 0;
    _currentDistance = distance;
    
    if (_currentDistance > 0 && wasZero) {
      // Starting a new run - begin heart rate data collection
      _startHeartRateDataCollection();
    } else if (_currentDistance <= 0) {
      // Stopping run - stop heart rate data collection
      _stopHeartRateDataCollection();
      _currentHeartRate = null;
    }
    notifyListeners();
  }

  @override
  void incrementDistance(double value) {
    bool wasPreviouslyZero = _currentDistance == 0;
    _currentDistance = ((_currentDistance * 10) + (value * 10)) / 10;
    
    if (wasPreviouslyZero && _currentDistance > 0) {
      // Starting a new run segment
      _startHeartRateDataCollection();
    } else if (_currentDistance > 0 && _heartRateDataTimer == null) {
      // Resume data collection if somehow stopped
      _startHeartRateDataCollection();
    }
    notifyListeners();
  }

  @override
  void resetCurrentDistance() {
    _currentDistance = 0;
    _stopHeartRateDataCollection();
    _currentRunHeartRateData.clear();
    _currentHeartRate = null;
    notifyListeners();
  }

  @override
  Future<bool> saveRun(String name) async {
    if (_currentDistance <= 0) {
      _error = "Distance must be greater than 0 to save a run.";
      notifyListeners();
      return false;
    }
    if (_isLoading) return false;
    
    // Stop heart rate data collection before saving
    _stopHeartRateDataCollection();

    _isLoading = true;
    _error = null;
    notifyListeners();
    
    // Copy heart rate data for this run
    List<int> heartDataForRun = List.from(_currentRunHeartRateData);

    try {
      final run = Run(
        id: _generateId(),
        name: name.isNotEmpty ? name : 'Unnamed Run',
        distance: _currentDistance,
        date: DateTime.now(),
        heartRateData: heartDataForRun,
      );
      
      final result = await _runRepository.addRun(run: run, userEmail: _currentUserEmail);
      
      if (result) {
        final runToAdd = run.copyWith(heartRateData: heartDataForRun); 
        final newRunsList = [runToAdd, ..._runs];
        newRunsList.sort((a,b) => b.date.compareTo(a.date));
        _runs = newRunsList;
        
        // Reset state after successful save
        _currentDistance = 0;
        _currentRunHeartRateData.clear();
        _currentHeartRate = null; 
        
        debugPrint('Run saved with ${heartDataForRun.length} heart rate data points');
      } else {
        _error = 'Failed to save run';
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
  Future<bool> deleteRun(String id) async {
    if (_isLoading) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _runRepository.deleteRun(id: id, userEmail: _currentUserEmail);
      
      if (result) {
        _runs.removeWhere((run) => run.id == id);
      } else {
        _error = 'Failed to delete run';
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
  Future<bool> updateRun(Run updatedRun) async {
    if (_isLoading) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _runRepository.updateRun(run: updatedRun, userEmail: _currentUserEmail);
      
      if (result) {
        final index = _runs.indexWhere((run) => run.id == updatedRun.id);
        if (index != -1) {
          final newRuns = List<Run>.from(_runs);
          newRuns[index] = updatedRun;
          newRuns.sort((a,b) => b.date.compareTo(a.date));
          _runs = newRuns;
        }
      } else {
        _error = 'Failed to update run';
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

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Getter for MQTT connection status
  bool get isMqttConnected => _mqttService?.isConnected ?? false;
  String get mqttConnectionStatus => _mqttService?.connectionStatus ?? 'Disconnected';
} 