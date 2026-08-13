import '../../models/product.dart';

abstract class IProductRepository {
  Future<List<Product>> getAll();

  Future<List<Product>> getByCategory(String categoryId);

  Future<Product> add(Product product);

  Future<void> update(Product product);

  Future<void> delete(String id);
}