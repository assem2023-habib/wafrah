import 'package:flutter_test/flutter_test.dart';
import 'package:wafrah/data/models/category.dart';
import 'package:wafrah/data/models/product.dart';
import 'package:wafrah/data/models/transaction.dart';
import 'package:wafrah/data/repositories/interfaces/category_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/product_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/transaction_repository_interface.dart';
import 'package:wafrah/modules/transactions/transactions_controller.dart';

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
  final bread = Product(id: 'p1', name: 'خبز', categoryId: 'c1');

  TransactionsController buildController({
    List<Transaction> transactions = const [],
    List<Category> categories = const [],
    List<Product> products = const [],
  }) {
    return TransactionsController(
      transactionRepository: FakeTransactionRepository(transactions),
      categoryRepository: FakeCategoryRepository(categories),
      productRepository: FakeProductRepository(products),
    );
  }

  group('TransactionsController', () {
    test('load fills lists and applies filters', () async {
      final controller = buildController(
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
        categories: [food],
        products: [bread],
      );
      await controller.load();

      expect(controller.loading.value, isFalse);
      expect(controller.all, hasLength(1));
      expect(controller.filtered, hasLength(1));
      expect(controller.categoriesForFilter, [food]);
      expect(controller.productsForFilter, [bread]);
      expect(controller.categoryNameFor('c1'), 'طعام وشراب');
      expect(controller.productNameFor('p1'), 'خبز');
      expect(controller.categoryNameFor('missing'), isNull);
    });

    test('type filter keeps only matching transactions', () async {
      final controller = buildController(
        transactions: [
          Transaction(
            id: 't1',
            type: TransactionType.income,
            amount: 100,
            date: DateTime(2026, 8, 10),
          ),
          Transaction(
            id: 't2',
            type: TransactionType.expense,
            amount: 200,
            date: DateTime(2026, 8, 11),
          ),
        ],
      );
      await controller.load();

      controller.setTypeFilter(TransactionType.income);

      expect(controller.filtered, hasLength(1));
      expect(controller.filtered.first.id, 't1');
    });

    test('category filter keeps only matching transactions', () async {
      final controller = buildController(
        transactions: [
          Transaction(
            id: 't1',
            type: TransactionType.expense,
            amount: 100,
            categoryId: 'c1',
            date: DateTime(2026, 8, 10),
          ),
          Transaction(
            id: 't2',
            type: TransactionType.expense,
            amount: 200,
            categoryId: 'c2',
            date: DateTime(2026, 8, 11),
          ),
        ],
        categories: [food, salary],
      );
      await controller.load();

      controller.setCategoryFilter(food);

      expect(controller.filtered, hasLength(1));
      expect(controller.filtered.first.id, 't1');
    });

    test('period filter keeps only transactions in period', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final old = today.subtract(const Duration(days: 10));
      final controller = buildController(
        transactions: [
          Transaction(
            id: 't1',
            type: TransactionType.expense,
            amount: 100,
            date: today,
          ),
          Transaction(
            id: 't2',
            type: TransactionType.expense,
            amount: 200,
            date: old,
          ),
        ],
      );
      await controller.load();

      controller.setPeriodFilter(PeriodFilter.day);

      expect(controller.filtered, hasLength(1));
      expect(controller.filtered.first.id, 't1');
    });

    test('clearFilters removes all filters', () async {
      final controller = buildController(
        transactions: [
          Transaction(
            id: 't1',
            type: TransactionType.income,
            amount: 100,
            categoryId: 'c1',
            date: DateTime(2026, 8, 10),
          ),
          Transaction(
            id: 't2',
            type: TransactionType.expense,
            amount: 200,
            categoryId: 'c2',
            date: DateTime(2026, 8, 11),
          ),
        ],
        categories: [food, salary],
      );
      await controller.load();

      controller.setTypeFilter(TransactionType.income);
      controller.setCategoryFilter(salary);
      expect(controller.hasFilters, isTrue);
      expect(controller.filtered, hasLength(0));

      controller.clearFilters();

      expect(controller.hasFilters, isFalse);
      expect(controller.filtered, hasLength(2));
      expect(controller.typeFilter.value, isNull);
      expect(controller.categoryFilter.value, isNull);
    });

    test('groupedByDate groups and sorts descending', () async {
      final controller = buildController(
        transactions: [
          Transaction(
            id: 't1',
            type: TransactionType.expense,
            amount: 100,
            date: DateTime(2026, 8, 10),
          ),
          Transaction(
            id: 't2',
            type: TransactionType.expense,
            amount: 200,
            date: DateTime(2026, 8, 12),
          ),
          Transaction(
            id: 't3',
            type: TransactionType.income,
            amount: 300,
            date: DateTime(2026, 8, 10),
          ),
        ],
      );
      await controller.load();

      final groups = controller.groupedByDate;

      expect(groups, hasLength(2));
      expect(groups.first.$1, DateTime(2026, 8, 12));
      expect(groups.last.$1, DateTime(2026, 8, 10));
      expect(groups.last.$2, hasLength(2));
    });

    test('delete removes transaction and refreshes list', () async {
      final target = Transaction(
        id: 't1',
        type: TransactionType.expense,
        amount: 100,
        date: DateTime(2026, 8, 10),
      );
      final controller = buildController(
        transactions: [target],
      );
      await controller.load();

      await controller.delete(target);

      expect(controller.all, isEmpty);
      expect(controller.filtered, isEmpty);
    });
  });
}