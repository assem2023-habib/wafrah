// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'electricity_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ElectricitySettingsAdapter extends TypeAdapter<ElectricitySettings> {
  @override
  final int typeId = 4;

  @override
  ElectricitySettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ElectricitySettings(
      cycleMonths: fields[0] as int,
      tiers: (fields[1] as List).cast<ElectricityTier>(),
    );
  }

  @override
  void write(BinaryWriter writer, ElectricitySettings obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.cycleMonths)
      ..writeByte(1)
      ..write(obj.tiers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ElectricitySettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ElectricityTierAdapter extends TypeAdapter<ElectricityTier> {
  @override
  final int typeId = 12;

  @override
  ElectricityTier read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ElectricityTier(
      limit: fields[0] as double,
      price: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ElectricityTier obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.limit)
      ..writeByte(1)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ElectricityTierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 5;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      darkMode: fields[0] as bool,
      reduceMotion: fields[1] as bool,
      electricity: fields[2] as ElectricitySettings,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.darkMode)
      ..writeByte(1)
      ..write(obj.reduceMotion)
      ..writeByte(2)
      ..write(obj.electricity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
