import 'package:cloud_firestore/cloud_firestore.dart';

class MarketQuestionSetPurchaseModel {
  final String id;
  final String userId;
  final String questionSetId;
  final double points;
  final DateTime purchasedAt;

  MarketQuestionSetPurchaseModel({
    required this.id,
    required this.userId,
    required this.questionSetId,
    required this.points,
    required this.purchasedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'questionSetId': questionSetId,
      'points': points,
      'purchasedAt': Timestamp.fromDate(purchasedAt),
    };
  }

  factory MarketQuestionSetPurchaseModel.fromMap(Map<String, dynamic> map) {
    return MarketQuestionSetPurchaseModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      questionSetId: map['questionSetId'] ?? '',
      points: map['points']?.toDouble() ?? 0.0,
      purchasedAt:
          (map['purchasedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
