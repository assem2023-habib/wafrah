import 'package:flutter_test/flutter_test.dart';
import 'package:wafrah/data/models/category.dart';
import 'package:wafrah/data/models/electricity_settings.dart';
import 'package:wafrah/data/models/transaction.dart';

void main() {
  group('Category', () {
    test('equals returns true for the same id', () {
      final first = Category(
        id: 'c1',
        name: 'طعام وشراب',
        iconCode: 'salad',
        type: CategoryType.expense,
      );
      final second = Category(
        id: 'c1',
        name: 'مواصلات',
        iconCode: 'car',
        type: CategoryType.income,
      );
      expect(first, equals(second));
      expect(first.hashCode, second.hashCode);
    });

    test('equals returns false for different ids', () {
      final first = Category(
        id: 'c1',
        name: 'طعام وشراب',
        iconCode: 'salad',
        type: CategoryType.expense,
      );
      final second = Category(
        id: 'c2',
        name: 'طعام وشراب',
        iconCode: 'salad',
        type: CategoryType.expense,
      );
      expect(first, isNot(equals(second)));
    });
  });

  group('Transaction', () {
    test('copyWith changes only the provided fields', () {
      final transaction = Transaction(
        id: 't1',
        type: TransactionType.expense,
        amount: 100,
        categoryId: 'c1',
        date: DateTime(2026, 1, 1),
      );
      final updated = transaction.copyWith(amount: 250, note: 'فواتير');
      expect(updated.amount, 250);
      expect(updated.note, 'فواتير');
      expect(updated.id, 't1');
      expect(updated.type, TransactionType.expense);
      expect(updated.categoryId, 'c1');
      expect(updated.date, DateTime(2026, 1, 1));
    });

    test('equals returns true for the same id', () {
      final first = Transaction(
        id: 't1',
        type: TransactionType.expense,
        amount: 100,
        date: DateTime(2026, 1, 1),
      );
      final second = Transaction(
        id: 't1',
        type: TransactionType.income,
        amount: 999,
        date: DateTime(2026, 2, 2),
      );
      expect(first, equals(second));
    });
  });

  group('ElectricitySettings', () {
    test('copyWith changes tiers and cycleMonths', () {
      const settings = ElectricitySettings(
        cycleMonths: 2,
        tiers: [ElectricityTier(limit: 300, price: 600)],
      );
      final updated = settings.copyWith(
        cycleMonths: 3,
        tiers: [
          ElectricityTier(limit: 400, price: 700),
          ElectricityTier(limit: 600, price: 900),
        ],
      );
      expect(updated.cycleMonths, 3);
      expect(updated.tiers, hasLength(2));
      expect(updated.tiers.first.limit, 400);
      expect(updated.tiers.first.price, 700);
      expect(updated.tiers.last.limit, 600);
      expect(updated.tiers.last.price, 900);
    });

    test('equals compares tiers with listEquals', () {
      const first = ElectricitySettings(
        cycleMonths: 3,
        tiers: [ElectricityTier(limit: 400, price: 700)],
      );
      const second = ElectricitySettings(
        cycleMonths: 3,
        tiers: [ElectricityTier(limit: 400, price: 700)],
      );
      expect(first, equals(second));
    });
  });

  group('Enums', () {
    test('CategoryType has the expected values in order', () {
      expect(CategoryType.values, [
        CategoryType.expense,
        CategoryType.income,
        CategoryType.both,
      ]);
      expect(CategoryType.expense.index, 0);
      expect(CategoryType.income.index, 1);
      expect(CategoryType.both.index, 2);
    });

    test('TransactionType has the expected values in order', () {
      expect(TransactionType.values, [
        TransactionType.expense,
        TransactionType.income,
      ]);
      expect(TransactionType.expense.index, 0);
      expect(TransactionType.income.index, 1);
    });
  });
}