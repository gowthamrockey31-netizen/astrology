import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/widgets/transit_orbit_painter.dart';

void main() {
  group('TransitOrbitPainter South Indian Chart Geometry & Boundary Tests', () {
    test('All 12 Rasi sign degree boundaries map continuously and correctly', () {
      // 0° is start of Mesham (Aries)
      final deg0 = TransitOrbitPainter.degreeToRadians(0.0);
      expect(deg0, closeTo(-2.1588, 0.01)); // ~ -123.7°

      // 15° is middle of Mesham
      final deg15 = TransitOrbitPainter.degreeToRadians(15.0);
      expect(deg15, closeTo(-1.8648, 0.01));

      // 30° is boundary of Mesham and Rishabam (top center)
      final deg30 = TransitOrbitPainter.degreeToRadians(30.0);
      expect(deg30, closeTo(-math.pi / 2.0, 0.001)); // -90°

      // 60° is boundary of Rishabam and Mithunam
      final deg60 = TransitOrbitPainter.degreeToRadians(60.0);
      expect(deg60, closeTo(-0.9828, 0.01)); // ~ -56.3°

      // 90° is boundary of Mithunam and Katakam
      final deg90 = TransitOrbitPainter.degreeToRadians(90.0);
      expect(deg90, closeTo(-0.5880, 0.01)); // ~ -33.7°

      // 120° is boundary of Katakam and Simham (right center)
      final deg120 = TransitOrbitPainter.degreeToRadians(120.0);
      expect(deg120, closeTo(0.0, 0.001)); // 0°

      // 180° is boundary of Simham and Kanni
      final deg180 = TransitOrbitPainter.degreeToRadians(180.0);
      expect(deg180, closeTo(0.9828, 0.01)); // ~ +56.3°

      // 210° is boundary of Thulam and Viruchigam (bottom center)
      final deg210 = TransitOrbitPainter.degreeToRadians(210.0);
      expect(deg210, closeTo(math.pi / 2.0, 0.001)); // +90°

      // 300° is boundary of Makaram and Kumbam (left center)
      final deg300 = TransitOrbitPainter.degreeToRadians(300.0);
      expect(deg300.abs(), closeTo(math.pi, 0.001)); // ±180°
    });

    test('Orbit radius and position coordinates stay strictly within 12 rasi boxes', () {
      const double canvasSize = 360.0;
      const double gridMargin = 18.0;
      final double gridSize = canvasSize - gridMargin * 2; // 324.0
      final double radius = gridSize * 0.39; // 126.36
      final center = Offset(canvasSize / 2, canvasSize / 2); // (180, 180)

      // Test every 1 degree around the circle (0..359)
      for (int d = 0; d < 360; d++) {
        final rad = TransitOrbitPainter.degreeToRadians(d.toDouble());
        final x = center.dx + radius * math.cos(rad);
        final y = center.dy + radius * math.sin(rad);

        // Must be inside outer grid boundary
        expect(x, greaterThan(gridMargin + 5.0), reason: 'x too close to left border at degree $d');
        expect(x, lessThan(canvasSize - gridMargin - 5.0), reason: 'x too close to right border at degree $d');
        expect(y, greaterThan(gridMargin + 5.0), reason: 'y too close to top border at degree $d');
        expect(y, lessThan(canvasSize - gridMargin - 5.0), reason: 'y too close to bottom border at degree $d');

        // Must not collapse into the center 2x2 empty box (which spans from 99 to 261)
        final bool inCenter2x2 = (x > 99.0 && x < 261.0 && y > 99.0 && y < 261.0);
        expect(inCenter2x2, isFalse, reason: 'Coordinates ($x, $y) entered center 2x2 at degree $d');
      }
    });
  });
}
