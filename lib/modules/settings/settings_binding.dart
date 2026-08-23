import 'package:get/get.dart';

import '../../data/repositories/interfaces/electricity_repository_interface.dart';
import 'settings_controller.dart';

class SettingsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => SettingsController(
        electricityRepository: Get.find<IElectricityRepository>(),
      ),
    );
  }
}
