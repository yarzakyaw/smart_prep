import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_prep/features/localization/app_localizations.dart';
import 'package:uuid/uuid.dart';

String? validatePassword(BuildContext context, dynamic value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }

  String pattern =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value)) {
    return 'Password must be at least 8 characters long, '
        'contain at least one uppercase letter, one lowercase letter, '
        'one number, and one special character.';
  }
  return null;
}

Future<String> uploadImageToStorage({required XFile imageFile}) async {
  try {
    Reference imageRef = FirebaseStorage.instance
        .ref()
        .child('images')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(const Uuid().v4());
    //create upload task
    UploadTask imageTask = imageRef.putFile(File(imageFile.path));
    //upload image
    TaskSnapshot imageSnapshot = await imageTask;
    //get image url
    String imageUrl = await imageSnapshot.ref.getDownloadURL();
    return imageUrl;
  } catch (e) {
    return '';
  }
}

Future<bool> isOffline() async {
  final List<ConnectivityResult> connectivityResult = await Connectivity()
      .checkConnectivity();
  return connectivityResult.contains(ConnectivityResult.none);
}

String translate(BuildContext context, String key) {
  return AppLocalizations.of(context).translate(key);
}
