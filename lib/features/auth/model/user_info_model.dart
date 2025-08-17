import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'user_info_model.g.dart';

@HiveType(typeId: 0)
class UserInfoModel {
  @HiveField(0)
  final String userId;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String phoneNumber;
  @HiveField(4)
  final String profileImageUrl;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final DateTime lastLoginAt;
  @HiveField(7)
  final String accountType;
  @HiveField(8)
  final String languagePreference;
  @HiveField(9)
  final double points;

  UserInfoModel({
    required this.userId,
    required this.accountType,
    required this.createdAt,
    required this.lastLoginAt,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.languagePreference,
    required this.profileImageUrl,
    this.points = 0.0,
  });

  UserInfoModel copyWith({
    String? userId,
    String? accountType,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? email,
    String? name,
    String? phoneNumber,
    String? languagePreference,
    String? profileImageUrl,
    double? points,
  }) {
    return UserInfoModel(
      userId: userId ?? this.userId,
      accountType: accountType ?? this.accountType,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      languagePreference: languagePreference ?? this.languagePreference,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'accountType': accountType,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt.millisecondsSinceEpoch,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'languagePreference': languagePreference,
      'profileImageUrl': profileImageUrl,
      'points': points,
    };
  }

  factory UserInfoModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value is String) {
        return DateTime.parse(value);
      }
      throw Exception('Invalid date format');
    }

    return UserInfoModel(
      userId: map['userId'] ?? '',
      accountType: map['accountType'] ?? '',
      createdAt: parseDate(map['createdAt']),
      lastLoginAt: parseDate(map['lastLoginAt']),
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      languagePreference: map['languagePreference'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      points: map['points']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserInfoModel.fromJson(String source) =>
      UserInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserInfoModel(userId: $userId, accountType: $accountType, createdAt: $createdAt, lastLoginAt: $lastLoginAt, email: $email, name: $name, phoneNumber: $phoneNumber, languagePreference: $languagePreference, profileImageUrl: $profileImageUrl, points: $points)';
  }

  @override
  bool operator ==(covariant UserInfoModel other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.accountType == accountType &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt &&
        other.email == email &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.languagePreference == languagePreference &&
        other.profileImageUrl == profileImageUrl &&
        other.points == points;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        accountType.hashCode ^
        createdAt.hashCode ^
        lastLoginAt.hashCode ^
        email.hashCode ^
        name.hashCode ^
        phoneNumber.hashCode ^
        languagePreference.hashCode ^
        profileImageUrl.hashCode ^
        points.hashCode;
  }
}
