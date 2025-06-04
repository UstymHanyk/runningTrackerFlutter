import 'dart:async'; // Added for Timer
import 'package:flutter/material.dart';
import 'package:my_project/models/run.dart';
import 'package:my_project/repositories/interfaces/run_repository_interface.dart';
import 'package:my_project/repositories/run_repository.dart';
import 'package:my_project/services/interfaces/run_provider_interface.dart';
import 'dart:math';

class RunProvider extends ChangeNotifier implements RunProviderInterface {
  final RunRepositoryInterface _runRepository = RunRepository();
  List<Run> _runs = [];
  bool _isLoading = false;
  String? _error;
  double _currentDistance = 0;
  String? _currentUserEmail;

  // Heart rate simulation state
  int? _currentHeartRate;
  List<int> _currentRunHeartRateData = [];
  Timer? _heartRateTimer;
  final Random _random = Random(); // For heart rate generation

  @override
  List<Run> get runs => List.unmodifiable(_runs);
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get error => _error;
  
  @override
  double get currentDistance => _currentDistance;

  @override
  int? get currentHeartRate => _currentHeartRate; // Implemented getter

  RunProvider() {
    loadRuns();
  }

  @override
  void dispose() {
    _heartRateTimer?.cancel();
    super.dispose();
  }

  void _startHeartRateSimulation() {
    _heartRateTimer?.cancel(); // Cancel any existing timer
    _heartRateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Simulate heart rate between 90 and 160 bpm
      _currentHeartRate = 90 + _random.nextInt(71); 
      _currentRunHeartRateData.add(_currentHeartRate!);
      notifyListeners();
    });
  }

  void _stopHeartRateSimulation() {
    _heartRateTimer?.cancel();
    _heartRateTimer = null;
    // _currentHeartRate = null; // Keep last HR displayed until run explicitly reset/saved
    notifyListeners(); // Notify if _currentHeartRate was changed to null
  }

  @override
  Future<void> checkUserAndReload(String? newUserEmail) async {
    if (_isLoading && _currentUserEmail == newUserEmail && _runs.isNotEmpty) return;

    bool userChanged = _currentUserEmail != newUserEmail;
    _currentUserEmail = newUserEmail;

    if (userChanged) {
      resetCurrentDistance(); // Reset run state for new user
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
    _currentDistance = distance;
    if (_currentDistance > 0 && (_heartRateTimer == null || !_heartRateTimer!.isActive)) {
      _currentRunHeartRateData.clear(); // Clear old data for a new segment if any
      _startHeartRateSimulation();
    } else if (_currentDistance <= 0) {
      _stopHeartRateSimulation();
      _currentRunHeartRateData.clear();
      _currentHeartRate = null;
    }
    notifyListeners();
  }

  @override
  void incrementDistance(double value) {
    bool wasPreviouslyZero = _currentDistance == 0;
    _currentDistance = ((_currentDistance * 10) + (value * 10)) / 10;
    
    if (wasPreviouslyZero && _currentDistance > 0) {
       _currentRunHeartRateData.clear(); // Start fresh HR data
       _currentHeartRate = null; // Reset display for new run
      _startHeartRateSimulation();
    } else if (_currentDistance > 0 && (_heartRateTimer == null || !_heartRateTimer!.isActive)) {
      // If somehow timer stopped but distance > 0, restart it.
      _startHeartRateSimulation();
    }
    notifyListeners();
  }

  @override
  void resetCurrentDistance() {
    _currentDistance = 0;
    _stopHeartRateSimulation();
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
    
    _stopHeartRateSimulation(); // Stop simulation before saving

    _isLoading = true;
    _error = null;
    notifyListeners();
    
    List<int> heartDataForRun = List.from(_currentRunHeartRateData); // Copy data

    try {
      final run = Run(
        id: _generateId(),
        name: name.isNotEmpty ? name : 'Unnamed Run',
        distance: _currentDistance,
        date: DateTime.now(),
        heartRateData: heartDataForRun, // Use accumulated data
      );
      
      final result = await _runRepository.addRun(run: run, userEmail: _currentUserEmail);
      
      if (result) {
        // The run object passed to addRun is what we want to add locally
        final runToAdd = run.copyWith(heartRateData: heartDataForRun); 
        final newRunsList = [runToAdd, ..._runs];
        newRunsList.sort((a,b) => b.date.compareTo(a.date));
        _runs = newRunsList;
        
        // Reset state after successful save
        _currentDistance = 0;
        _currentRunHeartRateData.clear();
        _currentHeartRate = null; 
      } else {
        _error = 'Failed to save run';
        // If save failed, potentially restart simulation if user wants to retry or continue run
        // For now, we keep it stopped. User might need to manually start a new action.
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
        _runs = _runs.where((run) => run.id != id).toList();
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
    return '${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';
  }
} 