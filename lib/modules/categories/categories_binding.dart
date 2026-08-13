import 'package:get/get.dart';

import '../../data/repositories/interfaces/category_repository_interface.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';
import 'categories_controller.dart';

class CategoriesBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => CategoriesController(
        categoryRepository: Get.find<ICategoryRepository>(),
        transactionRepository: Get.find<ITransactionRepository>(),
      ),
    );
  }
}