import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2)
class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    this.categoryId,
    this.productId,
    required this.date,
    this.note,
  });

  @HiveField(6)
  final String id;

  @HiveField(0)
  final TransactionType type;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String? categoryId;

  @HiveField(3)
  final String? productId;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? note;

  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? categoryId,
    String? productId,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      productId: productId ?? this.productId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) => other is Transaction && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Transaction(id: $id, type: $type, amount: $amount, '
      'categoryId: $categoryId, productId: $productId, '
      'date: $date, note: $note)';
}

@HiveType(typeId: 11)
enum TransactionType { expense, income }