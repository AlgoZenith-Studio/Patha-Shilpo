/// Where the market band came from. The floor is always deterministic.
enum PriceSource { cached, live }

/// Output contract for the pricing pipeline (TRD.md §7).
///
/// Carries **numbers only, no prose**. The explanation shown to the artisan is
/// formatted in the UI layer from these components, so it renders in whichever
/// language is selected in Settings.
class PriceResult {
  const PriceResult({
    required this.floor,
    required this.suggested,
    required this.max,
    required this.materialCost,
    required this.hoursOfWork,
    required this.labourCost,
    required this.fairWagePerHour,
    required this.source,
  });

  /// Cost floor. Below this the artisan loses money — never present a price
  /// under it, and never let a server recomputation move it.
  final int floor;

  final int suggested;
  final int max;

  // Components, kept so the reasoning can be rebuilt in any language.
  final int materialCost;
  final int hoursOfWork;
  final int labourCost;
  final int fairWagePerHour;

  final PriceSource source;
}
