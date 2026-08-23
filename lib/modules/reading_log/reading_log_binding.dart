import 'package:get/get.dart';

import '../../data/repositories/interfaces/electricity_repository_interface.dart';
import 'reading_log_controller.dart';

class ReadingLogBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ReadingLogController(
        electricityRepository: Get.find<IElectricityRepository>(),
      ),
    );
  }
}
