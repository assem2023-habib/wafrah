import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService {
  ThemeService._();

  static const String _boxName = 'ui';
  static const String _modeKey = 'themeMode';
  static const String _reduceMotionKey = 'reduceMotion';
  static Box? _box;

  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  static ThemeMode load() {
    final index = _box?.get(_modeKey, defaultValue: ThemeMode.system.index);
    if (index is! int || index < 0 || index >= ThemeMode.values.length) {
      return ThemeMode.system;
    }
    return ThemeMode.values[index];
  }

  static Future<void> save(ThemeMode mode) async {
    await _box?.put(_modeKey, mode.index);
  }

  static bool get reduceMotion =>
      _box?.get(_reduceMotionKey, defaultValue: false) as bool? ?? false;

  static Future<void> saveReduceMotion(bool value) async {
    await _box?.put(_reduceMotionKey, value);
  }
}
