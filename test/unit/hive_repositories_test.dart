import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:wafrah/data/hive_service.dart';
import 'package:wafrah/data/models/category.dart'
    show Category, CategoryType, CategoryAdapter, CategoryTypeAdapter;
import 'package:wafrah/data/models/electricity_reading.dart'
    show ElectricityReading, ElectricityReadingAdapter;
import 'package:wafrah/data/models/electricity_settings.dart'
    show
        AppSettings,
        ElectricitySettings,
        ElectricityTier,
        AppSettingsAdapter,
        ElectricitySettingsAdapter,
        ElectricityTierAdapter;
import 'package:wafrah/data/models/product.dart'
    show Product, ProductAdapter;
import 'package:wafrah/data/models/transaction.dart'
    show Transaction, TransactionType, TransactionAdapter, TransactionTypeAdapter;
import 'package:wafrah/data/repositories/hive/hive_category_repository.dart';
import 'package:wafrah/data/repositories/hive/hive_electricity_repository.dart';
import 'package:wafrah/data/repositories/hive/hive_product_repository.dart';
import 'package:wafrah/data/repositories/hive/hive_transaction_repository.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(CategoryTypeAdapter());
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(ElectricityReadingAdapter());
    Hive.registerAdapter(ElectricitySettingsAdapter());
    Hive.registerAdapter(ElectricityTierAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    await Hive.openBox<Category>('categories');
    await Hive.openBox<Product>('products');
    await Hive.openBox<Transaction>('transactions');
    await Hive.openBox<ElectricityReading>('electricityReadings');
    await Hive.openBox<AppSettings>('appSettings');
  });

  setUp(() async {
    await Hive.box<Category>('categories').clear();
    await Hive.box<Product>('products').clear();
    await Hive.box<Transaction>('transactions').clear();
    await Hive.box<ElectricityReading>('electricityReadings').clear();
    await Hive.box<AppSettings>('appSettings').clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await Hive.deleteFromDisk();
  });

  group('HiveCategoryRepository', () {
    final repository = HiveCategoryRepository();

    test('adds, reads, updates and deletes categories', () async {
      await repository.add(Category(
        id: 'c1',
        name: 'طعام وشراب',
        iconCode: 'salad',
        type: CategoryType.expense,
      ));
      await repository.add(Category(
        id: 'c2',
        name: 'راتب',
        iconCode: 'wallet',
        type: CategoryType.income,
      ));

      final all = await repository.getAll();
      expect(all, hasLength(2));

      final found = await repository.getById('c1');
      expect(found, isNotNull);
      expect(found!.name, 'طعام وشراب');
      expect(found.type, CategoryType.expense);

      await repository.update(Category(
        id: 'c1',
        name: 'مطاعم',
        iconCode: 'salad',
        type: CategoryType.expense,
      ));
      final updated = await repository.getById('c1');
      expect(updated!.name, 'مطاعم');

      await repository.delete('c1');
      expect(await repository.getAll(), hasLength(1));
      expect(await repository.getById('c1'), isNull);
      expect(await repository.getById('c2'), isNotNull);
    });
  });

  group('HiveProductRepository', () {
    final repository = HiveProductRepository();

    test('adds products and filters by category', () async {
      await repository.add(Product(id: 'p1', name: 'خبز', categoryId: 'food'));
      await repository.add(Product(id: 'p2', name: 'لحم', categoryId: 'food'));
      await repository.add(
        Product(id: 'p3', name: 'أدوية مزمنة', categoryId: 'health'),
      );

      expect(await repository.getAll(), hasLength(3));

      final foodProducts = await repository.getByCategory('food');
      expect(foodProducts, hasLength(2));
      expect(foodProducts.map((product) => product.name),
          containsAll(['خبز', 'لحم']));

      await repository.delete('p2');
      expect(await repository.getByCategory('food'), hasLength(1));
    });
  });

  group('HiveTransactionRepository', () {
    final repository = HiveTransactionRepository();

    test('adds, reads, updates and deletes transactions', () async {
      await repository.add(Transaction(
        id: 't1',
        type: TransactionType.expense,
        amount: 150.5,
        categoryId: 'c1',
        date: DateTime(2026, 1, 15),
        note: 'بقالة',
      ));
      await repository.add(Transaction(
        id: 't2',
        type: TransactionType.income,
        amount: 5000,
        categoryId: 'c2',
        date: DateTime(2026, 2, 1),
      ));

      expect(await repository.getAll(), hasLength(2));

      final found = await repository.getById('t1');
      expect(found, isNotNull);
      expect(found!.amount, 150.5);
      expect(found.type, TransactionType.expense);

      await repository.update(found.copyWith(amount: 200, note: 'سوبر ماركت'));
      final updated = await repository.getById('t1');
      expect(updated!.amount, 200);
      expect(updated.note, 'سوبر ماركت');

      await repository.delete('t2');
      expect(await repository.getAll(), hasLength(1));
      expect(await repository.getById('t2'), isNull);
    });
  });

  group('HiveElectricityRepository', () {
    final repository = HiveElectricityRepository();

    test('adds, reads and deletes readings', () async {
      await repository.addReading(ElectricityReading(
        id: 'r1',
        fromDate: DateTime(2026, 1, 1),
        toDate: DateTime(2026, 1, 31),
        kwhValue: 123.5,
        note: 'قراءة يناير',
      ));

      expect(await repository.getAllReadings(), hasLength(1));

      final found = await repository.getReadingById('r1');
      expect(found, isNotNull);
      expect(found!.kwhValue, 123.5);
      expect(found.fromDate, DateTime(2026, 1, 1));

      await repository.deleteReading('r1');
      expect(await repository.getAllReadings(), isEmpty);
      expect(await repository.getReadingById('r1'), isNull);
    });

    test('creates and persists default app settings when box is empty',
        () async {
      final settings = await repository.getAppSettings();
      expect(settings.darkMode, isFalse);
      expect(settings.reduceMotion, isFalse);
      expect(settings.electricity.cycleMonths, 2);
      expect(settings.electricity.tiers, hasLength(1));
      expect(settings.electricity.tiers.first.limit, 300);
      expect(settings.electricity.tiers.first.price, 600);

      final stored = Hive.box<AppSettings>('appSettings').values.first;
      expect(stored.darkMode, isFalse);
    });

    test('updates app settings', () async {
      await repository.updateAppSettings(const AppSettings(
        darkMode: true,
        reduceMotion: true,
        electricity: ElectricitySettings(
          cycleMonths: 3,
          tiers: [ElectricityTier(limit: 500, price: 800)],
        ),
      ));

      final settings = await repository.getAppSettings();
      expect(settings.darkMode, isTrue);
      expect(settings.reduceMotion, isTrue);
      expect(settings.electricity.cycleMonths, 3);
      expect(settings.electricity.tiers.first.limit, 500);
    });

    test('updates electricity settings without touching the rest', () async {
      await repository.updateElectricitySettings(const ElectricitySettings(
        cycleMonths: 4,
        tiers: [ElectricityTier(limit: 600, price: 900)],
      ));

      final electricity = await repository.getElectricitySettings();
      expect(electricity.cycleMonths, 4);
      expect(electricity.tiers.first.price, 900);

      final settings = await repository.getAppSettings();
      expect(settings.darkMode, isFalse);
      expect(settings.reduceMotion, isFalse);
    });
  });

  group('HiveService', () {
    test('seedIfNeeded seeds 12 categories and 6 products', () async {
      await HiveService.seedIfNeeded();

      final categories = Hive.box<Category>('categories');
      final products = Hive.box<Product>('products');
      expect(categories.length, 12);
      expect(products.length, 6);

      final food =
          categories.values.firstWhere((category) => category.name == 'طعام وشراب');
      final bread = products.values.firstWhere((product) => product.name == 'خبز');
      expect(bread.categoryId, food.id);

      final health = categories.values
          .firstWhere((category) => category.name == 'صحة وأدوية');
      expect(
        products.values.any(
          (product) =>
              product.name == 'كشف طبي' && product.categoryId == health.id,
        ),
        isTrue,
      );
    });

    test('seedIfNeeded is idempotent', () async {
      await HiveService.seedIfNeeded();
      await HiveService.seedIfNeeded();

      expect(Hive.box<Category>('categories').length, 12);
      expect(Hive.box<Product>('products').length, 6);
    });
  });
}