import 'package:get/get.dart';

import 'interfaces/category_repository_interface.dart';
import 'interfaces/electricity_repository_interface.dart';
import 'interfaces/product_repository_interface.dart';
import 'interfaces/transaction_repository_interface.dart';
import 'hive/hive_category_repository.dart';
import 'hive/hive_electricity_repository.dart';
import 'hive/hive_product_repository.dart';
import 'hive/hive_transaction_repository.dart';

class RepositoryBindings {
  static void init() {
    Get.put<ICategoryRepository>(HiveCategoryRepository());
    Get.put<IProductRepository>(HiveProductRepository());
    Get.put<ITransactionRepository>(HiveTransactionRepository());
    Get.put<IElectricityRepository>(HiveElectricityRepository());
  }
}