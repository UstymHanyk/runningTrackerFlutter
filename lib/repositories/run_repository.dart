import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/models/run.dart';
import 'package:my_project/repositories/interfaces/run_repository_interface.dart';

class RunRepository implements RunRepositoryInterface {
  static const String _baseRunsKey = 'runs';
  
  String _generateUserRunsKey(String? userEmail) {
    final String effectiveEmail = userEmail ?? 'guest';
    return '${_baseRunsKey}_${effectiveEmail.replaceAll('.', '_').replaceAll('@', '_')}';
  }
  
  @override
  Future<List<Run>> getAllRuns({required String? userEmail}) async {
    final prefs = await SharedPreferences.getInstance();
    final String runsKey = _generateUserRunsKey(userEmail);
    final runsJson = prefs.getString(runsKey) ?? '{}';
    final Map<String, dynamic> runsMap = json.decode(runsJson);
    
    return runsMap.values
        .map((runJson) => Run.fromJson(runJson as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
  
  @override
  Future<bool> addRun({required Run run, required String? userEmail}) async {
    final prefs = await SharedPreferences.getInstance();
    final String runsKey = _generateUserRunsKey(userEmail);
    final runsJson = prefs.getString(runsKey) ?? '{}';
    final Map<String, dynamic> runsMap = json.decode(runsJson);

    Run runToAdd = run;
    if (run.heartRateData.isEmpty) {
      final random = Random();
      final int dataPoints = 20 + random.nextInt(11);
      final List<int> randomHeartRateData = List.generate(
        dataPoints, 
        (_) => 70 + random.nextInt(101)
      );
      runToAdd = run.copyWith(heartRateData: randomHeartRateData);
    }
    
    runsMap[runToAdd.id] = runToAdd.toJson();
    return prefs.setString(runsKey, json.encode(runsMap));
  }
  
  @override
  Future<bool> updateRun({required Run run, required String? userEmail}) async {
    final prefs = await SharedPreferences.getInstance();
    final String runsKey = _generateUserRunsKey(userEmail);
    final runsJson = prefs.getString(runsKey) ?? '{}';
    final Map<String, dynamic> runsMap = json.decode(runsJson);
    
    if (!runsMap.containsKey(run.id)) {
      return false;
    }
    
    Run runToUpdate = run;
    if (run.heartRateData.isEmpty) {
        final existingRunData = runsMap[run.id];
        if (existingRunData != null && (existingRunData as Map).containsKey('heartRateData') && existingRunData['heartRateData'] != null) {
            final existingHeartRateData = List<int>.from(existingRunData['heartRateData'] as List);
            if (existingHeartRateData.isNotEmpty) {
                 runToUpdate = run.copyWith(heartRateData: existingHeartRateData);
            }
        }
    }

    runsMap[runToUpdate.id] = runToUpdate.toJson();
    return prefs.setString(runsKey, json.encode(runsMap));
  }
  
  @override
  Future<bool> deleteRun({required String id, required String? userEmail}) async {
    final prefs = await SharedPreferences.getInstance();
    final String runsKey = _generateUserRunsKey(userEmail);
    final runsJson = prefs.getString(runsKey) ?? '{}';
    final Map<String, dynamic> runsMap = json.decode(runsJson);
    
    if (!runsMap.containsKey(id)) {
      return false;
    }
    
    runsMap.remove(id);
    return prefs.setString(runsKey, json.encode(runsMap));
  }
  
  @override
  Future<Run?> getRunById({required String id, required String? userEmail}) async {
    final prefs = await SharedPreferences.getInstance();
    final String runsKey = _generateUserRunsKey(userEmail);
    final runsJson = prefs.getString(runsKey) ?? '{}';
    final Map<String, dynamic> runsMap = json.decode(runsJson);
    
    if (!runsMap.containsKey(id)) {
      return null;
    }
    
    return Run.fromJson(runsMap[id] as Map<String, dynamic>);
  }
} 