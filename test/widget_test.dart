import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:wafrah/data/models/category.dart';
import 'package:wafrah/data/models/electricity_reading.dart';
import 'package:wafrah/data/models/electricity_settings.dart';
import 'package:wafrah/data/models/product.dart';
import 'package:wafrah/data/models/transaction.dart';
import 'package:wafrah/data/repositories/repository_bindings.dart';
import 'package:wafrah/main.dart';

void main() {
  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync('wafrah_smoke_test');
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

  testWidgets('App renders smoke test', (WidgetTester tester) async {
    RepositoryBindings.init();
    await tester.pumpWidget(
      const WafrahApp(initialThemeMode: ThemeMode.system),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('وِفرة'), findsOneWidget);
  });
}