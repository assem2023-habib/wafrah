import '../../models/category.dart';

abstract class ICategoryRepository {
  Future<List<Category>> getAll();

  Future<Category?> getById(String id);

  Future<Category> add(Category category);

  Future<void> update(Category category);

  Future<void> delete(String id);
}