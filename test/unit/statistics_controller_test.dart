import 'package:flutter_test/flutter_test.dart';
import 'package:wafrah/data/models/category.dart';
import 'package:wafrah/data/models/transaction.dart';
import 'package:wafrah/data/repositories/interfaces/category_repository_interface.dart';
import 'package:wafrah/data/repositories/interfaces/transaction_repository_interface.dart';
import 'package:wafrah/modules/statistics/statistics_controller.dart';

class FakeCategoryRepository implements ICategoryRepository {
  FakeCategoryRepository(this._items);
  final List<Category> _items;
  @override
  Future<List<Category>> getAll() async => List.of(_items);
  @override
  Future<Category?> getById(String id) async {
    for (final item in _items) { if (item.id == id) return item; }
    return null;
  }
  @override
  Future<Category> add(Category c) async { _items.add(c); return c; }
  @override
  Future<void> update(Category c) async {
    final i = _items.indexWhere((x) => x.id == c.id);
    if (i != -1) _items[i] = c;
  }
  @override
  Future<void> delete(String id) async => _items.removeWhere((c) => c.id == id);
}

class FakeTransactionRepository implements ITransactionRepository {
  FakeTransactionRepository(this._items);
  final List<Transaction> _items;
  @override
  Future<List<Transaction>> getAll() async => List.of(_items);
  @override
  Future<Transaction?> getById(String id) async {
    for (final item in _items) { if (item.id == id) return item; }
    return null;
  }
  @override
  Future<Transaction> add(Transaction t) async { _items.add(t); return t; }
  @override
  Future<void> update(Transaction t) async {
    final i = _items.indexWhere((x) => x.id == t.id);
    if (i != -1) _items[i] = t;
  }
  @override
  Future<void> delete(String id) async => _items.removeWhere((t) => t.id == id);
}

DateTime ago(int months) {
  final now = DateTime.now();
  return DateTime(now.year, now.month - months, 15);
}

void main() {
  StatisticsController build({
    List<Category> categories = const [],
    List<Transaction> txs = const [],
  }) {
    return StatisticsController(
      transactionRepository: FakeTransactionRepository(List.of(txs)),
      categoryRepository: FakeCategoryRepository(List.of(categories)),
    );
  }

  final food = Category(id: 'c1', name: 'طعام', iconCode: 'salad', type: CategoryType.expense);
  final car = Category(id: 'c2', name: 'مواصلات', iconCode: 'car', type: CategoryType.expense);
  final salary = Category(id: 'c3', name: 'راتب', iconCode: 'wallet', type: CategoryType.income);

  test('inPeriod keeps only window', () async {
    final controller = build(
      txs: [
        Transaction(id: 't1', type: TransactionType.expense, amount: 100, categoryId: 'c1', date: ago(0)),
        Transaction(id: 't2', type: TransactionType.expense, amount: 200, categoryId: 'c1', date: ago(10)),
      ],
    );
    await controller.load();
    controller.setPeriod(1);
    expect(controller.inPeriod, hasLength(1));
    expect(controller.inPeriod.first.id, 't1');
  });

  test('totals and expense-by-category sorted', () async {
    final controller = build(
      categories: [food, car, salary],
      txs: [
        Transaction(id: 't1', type: TransactionType.expense, amount: 100, categoryId: 'c1', date: ago(0)),
        Transaction(id: 't2', type: TransactionType.expense, amount: 300, categoryId: 'c2', date: ago(0)),
        Transaction(id: 't3', type: TransactionType.expense, amount: 50, categoryId: 'c1', date: ago(0)),
        Transaction(id: 't4', type: TransactionType.income, amount: 1000, categoryId: 'c3', date: ago(0)),
      ],
    );
    await controller.load();
    controller.setPeriod(1);
    expect(controller.totalIncome, 1000);
    expect(controller.totalExpense, 450);
    expect(controller.expenseByCategory.first.category?.id, 'c2');
    expect(controller.expenseByCategory.first.value, 300);
  });

  test('monthly buckets group by month', () async {
    final now = DateTime.now();
    final controller = build(
      txs: [
        Transaction(id: 't1', type: TransactionType.income, amount: 500, date: DateTime(now.year, now.month, 5)),
        Transaction(id: 't2', type: TransactionType.expense, amount: 200, date: DateTime(now.year, now.month, 6)),
        Transaction(id: 't3', type: TransactionType.income, amount: 300, date: DateTime(now.year, now.month - 1, 10)),
      ],
    );
    await controller.load();
    controller.setPeriod(3);
    expect(controller.monthlyBuckets.length, greaterThanOrEqualTo(2));
    final current = controller.monthlyBuckets.last;
    expect(current.income, 500);
    expect(current.expense, 200);
  });
}
