/* import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prep/services/firestore_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      debugPrint('Signed in anonymously: ${_auth.currentUser?.uid}');
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      rethrow;
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password, {
    String? name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        final firestoreService = FirestoreService();
        await firestoreService.saveUserProfile(email: email, name: name);
      }
      debugPrint('Success signing up');
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }

  Future<void> convertAnonymousToEmail(
    String email,
    String password, {
    String? name,
  }) async {
    try {
      final anonymousUser = _auth.currentUser;
      if (anonymousUser != null && anonymousUser.isAnonymous) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await anonymousUser.linkWithCredential(credential);
        await anonymousUser.updateDisplayName(name);
        final firestoreService = FirestoreService();
        await firestoreService.saveUserProfile(email: email, name: name);
        debugPrint('Success converting anonymous to email');
      }
    } catch (e) {
      debugPrint('Error converting anonymous to email: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await signInAnonymously(); // Re-sign in as anonymous after sign-out
  }
}
 */
