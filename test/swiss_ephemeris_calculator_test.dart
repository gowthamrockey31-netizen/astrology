import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/swiss_ephemeris_calculator.dart';

void main() {
  group('SwissEphemerisCalculator Core Astronomical Tests', () {
    test('Julian Day calculation from local DateTime + UTC offset', () {
      final jd = SwissEphemerisCalculator.getJulianDay(
        DateTime(1995, 8, 15, 8, 30),
        utcOffsetHours: 5.5,
      );
      expect(jd, 2449944.625);
    });

    test('Chitrapaksha / Lahiri Ayanamsa calculation', () {
      final jd = 2449944.625;
      final ayan = SwissEphemerisCalculator.calculateLahiriAyanamsa(jd);
      // Expected: 23° 47' 45" (~23.7959°)
      expect(ayan, closeTo(23.7959, 0.001));
    });

    test('DMS formatting preserves exact degrees, minutes, and seconds', () {
      expect(SwissEphemerisCalculator.formatRasiDms(23.234444), "23°14'04\"");
      expect(SwissEphemerisCalculator.formatRasiDmsDisplay(23.234444), "23° 14′ 04″");
      expect(SwissEphemerisCalculator.formatRasiDms(0.0), "00°00'00\"");
      expect(SwissEphemerisCalculator.formatRasiDms(29.999999), "00°00'00\"");
    });

    test('Dindigul Horoscope (1995-08-15 08:30 AM IST) Planetary Longitudes', () {
      final jd = SwissEphemerisCalculator.getJulianDay(DateTime(1995, 8, 15, 8, 30), utcOffsetHours: 5.5);
      final ayan = SwissEphemerisCalculator.calculateLahiriAyanamsa(jd);

      final lagna = SwissEphemerisCalculator.calculateAscendantSidereal(
        jd: jd,
        latitude: 10.368,
        longitude: 77.980,
        ayanamsa: ayan,
      );

      // Lagna is in Virgo (Kanni: 150°..180°) at ~2° 12'
      expect(lagna, inInclusiveRange(152.0, 153.0));
      final lagnaRasi = (lagna / 30).floor();
      expect(lagnaRasi, 5); // Kanni
      expect(SwissEphemerisCalculator.formatRasiDms(lagna % 30), "02°12'13\"");

      final planets = SwissEphemerisCalculator.calculatePlanetaryPositions(jd: jd, ayanamsa: ayan);

      // Sun: Cancer (Kadagam: 90°..120°) at ~28° 02'
      expect(planets['Sun']!.longitude, inInclusiveRange(118.0, 119.0));

      // Moon: Pisces (Meena: 330°..360°) at ~23° 51'
      expect(planets['Moon']!.longitude, inInclusiveRange(353.5, 354.5));

      // Mars: Virgo (Kanni: 150°..180°) at ~21° 16'
      expect(planets['Mars']!.longitude, inInclusiveRange(171.0, 172.0));

      // Saturn: Aquarius (Kumbha: 300°..330°) at ~29° 42' (Previously was 28°50' with low-order formula!)
      expect(planets['Saturn']!.longitude, inInclusiveRange(329.0, 330.0));
      expect(planets['Saturn']!.isRetrograde, isTrue);

      // Rahu: Libra (Tula: 180°..210°) at ~5° 59'
      expect(planets['Rahu']!.longitude, inInclusiveRange(185.9, 186.1));
      expect(planets['Rahu']!.isRetrograde, isTrue);

      // Ketu: Aries (Mesha: 0°..30°) at ~5° 59'
      expect(planets['Ketu']!.longitude, inInclusiveRange(5.9, 6.1));
      expect(planets['Ketu']!.isRetrograde, isTrue);
    });

    test('Reference Chart Planetary Longitudes Match (1987-03-11 09:49 AM IST)', () {
      final jd = SwissEphemerisCalculator.getJulianDay(DateTime(1987, 3, 11, 9, 49), utcOffsetHours: 5.5);
      final ayan = SwissEphemerisCalculator.calculateLahiriAyanamsa(jd);

      final planets = SwissEphemerisCalculator.calculatePlanetaryPositions(jd: jd, ayanamsa: ayan);

      // Sun in Aquarius (Kumbha) 26°
      expect((planets['Sun']!.longitude / 30).floor(), 10);
      expect((planets['Sun']!.longitude % 30).floor(), 26);

      // Moon in Cancer (Kataka) 6°
      expect((planets['Moon']!.longitude / 30).floor(), 3);
      expect((planets['Moon']!.longitude % 30).floor(), 6);

      // Mars in Aries (Mesha) 19°
      expect((planets['Mars']!.longitude / 30).floor(), 0);
      expect((planets['Mars']!.longitude % 30).floor(), 19);

      // Mercury in Aquarius (Kumbha) 6°
      expect((planets['Mercury']!.longitude / 30).floor(), 10);
      expect((planets['Mercury']!.longitude % 30).floor(), 6);

      // Jupiter in Pisces (Meena) 8°
      expect((planets['Jupiter']!.longitude / 30).floor(), 11);
      expect((planets['Jupiter']!.longitude % 30).floor(), 8);

      // Venus in Capricorn (Makara) 15°
      expect((planets['Venus']!.longitude / 30).floor(), 9);
      expect((planets['Venus']!.longitude % 30).floor(), 15);

      // Saturn in Scorpio (Vrischika) 27°
      expect((planets['Saturn']!.longitude / 30).floor(), 7);
      expect((planets['Saturn']!.longitude % 30).floor(), 27);

      // Rahu in Pisces (Meena) 19°
      expect((planets['Rahu']!.longitude / 30).floor(), 11);
      expect((planets['Rahu']!.longitude % 30).floor(), 19);

      // Ketu in Virgo (Kanni) 19°
      expect((planets['Ketu']!.longitude / 30).floor(), 5);
      expect((planets['Ketu']!.longitude % 30).floor(), 19);
    });
  });
}
