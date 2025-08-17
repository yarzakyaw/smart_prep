import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'test_model.g.dart';

@HiveType(typeId: 2)
class TestModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String classId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String type; // 'mcq', 'fill-in-the-blank', 'essay'
  @HiveField(4)
  final String? pdfUrl; // Firebase Storage URL for PDF test set
  @HiveField(5)
  final List<Map<String, dynamic>>? questions; // For non-PDF tests
  @HiveField(6)
  final DateTime createdAt;
  @HiveField(7)
  final DateTime? dueDate;
  @HiveField(8)
  final bool isOnline;

  TestModel({
    required this.id,
    required this.classId,
    required this.title,
    required this.type,
    this.pdfUrl,
    this.questions,
    required this.createdAt,
    this.dueDate,
    required this.isOnline,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'title': title,
      'type': type,
      'pdfUrl': pdfUrl,
      'questions': questions,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'isOnline': isOnline,
    };
  }

  factory TestModel.fromMap(Map<String, dynamic> map) {
    return TestModel(
      id: map['id'] ?? '',
      classId: map['classId'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? 'mcq',
      pdfUrl: map['pdfUrl'],
      questions: map['questions'] != null
          ? List<Map<String, dynamic>>.from(map['questions'])
          : null,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      isOnline: map['isOnline'] ?? true,
    );
  }
}
