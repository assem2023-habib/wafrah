import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wafrah/core/constants/app_strings.dart';
import 'package:wafrah/data/models/category.dart';
import 'package:wafrah/data/models/transaction.dart';
import 'package:wafrah/data/repositories/interfaces/category_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/product_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/transaction_repository_interface.dart';
import 'package:wafrah/modules/transactions/transactions_controller.dart';
import 'package:wafrah/modules/transactions/transactions_view.dart';
import 'package:wafrah/data/models/product.dart';

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
  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

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

  setUp(() {
    Get.reset();
  });

  Future<void> pumpTransactionsView(
    WidgetTester tester,
    List<Transaction> transactions,
  ) async {
    final controller = TransactionsController(
      transactionRepository: FakeTransactionRepository(transactions),
      categoryRepository: FakeCategoryRepository([food, salary]),
      productRepository: FakeProductRepository(const []),
    );
    Get.put(controller);
    await tester.pumpWidget(
      GetMaterialApp(home: const TransactionsView()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('filtering by type shows only matching transactions',
      (tester) async {
    await pumpTransactionsView(tester, [
      Transaction(
        id: 't1',
        type: TransactionType.income,
        amount: 1000,
        categoryId: 'c2',
        date: DateTime(2026, 8, 10),
      ),
      Transaction(
        id: 't2',
        type: TransactionType.expense,
        amount: 250,
        categoryId: 'c1',
        date: DateTime(2026, 8, 11),
      ),
    ]);

    expect(find.text('راتب'), findsOneWidget);
    expect(find.text('طعام وشراب'), findsOneWidget);

    await tester.tap(find.byTooltip(AppStrings.filter));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.allTypes));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.typeIncome).last);
    await tester.pumpAndSettle();

    expect(find.text('راتب'), findsOneWidget);
    expect(find.text('طعام وشراب'), findsNothing);

    await tester.tap(find.text(AppStrings.clearFilters));
    await tester.pump();

    expect(find.text('راتب'), findsOneWidget);
    expect(find.text('طعام وشراب'), findsOneWidget);
  });
}