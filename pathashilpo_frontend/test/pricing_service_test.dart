import 'package:flutter_test/flutter_test.dart';
import 'package:pathashilpa/ai/pricing/controllers/pricing_service.dart';
import 'package:pathashilpa/ai/pricing/models/price_result.dart';

void main() {
  const PricingService pricing = PricingService();

  group('fair-wage formula', () {
    test('worked example from the docs: ₹800 materials, 12 hours', () {
      // (800 + 12×150) × 1.15 = 2990 → floor 3000
      // 3000 × 1.25 = 3750 → suggested 3750
      // 3750 × 1.30 = 4875 → max 4900
      final PriceResult r = pricing.compute(materialCost: 800, hoursOfWork: 12);

      expect(r.floor, 3000);
      expect(r.suggested, 3750);
      expect(r.max, 4900);
    });

    test('every price is a multiple of ₹50', () {
      for (int cost = 0; cost <= 5000; cost += 137) {
        for (int hours = 0; hours <= 40; hours += 3) {
          final PriceResult r =
              pricing.compute(materialCost: cost, hoursOfWork: hours);
          expect(r.floor % 50, 0, reason: 'floor for $cost/$hours');
          expect(r.suggested % 50, 0, reason: 'suggested for $cost/$hours');
          expect(r.max % 50, 0, reason: 'max for $cost/$hours');
        }
      }
    });

    test('the band never inverts', () {
      for (int cost = 0; cost <= 3000; cost += 91) {
        for (int hours = 0; hours <= 30; hours += 2) {
          final PriceResult r =
              pricing.compute(materialCost: cost, hoursOfWork: hours);
          expect(r.floor <= r.suggested, isTrue, reason: '$cost/$hours');
          expect(r.suggested <= r.max, isTrue, reason: '$cost/$hours');
        }
      }
    });

    test('floor never falls below raw cost — the artisan cannot lose money', () {
      for (int cost = 0; cost <= 5000; cost += 173) {
        for (int hours = 0; hours <= 40; hours += 5) {
          final PriceResult r =
              pricing.compute(materialCost: cost, hoursOfWork: hours);
          final int rawCost = cost + hours * 150;
          expect(
            r.floor >= rawCost,
            isTrue,
            reason: 'floor ${r.floor} < raw cost $rawCost for $cost/$hours',
          );
        }
      }
    });

    test('is deterministic — same input, same output, always', () {
      final PriceResult a = pricing.compute(materialCost: 1250, hoursOfWork: 9);
      final PriceResult b = pricing.compute(materialCost: 1250, hoursOfWork: 9);
      expect(a.floor, b.floor);
      expect(a.suggested, b.suggested);
      expect(a.max, b.max);
    });

    test('handles the zero case without dividing by anything', () {
      final PriceResult r = pricing.compute(materialCost: 0, hoursOfWork: 0);
      expect(r.floor, 0);
      expect(r.suggested, 0);
      expect(r.max, 0);
    });

    test('rejects negative input', () {
      expect(
        () => pricing.compute(materialCost: -1, hoursOfWork: 5),
        throwsArgumentError,
      );
      expect(
        () => pricing.compute(materialCost: 100, hoursOfWork: -1),
        throwsArgumentError,
      );
    });

    test('carries the components needed to rebuild the explanation', () {
      // The result holds numbers only — the sentence is formatted in the UI so
      // it follows the language selected in Settings.
      final PriceResult r = pricing.compute(materialCost: 800, hoursOfWork: 12);
      expect(r.materialCost, 800);
      expect(r.hoursOfWork, 12);
      expect(r.labourCost, 1800); // 12 × 150
      expect(r.fairWagePerHour, 150);
    });
  });
}
