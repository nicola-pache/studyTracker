import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

/// The adapter converts the duration class to a format that can be read by
/// the Hive-Database.
class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final typeId = 2;

  @override
  void write(BinaryWriter writer, Duration value) =>
      writer.writeInt(value.inMicroseconds);

  @override
  Duration read(BinaryReader reader) =>
      Duration(microseconds: reader.readInt());
}


