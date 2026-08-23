import '../../data/models/electricity_settings.dart';

class TariffCalculator {
  TariffCalculator._();

  static double costOfConsumption(
    double consumptionKwh,
    List<ElectricityTier> tiers,
  ) {
    var cost = 0.0;
    var previousLimit = 0.0;
    for (final tier in tiers) {
      if (consumptionKwh > previousLimit) {
        final withinTier =
            (consumptionKwh.clamp(0.0, tier.limit)) - previousLimit;
        cost += withinTier * tier.price;
      }
      previousLimit = tier.limit;
    }
    return cost;
  }
}
