import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/number_formatter.dart';
import '../../core/utils/validators.dart';
import '../../data/models/category.dart';
import '../../data/models/product.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/interfaces/category_repository_interface.dart';
import '../../data/repositories/interfaces/product_repository_interface.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';
import '../../routes/app_routes.dart';
import '../../widgets/success_screen.dart';

class AddExpenseController extends GetxController {
  AddExpenseController({
    required ICategoryRepository categoryRepository,
    required IProductRepository productRepository,
    required ITransactionRepository transactionRepository,
  })  : _categoryRepository = categoryRepository,
        _productRepository = productRepository,
        _transactionRepository = transactionRepository;

  final ICategoryRepository _categoryRepository;
  final IProductRepository _productRepository;
  final ITransactionRepository _transactionRepository;

  final RxList<Category> categories = <Category>[].obs;
  final Rx<Category?> selectedCategory = Rx<Category?>(null);
  final RxList<Product> products = <Product>[].obs;
  final Rx<Product?> selectedProduct = Rx<Product?>(null);
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();
  final Rx<DateTime> date = DateTime.now().obs;
  final RxString error = ''.obs;
  final RxBool saving = false.obs;
  final RxBool isEdit = false.obs;

  String? _editId;

  @override
  void onInit() {
    super.onInit();
    _editId = Get.arguments as String?;
    _initLoad();
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }

  Future<void> _initLoad() async {
    await _loadCategories();
    if (_editId == null) {
      return;
    }
    final tx = await _transactionRepository.getById(_editId!);
    if (tx == null || tx.type != TransactionType.expense) {
      _editId = null;
      return;
    }
    isEdit.value = true;
    amountCtrl.text = NumberFormatter.formatNumber(tx.amount);
    noteCtrl.text = tx.note ?? '';
    date.value = tx.date;
    if (tx.categoryId != null) {
      for (final category in categories) {
        if (category.id == tx.categoryId) {
          selectedCategory.value = category;
          break;
        }
      }
      if (selectedCategory.value != null) {
        await _loadProducts(selectedCategory.value!.id);
      }
      if (tx.productId != null) {
        for (final product in products) {
          if (product.id == tx.productId) {
            selectedProduct.value = product;
            break;
          }
        }
      }
    }
  }

  Future<void> _loadCategories() async {
    final all = await _categoryRepository.getAll();
    categories.assignAll(
      all.where(
        (c) => c.type == CategoryType.expense || c.type == CategoryType.both,
      ),
    );
  }

  void selectCategory(Category? category) {
    selectedCategory.value = category;
    selectedProduct.value = null;
    products.clear();
    if (category != null) {
      _loadProducts(category.id);
    }
    clearError();
  }

  Future<void> _loadProducts(String categoryId) async {
    final items = await _productRepository.getByCategory(categoryId);
    products.assignAll(items);
  }

  void selectProduct(Product? product) {
    selectedProduct.value = product;
    clearError();
  }

  void setDate(DateTime value) {
    date.value = value;
    clearError();
  }

  void clearError() {
    if (error.isNotEmpty) {
      error.value = '';
    }
  }

  Future<void> save() async {
    final amountError = Validators.positiveNumber(amountCtrl.text);
    if (amountError != null) {
      error.value = amountError;
      return;
    }
    if (selectedCategory.value == null) {
      error.value = AppStrings.categoryRequired;
      return;
    }
    final canGoBack = Get.key.currentState?.canPop() ?? false;
    saving.value = true;
    try {
      final transaction = Transaction(
        id: _editId ?? _newId(),
        type: TransactionType.expense,
        amount: Validators.parseNumber(amountCtrl.text) ?? 0,
        categoryId: selectedCategory.value!.id,
        productId: selectedProduct.value?.id,
        date: date.value,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      );
      if (isEdit.value) {
        await _transactionRepository.update(transaction);
      } else {
        await _transactionRepository.add(transaction);
      }
      Get.dialog(const SuccessScreen(message: AppStrings.savedSuccess));
      await Future.delayed(const Duration(milliseconds: 1200));
      if (Get.isDialogOpen == true) {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
      }
      if (canGoBack) {
        Get.back();
      } else {
        Get.offNamed(AppRoutes.home);
      }
    } finally {
      saving.value = false;
    }
  }

  String _newId() =>
      DateTime.now().microsecondsSinceEpoch.toString() +
      Random().nextInt(9999).toString();
}
