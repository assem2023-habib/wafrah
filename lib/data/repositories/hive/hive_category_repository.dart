import 'package:hive/hive.dart';

import '../../models/category.dart';
import '../interfaces/category_repository_interface.dart';

class HiveCategoryRepository implements ICategoryRepository {
  Box<Category> get _box => Hive.box<Category>('categories');

  @override
  Future<List<Category>> getAll() async => _box.values.toList();

  @override
  Future<Category?> getById(String id) async {
    for (final key in _box.keys) {
      final category = _box.get(key);
      if (category != null && category.id == id) return category;
    }
    return null;
  }

  @override
  Future<Category> add(Category category) async {
    await _box.add(category);
    return category;
  }

  @override
  Future<void> update(Category category) async {
    for (final key in _box.keys) {
      final existing = _box.get(key);
      if (existing != null && existing.id == category.id) {
        await _box.put(key, category);
        return;
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    for (final key in _box.keys) {
      final existing = _box.get(key);
      if (existing != null && existing.id == id) {
        await _box.delete(key);
        return;
      }
    }
  }
}