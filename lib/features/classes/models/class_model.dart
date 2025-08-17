import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String title;
  final String description;
  final String teacherId;
  final String teacherName;
  final String subject;
  final DateTime createdAt;

  ClassModel({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    required this.teacherName,
    required this.subject,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'subject': subject,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      subject: map['subject'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
