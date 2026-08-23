import 'package:get/get.dart';

import 'theme_service.dart';

class Motion {
  Motion._();

  static final RxBool reduced = false.obs;

  static void init() {
    reduced.value = ThemeService.reduceMotion;
  }

  static Future<void> set(bool value) async {
    reduced.value = value;
    await ThemeService.saveReduceMotion(value);
  }

  static Duration dur(Duration normal) =>
      reduced.value ? Duration.zero : normal;
}
