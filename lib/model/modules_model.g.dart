// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modules_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ModuleAdapter extends TypeAdapter<Module> {
  @override
  final int typeId = 0;

  @override
  Module read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Module(
      abbreviation: fields[0] as String,
      name: fields[1] as String,
      color: fields[7] as Color,
      creationDate: fields[10] as String,
    )
      ..teacher = fields[2] as String?
      ..semester = fields[3] as String?
      ..credits = fields[4] as String?
      ..notes = fields[5] as String?
      ..timeLearned = fields[6] as Duration
      ..goals = (fields[8] as HiveList).castHiveList()
      ..isClosed = fields[9] as bool;
  }

  @override
  void write(BinaryWriter writer, Module obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.abbreviation)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.teacher)
      ..writeByte(3)
      ..write(obj.semester)
      ..writeByte(4)
      ..write(obj.credits)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.timeLearned)
      ..writeByte(7)
      ..write(obj.color)
      ..writeByte(8)
      ..write(obj.goals)
      ..writeByte(9)
      ..write(obj.isClosed)
      ..writeByte(10)
      ..write(obj.creationDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
