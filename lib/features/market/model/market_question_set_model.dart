import 'package:cloud_firestore/cloud_firestore.dart';

class MarketQuestionSetModel {
  final String id;
  final String title;
  final String subject;
  final String difficulty; // e.g., 'easy', 'medium', 'hard'
  final double points; // Points required to purchase
  final String creatorId;
  final String creatorName;
  final String? pdfUrl;
  final List<Map<String, dynamic>>? questions;
  final List<String> tags;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final double averageRating; // Average of all ratings
  final int ratingCount; // Number of ratings
  final List<Map<String, dynamic>>
  reviews; // List of {userId, rating, comment, timestamp}

  MarketQuestionSetModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.difficulty,
    required this.points,
    required this.creatorId,
    required this.creatorName,
    this.pdfUrl,
    this.questions,
    required this.tags,
    required this.status,
    required this.createdAt,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.reviews = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'difficulty': difficulty,
      'points': points,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'pdfUrl': pdfUrl,
      'questions': questions,
      'tags': tags,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'reviews': reviews,
    };
  }

  factory MarketQuestionSetModel.fromMap(Map<String, dynamic> map) {
    return MarketQuestionSetModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      difficulty: map['difficulty'] ?? 'medium',
      points: map['points']?.toDouble() ?? 0.0,
      creatorId: map['creatorId'] ?? '',
      creatorName: map['creatorName'] ?? '',
      pdfUrl: map['pdfUrl'],
      questions: map['questions'] != null
          ? List<Map<String, dynamic>>.from(map['questions'])
          : null,
      tags: List<String>.from(map['tags'] ?? []),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      averageRating: map['averageRating']?.toDouble() ?? 0.0,
      ratingCount: map['ratingCount'] ?? 0,
      reviews: List<Map<String, dynamic>>.from(map['reviews'] ?? []),
    );
  }
}
