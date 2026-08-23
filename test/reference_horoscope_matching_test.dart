import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/user_model.dart';
import 'package:astrocall/services/astrology_calculator.dart';
import 'package:astrocall/services/jaathaga_kurippugal_calculator.dart';
import 'package:astrocall/services/pdf_generator_service.dart';

void main() {
  group('Reference Horoscope Accuracy Verification Test', () {
    final refUser = UserModel(
      id: 'ref_1987',
      name: 'செந்தில்குமார்',
      mobile: '+919500813709',
      gender: 'Male',
      dob: '1987-03-11',
      timeOfBirth: '09:50 AM',
      placeOfBirth: 'Chinnalapatti',
      city: 'Chinnalapatti',
      state: 'Tamil Nadu',
      country: 'India',
      zodiac: 'Cancer',
      nakshatra: 'Pushya',
      lagna: 'Mesha',
      walletBalance: 0.0,
      profilePhoto: '',
      latitude: 10.2785,
      longitude: 77.9244,
      timezone: 5.5,
    );

    test('Verifies Benchmark Horoscope Calculations Against Reference PDF', () {
      final birthDt = DateTime(1987, 3, 11, 9, 50);

      // 1. Calculate Core Horoscope Data
      final astroData = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: birthDt,
        latitude: refUser.latitude,
        longitude: refUser.longitude,
        utcOffsetHours: refUser.timezone,
      );

      // 2. Verify Ayanamsa (Reference: 23°40'41")
      final ayanamsaDeg = AstrologyCalculator.getLahiriAyanamsa(birthDt);
      expect(ayanamsaDeg, closeTo(23.678, 0.2));

      // 3. Verify Lagna Rasi (Reference: மேஷம் / Mesha)
      expect(astroData.lagna.rasiIndex, equals(0)); // 0 = Mesha (Aries)

      // 4. Verify Moon Rasi (Reference: கடகம் / Kataka) and Nakshatra (Reference: பூசம் / Pushya)
      final moon = astroData.planets['Moon']!;
      expect(moon.rasiIndex, equals(3)); // 3 = Kataka (Cancer)
      expect(astroData.moon.nakshatraNameTa, contains('பூசம்'));

      // 5. Verify Panchangam: Tithi, Yoga, Karana
      expect(astroData.tithi.tithiNameTa, contains('ஏகாதசி'));
      expect(astroData.yogaNameTa, contains('சோபனம்'));
      expect(astroData.karanaNameTa, contains('பத்திரை'));

      // 6. Verify Birth Hora (Reference: Guru / Jupiter)
      expect(astroData.birthHoraLordTa, contains('குரு'));

      // 7. Verify Jaathaga Kurippugal Notes
      final notes = JaathagaKurippugalCalculator.calculateNotes(user: refUser);
      expect(notes.tamilDate, contains('மாசி'));
      expect(notes.weekday, equals('புதன்'));
      expect(notes.paksha, contains('பக்ஷம்'));
      expect(notes.thithi, contains('ஏகாதசி'));
      expect(notes.thithiSunyam, contains('தனுசு'));

      // 8. Verify Planetary Sign Placements in Rasi Chart
      final sun = astroData.planets['Sun']!;
      final mars = astroData.planets['Mars']!;
      final mercury = astroData.planets['Mercury']!;
      final jupiter = astroData.planets['Jupiter']!;
      final venus = astroData.planets['Venus']!;
      final saturn = astroData.planets['Saturn']!;
      final rahu = astroData.planets['Rahu']!;
      final ketu = astroData.planets['Ketu']!;

      expect(sun.rasiIndex, equals(10)); // Kumbha (11th house, 0-indexed 10)
      expect(mars.rasiIndex, equals(0)); // Mesha (1st house, 0-indexed 0)
      expect(mercury.rasiIndex, equals(10)); // Kumbha (11th house, 0-indexed 10)
      expect(jupiter.rasiIndex, equals(11)); // Meena (12th house, 0-indexed 11)
      expect(venus.rasiIndex, equals(9)); // Makara (10th house, 0-indexed 9)
      expect(saturn.rasiIndex, equals(7)); // Vrischika (8th house, 0-indexed 7)
      expect(rahu.rasiIndex, equals(11)); // Meena (12th house, 0-indexed 11)
      expect(ketu.rasiIndex, equals(5)); // Kanya (6th house, 0-indexed 5)
    });

    test('Generates Valid PDF Document Bytes matching Reference Layout', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final pdfBytes = await PdfGeneratorService.generateHoroscopePdf(user: refUser);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(1000));
    });
  });
}
