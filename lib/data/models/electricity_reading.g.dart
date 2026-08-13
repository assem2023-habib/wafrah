// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'electricity_reading.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ElectricityReadingAdapter extends TypeAdapter<ElectricityReading> {
  @override
  final int typeId = 3;

  @override
  ElectricityReading read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ElectricityReading(
      id: fields[4] as String,
      fromDate: fields[0] as DateTime,
      toDate: fields[1] as DateTime?,
      kwhValue: fields[2] as double,
      note: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ElectricityReading obj) {
    writer
      ..writeByte(5)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(0)
      ..write(obj.fromDate)
      ..writeByte(1)
      ..write(obj.toDate)
      ..writeByte(2)
      ..write(obj.kwhValue)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ElectricityReadingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
