import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/astrology_calculator.dart';

void main() {
  group('Senthilkumar Rasi Sphutam Reference Calibration & Location Test', () {
    test('Calculates exact planetary degrees for Dindigul matching reference app (Image 3)', () {
      final dt = DateTime(1987, 3, 11, 9, 50, 0);
      final res = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: dt,
        latitude: 10.3673,
        longitude: 77.9803,
        utcOffsetHours: 5.5,
      );

      // Verify Ayanamsa
      expect(res.ayanamsaFormatted, equals("23°40'39\""));

      // Verify Lagna & Grahas
      final lagna = res.planets['Lagna']!;
      expect(lagna.degreeFormatted, equals("23°14'04\""));
      expect(lagna.rasiNameTa, equals('மேஷம்'));
      expect(lagna.nakshatraNameTa, equals('பரணி'));
      expect(lagna.pada, equals(3));

      final sun = res.planets['Sun']!;
      expect(sun.degreeFormatted, equals("26°23'26\""));
      expect(sun.rasiNameTa, equals('கும்பம்'));
      expect(sun.nakshatraNameTa, equals('பூரட்டாதி'));
      expect(sun.pada, equals(2));

      final moon = res.planets['Moon']!;
      expect(moon.degreeFormatted, equals("06°31'41\""));
      expect(moon.rasiNameTa, equals('கடகம்'));
      expect(moon.nakshatraNameTa, equals('பூசம்'));
      expect(moon.pada, equals(1));

      final mars = res.planets['Mars']!;
      expect(mars.degreeFormatted, equals("19°03'24\""));
      expect(mars.rasiNameTa, equals('மேஷம்'));
      expect(mars.nakshatraNameTa, equals('பரணி'));
      expect(mars.pada, equals(2));

      final merc = res.planets['Mercury']!;
      expect(merc.degreeFormatted, equals("06°26'03\""));
      expect(merc.rasiNameTa, equals('கும்பம்'));
      expect(merc.nakshatraNameTa, equals('அவிட்டம்'));
      expect(merc.pada, equals(4));
      expect(merc.isRetrograde, isTrue);

      final jup = res.planets['Jupiter']!;
      expect(jup.degreeFormatted, equals("08°20'54\""));
      expect(jup.rasiNameTa, equals('மீனம்'));
      expect(jup.nakshatraNameTa, equals('உத்தரட்டாதி'));
      expect(jup.pada, equals(2));

      final ven = res.planets['Venus']!;
      expect(ven.degreeFormatted, equals("15°33'14\""));
      expect(ven.rasiNameTa, equals('மகரம்'));
      expect(ven.nakshatraNameTa, equals('திருவோணம்'));
      expect(ven.pada, equals(2));

      final sat = res.planets['Saturn']!;
      expect(sat.degreeFormatted, equals("27°09'19\""));
      expect(sat.rasiNameTa, equals('விருச்சிகம்'));
      expect(sat.nakshatraNameTa, equals('கேட்டை'));
      expect(sat.pada, equals(4));

      final rahu = res.planets['Rahu']!;
      expect(rahu.degreeFormatted, equals("19°09'02\""));
      expect(rahu.rasiNameTa, equals('மீனம்'));
      expect(rahu.nakshatraNameTa, equals('ரேவதி'));
      expect(rahu.pada, equals(1));
      expect(rahu.isRetrograde, isTrue);

      final ketu = res.planets['Ketu']!;
      expect(ketu.degreeFormatted, equals("19°09'02\""));
      expect(ketu.rasiNameTa, equals('கன்னி'));
      expect(ketu.nakshatraNameTa, equals('ஹஸ்தம்'));
      expect(ketu.pada, equals(3));
      expect(ketu.isRetrograde, isTrue);
    });

    test('Lagna degree dynamically changes based on location when place is changed', () {
      final dt = DateTime(1987, 3, 11, 9, 50, 0);

      // Dindigul
      final resDindigul = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: dt,
        latitude: 10.3673,
        longitude: 77.9803,
        utcOffsetHours: 5.5,
      );

      // Chennai
      final resChennai = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: dt,
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );

      // Degree must change when location changes!
      expect(resDindigul.lagna.degreeFormatted, equals("23°14'04\""));
      expect(resChennai.lagna.degreeFormatted, equals("26°36'00\""));
      expect(resDindigul.lagna.degreeFormatted != resChennai.lagna.degreeFormatted, isTrue);
    });

    test('Standard calculation continues to work for other dates without disturbance', () {
      final dt = DateTime(2000, 1, 1, 12, 0, 0);
      final res = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: dt,
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );
      expect(res.planets.containsKey('Sun'), isTrue);
      expect(res.planets.containsKey('Moon'), isTrue);
      expect(res.planets.containsKey('Lagna'), isTrue);
    });
  });
}
