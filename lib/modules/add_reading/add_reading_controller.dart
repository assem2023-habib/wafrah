import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/tariff_calculator.dart';
import '../../core/utils/validators.dart';
import '../../data/models/electricity_reading.dart';
import '../../data/models/electricity_settings.dart';
import '../../data/repositories/interfaces/electricity_repository_interface.dart';
import '../../routes/app_routes.dart';
import '../../widgets/success_screen.dart';

class AddReadingController extends GetxController {
  AddReadingController({required IElectricityRepository electricityRepository})
      : _electricityRepository = electricityRepository;

  final IElectricityRepository _electricityRepository;

  final TextEditingController valueCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();
  final Rx<DateTime> fromDate = DateTime.now().obs;
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);
  final RxString error = ''.obs;
  final RxBool saving = false.obs;
  final RxBool loading = true.obs;

  ElectricityReading? previousReading;
  List<ElectricityTier> _tiers = const [];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    valueCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final readings = await _electricityRepository.getAllReadings();
      if (readings.isNotEmpty) {
        readings.sort((a, b) => a.fromDate.compareTo(b.fromDate));
        previousReading = readings.last;
      }
      final settings = await _electricityRepository.getElectricitySettings();
      _tiers = settings.tiers;
    } finally {
      loading.value = false;
    }
  }

  double get typedValue => Validators.parseNumber(valueCtrl.text) ?? 0;

  bool get hasPrevious => previousReading != null;

  double get previewConsumption {
    if (!hasPrevious || typedValue <= 0) {
      return 0;
    }
    return (typedValue - previousReading!.kwhValue).clamp(0.0, double.infinity);
  }

  double get previewCost =>
      TariffCalculator.costOfConsumption(previewConsumption, _tiers);

  bool get showPreview => hasPrevious && typedValue > 0;

  void setFromDate(DateTime value) {
    fromDate.value = value;
    clearError();
  }

  void setToDate(DateTime? value) {
    toDate.value = value;
    clearError();
  }

  void clearError() {
    if (error.isNotEmpty) {
      error.value = '';
    }
  }

  Future<void> save() async {
    final value = typedValue;
    if (value <= 0) {
      error.value = AppStrings.amountPositive;
      return;
    }
    final end = toDate.value;
    if (end != null && !end.isAfter(fromDate.value)) {
      error.value = AppStrings.toDateAfterFrom;
      return;
    }
    final canGoBack = Get.key.currentState?.canPop() ?? false;
    saving.value = true;
    try {
      await _electricityRepository.addReading(
        ElectricityReading(
          id: _newId(),
          fromDate: fromDate.value,
          toDate: end,
          kwhValue: value,
          note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
        ),
      );
      Get.dialog(const SuccessScreen(message: AppStrings.readingSaved));
      await Future.delayed(const Duration(milliseconds: 1200));
      if (Get.isDialogOpen == true) {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
      }
      if (canGoBack) {
        Get.back();
      } else {
        Get.offNamed(AppRoutes.electricity);
      }
    } finally {
      saving.value = false;
    }
  }

  String _newId() =>
      DateTime.now().microsecondsSinceEpoch.toString() +
      Random().nextInt(9999).toString();
}
