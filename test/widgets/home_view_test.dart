import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wafrah/core/constants/app_strings.dart';
import 'package:wafrah/data/models/category.dart';
import 'package:wafrah/data/models/transaction.dart';
import 'package:wafrah/data/repositories/interfaces/category_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/transaction_repository_interface.dart';
import 'package:wafrah/modules/home/home_controller.dart';
import 'package:wafrah/modules/home/home_view.dart';

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
  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  final food = Category(
    id: 'c1',
    name: 'طعام وشراب',
    iconCode: 'salad',
    type: CategoryType.expense,
  );

  setUp(() {
    Get.reset();
  });

  Future<HomeController> pumpHome(
    WidgetTester tester, {
    List<Transaction> transactions = const [],
    List<Category> categories = const [],
  }) async {
    final controller = HomeController(
      transactionRepository: FakeTransactionRepository(transactions),
      categoryRepository: FakeCategoryRepository(categories),
    );
    Get.put(controller);
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('ar'),
        home: const HomeView(),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets('shows balance and recent transactions when data exists',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await pumpHome(
      tester,
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
          categoryId: 'c1',
          date: DateTime(2026, 8, 9),
        ),
        Transaction(
          id: 't3',
          type: TransactionType.expense,
          amount: 100,
          date: DateTime(2026, 8, 8),
        ),
      ],
      categories: [food],
    );

    expect(find.text(AppStrings.balance), findsOneWidget);
    expect(find.text(AppStrings.recentTransactions), findsOneWidget);
    expect(find.text('طعام وشراب'), findsOneWidget);
  });

  testWidgets('shows empty state when there are no transactions',
      (tester) async {
    await pumpHome(tester);

    expect(find.text(AppStrings.welcomeEmptyTitle), findsOneWidget);
    expect(find.text(AppStrings.balance), findsNothing);
  });
}