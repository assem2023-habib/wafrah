import 'package:get/get.dart';

import '../../data/repositories/interfaces/electricity_repository_interface.dart';
import 'electricity_home_controller.dart';

class ElectricityHomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ElectricityHomeController(
        electricityRepository: Get.find<IElectricityRepository>(),
      ),
    );
  }
}
