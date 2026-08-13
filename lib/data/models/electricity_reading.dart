import 'package:hive/hive.dart';

part 'electricity_reading.g.dart';

@HiveType(typeId: 3)
class ElectricityReading {
  const ElectricityReading({
    required this.id,
    required this.fromDate,
    this.toDate,
    required this.kwhValue,
    this.note,
  });

  @HiveField(4)
  final String id;

  @HiveField(0)
  final DateTime fromDate;

  @HiveField(1)
  final DateTime? toDate;

  @HiveField(2)
  final double kwhValue;

  @HiveField(3)
  final String? note;

  ElectricityReading copyWith({
    String? id,
    DateTime? fromDate,
    DateTime? toDate,
    double? kwhValue,
    String? note,
  }) {
    return ElectricityReading(
      id: id ?? this.id,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      kwhValue: kwhValue ?? this.kwhValue,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ElectricityReading &&
      other.id == id &&
      other.fromDate == fromDate &&
      other.toDate == toDate &&
      other.kwhValue == kwhValue &&
      other.note == note;

  @override
  int get hashCode => Object.hash(id, fromDate, toDate, kwhValue, note);

  @override
  String toString() =>
      'ElectricityReading(id: $id, fromDate: $fromDate, toDate: $toDate, '
      'kwhValue: $kwhValue, note: $note)';
}