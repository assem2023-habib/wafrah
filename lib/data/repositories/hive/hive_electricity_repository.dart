import 'package:hive/hive.dart';

import '../../models/electricity_reading.dart';
import '../../models/electricity_settings.dart';
import '../interfaces/electricity_repository_interface.dart';

class HiveElectricityRepository implements IElectricityRepository {
  Box<ElectricityReading> get _readingsBox =>
      Hive.box<ElectricityReading>('electricityReadings');

  Box<AppSettings> get _settingsBox => Hive.box<AppSettings>('appSettings');

  @override
  Future<List<ElectricityReading>> getAllReadings() async =>
      _readingsBox.values.toList();

  @override
  Future<ElectricityReading?> getReadingById(String id) async {
    for (final key in _readingsBox.keys) {
      final reading = _readingsBox.get(key);
      if (reading != null && reading.id == id) return reading;
    }
    return null;
  }

  @override
  Future<ElectricityReading> addReading(ElectricityReading reading) async {
    await _readingsBox.add(reading);
    return reading;
  }

  @override
  Future<void> deleteReading(String id) async {
    for (final key in _readingsBox.keys) {
      final existing = _readingsBox.get(key);
      if (existing != null && existing.id == id) {
        await _readingsBox.delete(key);
        return;
      }
    }
  }

  @override
  Future<AppSettings> getAppSettings() async {
    if (_settingsBox.isEmpty) {
      const defaultSettings = AppSettings(
        darkMode: false,
        reduceMotion: false,
        electricity: ElectricitySettings(
          cycleMonths: 2,
          tiers: [ElectricityTier(limit: 300, price: 600)],
        ),
      );
      await _settingsBox.add(defaultSettings);
      return defaultSettings;
    }
    return _settingsBox.values.first;
  }

  @override
  Future<ElectricitySettings> getElectricitySettings() async {
    final appSettings = await getAppSettings();
    return appSettings.electricity;
  }

  @override
  Future<void> updateAppSettings(AppSettings settings) async {
    if (_settingsBox.isEmpty) {
      await _settingsBox.add(settings);
    } else {
      await _settingsBox.put(_settingsBox.keys.first, settings);
    }
  }

  @override
  Future<void> updateElectricitySettings(ElectricitySettings settings) async {
    final appSettings = await getAppSettings();
    await updateAppSettings(appSettings.copyWith(electricity: settings));
  }
}