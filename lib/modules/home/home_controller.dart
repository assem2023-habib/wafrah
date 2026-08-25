import 'package:get/get.dart';

import '../../data/models/transaction.dart';
import '../../data/repositories/interfaces/category_repository_interface.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';

class HomeController extends GetxController {
  HomeController({
    required ITransactionRepository transactionRepository,
    required ICategoryRepository categoryRepository,
  })  : _transactionRepository = transactionRepository,
        _categoryRepository = categoryRepository;

  final ITransactionRepository _transactionRepository;
  final ICategoryRepository _categoryRepository;

  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxBool loading = true.obs;
  final RxString error = ''.obs;

  final Map<String, String> _categoryNames = {};

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      loading.value = true;
    }
    try {
      final items = await _transactionRepository.getAll();
      transactions.assignAll(items);
      final categoryIds =
          items.map((t) => t.categoryId).whereType<String>().toSet();
      for (final id in categoryIds) {
        if (_categoryNames.containsKey(id)) {
          continue;
        }
        final category = await _categoryRepository.getById(id);
        if (category != null) {
          _categoryNames[id] = category.name;
        }
      }
    } catch (_) {
      error.value = 'تعذر تحميل البيانات، حاول مجددًا';
    } finally {
      loading.value = false;
    }
  }

  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  List<Transaction> get lastFive {
    final sorted = [...transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  String? categoryNameFor(String? id) => id == null ? null : _categoryNames[id];

  void clearError() {
    if (error.isNotEmpty) {
      error.value = '';
    }
  }
}
