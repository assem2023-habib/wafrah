import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 1)
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
  });

  @HiveField(2)
  final String id;

  @HiveField(0)
  final String name;

  @HiveField(1)
  final String categoryId;

  Product copyWith({String? id, String? name, String? categoryId}) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Product &&
      other.id == id &&
      other.name == name &&
      other.categoryId == categoryId;

  @override
  int get hashCode => Object.hash(id, name, categoryId);

  @override
  String toString() =>
      'Product(id: $id, name: $name, categoryId: $categoryId)';
}