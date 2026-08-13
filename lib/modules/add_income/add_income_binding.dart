import 'package:get/get.dart';

import '../../data/repositories/interfaces/transaction_repository_interface.dart';
import 'add_income_controller.dart';

class AddIncomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AddIncomeController(
        transactionRepository: Get.find<ITransactionRepository>(),
      ),
    );
  }
}