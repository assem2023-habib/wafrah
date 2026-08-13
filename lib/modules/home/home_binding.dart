import 'package:get/get.dart';

import '../../data/repositories/interfaces/category_repository_interface.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';
import 'home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => HomeController(
        transactionRepository: Get.find<ITransactionRepository>(),
        categoryRepository: Get.find<ICategoryRepository>(),
      ),
    );
  }
}