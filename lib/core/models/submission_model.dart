import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'submission_model.g.dart';

@HiveType(typeId: 1)
class SubmissionModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String testId;
  @HiveField(2)
  final String classId;
  @HiveField(3)
  final String studentId;
  @HiveField(4)
  final String studentName;
  @HiveField(5)
  final String questionType;
  @HiveField(6)
  final List<Map<String, dynamic>>? answers; // For MCQ/fill-in-the-blank
  @HiveField(7)
  final String? submissionUrl; // For essay/PDF submissions
  @HiveField(8)
  final double? score;
  @HiveField(9)
  final String? feedback;
  @HiveField(10)
  final DateTime submittedAt;
  @HiveField(11)
  final DateTime? gradedAt;

  SubmissionModel({
    required this.id,
    required this.testId,
    required this.classId,
    required this.studentId,
    required this.studentName,
    required this.questionType,
    this.answers,
    this.submissionUrl,
    this.score,
    this.feedback,
    required this.submittedAt,
    this.gradedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'testId': testId,
      'classId': classId,
      'studentId': studentId,
      'studentName': studentName,
      'questionType': questionType,
      'answers': answers,
      'submissionUrl': submissionUrl,
      'score': score,
      'feedback': feedback,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'gradedAt': gradedAt != null ? Timestamp.fromDate(gradedAt!) : null,
    };
  }

  factory SubmissionModel.fromMap(Map<String, dynamic> map) {
    return SubmissionModel(
      id: map['id'] ?? '',
      testId: map['testId'] ?? '',
      classId: map['classId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      questionType: map['questionType'] ?? '',
      answers: map['answers'] != null
          ? List<Map<String, dynamic>>.from(map['answers'])
          : null,
      submissionUrl: map['submissionUrl'],
      score: map['score']?.toDouble(),
      feedback: map['feedback'],
      submittedAt:
          (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gradedAt: (map['gradedAt'] as Timestamp?)?.toDate(),
    );
  }
}
