import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wafrah/core/constants/app_strings.dart';
import 'package:wafrah/data/models/category.dart';
import 'package:wafrah/data/models/product.dart';
import 'package:wafrah/data/models/transaction.dart';
import 'package:wafrah/data/repositories/interfaces/category_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/product_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/transaction_repository_interface.dart';
import 'package:wafrah/modules/add_expense/add_expense_controller.dart';
import 'package:wafrah/routes/app_routes.dart';

class FakeTransactionRepository implements ITransactionRepository {
  FakeTransactionRepository([List<Transaction>? items]) : _items = items ?? [];

  final List<Transaction> _items;
  bool added = false;
  Transaction? lastAdded;

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
    added = true;
    lastAdded = transaction;
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

  AddExpenseController buildController(
    FakeTransactionRepository txRepo, {
    List<Category> categories = const [],
    List<Product> products = const [],
  }) {
    final controller = AddExpenseController(
      categoryRepository: FakeCategoryRepository(categories),
      productRepository: FakeProductRepository(products),
      transactionRepository: txRepo,
    );
    Get.put(controller);
    return controller;
  }

  group('AddExpenseController', () {
    test('save without category sets category error and does not add',
        () async {
      final txRepo = FakeTransactionRepository();
      final controller = buildController(txRepo, categories: [food]);
      controller.amountCtrl.text = '100';

      await controller.save();

      expect(controller.error.value, AppStrings.categoryRequired);
      expect(controller.saving.value, isFalse);
      expect(txRepo.added, isFalse);
    });

    test('save with non-positive amount sets amount error and does not add',
        () async {
      final txRepo = FakeTransactionRepository();
      final controller = buildController(txRepo, categories: [food]);
      controller.amountCtrl.text = '-50';
      controller.selectCategory(food);

      await controller.save();

      expect(controller.error.value, AppStrings.amountPositive);
      expect(controller.saving.value, isFalse);
      expect(txRepo.added, isFalse);
    });

    test('save with arabic digits and no category still validates amount',
        () async {
      final txRepo = FakeTransactionRepository();
      final controller = buildController(txRepo, categories: [food]);
      controller.amountCtrl.text = '١٬٠٠٠';

      await controller.save();

      expect(controller.error.value, AppStrings.categoryRequired);
      expect(txRepo.added, isFalse);
    });

    testWidgets('successful save adds an expense transaction',
        (tester) async {
      final txRepo = FakeTransactionRepository();
      final controller = buildController(txRepo, categories: [food]);
      await tester.pumpWidget(
        GetMaterialApp(
          home: const SizedBox(),
          getPages: [
            GetPage(name: AppRoutes.home, page: () => const SizedBox()),
          ],
        ),
      );
      controller.amountCtrl.text = '1000';
      controller.selectCategory(food);
      controller.save();
      await tester.pump();

      expect(txRepo.added, isTrue);
      expect(txRepo.lastAdded!.type, TransactionType.expense);
      expect(txRepo.lastAdded!.amount, 1000);
      expect(txRepo.lastAdded!.categoryId, 'c1');
      expect(find.text(AppStrings.savedSuccess), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();
    });
  });
}