import '../../models/electricity_reading.dart';
import '../../models/electricity_settings.dart';

abstract class IElectricityRepository {
  Future<List<ElectricityReading>> getAllReadings();

  Future<ElectricityReading?> getReadingById(String id);

  Future<ElectricityReading> addReading(ElectricityReading reading);

  Future<void> deleteReading(String id);

  Future<ElectricitySettings> getElectricitySettings();

  Future<void> updateElectricitySettings(ElectricitySettings settings);

  Future<AppSettings> getAppSettings();

  Future<void> updateAppSettings(AppSettings settings);
}