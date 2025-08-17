import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_prep/core/providers/current_user_notifier.dart';
import 'package:smart_prep/core/utils.dart';
import 'package:smart_prep/features/auth/model/user_info_model.dart';
import 'package:smart_prep/features/auth/model/user_model.dart';
import 'package:smart_prep/features/auth/repositories/auth_local_repository.dart';
import 'package:smart_prep/features/auth/repositories/auth_remote_repository.dart';

part 'auth_view_model.g.dart';

@riverpod
Future<UserInfoModel> getUserInfoOnline(Ref ref, String userId) async {
  final res = await ref
      .watch(authRemoteRepositoryProvider)
      .getUserInfoOnline(userId: userId);

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  AsyncValue<UserModel>? build() => null;

  AuthRemoteRepository get _authRemoteRepository =>
      ref.read(authRemoteRepositoryProvider);
  AuthLocalRepository get _authLocalRepository =>
      ref.read(authLocalRepositoryProvider);
  CurrentUserNotifier get _currentUserNotifier =>
      ref.read(currentUserNotifierProvider.notifier);

  /// Setting initial screen
  Future<void> setInitialScreen() async {
    if (await isOffline()) {
      final String? name = await _authLocalRepository.getName();
      final String? email = await _authLocalRepository.getEmail();
      debugPrint('--------- Now is offline: name $name, email: $email');

      if (name != null && email != null) {
        debugPrint(
          '--------- Now signing in offline with saved name and email',
        );
        final res = await _authLocalRepository
            .offlineSignInWithEmailAndPassword(name: name, email: email);
        switch (res) {
          case Right(value: final user):
            _currentUserNotifier.addUser(user);
            debugPrint('--------- Now added offline user to current user');
          case Left():
            break;
        }
      } else {
        debugPrint('--------- Now signing in offline anonymously');
        final res = await _authRemoteRepository.signInAnonymously();
        switch (res) {
          case Right(value: final user):
            _currentUserNotifier.addUser(user);
          case Left():
            break;
        }
      }
    } else {
      final user = FirebaseAuth.instance.currentUser;
      debugPrint('------------- current user: $user');
      if (user != null) {
        debugPrint('------------- User is not null');
        final String? name = await _authLocalRepository.getName();
        UserModel? userModel = UserModel(
          username: name ?? '',
          userDetails: user,
        );
        final docRef = FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();
        final isExist = await docRef.then((value) => value.exists);
        debugPrint('------------ user exists: ${isExist.toString()}');
        if (isExist || user.isAnonymous) {
          debugPrint('----------- in the isExists or anonymous');
          _currentUserNotifier.addUser(userModel);
        } else {
          debugPrint('----------- User is not null nor anonymous');
          await _authRemoteRepository.signingOut();
          final res = await _authRemoteRepository.signInAnonymously();
          switch (res) {
            case Right(value: final anonymousUser):
              _currentUserNotifier.addUser(anonymousUser);
            case Left():
              break;
          }
        }
      } else {
        debugPrint('------------- User is null so signing in anonymously');
        final res = await _authRemoteRepository.signInAnonymously();
        switch (res) {
          case Right(value: final user):
            _currentUserNotifier.addUser(user);
          case Left():
            break;
        }
      }
    }
  }

  Future<void> signupUser({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final res = await _authRemoteRepository.signupWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
    );
    await _authLocalRepository.setName(name);
    await _authLocalRepository.setEmail(email);
    debugPrint('Set Credentials to Local Storage.............');

    final val = switch (res) {
      Left(value: final l) => state = AsyncValue.error(
        l.message,
        StackTrace.current,
      ),
      Right(value: final r) => createUserWithEmail(r, name),
    };
    debugPrint(val.toString());
  }

  Future<void> createUserWithEmail(UserModel user, String name) async {
    final res = await _authRemoteRepository.createUserDB(user, name);

    switch (res) {
      case Right(value: final r):
        state = AsyncValue.data(r);
        final userInfo = await _authRemoteRepository.getUserInfoOnline(
          userId: r.userDetails!.uid,
        );
        switch (userInfo) {
          case Right(value: final info):
            _authLocalRepository.saveUserInfo(info);
          case Left():
            break;
        }
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
    }
  }

  Future<void> signinUser({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    if (await isOffline()) {
      final res = await _authLocalRepository.offlineSignInWithEmailAndPassword(
        name: name,
        email: email,
      );
      switch (res) {
        case Left(value: final l):
          state = AsyncValue.error(l.message, StackTrace.current);
        case Right(value: final r):
          _loginSuccess(r);
      }
    } else {
      final res = await _authRemoteRepository.signingInWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );
      await _authLocalRepository.setName(name);
      await _authLocalRepository.setEmail(email);
      debugPrint('Set Credentials to Local Storage.............');

      switch (res) {
        case Left(value: final l):
          state = AsyncValue.error(l.message, StackTrace.current);
        case Right(value: final r):
          _loginSuccess(r);
          final userInfo = await _authRemoteRepository.getUserInfoOnline(
            userId: r.userDetails!.uid,
          );
          switch (userInfo) {
            case Right(value: final info):
              _authLocalRepository.saveUserInfo(info);
            case Left():
              break;
          }
      }
    }
  }

  Future<void> convertAnonymousToEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final res = await _authRemoteRepository.convertAnonymousToEmail(
      name: name,
      email: email,
      password: password,
    );
    await _authLocalRepository.setName(name);
    await _authLocalRepository.setEmail(email);
    final val = switch (res) {
      Left(value: final l) => state = AsyncValue.error(
        l.message,
        StackTrace.current,
      ),
      Right(value: final r) => createUserWithEmail(r, name),
    };
    debugPrint(val.toString());
  }

  AsyncValue<UserModel>? _loginSuccess(UserModel user) {
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }

  UserInfoModel? getUserInfo() {
    return _authLocalRepository.getUserInfo();
  }

  void setUserInfo(UserInfoModel newInfo) {
    _authLocalRepository.saveUserInfo(newInfo);
  }

  Future<bool> signoutUser() async {
    try {
      await _authRemoteRepository.signingOut();
      await _authLocalRepository.clearAll();
      state = null;
      _currentUserNotifier.clear();
      await setInitialScreen();
      return true;
    } catch (e) {
      debugPrint('Logout failed: $e');
      return false;
    }
  }

  Future<void> refreshUserInfo() async {
    final user = ref.read(currentUserNotifierProvider);
    if (user != null && !(user.userDetails?.isAnonymous ?? true)) {
      final userInfo = await _authRemoteRepository.getUserInfoOnline(
        userId: user.userDetails!.uid,
      );
      switch (userInfo) {
        case Right(value: final info):
          _authLocalRepository.saveUserInfo(info);
        case Left():
          break;
      }
    }
  }
}
