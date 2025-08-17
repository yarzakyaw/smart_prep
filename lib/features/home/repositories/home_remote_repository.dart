import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_prep/core/models/submission_model.dart';
import 'package:smart_prep/core/models/test_model.dart';
import 'package:smart_prep/features/classes/models/class_model.dart';
import 'package:uuid/uuid.dart';

part 'home_remote_repository.g.dart';

@riverpod
HomeRemoteRepository homeRemoteRepository(Ref ref) {
  return HomeRemoteRepository();
}

class HomeRemoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  // Save progress to Firestore
  Future<void> saveProgress({
    required String mode,
    String? subject,
    required int score,
    required int totalQuestions,
    required Map<int, String> incorrectAnswers,
    required DateTime timestamp,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      final docRef = await _firestore.collection('progress').add({
        'userId': user.uid,
        'mode': mode,
        'subject': subject,
        'score': score,
        'totalQuestions': totalQuestions,
        'incorrectAnswers': incorrectAnswers.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
        'timestamp': Timestamp.fromDate(timestamp),
      });
      await docRef.update({'id': docRef.id}); // Store document ID
    }
  }

  // Get progress from Firestore
  Future<List<Map<String, dynamic>>> getProgress() async {
    final user = _auth.currentUser;
    if (user != null) {
      final query = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();
      return query.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    }
    return [];
  }

  // Submit teacher privilege request
  Future<void> submitTeacherRequest({
    required String name,
    required String email,
    required String teacherInfo,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      final docRef = await _firestore.collection('teacher_requests').add({
        'userId': user.uid,
        'name': name,
        'email': email,
        'teacherInfo': teacherInfo,
        'status': 'pending',
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });
      await docRef.update({'id': docRef.id});
    }
  }

  Future<List<ClassModel>> getClasses() async {
    final query = await _firestore
        .collection('classes')
        .orderBy('createdAt', descending: true)
        .get();
    return query.docs.map((doc) => ClassModel.fromMap(doc.data())).toList();
  }

  Future<void> submitClassJoinRequest({
    required String classId,
    required String userName,
    required String userEmail,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      final docRef = await _firestore.collection('class_join_requests').add({
        'classId': classId,
        'userId': user.uid,
        'userName': userName,
        'userEmail': userEmail,
        'status': 'pending',
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });
      await docRef.update({'id': docRef.id});
    }
  }

  Stream<List<TestModel>> getTests(String classId) {
    return _firestore
        .collection('tests')
        .where('classId', isEqualTo: classId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TestModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> submitTest({
    required String testId,
    required String studentId,
    required String classId,
    required String studentName,
    required String questionType,
    String? pdfPath,
    List<Map<String, dynamic>>? answers,
  }) async {
    final testDoc = await _firestore.collection('tests').doc(testId).get();
    final test = TestModel.fromMap(testDoc.data()!);
    if (test.dueDate != null && DateTime.now().isAfter(test.dueDate!)) {
      throw Exception('Submission deadline has passed');
    }

    final submission = SubmissionModel(
      id: const Uuid().v4(),
      testId: testId,
      classId: classId,
      studentId: studentId,
      studentName: studentName,
      questionType: questionType,
      answers: answers,
      submittedAt: DateTime.now(),
    );
    await _firestore
        .collection('submissions')
        .doc(submission.id)
        .set(submission.toMap());
  }

  Stream<List<SubmissionModel>> getUserSubmissions(String userId) {
    return _firestore
        .collection('submissions')
        .where('studentId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SubmissionModel.fromMap(doc.data()))
              .toList(),
        );
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

  Future<void> synceUserInfoOnline({
    required File selectedThumbnail,
    required String languagePreference,
    required String name,
    required String phoneNumber,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      if (!selectedThumbnail.existsSync()) {
        debugPrint('File does not exist: ${selectedThumbnail.path}');
        return;
      }
      try {
        debugPrint('File path: ${selectedThumbnail.path}');
        String profileUrl;
        final taskId = const Uuid().v4();
        Reference profileRef = FirebaseStorage.instance
            .ref()
            .child('profiles')
            .child(_auth.currentUser!.uid)
            .child(taskId);

        //create upload task
        UploadTask thumbnailTask = profileRef.putFile(selectedThumbnail);
        //upload image
        TaskSnapshot thumbnailSnapshot = await thumbnailTask;
        //get image url
        profileUrl = await thumbnailSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({
              'languagePreference': languagePreference,
              'name': name,
              'phoneNumber': phoneNumber,
              'profileImageUrl': profileUrl,
            });
      } catch (e, stack) {
        debugPrint('Error uploading profile image or updating user info: $e');
        debugPrint('$stack');
      }
    }
  }
}
