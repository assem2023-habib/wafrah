import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:wafrah/core/constants/app_strings.dart';
import 'package:wafrah/data/models/category.dart';
import 'package:wafrah/data/models/product.dart';
import 'package:wafrah/data/models/transaction.dart';
import 'package:wafrah/data/repositories/interfaces/category_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/product_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/transaction_repository_interface.dart';
import 'package:wafrah/modules/categories/categories_controller.dart';
import 'package:wafrah/modules/categories/categories_view.dart';

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
  setUp(() {
    Get.reset();
  });

  testWidgets('shows categories after fetch', (tester) async {
    final controller = CategoriesController(
      categoryRepository: FakeCategoryRepository([
        Category(
          id: 'c1',
          name: 'طعام وشراب',
          iconCode: 'salad',
          type: CategoryType.expense,
        ),
        Category(
          id: 'c2',
          name: 'راتب',
          iconCode: 'wallet',
          type: CategoryType.income,
        ),
      ]),
      transactionRepository: FakeTransactionRepository(const []),
      productRepository: FakeProductRepository(const []),
    );
    Get.put(controller);
    await tester.pumpWidget(
      GetMaterialApp(home: const CategoriesView()),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.manageCategories), findsOneWidget);
    expect(find.text('طعام وشراب'), findsOneWidget);
    expect(find.text('راتب'), findsOneWidget);
    expect(find.text(AppStrings.typeExpense), findsOneWidget);
    expect(find.text(AppStrings.typeIncome), findsOneWidget);
  });

  testWidgets('shows empty state when there are no categories', (tester) async {
    final controller = CategoriesController(
      categoryRepository: FakeCategoryRepository(const []),
      transactionRepository: FakeTransactionRepository(const []),
      productRepository: FakeProductRepository(const []),
    );
    Get.put(controller);
    await tester.pumpWidget(
      GetMaterialApp(home: const CategoriesView()),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noCategories), findsOneWidget);
    expect(find.text(AppStrings.noCategoriesDesc), findsOneWidget);
  });

  testWidgets('add button opens the form', (tester) async {
    final controller = CategoriesController(
      categoryRepository: FakeCategoryRepository(const []),
      transactionRepository: FakeTransactionRepository(const []),
      productRepository: FakeProductRepository(const []),
    );
    Get.put(controller);
    await tester.pumpWidget(
      GetMaterialApp(home: const CategoriesView()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(AppStrings.addCategory));
    await tester.pump();

    expect(find.text(AppStrings.name), findsOneWidget);
    expect(find.text(AppStrings.type), findsOneWidget);
    expect(find.text(AppStrings.save), findsOneWidget);
    expect(find.text(AppStrings.cancel), findsOneWidget);
  });
}