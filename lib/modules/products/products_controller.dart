import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../data/models/category.dart';
import '../../data/models/product.dart';
import '../../data/repositories/interfaces/category_repository_interface.dart';
import '../../data/repositories/interfaces/product_repository_interface.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';

class ProductsController extends GetxController {
  ProductsController({
    required IProductRepository productRepository,
    required ICategoryRepository categoryRepository,
    required ITransactionRepository transactionRepository,
  })  : _productRepository = productRepository,
        _categoryRepository = categoryRepository,
        _transactionRepository = transactionRepository;

  final IProductRepository _productRepository;
  final ICategoryRepository _categoryRepository;
  final ITransactionRepository _transactionRepository;

  final RxList<Product> products = <Product>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final Rx<Product?> editing = Rx<Product?>(null);
  final RxBool addMode = false.obs;
  final TextEditingController nameCtrl = TextEditingController();
  final Rx<Category?> selectedCategory = Rx<Category?>(null);
  final RxString nameError = RxString('');
  final RxString categoryError = RxString('');
  final RxString refsError = RxString('');

  bool get showForm => addMode.value || editing.value != null;

  List<Category> get categoryOptions => categories
      .where(
        (c) =>
            c.type == CategoryType.expense || c.type == CategoryType.both,
      )
      .toList();

  List<(Category, List<Product>)> get groups {
    final grouped = <String, List<Product>>{};
    for (final product in products) {
      grouped.putIfAbsent(product.categoryId, () => []).add(product);
    }
    final result = <(Category, List<Product>)>[];
    for (final entry in grouped.entries) {
      final category = _categoryById(entry.key);
      if (category != null) {
        result.add((category, entry.value));
      }
    }
    result.sort((a, b) => a.$1.name.compareTo(b.$1.name));
    return result;
  }

  Category? _categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) {
        return category;
      }
    }
    return null;
  }

  static const Map<String, IconData> _iconMap = {
    'salad': TablerIcons.salad,
    'car': TablerIcons.car,
    'medical_cross': TablerIcons.medical_cross,
    'home': TablerIcons.home,
    'bolt': TablerIcons.bolt,
    'shopping_bag': TablerIcons.shopping_bag,
    'movie': TablerIcons.movie,
    'package': TablerIcons.package,
    'wallet': TablerIcons.wallet,
    'building_bank': TablerIcons.building_bank,
    'gift': TablerIcons.gift,
    'coin': TablerIcons.coin,
  };

  static IconData categoryIconFor(String code) =>
      _iconMap[code] ?? TablerIcons.package;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    products.assignAll(await _productRepository.getAll());
    categories.assignAll(await _categoryRepository.getAll());
  }

  void startAdd() {
    addMode.value = true;
    editing.value = null;
    nameCtrl.text = '';
    selectedCategory.value = null;
    nameError.value = '';
    categoryError.value = '';
    refsError.value = '';
  }

  void startEdit(Product product) {
    editing.value = product;
    addMode.value = false;
    nameCtrl.text = product.name;
    selectedCategory.value = _categoryById(product.categoryId);
    nameError.value = '';
    categoryError.value = '';
    refsError.value = '';
  }

  void cancelEdit() {
    editing.value = null;
    addMode.value = false;
    nameCtrl.clear();
    selectedCategory.value = null;
    nameError.value = '';
    categoryError.value = '';
  }

  Future<void> save() async {
    final name = nameCtrl.text.trim();
    final nameErr = Validators.requiredField(name);
    if (nameErr != null) {
      nameError.value = nameErr;
      return;
    }
    nameError.value = '';

    final category = selectedCategory.value;
    if (category == null) {
      categoryError.value = AppStrings.categoryRequired;
      return;
    }
    categoryError.value = '';

    final current = editing.value;
    if (current != null) {
      final updated = current.copyWith(name: name, categoryId: category.id);
      await _productRepository.update(updated);
      final index = products.indexWhere((p) => p.id == updated.id);
      if (index != -1) {
        products[index] = updated;
      }
    } else {
      final created = Product(
        id: _newId(),
        name: name,
        categoryId: category.id,
      );
      await _productRepository.add(created);
      products.add(created);
    }
    cancelEdit();
  }

  Future<void> delete(Product product) async {
    final transactions = await _transactionRepository.getAll();
    final used = transactions.any((tx) => tx.productId == product.id);
    if (used) {
      refsError.value = AppStrings.deleteBlocked;
      return;
    }
    await _productRepository.delete(product.id);
    products.removeWhere((p) => p.id == product.id);
    if (editing.value?.id == product.id) {
      cancelEdit();
    }
  }

  void clearRefsError() => refsError.value = '';

  String _newId() =>
      DateTime.now().microsecondsSinceEpoch.toString() +
      Random().nextInt(9999).toString();
}