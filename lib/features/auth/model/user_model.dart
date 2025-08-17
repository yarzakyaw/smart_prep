import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String username;
  final User? userDetails;

  UserModel({required this.username, this.userDetails});

  UserModel copyWith({String? username, User? userDetails}) {
    return UserModel(
      username: username ?? this.username,
      userDetails: userDetails ?? this.userDetails,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'username': username, 'userDetails': userDetails};
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      userDetails: map['userDetails'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'UserModel(username: $username, userDetails: $userDetails)';

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.username == username && other.userDetails == userDetails;
  }

  @override
  int get hashCode => username.hashCode ^ userDetails.hashCode;
}
