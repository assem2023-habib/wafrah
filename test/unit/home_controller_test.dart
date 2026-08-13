import 'package:flutter_test/flutter_test.dart';
import 'package:wafrah/data/models/category.dart';
import 'package:wafrah/data/models/transaction.dart';
import 'package:wafrah/data/repositories/interfaces/category_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/transaction_repository_interface.dart';
import 'package:wafrah/modules/home/home_controller.dart';

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

void main() {
  final food = Category(
    id: 'c1',
    name: 'طعام وشراب',
    iconCode: 'salad',
    type: CategoryType.expense,
  );

  HomeController buildController({
    List<Transaction> transactions = const [],
    List<Category> categories = const [],
  }) {
    return HomeController(
      transactionRepository: FakeTransactionRepository(transactions),
      categoryRepository: FakeCategoryRepository(categories),
    );
  }

  group('HomeController', () {
    test('load assigns transactions and builds category names', () async {
      final controller = buildController(
        transactions: [
          Transaction(
            id: 't1',
            type: TransactionType.expense,
            amount: 100,
            categoryId: 'c1',
            date: DateTime(2026, 8, 10),
          ),
        ],
        categories: [food],
      );

      await controller.load();

      expect(controller.loading.value, isFalse);
      expect(controller.transactions, hasLength(1));
      expect(controller.categoryNameFor('c1'), 'طعام وشراب');
      expect(controller.categoryNameFor('missing'), isNull);
      expect(controller.categoryNameFor(null), isNull);
    });

    test('totalIncome totalExpense and balance are computed correctly',
        () async {
      final controller = buildController(
        transactions: [
          Transaction(
            id: 't1',
            type: TransactionType.income,
            amount: 1000,
            date: DateTime(2026, 8, 10),
          ),
          Transaction(
            id: 't2',
            type: TransactionType.expense,
            amount: 250,
            date: DateTime(2026, 8, 11),
          ),
          Transaction(
            id: 't3',
            type: TransactionType.expense,
            amount: 50,
            date: DateTime(2026, 8, 12),
          ),
        ],
      );

      await controller.load();

      expect(controller.totalIncome, 1000);
      expect(controller.totalExpense, 300);
      expect(controller.balance, 700);
    });

    test('lastFive returns the five most recent transactions descending',
        () async {
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
            type: TransactionType.income,
            amount: 200,
            date: DateTime(2026, 8, 14),
          ),
          Transaction(
            id: 't3',
            type: TransactionType.expense,
            amount: 300,
            date: DateTime(2026, 8, 12),
          ),
          Transaction(
            id: 't4',
            type: TransactionType.expense,
            amount: 400,
            date: DateTime(2026, 8, 11),
          ),
          Transaction(
            id: 't5',
            type: TransactionType.income,
            amount: 500,
            date: DateTime(2026, 8, 13),
          ),
          Transaction(
            id: 't6',
            type: TransactionType.expense,
            amount: 600,
            date: DateTime(2026, 8, 9),
          ),
        ],
      );

      await controller.load();

      final ids = controller.lastFive.map((t) => t.id).toList();
      expect(ids, ['t2', 't5', 't3', 't4', 't1']);
    });

    test('empty state has zero totals and no recent transactions', () async {
      final controller = buildController();

      await controller.load();

      expect(controller.loading.value, isFalse);
      expect(controller.transactions, isEmpty);
      expect(controller.totalIncome, 0);
      expect(controller.totalExpense, 0);
      expect(controller.balance, 0);
      expect(controller.lastFive, isEmpty);
    });
  });
}