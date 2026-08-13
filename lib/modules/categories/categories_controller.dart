import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../data/models/category.dart';
import '../../data/repositories/interfaces/category_repository_interface.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';

class CategoriesController extends GetxController {
  CategoriesController({
    required ICategoryRepository categoryRepository,
    required ITransactionRepository transactionRepository,
  })  : _categoryRepository = categoryRepository,
        _transactionRepository = transactionRepository;

  final ICategoryRepository _categoryRepository;
  final ITransactionRepository _transactionRepository;

  static const List<(String, IconData)> iconOptions = [
    ('salad', TablerIcons.salad),
    ('car', TablerIcons.car),
    ('medical_cross', TablerIcons.medical_cross),
    ('home', TablerIcons.home),
    ('bolt', TablerIcons.bolt),
    ('shopping_bag', TablerIcons.shopping_bag),
    ('movie', TablerIcons.movie),
    ('package', TablerIcons.package),
    ('wallet', TablerIcons.wallet),
    ('building_bank', TablerIcons.building_bank),
    ('gift', TablerIcons.gift),
    ('coin', TablerIcons.coin),
  ];

  final RxList<Category> categories = <Category>[].obs;
  final Rx<Category?> editing = Rx<Category?>(null);
  final RxBool addMode = false.obs;
  final TextEditingController nameCtrl = TextEditingController();
  final Rx<CategoryType> type = Rx<CategoryType>(CategoryType.expense);
  final RxString iconCode = RxString('package');
  final RxString nameError = RxString('');
  final RxString refsError = RxString('');

  bool get showForm => addMode.value || editing.value != null;

  IconData iconFor(String code) {
    for (final option in iconOptions) {
      if (option.$1 == code) {
        return option.$2;
      }
    }
    return TablerIcons.package;
  }

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
    categories.assignAll(await _categoryRepository.getAll());
  }

  void startAdd() {
    addMode.value = true;
    editing.value = null;
    nameCtrl.text = '';
    type.value = CategoryType.expense;
    iconCode.value = 'package';
    nameError.value = '';
    refsError.value = '';
  }

  void startEdit(Category category) {
    editing.value = category;
    addMode.value = false;
    nameCtrl.text = category.name;
    type.value = category.type;
    iconCode.value = category.iconCode;
    nameError.value = '';
    refsError.value = '';
  }

  void cancelEdit() {
    editing.value = null;
    addMode.value = false;
    nameCtrl.clear();
    nameError.value = '';
    type.value = CategoryType.expense;
    iconCode.value = 'package';
  }

  Future<void> save() async {
    final name = nameCtrl.text.trim();
    final nameErr = Validators.requiredField(name);
    if (nameErr != null) {
      nameError.value = nameErr;
      return;
    }
    nameError.value = '';

    final current = editing.value;
    if (current != null) {
      final updated = current.copyWith(
        name: name,
        iconCode: iconCode.value,
        type: type.value,
      );
      await _categoryRepository.update(updated);
      final index = categories.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        categories[index] = updated;
      }
    } else {
      final created = Category(
        id: _newId(),
        name: name,
        iconCode: iconCode.value,
        type: type.value,
      );
      await _categoryRepository.add(created);
      categories.add(created);
    }
    cancelEdit();
  }

  Future<void> delete(Category category) async {
    final transactions = await _transactionRepository.getAll();
    final used = transactions.any((tx) => tx.categoryId == category.id);
    if (used) {
      refsError.value = AppStrings.deleteBlocked;
      return;
    }
    await _categoryRepository.delete(category.id);
    categories.removeWhere((c) => c.id == category.id);
    if (editing.value?.id == category.id) {
      cancelEdit();
    }
  }

  void clearRefsError() => refsError.value = '';

  String _newId() =>
      DateTime.now().microsecondsSinceEpoch.toString() +
      Random().nextInt(9999).toString();
}