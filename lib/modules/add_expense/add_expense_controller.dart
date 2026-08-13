import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_strings.dart';
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

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
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
      await _transactionRepository.add(
        Transaction(
          id: _newId(),
          type: TransactionType.expense,
          amount: Validators.parseNumber(amountCtrl.text) ?? 0,
          categoryId: selectedCategory.value!.id,
          productId: selectedProduct.value?.id,
          date: date.value,
          note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
        ),
      );
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