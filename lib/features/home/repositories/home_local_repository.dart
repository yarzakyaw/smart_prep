import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_prep/core/models/submission_model.dart';
import 'package:smart_prep/core/models/test_model.dart';

part 'home_local_repository.g.dart';

@riverpod
HomeLocalRepository homeLocalRepository(Ref ref) {
  return HomeLocalRepository();
}

class HomeLocalRepository {
  static const String _submissionBox = 'submissions';
  static const String _testBox = 'tests';

  Future<void> init() async {
    await Hive.openBox(_submissionBox);
    await Hive.openBox(_testBox);
  }

  Future<void> cacheSubmission(SubmissionModel submission) async {
    final box = Hive.box(_submissionBox);
    await box.put(submission.id, submission.toMap());
  }

  List<SubmissionModel> getCachedSubmissions() {
    final box = Hive.box(_submissionBox);
    return box.values
        .map((data) => SubmissionModel.fromMap(Map<String, dynamic>.from(data)))
        .toList();
  }

  Future<void> cacheTest(TestModel test) async {
    final box = Hive.box(_testBox);
    await box.put(test.id, test.toMap());
  }

  List<TestModel> getCachedTests() {
    final box = Hive.box(_testBox);
    return box.values
        .map((data) => TestModel.fromMap(Map<String, dynamic>.from(data)))
        .toList();
  }
}
