/// Fair-wage pricing constants — TRD.md §17.3.
///
/// These are the artisan's protection against loss-making sales. They are
/// deliberately deterministic and never learned: the floor must be explainable
/// aloud, and must compute to the same number offline and online.
abstract final class PricingConstants {
  /// Rupees per hour of skilled craft labour.
  static const int fairWagePerHour = 150;

  /// Covers thread, dye, wastage, transport to market.
  static const double overheadFactor = 1.15;

  /// Margin above the cost floor for the suggested price.
  static const double marginFactor = 1.25;

  /// Ceiling above the suggested price.
  static const double maxFactor = 1.30;

  /// All displayed prices round to this, so an artisan never has to read
  /// an odd number aloud to a buyer.
  static const int roundTo = 50;
}
