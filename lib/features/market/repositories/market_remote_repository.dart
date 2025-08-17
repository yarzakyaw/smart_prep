import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_prep/features/auth/model/user_info_model.dart';
import 'package:smart_prep/features/market/model/market_question_set_model.dart';
import 'package:smart_prep/features/market/model/market_question_set_purchase_model.dart';
import 'package:uuid/uuid.dart';

part 'market_remote_repository.g.dart';

@riverpod
MarketRemoteRepository marketRemoteRepository(Ref ref) {
  return MarketRemoteRepository();
}

class MarketRemoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<MarketQuestionSetModel>> getQuestionSetsFromMarket({
    String? subject,
    String? difficulty,
    String? status,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('question_set_market')
        .orderBy('createdAt', descending: true);
    if (subject != null) {
      query = query.where('subject', isEqualTo: subject);
    }
    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => MarketQuestionSetModel.fromMap(doc.data()))
          .toList(),
    );
  }

  /* Future<void> createQuestionSetForMarket(MarketQuestionSetModel set) async {
    await _firestore
        .collection('question_set_market')
        .doc(set.id)
        .set(set.toMap());
  } */

  Future<void> purchaseQuestionSetFromMarket(
    String questionSetId,
    double points,
    String buyerId,
  ) async {
    final setDoc = await _firestore
        .collection('question_set_market')
        .doc(questionSetId)
        .get();
    final set = MarketQuestionSetModel.fromMap(setDoc.data()!);
    if (set.status != 'approved') {
      throw Exception('Question set not approved');
    }

    await _firestore.runTransaction((transaction) async {
      final buyerDoc = _firestore.collection('users').doc(buyerId);
      final buyer = UserInfoModel.fromMap(
        (await transaction.get(buyerDoc)).data()!,
      );
      if (buyer.points < points) {
        throw Exception('Insufficient points');
      }

      // Deduct points from buyer
      transaction.update(buyerDoc, {'points': buyer.points - points});

      // Distribute points: 80% to seller, 20% to admin (store in audit_logs for simplicity)
      final sellerPoints = points * 0.8;
      final adminPoints = points * 0.2;
      transaction.update(_firestore.collection('users').doc(set.creatorId), {
        'points': FieldValue.increment(sellerPoints),
      });
      transaction.set(_firestore.collection('audit_logs').doc(), {
        'adminId': 'system',
        'action': 'admin_points',
        'points': adminPoints,
        'questionSetId': questionSetId,
        'timestamp': Timestamp.now(),
      });

      // Record purchase
      final purchase = MarketQuestionSetPurchaseModel(
        id: const Uuid().v4(),
        userId: buyerId,
        questionSetId: questionSetId,
        points: points,
        purchasedAt: DateTime.now(),
      );
      transaction.set(
        _firestore.collection('purchases').doc(purchase.id),
        purchase.toMap(),
      );
    });
  }

  Stream<List<MarketQuestionSetPurchaseModel>> getUserPurchases(String userId) {
    return _firestore
        .collection('purchases')
        .where('userId', isEqualTo: userId)
        .orderBy('purchasedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MarketQuestionSetPurchaseModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> rateMarketQuestionSet(
    String setId,
    String userId,
    double rating,
    String comment,
  ) async {
    await _firestore.runTransaction((transaction) async {
      final setDoc = _firestore.collection('question_set_market').doc(setId);
      final set = MarketQuestionSetModel.fromMap(
        (await transaction.get(setDoc)).data()!,
      );
      final newReview = {
        'userId': userId,
        'rating': rating,
        'comment': comment,
        'timestamp': Timestamp.now(),
      };
      final updatedReviews = [...set.reviews, newReview];
      final newRatingCount = set.ratingCount + 1;
      final newAverageRating =
          (set.averageRating * set.ratingCount + rating) / newRatingCount;

      transaction.update(setDoc, {
        'reviews': updatedReviews,
        'ratingCount': newRatingCount,
        'averageRating': newAverageRating,
      });
    });
  }

  Future<String> uploadTestPdf(String testId, File file) async {
    final ref = _storage.ref().child('test_pdfs/$testId.pdf');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadMarketQuestionSetPdf(String setId, File file) async {
    final ref = _storage.ref().child('market_question_set_pdfs/$setId.pdf');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<String> uploadSubmissionPdf(
    String submissionId,
    File file,
    String studentId,
  ) async {
    final ref = _storage.ref().child('submission_pdfs/$submissionId.pdf');
    await ref.putFile(
      file,
      SettableMetadata(customMetadata: {'studentId': studentId}),
    );
    return await ref.getDownloadURL();
  }
}
