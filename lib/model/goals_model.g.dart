// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 1;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      name: fields[0] as String,
      color: fields[7] as Color,
      creationDate: fields[10] as String,
    )
      ..estimatedTime = fields[1] as Duration?
      ..deadline = fields[2] as DateTime?
      ..reminder = fields[3] as String?
      ..module = fields[4] as String
      ..notes = fields[5] as String?
      ..timeLearned = fields[6] as Duration
      ..isCompleted = fields[8] as bool
      ..isArchived = fields[9] as bool;
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.estimatedTime)
      ..writeByte(2)
      ..write(obj.deadline)
      ..writeByte(3)
      ..write(obj.reminder)
      ..writeByte(4)
      ..write(obj.module)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.timeLearned)
      ..writeByte(7)
      ..write(obj.color)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.isArchived)
      ..writeByte(10)
      ..write(obj.creationDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
