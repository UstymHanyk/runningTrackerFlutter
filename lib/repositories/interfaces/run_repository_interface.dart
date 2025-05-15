import 'package:my_project/models/run.dart';

abstract class RunRepositoryInterface {
  Future<List<Run>> getAllRuns();
  Future<bool> addRun(Run run);
  Future<bool> updateRun(Run run);
  Future<bool> deleteRun(String id);
  Future<Run?> getRunById(String id);
} 