// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserInfoModelAdapter extends TypeAdapter<UserInfoModel> {
  @override
  final int typeId = 0;

  @override
  UserInfoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserInfoModel(
      userId: fields[0] as String,
      accountType: fields[7] as String,
      createdAt: fields[5] as DateTime,
      lastLoginAt: fields[6] as DateTime,
      email: fields[2] as String,
      name: fields[1] as String,
      phoneNumber: fields[3] as String,
      languagePreference: fields[8] as String,
      profileImageUrl: fields[4] as String,
      points: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, UserInfoModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.profileImageUrl)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.lastLoginAt)
      ..writeByte(7)
      ..write(obj.accountType)
      ..writeByte(8)
      ..write(obj.languagePreference)
      ..writeByte(9)
      ..write(obj.points);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInfoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
