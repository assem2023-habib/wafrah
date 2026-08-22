import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/number_formatter.dart';
import '../../core/utils/validators.dart';
import '../../data/models/transaction.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';
import '../../routes/app_routes.dart';
import '../../widgets/success_screen.dart';

class AddIncomeController extends GetxController {
  AddIncomeController({
    required ITransactionRepository transactionRepository,
  })  : _transactionRepository = transactionRepository;

  final ITransactionRepository _transactionRepository;

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
    if (_editId != null) {
      _loadForEdit();
    }
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadForEdit() async {
    final tx = await _transactionRepository.getById(_editId!);
    if (tx == null || tx.type != TransactionType.income) {
      _editId = null;
      return;
    }
    isEdit.value = true;
    amountCtrl.text = NumberFormatter.formatNumber(tx.amount);
    noteCtrl.text = tx.note ?? '';
    date.value = tx.date;
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
    final canGoBack = Get.key.currentState?.canPop() ?? false;
    saving.value = true;
    try {
      final transaction = Transaction(
        id: _editId ?? _newId(),
        type: TransactionType.income,
        amount: Validators.parseNumber(amountCtrl.text) ?? 0,
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
