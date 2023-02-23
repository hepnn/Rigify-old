// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RouteTypeAdapter extends TypeAdapter<RouteType> {
  @override
  final int typeId = 1;

  @override
  RouteType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RouteType()
      ..transport = fields[0] as String?
      ..number = fields[1] as String?
      ..name = fields[2] as String?
      ..type = fields[3] as String?;
  }

  @override
  void write(BinaryWriter writer, RouteType obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.transport)
      ..writeByte(1)
      ..write(obj.number)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
