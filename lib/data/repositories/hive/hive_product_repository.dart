import 'package:hive/hive.dart';

import '../../models/product.dart';
import '../interfaces/product_repository_interface.dart';

class HiveProductRepository implements IProductRepository {
  Box<Product> get _box => Hive.box<Product>('products');

  @override
  Future<List<Product>> getAll() async => _box.values.toList();

  @override
  Future<List<Product>> getByCategory(String categoryId) async =>
      _box.values.where((product) => product.categoryId == categoryId).toList();

  @override
  Future<Product> add(Product product) async {
    await _box.add(product);
    return product;
  }

  @override
  Future<void> update(Product product) async {
    for (final key in _box.keys) {
      final existing = _box.get(key);
      if (existing != null && existing.id == product.id) {
        await _box.put(key, product);
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