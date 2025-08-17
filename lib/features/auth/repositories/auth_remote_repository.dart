import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_prep/core/constants/firebase_exceptions.dart';
import 'package:smart_prep/core/failure/app_failure.dart';
import 'package:smart_prep/features/auth/model/user_info_model.dart';
import 'package:smart_prep/features/auth/model/user_model.dart';
import 'package:smart_prep/features/auth/repositories/auth_local_repository.dart';

part 'auth_remote_repository.g.dart';

@riverpod
AuthRemoteRepository authRemoteRepository(Ref ref) {
  return AuthRemoteRepository(ref);
}

class AuthRemoteRepository {
  final Ref ref;
  AuthRemoteRepository(this.ref);

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  /// [EmailAuthentication] - REGISTER
  Future<Either<AppFailure, UserModel>> signupWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = UserModel(username: name, userDetails: userCredential.user);
      //await sendEmailVerification();
      return Right(user);
    } on FirebaseAuthException catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Signup failed',
      );
      return Left(AppFailure(FirebaseExceptions.fromCode(e.code).message));
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Unexpected signup error',
      );
      return Left(AppFailure(const FirebaseExceptions().message));
    }
  }

  /// [EmailVerification] - EMAIL VERIFICATION
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AppFailure(FirebaseExceptions.fromCode(e.code).message);
    } catch (e) {
      throw AppFailure('Unexpected error: $e');
    }
  }

  Future<Either<AppFailure, UserModel>> createUserDB(
    UserModel user,
    String name,
  ) async {
    try {
      final userInfo = UserInfoModel(
        userId: user.userDetails!.uid,
        accountType: 'user',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        email: user.userDetails!.email ?? '',
        name: name,
        phoneNumber: user.userDetails!.phoneNumber ?? '',
        languagePreference: 'en',
        points: 0,
        profileImageUrl: '',
      );
      await _db
          .collection("users")
          .doc(user.userDetails!.uid)
          .set(userInfo.toMap(), SetOptions(merge: true));
      return Right(user);
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Failed to create user in Firestore',
      );
      return Left(AppFailure(e.toString()));
    }
  }

  /// [EmailAuthentication] - SIGNIN
  Future<Either<AppFailure, UserModel>> signingInWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential currentUserCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      final user = UserModel(
        username: name,
        userDetails: currentUserCredential.user,
      );
      return Right(user);
    } on FirebaseAuthException catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Sign-in failed',
      );
      return Left(AppFailure(FirebaseExceptions.fromCode(e.code).message));
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Unexpected sign-in error',
      );
      return Left(AppFailure(const FirebaseExceptions().message));
    }
  }

  Future<Either<AppFailure, UserModel>> signInAnonymously() async {
    debugPrint('----------- in the remote repo signinanonymously');
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      final user = UserModel(
        username: 'Anonymous',
        userDetails: userCredential.user,
      );
      // save user info first time when log in anonymously
      final authLocal = ref.read(authLocalRepositoryProvider);

      final userInfo = UserInfoModel(
        userId: user.userDetails!.uid,
        accountType: 'user',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        email: '',
        name: user.username,
        phoneNumber: '',
        languagePreference: 'en',
        profileImageUrl: '',
      );

      authLocal.saveUserInfo(userInfo);
      debugPrint('Set Anonymous Credentials to Hive Storage.............');
      await authLocal.setName(user.username);
      await authLocal.setEmail('');
      debugPrint('Set Anonymous Credentials to Local Storage.............');
      return Right(user);
    } on FirebaseAuthException catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Anonymous sign-in failed',
      );
      return Left(AppFailure(FirebaseExceptions.fromCode(e.code).message));
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Unexpected anonymous sign-in error',
      );
      return Left(AppFailure(const FirebaseExceptions().message));
    }
  }

  Future<Either<AppFailure, UserModel>> convertAnonymousToEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final anonymousUser = _auth.currentUser;
      if (anonymousUser != null && anonymousUser.isAnonymous) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        final userCredential = await anonymousUser.linkWithCredential(
          credential,
        );
        final user = UserModel(
          username: name,
          userDetails: userCredential.user,
        );
        return Right(user);
      }
      return Left(AppFailure('No anonymous user to convert'));
    } on FirebaseAuthException catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Anonymous conversion failed',
      );
      return Left(AppFailure(FirebaseExceptions.fromCode(e.code).message));
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Unexpected anonymous conversion error',
      );
      return Left(AppFailure(const FirebaseExceptions().message));
    }
  }

  // [LogoutUser] - Valid for any authentication.
  Future<void> signingOut() async {
    try {
      _auth.signOut();
    } on FirebaseAuthException catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Sign-out failed',
      );
      throw AppFailure(FirebaseExceptions.fromCode(e.code).message);
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Unexpected sign-out error',
      );
      throw AppFailure(const FirebaseExceptions().message);
    }
  }

  Future<Either<AppFailure, UserInfoModel>> getUserInfoOnline({
    required String userId,
  }) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return Left(AppFailure('User not found'));
      }
      final userInfo = UserInfoModel.fromMap(
        userDoc.data() as Map<String, dynamic>,
      );
      return Right(userInfo);
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        reason: 'Failed to fetch user info',
      );
      return Left(AppFailure(e.toString()));
    }
  }
}
