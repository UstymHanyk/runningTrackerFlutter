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

  @override
  List<Run> get runs => List.unmodifiable(_runs);
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get error => _error;
  
  @override
  double get currentDistance => _currentDistance;

  RunProvider() {
    loadRuns();
  }

  @override
  Future<void> checkUserAndReload(String? currentUserEmail) async {
    if (_currentUserEmail != currentUserEmail) {
      _currentUserEmail = currentUserEmail;
      await loadRuns();
    }
  }

  @override
  Future<void> loadRuns() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _runs = await _runRepository.getAllRuns();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void updateCurrentDistance(double distance) {
    _currentDistance = distance;
    notifyListeners();
  }

  @override
  void incrementDistance(double value) {
    _currentDistance = ((_currentDistance * 10) + (value * 10)) / 10;
    notifyListeners();
  }

  @override
  void resetCurrentDistance() {
    _currentDistance = 0;
    notifyListeners();
  }

  @override
  Future<bool> saveRun(String name) async {
    if (_currentDistance <= 0) return false;
    if (_isLoading) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final run = Run(
        id: _generateId(),
        name: name.isNotEmpty ? name : 'Unnamed Run',
        distance: _currentDistance,
        date: DateTime.now(),
      );
      
      final result = await _runRepository.addRun(run);
      
      if (result) {
        final newRuns = [run, ..._runs];
        _runs = newRuns;
        _currentDistance = 0;
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
      final result = await _runRepository.deleteRun(id);
      
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
      final result = await _runRepository.updateRun(updatedRun);
      
      if (result) {
        final index = _runs.indexWhere((run) => run.id == updatedRun.id);
        if (index != -1) {
          final newRuns = List<Run>.from(_runs);
          newRuns[index] = updatedRun;
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
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }
} 