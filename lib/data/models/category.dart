import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 0)
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.type,
  });

  @HiveField(3)
  final String id;

  @HiveField(0)
  final String name;

  @HiveField(1)
  final String iconCode;

  @HiveField(2)
  final CategoryType type;

  Category copyWith({
    String? id,
    String? name,
    String? iconCode,
    CategoryType? type,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) => other is Category && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Category(id: $id, name: $name, iconCode: $iconCode, type: $type)';
}

@HiveType(typeId: 10)
enum CategoryType { expense, income, both }