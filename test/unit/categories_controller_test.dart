import 'package:flutter_test/flutter_test.dart';
import 'package:wafrah/core/constants/app_strings.dart';
import 'package:wafrah/data/models/category.dart';
import 'package:wafrah/data/models/transaction.dart';
import 'package:wafrah/data/repositories/interfaces/category_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/transaction_repository_interface.dart';
import 'package:wafrah/modules/categories/categories_controller.dart';

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
  CategoriesController buildController({
    List<Category> categories = const [],
    List<Transaction> transactions = const [],
  }) {
    return CategoriesController(
      categoryRepository: FakeCategoryRepository(List.of(categories)),
      transactionRepository: FakeTransactionRepository(List.of(transactions)),
    );
  }

  group('CategoriesController', () {
    test('save adds a new category', () async {
      final controller = buildController();
      await controller.load();

      controller.startAdd();
      controller.nameCtrl.text = 'سفر';
      controller.iconCode.value = 'car';
      controller.type.value = CategoryType.expense;
      await controller.save();

      expect(controller.categories, hasLength(1));
      final created = controller.categories.first;
      expect(created.name, 'سفر');
      expect(created.iconCode, 'car');
      expect(created.type, CategoryType.expense);
      expect(created.id, isNotEmpty);
      expect(controller.showForm, isFalse);
    });

    test('save requires a name', () async {
      final controller = buildController();
      await controller.load();

      controller.startAdd();
      controller.nameCtrl.text = '   ';
      await controller.save();

      expect(controller.nameError.value, AppStrings.nameRequired);
      expect(controller.categories, isEmpty);
      expect(controller.showForm, isTrue);
    });

    test('save updates an existing category', () async {
      final existing = Category(
        id: 'c1',
        name: 'طعام',
        iconCode: 'salad',
        type: CategoryType.expense,
      );
      final controller = buildController(categories: [existing]);
      await controller.load();

      controller.startEdit(existing);
      controller.nameCtrl.text = 'طعام وشراب';
      controller.iconCode.value = 'shopping_bag';
      controller.type.value = CategoryType.both;
      await controller.save();

      expect(controller.categories, hasLength(1));
      expect(controller.categories.first.name, 'طعام وشراب');
      expect(controller.categories.first.iconCode, 'shopping_bag');
      expect(controller.categories.first.type, CategoryType.both);
      expect(controller.showForm, isFalse);
    });

    test('cancelEdit clears the form', () async {
      final controller = buildController();
      await controller.load();

      controller.startAdd();
      controller.nameCtrl.text = 'سفر';
      controller.cancelEdit();

      expect(controller.showForm, isFalse);
      expect(controller.nameCtrl.text, isEmpty);
      expect(controller.nameError.value, isEmpty);
    });

    test('delete is blocked when category has transactions', () async {
      final category = Category(
        id: 'c1',
        name: 'طعام',
        iconCode: 'salad',
        type: CategoryType.expense,
      );
      final controller = buildController(
        categories: [category],
        transactions: [
          Transaction(
            id: 't1',
            type: TransactionType.expense,
            amount: 100,
            categoryId: 'c1',
            date: DateTime(2026, 8, 10),
          ),
        ],
      );
      await controller.load();

      await controller.delete(category);

      expect(controller.refsError.value, AppStrings.deleteBlocked);
      expect(controller.categories, hasLength(1));
    });

    test('delete removes category when unused', () async {
      final category = Category(
        id: 'c1',
        name: 'طعام',
        iconCode: 'salad',
        type: CategoryType.expense,
      );
      final controller = buildController(categories: [category]);
      await controller.load();

      await controller.delete(category);

      expect(controller.refsError.value, isEmpty);
      expect(controller.categories, isEmpty);
    });

    test('iconFor returns the matching icon or fallback', () {
      final controller = buildController();
      expect(controller.iconFor('salad'), isNotNull);
      expect(controller.iconFor('unknown_code'), controller.iconFor('package'));
      expect(CategoriesController.iconOptions, hasLength(12));
    });
  });
}