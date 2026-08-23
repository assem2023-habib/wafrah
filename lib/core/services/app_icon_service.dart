import 'package:flutter/services.dart';

class AppIconService {
  AppIconService._();

  static const MethodChannel _channel =
      MethodChannel('com.wafrah.wafrah/app_icon');

  static Future<void> setIcon({required bool isDark}) async {
    try {
      await _channel.invokeMethod('setIcon', {'isDark': isDark});
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }
}
