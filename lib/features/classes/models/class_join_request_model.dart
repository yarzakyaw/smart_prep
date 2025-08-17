import 'package:cloud_firestore/cloud_firestore.dart';

class ClassJoinRequestModel {
  final String id;
  final String classId;
  final String userId;
  final String userName;
  final String userEmail;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime timestamp;

  ClassJoinRequestModel({
    required this.id,
    required this.classId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ClassJoinRequestModel.fromMap(Map<String, dynamic> map) {
    return ClassJoinRequestModel(
      id: map['id'] ?? '',
      classId: map['classId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      status: map['status'] ?? 'pending',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
