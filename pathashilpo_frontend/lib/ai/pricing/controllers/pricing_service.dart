import '../../../core/constants/pricing_constants.dart';
import '../models/price_result.dart';

/// Deterministic fair-wage pricing.
///
/// **One implementation, no router.** Unlike every other pipeline (TRD.md AD-5)
/// this has no online/offline split, because the formula must produce a
/// bit-identical result either way — that is what lets the app promise the
/// artisan their price will not change after sync (TRD.md §9.4).
///
/// ```
/// floor     = (materialCost + hours × 150) × 1.15
/// suggested = round(floor × 1.25, 50)
/// max       = round(suggested × 1.30, 50)
/// ```
///
/// Returns numbers only. The human explanation is built in the UI so it follows
/// the language selected in Settings.
class PricingService {
  const PricingService();

  PriceResult compute({
    required int materialCost,
    required int hoursOfWork,
    PriceSource source = PriceSource.cached,
  }) {
    if (materialCost < 0) {
      throw ArgumentError.value(
          materialCost, 'materialCost', 'must not be negative');
    }
    if (hoursOfWork < 0) {
      throw ArgumentError.value(
          hoursOfWork, 'hoursOfWork', 'must not be negative');
    }

    final int labour = hoursOfWork * PricingConstants.fairWagePerHour;
    final double rawFloor =
        (materialCost + labour) * PricingConstants.overheadFactor;

    // The floor rounds UP: rounding it down would put the artisan below cost.
    final int floor = _roundUp(rawFloor, PricingConstants.roundTo);
    final int suggested = _roundNearest(
        floor * PricingConstants.marginFactor, PricingConstants.roundTo);
    final int max = _roundNearest(
        suggested * PricingConstants.maxFactor, PricingConstants.roundTo);

    return PriceResult(
      floor: floor,
      suggested: suggested,
      max: max,
      materialCost: materialCost,
      hoursOfWork: hoursOfWork,
      labourCost: labour,
      fairWagePerHour: PricingConstants.fairWagePerHour,
      source: source,
    );
  }

  static int _roundUp(double value, int step) => (value / step).ceil() * step;

  static int _roundNearest(double value, int step) =>
      (value / step).round() * step;
}
