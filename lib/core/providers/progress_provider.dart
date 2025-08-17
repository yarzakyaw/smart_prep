import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prep/core/models/question.dart';
import 'package:smart_prep/core/providers/quiz_provider.dart';
import 'package:smart_prep/features/home/repositories/home_remote_repository.dart';

class ProgressEntry {
  final int? id; // Added for database
  final String? firestoreId; // For Firestore
  final String mode;
  final String? subject; // Added subject
  final int score;
  final int totalQuestions;
  final Map<int, String> incorrectAnswers; // questionId -> userAnswer
  final DateTime timestamp; // Added timestamp

  ProgressEntry({
    this.id,
    this.firestoreId,
    required this.mode,
    this.subject,
    required this.score,
    required this.totalQuestions,
    required this.incorrectAnswers,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mode': mode,
      'subject': subject,
      'score': score,
      'total_questions': totalQuestions,
      'incorrect_answers': jsonEncode(
        incorrectAnswers.map((key, value) => MapEntry(key.toString(), value)),
      ),
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ProgressEntry.fromMap(Map<String, dynamic> map) {
    return ProgressEntry(
      id: map['id'],
      mode: map['mode'] ?? '',
      subject: map['subject'],
      score: map['score'] ?? 0,
      totalQuestions: map['total_questions'] ?? 0,
      incorrectAnswers: Map<int, String>.fromEntries(
        (jsonDecode(map['incorrect_answers'] ?? '{}') as Map).entries.map(
          (e) => MapEntry(int.parse(e.key), e.value as String),
        ),
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestoreMap(String userId) {
    return {
      'userId': userId,
      'mode': mode,
      'subject': subject,
      'score': score,
      'totalQuestions': totalQuestions,
      'incorrectAnswers': incorrectAnswers.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ProgressEntry.fromFirestoreMap(
    Map<String, dynamic> map,
    String firestoreId,
  ) {
    return ProgressEntry(
      firestoreId: firestoreId,
      mode: map['mode'] ?? '',
      subject: map['subject'],
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      incorrectAnswers: Map<int, String>.fromEntries(
        (map['incorrectAnswers'] as Map<String, dynamic>? ?? {}).entries.map(
          (e) => MapEntry(int.parse(e.key), e.value as String),
        ),
      ),
      /* incorrectAnswers: Map<int, String>.fromEntries(
        (map['incorrectAnswers'] ?? {}).entries.map(
          (e) => MapEntry(int.parse(e.key), e.value as String),
        ),
      ), */
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class ProgressNotifier extends StateNotifier<List<ProgressEntry>> {
  // ProgressNotifier() : super([]);

  final Ref ref;

  ProgressNotifier(this.ref) : super([]) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final dbService = ref.read(databaseServiceProvider);
    final firestoreService = ref.read(homeRemoteRepositoryProvider);
    // final authState = ref.read(authStateProvider).value;
    final authState = FirebaseAuth.instance.currentUser;

    // Load local progress
    // final progressMaps = await dbService.getProgress();
    final localProgress = await dbService.getProgress();
    final localEntries = localProgress
        .map((map) => ProgressEntry.fromMap(map))
        .toList();
    // debugPrint('------------ LocalProgressEntries: ${localEntries.length}');

    // Load Firestore progress for registered users
    List<ProgressEntry> firestoreEntries = [];
    if (authState != null && !authState.isAnonymous) {
      final firestoreProgress = await firestoreService.getProgress();
      firestoreEntries = firestoreProgress.map((map) {
        final firestoreId = map['id'] as String;
        return ProgressEntry.fromFirestoreMap(map, firestoreId);
      }).toList();
      // debugPrint('------------ FirestoreEntries: ${firestoreEntries.length}');
      /* firestoreEntries = firestoreProgress
          .asMap()
          .entries
          .map(
            (entry) => ProgressEntry.fromFirestoreMap(
              entry.value,
              entry.value['id'] ?? entry.key.toString(),
            ),
          )
          .toList(); */
      /* firestoreEntries = firestoreProgress
          .map((map) => ProgressEntry.fromFirestoreMap(map))
          .toList(); */
    }

    // Combine and deduplicate (based on timestamp and mode)
    final allEntries = [...localEntries, ...firestoreEntries];
    // debugPrint('------------ AllEntries ${allEntries.length}');
    final uniqueEntries = <String, ProgressEntry>{};
    for (var entry in allEntries) {
      final key =
          '${entry.timestamp.millisecondsSinceEpoch}_${entry.mode}_${entry.subject ?? 'all'}';
      uniqueEntries[key] = entry;
    }
    state = uniqueEntries.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    // state = progressMaps.map((map) => ProgressEntry.fromMap(map)).toList();

    // Auto-sync if internet is available
    if (authState != null && !authState.isAnonymous) {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (!connectivityResult.contains(ConnectivityResult.none)) {
        await syncLocalProgressToFirestore(authState.uid);
      }
    }
  }

  Future<void> addProgress(
    String mode,
    int score,
    int totalQuestions,
    Map<int, String> userAnswers,
    List<Question> questions, {
    String? subject,
  }) async {
    final incorrectAnswers = <int, String>{};
    for (var question in questions) {
      final userAnswer = userAnswers[question.id] ?? '';
      if (userAnswer.trim().toLowerCase() !=
          question.correctAnswer.trim().toLowerCase()) {
        incorrectAnswers[question.id] = userAnswer;
      }
    }
    final entry = ProgressEntry(
      mode: mode,
      subject: subject,
      score: score,
      totalQuestions: totalQuestions,
      incorrectAnswers: incorrectAnswers,
      timestamp: DateTime.now(),
    );

    final dbService = ref.read(databaseServiceProvider);
    final firestoreService = ref.read(homeRemoteRepositoryProvider);
    // final authState = ref.read(authStateProvider).value;
    final authState = FirebaseAuth.instance.currentUser;

    // Save to Firestore for registered users
    if (authState != null && !authState.isAnonymous) {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (!connectivityResult.contains(ConnectivityResult.none)) {
        await firestoreService.saveProgress(
          mode: mode,
          subject: subject,
          score: score,
          totalQuestions: totalQuestions,
          incorrectAnswers: incorrectAnswers,
          timestamp: entry.timestamp,
        );
      } else {
        // Save to SQLite
        await dbService.insertProgress(entry.toMap());
      }
    }

    // state = [...state, entry];
    state = [...state, entry]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> syncLocalProgressToFirestore(String userId) async {
    final dbService = ref.read(databaseServiceProvider);
    final firestoreService = ref.read(homeRemoteRepositoryProvider);
    final localProgress = await dbService.getProgress();
    for (var map in localProgress) {
      final entry = ProgressEntry.fromMap(map);
      await firestoreService.saveProgress(
        mode: entry.mode,
        subject: entry.subject,
        score: entry.score,
        totalQuestions: entry.totalQuestions,
        incorrectAnswers: entry.incorrectAnswers,
        timestamp: entry.timestamp,
      );
    }
    await dbService.clearProgress(); // Clear local progress after syncing
    await _loadProgress(); // Reload combined progress
  }

  /* state = [
      ...state,
      ProgressEntry(
        mode: mode,
        subject: subject,
        score: score,
        totalQuestions: totalQuestions,
        incorrectAnswers: incorrectAnswers,
        timestamp: DateTime.now(), // Add current timestamp
      ),
    ]; */

  Future<void> clearProgress() async {
    final dbService = ref.read(databaseServiceProvider);
    final firestoreService = ref.read(homeRemoteRepositoryProvider);
    // final authState = ref.read(authStateProvider).value;
    final authState = FirebaseAuth.instance.currentUser;

    // Clear local progress
    await dbService.clearProgress();

    // Clear Firestore progress for registered users
    if (authState != null && !authState.isAnonymous) {
      final progress = await firestoreService.getProgress();
      for (var doc in progress) {
        await FirebaseFirestore.instance
            .collection('progress')
            .doc(doc['id'])
            .delete();
      }
    }

    state = [];
  }

  /* Future<void> clearProgress() async {
    final dbService = ref.read(databaseServiceProvider);
    await dbService.clearProgress();
    state = [];
  } */

  /* void clearProgress() {
    state = [];
  } */
}

final progressProvider =
    StateNotifierProvider<ProgressNotifier, List<ProgressEntry>>(
      (ref) => ProgressNotifier(ref),
    );
