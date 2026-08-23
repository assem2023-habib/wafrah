import 'package:get/get.dart';

import '../../data/repositories/interfaces/electricity_repository_interface.dart';
import 'add_reading_controller.dart';

class AddReadingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AddReadingController(
        electricityRepository: Get.find<IElectricityRepository>(),
      ),
    );
  }
}
