import 'package:get/get.dart';

import '../../data/repositories/interfaces/category_repository_interface.dart';
import '../../data/repositories/interfaces/electricity_repository_interface.dart';
import '../../data/repositories/interfaces/product_repository_interface.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';
import '../electricity_home/electricity_home_controller.dart';
import '../home/home_controller.dart';
import '../statistics/statistics_controller.dart';
import '../transactions/transactions_controller.dart';
import 'main_shell_controller.dart';

class MainShellBinding implements Bindings {
  @override
  void dependencies() {
    final homeController = Get.put(
      HomeController(
        transactionRepository: Get.find<ITransactionRepository>(),
        categoryRepository: Get.find<ICategoryRepository>(),
      ),
    );
    final transactionsController = Get.put(
      TransactionsController(
        transactionRepository: Get.find<ITransactionRepository>(),
        categoryRepository: Get.find<ICategoryRepository>(),
        productRepository: Get.find<IProductRepository>(),
      ),
    );
    final statisticsController = Get.put(
      StatisticsController(
        transactionRepository: Get.find<ITransactionRepository>(),
        categoryRepository: Get.find<ICategoryRepository>(),
      ),
    );
    final electricityController = Get.put(
      ElectricityHomeController(
        electricityRepository: Get.find<IElectricityRepository>(),
      ),
    );
    Get.put(
      MainShellController(
        homeController: homeController,
        transactionsController: transactionsController,
        statisticsController: statisticsController,
        electricityController: electricityController,
      ),
    );
  }
}
