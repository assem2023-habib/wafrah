import 'package:get/get.dart';

import '../electricity_home/electricity_home_controller.dart';
import '../home/home_controller.dart';
import '../statistics/statistics_controller.dart';
import '../transactions/transactions_controller.dart';

class MainShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  MainShellController({
    required HomeController homeController,
    required TransactionsController transactionsController,
    required StatisticsController statisticsController,
    required ElectricityHomeController electricityController,
  })  : _homeController = homeController,
        _transactionsController = transactionsController,
        _statisticsController = statisticsController,
        _electricityController = electricityController;

  final HomeController _homeController;
  final TransactionsController _transactionsController;
  final StatisticsController _statisticsController;
  final ElectricityHomeController _electricityController;

  void changeTab(int index) {
    if (index < 0 || index > 3 || index == currentIndex.value) {
      return;
    }
    currentIndex.value = index;
    switch (index) {
      case 0:
        _homeController.load(silent: true);
      case 1:
        _transactionsController.load(silent: true);
      case 2:
        _statisticsController.load(silent: true);
      case 3:
        _electricityController.load(silent: true);
    }
  }
}
