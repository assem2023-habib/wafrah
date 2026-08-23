import 'package:get/get.dart';

import '../../data/repositories/interfaces/category_repository_interface.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';
import 'statistics_controller.dart';

class StatisticsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => StatisticsController(
        transactionRepository: Get.find<ITransactionRepository>(),
        categoryRepository: Get.find<ICategoryRepository>(),
      ),
    );
  }
}
