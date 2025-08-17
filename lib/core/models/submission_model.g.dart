// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubmissionModelAdapter extends TypeAdapter<SubmissionModel> {
  @override
  final int typeId = 1;

  @override
  SubmissionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubmissionModel(
      id: fields[0] as String,
      testId: fields[1] as String,
      classId: fields[2] as String,
      studentId: fields[3] as String,
      studentName: fields[4] as String,
      questionType: fields[5] as String,
      answers: (fields[6] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
      submissionUrl: fields[7] as String?,
      score: fields[8] as double?,
      feedback: fields[9] as String?,
      submittedAt: fields[10] as DateTime,
      gradedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SubmissionModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.testId)
      ..writeByte(2)
      ..write(obj.classId)
      ..writeByte(3)
      ..write(obj.studentId)
      ..writeByte(4)
      ..write(obj.studentName)
      ..writeByte(5)
      ..write(obj.questionType)
      ..writeByte(6)
      ..write(obj.answers)
      ..writeByte(7)
      ..write(obj.submissionUrl)
      ..writeByte(8)
      ..write(obj.score)
      ..writeByte(9)
      ..write(obj.feedback)
      ..writeByte(10)
      ..write(obj.submittedAt)
      ..writeByte(11)
      ..write(obj.gradedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmissionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
