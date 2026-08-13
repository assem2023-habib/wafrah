import 'package:get/get.dart';

import '../../data/repositories/interfaces/category_repository_interface.dart';
import '../../data/repositories/interfaces/product_repository_interface.dart';
import '../../data/repositories/interfaces/transaction_repository_interface.dart';
import 'products_controller.dart';

class ProductsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ProductsController(
        productRepository: Get.find<IProductRepository>(),
        categoryRepository: Get.find<ICategoryRepository>(),
        transactionRepository: Get.find<ITransactionRepository>(),
      ),
    );
  }
}