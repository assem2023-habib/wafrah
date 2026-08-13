import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

import 'models/category.dart';
import 'models/electricity_reading.dart';
import 'models/electricity_settings.dart';
import 'models/product.dart';
import 'models/transaction.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
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
  }

  static Future<void> seedIfNeeded() async {
    final categoriesBox = await Hive.openBox<Category>('categories');
    if (categoriesBox.isEmpty) {
      final categoryIds = <String, String>{};
      for (final seed in _seedCategories) {
        final id = newId;
        categoryIds[seed.$1] = id;
        await categoriesBox.add(Category(
          id: id,
          name: seed.$1,
          iconCode: seed.$2,
          type: seed.$3,
        ));
      }
      final productsBox = await Hive.openBox<Product>('products');
      if (productsBox.isEmpty) {
        for (final seed in _seedProducts) {
          await productsBox.add(Product(
            id: newId,
            name: seed.$1,
            categoryId: categoryIds[seed.$2]!,
          ));
        }
      }
    }
  }
}

String get newId =>
    DateTime.now().microsecondsSinceEpoch.toString() +
    Random().nextInt(9999).toString();

const _seedCategories = <(String, String, CategoryType)>[
  ('طعام وشراب', 'salad', CategoryType.expense),
  ('مواصلات', 'car', CategoryType.expense),
  ('صحة وأدوية', 'medical_cross', CategoryType.expense),
  ('منزل', 'home', CategoryType.expense),
  ('كهرباء', 'bolt', CategoryType.expense),
  ('تسوق', 'shopping_bag', CategoryType.expense),
  ('ترفيه', 'movie', CategoryType.expense),
  ('أخرى', 'package', CategoryType.expense),
  ('راتب', 'wallet', CategoryType.income),
  ('تقاعد', 'building_bank', CategoryType.income),
  ('هدية', 'gift', CategoryType.income),
  ('دخل آخر', 'coin', CategoryType.income),
];

const _seedProducts = <(String, String)>[
  ('خبز', 'طعام وشراب'),
  ('لحم', 'طعام وشراب'),
  ('خضروات', 'طعام وشراب'),
  ('دجاج', 'طعام وشراب'),
  ('أدوية مزمنة', 'صحة وأدوية'),
  ('كشف طبي', 'صحة وأدوية'),
];