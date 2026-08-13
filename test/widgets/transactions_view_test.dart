import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wafrah/core/constants/app_strings.dart';
import 'package:wafrah/data/models/category.dart';
import 'package:wafrah/data/models/product.dart';
import 'package:wafrah/data/models/transaction.dart';
import 'package:wafrah/data/repositories/interfaces/category_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/product_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/transaction_repository_interface.dart';
import 'package:wafrah/modules/transactions/transactions_controller.dart';
import 'package:wafrah/modules/transactions/transactions_view.dart';
import 'package:wafrah/widgets/skeleton_card.dart';

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

class _DelayedTransactionRepository implements ITransactionRepository {
  _DelayedTransactionRepository(this._completer);

  final Completer<List<Transaction>> _completer;

  @override
  Future<List<Transaction>> getAll() => _completer.future;

  @override
  Future<Transaction?> getById(String id) async => null;

  @override
  Future<Transaction> add(Transaction transaction) async => transaction;

  @override
  Future<void> update(Transaction transaction) async {}

  @override
  Future<void> delete(String id) async {}
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
  final bread = Product(id: 'p1', name: 'خبز', categoryId: 'c1');

  setUp(() {
    Get.reset();
  });

  Future<TransactionsController> pumpView(
    WidgetTester tester, {
    List<Transaction> transactions = const [],
    List<Category> categories = const [],
    List<Product> products = const [],
  }) async {
    final controller = TransactionsController(
      transactionRepository: FakeTransactionRepository(transactions),
      categoryRepository: FakeCategoryRepository(categories),
      productRepository: FakeProductRepository(products),
    );
    Get.put(controller);
    await tester.pumpWidget(
      GetMaterialApp(home: const TransactionsView()),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets('shows title and transaction rows after fetch', (tester) async {
    await pumpView(
      tester,
      transactions: [
        Transaction(
          id: 't1',
          type: TransactionType.expense,
          amount: 100,
          categoryId: 'c1',
          productId: 'p1',
          date: DateTime(2026, 8, 10),
        ),
        Transaction(
          id: 't2',
          type: TransactionType.income,
          amount: 500,
          categoryId: 'c2',
          date: DateTime(2026, 8, 9),
        ),
      ],
      categories: [food],
      products: [bread],
    );

    expect(find.text(AppStrings.transactionsLog), findsOneWidget);
    expect(find.text('طعام وشراب'), findsOneWidget);
    expect(find.text('+ ٥٠٠ ل.س'), findsOneWidget);
    expect(find.text('- ١٠٠ ل.س'), findsOneWidget);
  });

  testWidgets('shows skeleton while loading', (tester) async {
    final completer = Completer<List<Transaction>>();
    final controller = TransactionsController(
      transactionRepository: _DelayedTransactionRepository(completer),
      categoryRepository: FakeCategoryRepository(const []),
      productRepository: FakeProductRepository(const []),
    );
    Get.put(controller);
    await tester.pumpWidget(
      GetMaterialApp(home: const TransactionsView()),
    );
    await tester.pump();

    expect(controller.loading.value, isTrue);
    expect(find.byType(SkeletonCard), findsWidgets);

    completer.complete(const []);
    await tester.pumpAndSettle();

    expect(controller.loading.value, isFalse);
    expect(find.byType(SkeletonCard), findsNothing);
    expect(find.text(AppStrings.noTransactions), findsOneWidget);
  });

  testWidgets('shows empty state when there are no transactions',
      (tester) async {
    await pumpView(tester);

    expect(find.text(AppStrings.noTransactions), findsOneWidget);
  });

  testWidgets('shows no results state when filters match nothing',
      (tester) async {
    await pumpView(
      tester,
      transactions: [
        Transaction(
          id: 't1',
          type: TransactionType.income,
          amount: 100,
          date: DateTime(2026, 8, 10),
        ),
      ],
    );

    final controller = Get.find<TransactionsController>();
    controller.setTypeFilter(TransactionType.expense);
    await tester.pump();

    expect(find.text(AppStrings.noResults), findsOneWidget);
    expect(find.text(AppStrings.noResultsDesc), findsOneWidget);
  });
}