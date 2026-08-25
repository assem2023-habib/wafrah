import 'package:get/get.dart';

import '../../data/models/transaction.dart';
import '../../data/repositories/interfaces/category_repository_interface.dart';
import '../../data/repositories/interfaces/product_repository_interface.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';
import '../../routes/app_routes.dart';

class TransactionDetailController extends GetxController {
  TransactionDetailController({
    required ITransactionRepository transactionRepository,
    required ICategoryRepository categoryRepository,
    required IProductRepository productRepository,
  })  : _transactionRepository = transactionRepository,
        _categoryRepository = categoryRepository,
        _productRepository = productRepository;

  final ITransactionRepository _transactionRepository;
  final ICategoryRepository _categoryRepository;
  final IProductRepository _productRepository;

  final Rx<Transaction?> transaction = Rx<Transaction?>(null);
  final RxString categoryName = ''.obs;
  final RxString productName = ''.obs;
  final RxBool confirmDelete = false.obs;

  String? _id;

  @override
  void onInit() {
    super.onInit();
    _id = Get.arguments as String?;
    if (_id != null) {
      load(_id!);
    }
  }

  void reloadCurrent() {
    if (_id != null) {
      load(_id!);
    }
  }

  Future<void> load(String id) async {
    final tx = await _transactionRepository.getById(id);
    transaction.value = tx;
    if (tx == null) {
      return;
    }
    if (tx.categoryId != null) {
      final category = await _categoryRepository.getById(tx.categoryId!);
      categoryName.value = category?.name ?? '';
    } else {
      categoryName.value = '';
    }
    if (tx.productId != null) {
      final products = await _productRepository.getAll();
      for (final product in products) {
        if (product.id == tx.productId) {
          productName.value = product.name;
          break;
        }
      }
    } else {
      productName.value = '';
    }
  }

  void toggleConfirmDelete() {
    confirmDelete.value = !confirmDelete.value;
  }

  Future<void> delete() async {
    final tx = transaction.value;
    if (tx == null) {
      return;
    }
    await _transactionRepository.delete(tx.id);
    Get.back();
  }

  void edit() {
    final tx = transaction.value;
    if (tx == null) {
      return;
    }
    final route = tx.type == TransactionType.income
        ? AppRoutes.addIncome
        : AppRoutes.addExpense;
    Get.toNamed(route, arguments: tx.id);
  }
}