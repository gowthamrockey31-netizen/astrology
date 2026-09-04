import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/engine/dignity_engine.dart';
import 'package:astrocall/models/planet_position.dart';

void main() {
  group('DignityEngine (நீசம் & உச்சம்) Tests', () {
    test('Exaltation (உச்சம், ↑) for classical 7 planets', () {
      // Sun in Mesha (0) -> Exalted
      final sun = PlanetPosition(planet: Planet.sun, longitude: 10.0, rasiIndex: 0);
      final sunRes = DignityEngine.get(sun);
      expect(sunRes?.name, 'உச்சம்');
      expect(sunRes?.symbol, '↑');

      // Moon in Taurus/Rishaba (1) -> Exalted
      final moon = PlanetPosition(planet: Planet.moon, longitude: 33.0, rasiIndex: 1);
      final moonRes = DignityEngine.get(moon);
      expect(moonRes?.name, 'உச்சம்');
      expect(moonRes?.symbol, '↑');

      // Mars in Capricorn/Makara (9) -> Exalted
      final mars = PlanetPosition(planet: Planet.mars, longitude: 298.0, rasiIndex: 9);
      final marsRes = DignityEngine.get(mars);
      expect(marsRes?.name, 'உச்சம்');
      expect(marsRes?.symbol, '↑');

      // Mercury in Virgo/Kanni (5) -> Exalted
      final mercury = PlanetPosition(planet: Planet.mercury, longitude: 165.0, rasiIndex: 5);
      final mercRes = DignityEngine.get(mercury);
      expect(mercRes?.name, 'உச்சம்');
      expect(mercRes?.symbol, '↑');

      // Jupiter in Cancer/Kadaga (3) -> Exalted
      final jupiter = PlanetPosition(planet: Planet.jupiter, longitude: 95.0, rasiIndex: 3);
      final jupRes = DignityEngine.get(jupiter);
      expect(jupRes?.name, 'உச்சம்');
      expect(jupRes?.symbol, '↑');

      // Venus in Pisces/Meena (11) -> Exalted
      final venus = PlanetPosition(planet: Planet.venus, longitude: 357.0, rasiIndex: 11);
      final venRes = DignityEngine.get(venus);
      expect(venRes?.name, 'உச்சம்');
      expect(venRes?.symbol, '↑');

      // Saturn in Libra/Thula (6) -> Exalted
      final saturn = PlanetPosition(planet: Planet.saturn, longitude: 200.0, rasiIndex: 6);
      final satRes = DignityEngine.get(saturn);
      expect(satRes?.name, 'உச்சம்');
      expect(satRes?.symbol, '↑');
    });

    test('Debilitation (நீசம், ↓) for classical 7 planets', () {
      // Sun in Libra/Thula (6) -> Debilitated
      final sun = PlanetPosition(planet: Planet.sun, longitude: 190.0, rasiIndex: 6);
      final sunRes = DignityEngine.get(sun);
      expect(sunRes?.name, 'நீசம்');
      expect(sunRes?.symbol, '↓');

      // Moon in Scorpio/Viruchiga (7) -> Debilitated
      final moon = PlanetPosition(planet: Planet.moon, longitude: 213.0, rasiIndex: 7);
      final moonRes = DignityEngine.get(moon);
      expect(moonRes?.name, 'நீசம்');
      expect(moonRes?.symbol, '↓');

      // Mars in Cancer/Kadaga (3) -> Debilitated
      final mars = PlanetPosition(planet: Planet.mars, longitude: 118.0, rasiIndex: 3);
      final marsRes = DignityEngine.get(mars);
      expect(marsRes?.name, 'நீசம்');
      expect(marsRes?.symbol, '↓');

      // Mercury in Pisces/Meena (11) -> Debilitated
      final mercury = PlanetPosition(planet: Planet.mercury, longitude: 345.0, rasiIndex: 11);
      final mercRes = DignityEngine.get(mercury);
      expect(mercRes?.name, 'நீசம்');
      expect(mercRes?.symbol, '↓');

      // Jupiter in Capricorn/Makara (9) -> Debilitated
      final jupiter = PlanetPosition(planet: Planet.jupiter, longitude: 275.0, rasiIndex: 9);
      final jupRes = DignityEngine.get(jupiter);
      expect(jupRes?.name, 'நீசம்');
      expect(jupRes?.symbol, '↓');

      // Venus in Virgo/Kanni (5) -> Debilitated
      final venus = PlanetPosition(planet: Planet.venus, longitude: 175.0, rasiIndex: 5);
      final venRes = DignityEngine.get(venus);
      expect(venRes?.name, 'நீசம்');
      expect(venRes?.symbol, '↓');

      // Saturn in Aries/Mesha (0) -> Debilitated
      final saturn = PlanetPosition(planet: Planet.saturn, longitude: 20.0, rasiIndex: 0);
      final satRes = DignityEngine.get(saturn);
      expect(satRes?.name, 'நீசம்');
      expect(satRes?.symbol, '↓');
    });

    test('Neutral / Non-exalted non-debilitated planets return null', () {
      // Sun in Simha (4) -> Own house, not exalted/debilitated
      final sun = PlanetPosition(planet: Planet.sun, longitude: 125.0, rasiIndex: 4);
      expect(DignityEngine.get(sun), isNull);

      // Venus in Kadagam (3) -> Not exalted/debilitated (returns null -> displayed as இயல்பு)
      final venus = PlanetPosition(planet: Planet.venus, longitude: 116.0, rasiIndex: 3);
      expect(DignityEngine.get(venus), isNull);

      // Rahu / Ketu in any rasi returns null in standard DignityEngine
      final rahu = PlanetPosition(planet: Planet.rahu, longitude: 200.0, rasiIndex: 6);
      expect(DignityEngine.get(rahu), isNull);
    });

    test('DignityEngine.getFromKey helper works accurately', () {
      final res1 = DignityEngine.getFromKey('Jupiter', 3);
      expect(res1?.name, 'உச்சம்');
      expect(res1?.symbol, '↑');

      final res2 = DignityEngine.getFromKey('Mars', 3);
      expect(res2?.name, 'நீசம்');
      expect(res2?.symbol, '↓');

      final res3 = DignityEngine.getFromKey('Saturn', 10);
      expect(res3, isNull);
    });
  });
}
