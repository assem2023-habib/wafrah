import 'package:get/get.dart';

import '../../data/repositories/interfaces/category_repository_interface.dart';
import '../../data/repositories/interfaces/product_repository_interface.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';
import 'add_expense_controller.dart';

class AddExpenseBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AddExpenseController(
        categoryRepository: Get.find<ICategoryRepository>(),
        productRepository: Get.find<IProductRepository>(),
        transactionRepository: Get.find<ITransactionRepository>(),
      ),
    );
  }
}