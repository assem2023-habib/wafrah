import 'package:get/get.dart';

import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 1200), () {
      Get.offNamed(AppRoutes.home);
    });
  }
}
