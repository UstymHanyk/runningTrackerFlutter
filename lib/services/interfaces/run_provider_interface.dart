import 'package:flutter/foundation.dart';
import 'package:my_project/models/run.dart';

abstract class RunProviderInterface extends ChangeNotifier {
  List<Run> get runs;
  bool get isLoading;
  String? get error;
  double get currentDistance;

  Future<void> checkUserAndReload(String? currentUserEmail);
  Future<void> loadRuns();
  void updateCurrentDistance(double distance);
  void incrementDistance(double value);
  void resetCurrentDistance();
  Future<bool> saveRun(String name);
  Future<bool> deleteRun(String id);
  Future<bool> updateRun(Run updatedRun);
} 