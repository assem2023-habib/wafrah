import 'package:get/get.dart';

import '../../data/repositories/interfaces/category_repository_interface.dart';
import '../../data/repositories/interfaces/product_repository_interface.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';
import 'transactions_controller.dart';

class TransactionsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => TransactionsController(
        transactionRepository: Get.find<ITransactionRepository>(),
        categoryRepository: Get.find<ICategoryRepository>(),
        productRepository: Get.find<IProductRepository>(),
      ),
    );
  }
}