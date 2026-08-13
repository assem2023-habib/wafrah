import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'electricity_settings.g.dart';

@HiveType(typeId: 4)
class ElectricitySettings {
  const ElectricitySettings({required this.cycleMonths, required this.tiers});

  @HiveField(0)
  final int cycleMonths;

  @HiveField(1)
  final List<ElectricityTier> tiers;

  ElectricitySettings copyWith({
    int? cycleMonths,
    List<ElectricityTier>? tiers,
  }) {
    return ElectricitySettings(
      cycleMonths: cycleMonths ?? this.cycleMonths,
      tiers: tiers ?? this.tiers,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ElectricitySettings &&
      other.cycleMonths == cycleMonths &&
      listEquals(other.tiers, tiers);

  @override
  int get hashCode => Object.hash(cycleMonths, Object.hashAll(tiers));

  @override
  String toString() =>
      'ElectricitySettings(cycleMonths: $cycleMonths, tiers: $tiers)';
}

@HiveType(typeId: 12)
class ElectricityTier {
  const ElectricityTier({required this.limit, required this.price});

  @HiveField(0)
  final double limit;

  @HiveField(1)
  final double price;

  ElectricityTier copyWith({double? limit, double? price}) {
    return ElectricityTier(
      limit: limit ?? this.limit,
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ElectricityTier &&
      other.limit == limit &&
      other.price == price;

  @override
  int get hashCode => Object.hash(limit, price);

  @override
  String toString() => 'ElectricityTier(limit: $limit, price: $price)';
}

@HiveType(typeId: 5)
class AppSettings {
  const AppSettings({
    required this.darkMode,
    required this.reduceMotion,
    required this.electricity,
  });

  @HiveField(0)
  final bool darkMode;

  @HiveField(1)
  final bool reduceMotion;

  @HiveField(2)
  final ElectricitySettings electricity;

  AppSettings copyWith({
    bool? darkMode,
    bool? reduceMotion,
    ElectricitySettings? electricity,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      electricity: electricity ?? this.electricity,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.darkMode == darkMode &&
      other.reduceMotion == reduceMotion &&
      other.electricity == electricity;

  @override
  int get hashCode => Object.hash(darkMode, reduceMotion, electricity);

  @override
  String toString() =>
      'AppSettings(darkMode: $darkMode, reduceMotion: $reduceMotion, '
      'electricity: $electricity)';
}