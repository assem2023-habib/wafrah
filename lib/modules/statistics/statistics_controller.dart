import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/category.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/interfaces/category_repository_interface.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';

class CategoryShare {
  CategoryShare({required this.category, required this.value});

  final Category? category;
  final double value;
}

class MonthlyBucket {
  MonthlyBucket({
    required this.month,
    required this.income,
    required this.expense,
  });

  final DateTime month;
  double income;
  double expense;

  String get label => DateFormat('MMM', 'ar').format(month);
}

class StatisticsController extends GetxController {
  StatisticsController({
    required ITransactionRepository transactionRepository,
    required ICategoryRepository categoryRepository,
  })  : _transactionRepository = transactionRepository,
        _categoryRepository = categoryRepository;

  final ITransactionRepository _transactionRepository;
  final ICategoryRepository _categoryRepository;

  final RxBool loading = true.obs;
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxInt periodMonths = 1.obs;

  final Map<String, Category> _categoryCache = {};

  static const List<int> periodOptions = [1, 3, 6, 12];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final items = await _transactionRepository.getAll();
      final categories = await _categoryRepository.getAll();
      transactions.assignAll(items);
      _categoryCache
        ..clear()
        ..addEntries(categories.map((c) => MapEntry(c.id, c)));
    } finally {
      loading.value = false;
    }
  }

  void setPeriod(int months) {
    if (periodOptions.contains(months)) {
      periodMonths.value = months;
    }
  }

  DateTime get _windowStart {
    final now = DateTime.now();
    return DateTime(now.year, now.month - (periodMonths.value - 1));
  }

  bool _inWindow(DateTime date) => !date.isBefore(_windowStart);

  List<Transaction> get inPeriod => transactions
      .where((t) => _inWindow(t.date))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  double get totalIncome => inPeriod
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => inPeriod
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  List<CategoryShare> get expenseByCategory {
    final totals = <String, double>{};
    for (final t in inPeriod) {
      if (t.type != TransactionType.expense || t.categoryId == null) {
        continue;
      }
      totals[t.categoryId!] = (totals[t.categoryId!] ?? 0) + t.amount;
    }
    final shares = totals.entries
        .map(
          (e) => CategoryShare(
            category: _categoryCache[e.key],
            value: e.value,
          ),
        )
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return shares;
  }

  List<MonthlyBucket> get monthlyBuckets {
    final buckets = <DateTime, MonthlyBucket>{};
    for (final t in inPeriod) {
      final month = DateTime(t.date.year, t.date.month);
      final bucket = buckets.putIfAbsent(
        month,
        () => MonthlyBucket(month: month, income: 0, expense: 0),
      );
      if (t.type == TransactionType.income) {
        bucket.income += t.amount;
      } else {
        bucket.expense += t.amount;
      }
    }
    final list = buckets.values.toList()
      ..sort((a, b) => a.month.compareTo(b.month));
    return list;
  }

  String categoryNameFor(String? id) =>
      id == null ? '' : (_categoryCache[id]?.name ?? '');
}
