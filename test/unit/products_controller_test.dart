import 'package:flutter_test/flutter_test.dart';
import 'package:wafrah/core/constants/app_strings.dart';
import 'package:wafrah/data/models/category.dart';
import 'package:wafrah/data/models/product.dart';
import 'package:wafrah/data/models/transaction.dart';
import 'package:wafrah/data/repositories/interfaces/category_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/product_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/transaction_repository_interface.dart';
import 'package:wafrah/modules/products/products_controller.dart';

class FakeProductRepository implements IProductRepository {
  FakeProductRepository(this._items);

  final List<Product> _items;

  @override
  Future<List<Product>> getAll() async => List.of(_items);

  @override
  Future<List<Product>> getByCategory(String categoryId) async =>
      _items.where((p) => p.categoryId == categoryId).toList();

  @override
  Future<Product> add(Product product) async {
    _items.add(product);
    return product;
  }

  @override
  Future<void> update(Product product) async {
    final index = _items.indexWhere((p) => p.id == product.id);
    if (index != -1) _items[index] = product;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((p) => p.id == id);
  }
}

class FakeCategoryRepository implements ICategoryRepository {
  FakeCategoryRepository(this._items);

  final List<Category> _items;

  @override
  Future<List<Category>> getAll() async => List.of(_items);

  @override
  Future<Category?> getById(String id) async {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<Category> add(Category category) async {
    _items.add(category);
    return category;
  }

  @override
  Future<void> update(Category category) async {
    final index = _items.indexWhere((c) => c.id == category.id);
    if (index != -1) _items[index] = category;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((c) => c.id == id);
  }
}

class FakeTransactionRepository implements ITransactionRepository {
  FakeTransactionRepository(this._items);

  final List<Transaction> _items;

  @override
  Future<List<Transaction>> getAll() async => List.of(_items);

  @override
  Future<Transaction?> getById(String id) async {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<Transaction> add(Transaction transaction) async {
    _items.add(transaction);
    return transaction;
  }

  @override
  Future<void> update(Transaction transaction) async {
    final index = _items.indexWhere((t) => t.id == transaction.id);
    if (index != -1) _items[index] = transaction;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((t) => t.id == id);
  }
}

void main() {
  final food = Category(
    id: 'c1',
    name: 'طعام وشراب',
    iconCode: 'salad',
    type: CategoryType.expense,
  );
  final salary = Category(
    id: 'c2',
    name: 'راتب',
    iconCode: 'wallet',
    type: CategoryType.income,
  );

  ProductsController buildController({
    List<Product> products = const [],
    List<Category> categories = const [],
    List<Transaction> transactions = const [],
  }) {
    return ProductsController(
      productRepository: FakeProductRepository(List.of(products)),
      categoryRepository: FakeCategoryRepository(List.of(categories)),
      transactionRepository: FakeTransactionRepository(List.of(transactions)),
    );
  }

  group('ProductsController', () {
    test('save requires a category', () async {
      final controller = buildController(categories: [food]);
      await controller.load();

      controller.startAdd();
      controller.nameCtrl.text = 'خبز';
      await controller.save();

      expect(controller.categoryError.value, AppStrings.categoryRequired);
      expect(controller.products, isEmpty);
      expect(controller.showForm, isTrue);
    });

    test('save adds a new product with a category', () async {
      final controller = buildController(categories: [food, salary]);
      await controller.load();

      controller.startAdd();
      controller.nameCtrl.text = 'خبز';
      controller.selectedCategory.value = food;
      await controller.save();

      expect(controller.products, hasLength(1));
      expect(controller.products.first.name, 'خبز');
      expect(controller.products.first.categoryId, 'c1');
      expect(controller.showForm, isFalse);
    });

    test('save updates an existing product', () async {
      final existing = Product(id: 'p1', name: 'خبز', categoryId: 'c1');
      final controller = buildController(
        products: [existing],
        categories: [food],
      );
      await controller.load();

      controller.startEdit(existing);
      controller.nameCtrl.text = 'خبز عربي';
      await controller.save();

      expect(controller.products, hasLength(1));
      expect(controller.products.first.name, 'خبز عربي');
    });

    test('save requires a name', () async {
      final controller = buildController(categories: [food]);
      await controller.load();

      controller.startAdd();
      await controller.save();

      expect(controller.nameError.value, AppStrings.nameRequired);
      expect(controller.products, isEmpty);
    });

    test('categoryOptions contains only expense and both types', () async {
      final both = Category(
        id: 'c3',
        name: 'إيرادات متفرقة',
        iconCode: 'coin',
        type: CategoryType.both,
      );
      final controller = buildController(categories: [food, salary, both]);
      await controller.load();

      expect(controller.categoryOptions, [food, both]);
    });

    test('groups products by category', () async {
      final controller = buildController(
        products: [
          Product(id: 'p1', name: 'خبز', categoryId: 'c1'),
          Product(id: 'p2', name: 'لحم', categoryId: 'c1'),
        ],
        categories: [food],
      );
      await controller.load();

      final groups = controller.groups;

      expect(groups, hasLength(1));
      expect(groups.first.$1, food);
      expect(groups.first.$2, hasLength(2));
    });

    test('delete is blocked when product has transactions', () async {
      final product = Product(id: 'p1', name: 'خبز', categoryId: 'c1');
      final controller = buildController(
        products: [product],
        categories: [food],
        transactions: [
          Transaction(
            id: 't1',
            type: TransactionType.expense,
            amount: 100,
            categoryId: 'c1',
            productId: 'p1',
            date: DateTime(2026, 8, 10),
          ),
        ],
      );
      await controller.load();

      await controller.delete(product);

      expect(controller.refsError.value, AppStrings.deleteBlocked);
      expect(controller.products, hasLength(1));
    });

    test('delete removes product when unused', () async {
      final product = Product(id: 'p1', name: 'خبز', categoryId: 'c1');
      final controller = buildController(
        products: [product],
        categories: [food],
      );
      await controller.load();

      await controller.delete(product);

      expect(controller.refsError.value, isEmpty);
      expect(controller.products, isEmpty);
    });
  });
}