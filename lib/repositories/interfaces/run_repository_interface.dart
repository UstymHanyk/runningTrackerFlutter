import 'package:my_project/models/run.dart';

abstract class RunRepositoryInterface {
  Future<List<Run>> getAllRuns({required String? userEmail});
  Future<bool> addRun({required Run run, required String? userEmail});
  Future<bool> updateRun({required Run run, required String? userEmail});
  Future<bool> deleteRun({required String id, required String? userEmail});
  Future<Run?> getRunById({required String id, required String? userEmail});
} 