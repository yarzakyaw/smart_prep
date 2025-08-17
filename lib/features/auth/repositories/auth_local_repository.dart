import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_prep/core/constants/firebase_exceptions.dart';
import 'package:smart_prep/core/failure/app_failure.dart';
import 'package:smart_prep/features/auth/model/user_info_model.dart';
import 'package:smart_prep/features/auth/model/user_model.dart';

part 'auth_local_repository.g.dart';

@riverpod
AuthLocalRepository authLocalRepository(Ref ref) {
  return AuthLocalRepository();
}

class AuthLocalRepository {
  final storage = const FlutterSecureStorage();
  final Box<UserInfoModel> userBox;

  AuthLocalRepository() : userBox = Hive.box<UserInfoModel>('user_info');

  void saveUserInfo(UserInfoModel user) {
    userBox.put('current', user);
  }

  UserInfoModel? getUserInfo() {
    return userBox.get('current');
  }

  final String _keyName = 'name';
  final String _keyEmail = 'email';

  Future setName(String name) async {
    await storage.write(key: _keyName, value: name);
  }

  Future<String?> getName() async {
    return await storage.read(key: _keyName);
  }

  Future setEmail(String email) async {
    await storage.write(key: _keyEmail, value: email);
  }

  Future<String?> getEmail() async {
    return await storage.read(key: _keyEmail);
  }

  /// [OfflineAuthentication] - SIGNIN
  Future<Either<AppFailure, UserModel>> offlineSignInWithEmailAndPassword({
    required String name,
    required String email,
  }) async {
    final String? securedName = await getName();
    final String? securedEmail = await getEmail();
    final user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null && securedName == name && securedEmail == email) {
        return Right(UserModel(username: name));
      }
      return Left(AppFailure(const FirebaseExceptions().message));
    } on FirebaseAuthException catch (e) {
      return Left(AppFailure(FirebaseExceptions.fromCode(e.code).message));
    } catch (_) {
      return Left(AppFailure(const FirebaseExceptions().message));
    }
  }

  Future<void> clearAll() async {
    await storage.deleteAll(); // FlutterSecureStorage
    await userBox.clear(); // Hive box
  }
}
