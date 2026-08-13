import 'package:get/get.dart';

import '../../data/repositories/interfaces/category_repository_interface.dart';
import '../../data/repositories/interfaces/product_repository_interface.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';
import 'transaction_detail_controller.dart';

class TransactionDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => TransactionDetailController(
        transactionRepository: Get.find<ITransactionRepository>(),
        categoryRepository: Get.find<ICategoryRepository>(),
        productRepository: Get.find<IProductRepository>(),
      ),
    );
  }
}