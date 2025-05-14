import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/models/run.dart';
import 'package:my_project/repositories/interfaces/run_repository_interface.dart';
import 'package:my_project/repositories/user_repository.dart';

class RunRepository implements RunRepositoryInterface {
  static const String _baseRunsKey = 'runs';
  final UserRepository _userRepository = UserRepository();
  
  Future<String> _getUserRunsKey() async {
    final currentUser = await _userRepository.getCurrentUser();
    final String userEmail = currentUser?.email ?? 'guest';
    return '${_baseRunsKey}_${userEmail.replaceAll('.', '_').replaceAll('@', '_')}';
  }
  
  @override
  Future<List<Run>> getAllRuns() async {
    final prefs = await SharedPreferences.getInstance();
    final String runsKey = await _getUserRunsKey();
    final runsJson = prefs.getString(runsKey) ?? '{}';
    final Map<String, dynamic> runs = json.decode(runsJson);
    
    return runs.values
        .map((runJson) => Run.fromJson(runJson))
        .toList()
        .cast<Run>()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
  
  @override
  Future<bool> addRun(Run run) async {
    final prefs = await SharedPreferences.getInstance();
    final String runsKey = await _getUserRunsKey();
    final runsJson = prefs.getString(runsKey) ?? '{}';
    final Map<String, dynamic> runs = json.decode(runsJson);
    
    runs[run.id] = run.toJson();
    return prefs.setString(runsKey, json.encode(runs));
  }
  
  @override
  Future<bool> updateRun(Run run) async {
    final prefs = await SharedPreferences.getInstance();
    final String runsKey = await _getUserRunsKey();
    final runsJson = prefs.getString(runsKey) ?? '{}';
    final Map<String, dynamic> runs = json.decode(runsJson);
    
    if (!runs.containsKey(run.id)) {
      return false;
    }
    
    runs[run.id] = run.toJson();
    return prefs.setString(runsKey, json.encode(runs));
  }
  
  @override
  Future<bool> deleteRun(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final String runsKey = await _getUserRunsKey();
    final runsJson = prefs.getString(runsKey) ?? '{}';
    final Map<String, dynamic> runs = json.decode(runsJson);
    
    if (!runs.containsKey(id)) {
      return false;
    }
    
    runs.remove(id);
    return prefs.setString(runsKey, json.encode(runs));
  }
  
  @override
  Future<Run?> getRunById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final String runsKey = await _getUserRunsKey();
    final runsJson = prefs.getString(runsKey) ?? '{}';
    final Map<String, dynamic> runs = json.decode(runsJson);
    
    if (!runs.containsKey(id)) {
      return null;
    }
    
    return Run.fromJson(runs[id]);
  }
} 