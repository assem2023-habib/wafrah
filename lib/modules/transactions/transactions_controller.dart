import 'package:get/get.dart';

import '../../data/models/category.dart';
import '../../data/models/product.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/interfaces/category_repository_interface.dart';
import '../../data/repositories/interfaces/product_repository_interface.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';

enum PeriodFilter { day, week, month }

class TransactionsController extends GetxController {
  TransactionsController({
    required ITransactionRepository transactionRepository,
    required ICategoryRepository categoryRepository,
    required IProductRepository productRepository,
  })  : _transactionRepository = transactionRepository,
        _categoryRepository = categoryRepository,
        _productRepository = productRepository;

  final ITransactionRepository _transactionRepository;
  final ICategoryRepository _categoryRepository;
  final IProductRepository _productRepository;

  final RxBool loading = true.obs;
  final RxList<Transaction> all = <Transaction>[].obs;
  final RxList<Transaction> filtered = <Transaction>[].obs;
  final Rx<TransactionType?> typeFilter = Rx<TransactionType?>(null);
  final Rx<Category?> categoryFilter = Rx<Category?>(null);
  final Rx<Product?> productFilter = Rx<Product?>(null);
  final Rx<PeriodFilter?> periodFilter = Rx<PeriodFilter?>(null);
  final RxString searchQuery = RxString('');

  final RxList<Category> _categories = <Category>[].obs;
  final RxList<Product> _products = <Product>[].obs;
  final Map<String, Category> _categoryCache = {};
  final Map<String, Product> _productCache = {};

  List<Category> get categoriesForFilter => _categories;

  List<Product> get productsForFilter => _products;

  bool get hasFilters =>
      typeFilter.value != null ||
      categoryFilter.value != null ||
      productFilter.value != null ||
      periodFilter.value != null ||
      searchQuery.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      loading.value = true;
    }
    final transactions = await _transactionRepository.getAll();
    final categories = await _categoryRepository.getAll();
    final products = await _productRepository.getAll();
    all.assignAll(transactions);
    _categories.assignAll(categories);
    _products.assignAll(products);
    _categoryCache
      ..clear()
      ..addEntries(categories.map((c) => MapEntry(c.id, c)));
    _productCache
      ..clear()
      ..addEntries(products.map((p) => MapEntry(p.id, p)));
    loading.value = false;
    applyFilters();
  }

  void setTypeFilter(TransactionType? value) {
    typeFilter.value = value;
    applyFilters();
  }

  void setCategoryFilter(Category? value) {
    categoryFilter.value = value;
    applyFilters();
  }

  void setProductFilter(Product? value) {
    productFilter.value = value;
    applyFilters();
  }

  void setPeriodFilter(PeriodFilter? value) {
    periodFilter.value = value;
    applyFilters();
  }

  void applyFilters() {
    final type = typeFilter.value;
    final category = categoryFilter.value;
    final product = productFilter.value;
    final period = periodFilter.value;
    final query = searchQuery.value.trim();

    final result = all.where((tx) {
      if (type != null && tx.type != type) return false;
      if (category != null && tx.categoryId != category.id) return false;
      if (product != null && tx.productId != product.id) return false;
      if (period != null && !_inPeriod(tx.date, period)) return false;
      if (query.isNotEmpty && !_matchesQuery(tx, query)) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    filtered.assignAll(result);
  }

  bool _matchesQuery(Transaction tx, String query) {
    final categoryName = _categoryCache[tx.categoryId]?.name ?? '';
    final productName = _productCache[tx.productId]?.name ?? '';
    final note = tx.note ?? '';
    return categoryName.contains(query) ||
        productName.contains(query) ||
        note.contains(query);
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
    applyFilters();
  }

  bool _inPeriod(DateTime date, PeriodFilter period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    switch (period) {
      case PeriodFilter.day:
        return day.isAfter(today.subtract(const Duration(days: 1)));
      case PeriodFilter.week:
        return day.isAfter(today.subtract(const Duration(days: 7)));
      case PeriodFilter.month:
        return day.year == today.year && day.month == today.month;
    }
  }

  void clearFilters() {
    typeFilter.value = null;
    categoryFilter.value = null;
    productFilter.value = null;
    periodFilter.value = null;
    searchQuery.value = '';
    applyFilters();
  }

  List<(DateTime, List<Transaction>)> get groupedByDate {
    final grouped = <DateTime, List<Transaction>>{};
    for (final transaction in filtered) {
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      grouped.putIfAbsent(day, () => []).add(transaction);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return [for (final entry in entries) (entry.key, entry.value)];
  }

  String? categoryNameFor(String? id) => _categoryCache[id]?.name;

  String? productNameFor(String? id) => _productCache[id]?.name;

  Future<void> delete(Transaction transaction) async {
    await _transactionRepository.delete(transaction.id);
    all.removeWhere((t) => t.id == transaction.id);
    applyFilters();
  }
}