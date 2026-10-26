import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/modules/professional_muhurtha/professional_muhurtha.dart';

void main() {
  group('Subha Muhurtham - 4 Nama Yogam Types Implementation Tests', () {
    // -------------------------------------------------------------------------
    // 1. LABEL & ENUM VERIFICATION
    // -------------------------------------------------------------------------
    test('Four Nama Yogam labels match requested specification exactly', () {
      expect(SubhaNamaYogaType.amirtha.tamilLabel, 'அமிர்தயோகம்');
      expect(SubhaNamaYogaType.amirtha.englishLabel, 'Amirtha Yogam');
      expect(SubhaNamaYogaType.amirtha.isAuspicious, isTrue);

      expect(SubhaNamaYogaType.siddha.tamilLabel, 'சித்தயோகம்');
      expect(SubhaNamaYogaType.siddha.englishLabel, 'Siddha Yogam');
      expect(SubhaNamaYogaType.siddha.isAuspicious, isTrue);

      expect(SubhaNamaYogaType.marana.tamilLabel, 'மரணயோகம்');
      expect(SubhaNamaYogaType.marana.englishLabel, 'Marana Yogam');
      expect(SubhaNamaYogaType.marana.isAuspicious, isFalse);

      expect(SubhaNamaYogaType.prabalaArishta.tamilLabel, 'பிரபலாரிஷ்ட யோகம்');
      expect(SubhaNamaYogaType.prabalaArishta.englishLabel, 'Prabala Arishta Yogam');
      expect(SubhaNamaYogaType.prabalaArishta.isAuspicious, isFalse);
    });

    // -------------------------------------------------------------------------
    // 2. SUNDAY (ஞாயிறு - weekdayNum = 7)
    // -------------------------------------------------------------------------
    test('Sunday (ஞாயிறு) 27 Nakshatras partition correctly', () {
      const weekday = 7;
      final prabala = {1}; // Bharani
      final amirtha = {11, 18, 20, 21, 25, 26}; // Uttara Phalguni, Mula, Uttara Ashadha, Shravana, Uttara Bhadrapada, Revati
      final marana = {9, 15, 16, 17, 22}; // Magha, Vishakha, Anuradha, Jyeshtha, Dhanishta
      final siddha = {0, 2, 3, 4, 5, 6, 7, 8, 10, 12, 13, 14, 19, 23, 24}; // Ashwini, Krittika, Rohini, Mrigashirsha, Ardra, Punarvasu, Pushya, Ashlesha, Purva Phalguni, Hasta, Chitra, Swati, Purva Ashadha, Shatabhisha, Purva Bhadrapada

      expect(prabala.length + amirtha.length + marana.length + siddha.length, 27);

      for (int i = 0; i < 27; i++) {
        final yoga = ProfessionalMuhurthaEngine.calculateNamaYoga(weekday, i);
        if (prabala.contains(i)) {
          expect(yoga, SubhaNamaYogaType.prabalaArishta, reason: 'Sunday nakIdx $i');
        } else if (amirtha.contains(i)) {
          expect(yoga, SubhaNamaYogaType.amirtha, reason: 'Sunday nakIdx $i');
        } else if (marana.contains(i)) {
          expect(yoga, SubhaNamaYogaType.marana, reason: 'Sunday nakIdx $i');
        } else if (siddha.contains(i)) {
          expect(yoga, SubhaNamaYogaType.siddha, reason: 'Sunday nakIdx $i');
        } else {
          fail('Nakshatra index $i not covered on Sunday');
        }
      }
    });

    // -------------------------------------------------------------------------
    // 3. MONDAY (திங்கள் - weekdayNum = 1)
    // -------------------------------------------------------------------------
    test('Monday (திங்கள்) 27 Nakshatras partition correctly', () {
      const weekday = 1;
      final prabala = {13}; // Chitra
      final amirtha = {3, 6, 14, 21}; // Rohini, Punarvasu, Swati, Shravana
      final marana = {2, 9, 15, 19, 20, 24}; // Krittika, Magha, Vishakha, Purva Ashadha, Uttara Ashadha, Purva Bhadrapada
      final siddha = {0, 1, 4, 5, 7, 8, 10, 11, 12, 16, 17, 18, 22, 23, 25, 26}; // Ashwini, Bharani, Mrigashirsha, Ardra, Pushya, Ashlesha, Purva Phalguni, Uttara Phalguni, Hasta, Anuradha, Jyeshtha, Mula, Dhanishta, Shatabhisha, Uttara Bhadrapada, Revati

      expect(prabala.length + amirtha.length + marana.length + siddha.length, 27);

      for (int i = 0; i < 27; i++) {
        final yoga = ProfessionalMuhurthaEngine.calculateNamaYoga(weekday, i);
        if (prabala.contains(i)) {
          expect(yoga, SubhaNamaYogaType.prabalaArishta, reason: 'Monday nakIdx $i');
        } else if (amirtha.contains(i)) {
          expect(yoga, SubhaNamaYogaType.amirtha, reason: 'Monday nakIdx $i');
        } else if (marana.contains(i)) {
          expect(yoga, SubhaNamaYogaType.marana, reason: 'Monday nakIdx $i');
        } else if (siddha.contains(i)) {
          expect(yoga, SubhaNamaYogaType.siddha, reason: 'Monday nakIdx $i');
        } else {
          fail('Nakshatra index $i not covered on Monday');
        }
      }
    });

    // -------------------------------------------------------------------------
    // 4. TUESDAY (செவ்வாய் - weekdayNum = 2)
    // -------------------------------------------------------------------------
    test('Tuesday (செவ்வாய்) 27 Nakshatras partition correctly', () {
      const weekday = 2;
      final prabala = {20}; // Uttara Ashadha
      final amirtha = {3, 11, 18, 25}; // Rohini, Uttara Phalguni, Mula, Uttara Bhadrapada
      final marana = {5, 15, 17, 23, 24}; // Ardra, Vishakha, Jyeshtha, Shatabhisha, Purva Bhadrapada
      final siddha = {0, 1, 2, 4, 6, 7, 8, 9, 10, 12, 13, 14, 16, 19, 21, 22, 26}; // Ashwini, Bharani, Krittika, Mrigashirsha, Punarvasu, Pushya, Ashlesha, Magha, Purva Phalguni, Hasta, Chitra, Swati, Anuradha, Purva Ashadha, Shravana, Dhanishta, Revati

      expect(prabala.length + amirtha.length + marana.length + siddha.length, 27);

      for (int i = 0; i < 27; i++) {
        final yoga = ProfessionalMuhurthaEngine.calculateNamaYoga(weekday, i);
        if (prabala.contains(i)) {
          expect(yoga, SubhaNamaYogaType.prabalaArishta, reason: 'Tuesday nakIdx $i');
        } else if (amirtha.contains(i)) {
          expect(yoga, SubhaNamaYogaType.amirtha, reason: 'Tuesday nakIdx $i');
        } else if (marana.contains(i)) {
          expect(yoga, SubhaNamaYogaType.marana, reason: 'Tuesday nakIdx $i');
        } else if (siddha.contains(i)) {
          expect(yoga, SubhaNamaYogaType.siddha, reason: 'Tuesday nakIdx $i');
        } else {
          fail('Nakshatra index $i not covered on Tuesday');
        }
      }
    });

    // -------------------------------------------------------------------------
    // 5. WEDNESDAY (புதன் - weekdayNum = 3)
    // -------------------------------------------------------------------------
    test('Wednesday (புதன்) 27 Nakshatras partition correctly', () {
      const weekday = 3;
      final prabala = {22}; // Dhanishta
      final amirtha = {2, 10, 11, 19, 20, 24}; // Krittika, Purva Phalguni, Uttara Phalguni, Purva Ashadha, Uttara Ashadha, Purva Bhadrapada
      final marana = {0, 12, 18, 26}; // Ashwini, Hasta, Mula, Revati
      final siddha = {1, 3, 4, 5, 6, 7, 8, 9, 13, 14, 15, 16, 17, 21, 23, 25}; // Bharani, Rohini, Mrigashirsha, Ardra, Punarvasu, Pushya, Ashlesha, Magha, Chitra, Swati, Vishakha, Anuradha, Jyeshtha, Shravana, Shatabhisha, Uttara Bhadrapada

      expect(prabala.length + amirtha.length + marana.length + siddha.length, 27);

      for (int i = 0; i < 27; i++) {
        final yoga = ProfessionalMuhurthaEngine.calculateNamaYoga(weekday, i);
        if (prabala.contains(i)) {
          expect(yoga, SubhaNamaYogaType.prabalaArishta, reason: 'Wednesday nakIdx $i');
        } else if (amirtha.contains(i)) {
          expect(yoga, SubhaNamaYogaType.amirtha, reason: 'Wednesday nakIdx $i');
        } else if (marana.contains(i)) {
          expect(yoga, SubhaNamaYogaType.marana, reason: 'Wednesday nakIdx $i');
        } else if (siddha.contains(i)) {
          expect(yoga, SubhaNamaYogaType.siddha, reason: 'Wednesday nakIdx $i');
        } else {
          fail('Nakshatra index $i not covered on Wednesday');
        }
      }
    });

    // -------------------------------------------------------------------------
    // 6. THURSDAY (வியாழன் - weekdayNum = 4)
    // -------------------------------------------------------------------------
    test('Thursday (வியாழன்) 27 Nakshatras partition correctly', () {
      const weekday = 4;
      final prabala = {17}; // Jyeshtha
      final amirtha = {0, 6, 9, 14}; // Ashwini, Punarvasu, Magha, Swati
      final marana = {2, 3, 4, 5, 11, 23}; // Krittika, Rohini, Mrigashirsha, Ardra, Uttara Phalguni, Shatabhisha
      final siddha = {1, 7, 8, 10, 12, 13, 15, 16, 18, 19, 20, 21, 22, 24, 25, 26}; // Bharani, Pushya, Ashlesha, Purva Phalguni, Hasta, Chitra, Vishakha, Anuradha, Mula, Purva Ashadha, Uttara Ashadha, Shravana, Dhanishta, Purva Bhadrapada, Uttara Bhadrapada, Revati

      expect(prabala.length + amirtha.length + marana.length + siddha.length, 27);

      for (int i = 0; i < 27; i++) {
        final yoga = ProfessionalMuhurthaEngine.calculateNamaYoga(weekday, i);
        if (prabala.contains(i)) {
          expect(yoga, SubhaNamaYogaType.prabalaArishta, reason: 'Thursday nakIdx $i');
        } else if (amirtha.contains(i)) {
          expect(yoga, SubhaNamaYogaType.amirtha, reason: 'Thursday nakIdx $i');
        } else if (marana.contains(i)) {
          expect(yoga, SubhaNamaYogaType.marana, reason: 'Thursday nakIdx $i');
        } else if (siddha.contains(i)) {
          expect(yoga, SubhaNamaYogaType.siddha, reason: 'Thursday nakIdx $i');
        } else {
          fail('Nakshatra index $i not covered on Thursday');
        }
      }
    });

    // -------------------------------------------------------------------------
    // 7. FRIDAY (வெள்ளி - weekdayNum = 5)
    // -------------------------------------------------------------------------
    test('Friday (வெள்ளி) 27 Nakshatras partition correctly', () {
      const weekday = 5;
      final prabala = {19}; // Purva Ashadha
      final amirtha = {0, 12, 18}; // Ashwini, Hasta, Mula
      final marana = {3, 7, 8, 9, 17, 21}; // Rohini, Pushya, Ashlesha, Magha, Jyeshtha, Shravana
      final siddha = {1, 2, 4, 5, 6, 10, 11, 13, 14, 15, 16, 20, 22, 23, 24, 25, 26}; // Bharani, Krittika, Mrigashirsha, Ardra, Punarvasu, Purva Phalguni, Uttara Phalguni, Chitra, Swati, Vishakha, Anuradha, Uttara Ashadha, Dhanishta, Shatabhisha, Purva Bhadrapada, Uttara Bhadrapada, Revati

      expect(prabala.length + amirtha.length + marana.length + siddha.length, 27);

      for (int i = 0; i < 27; i++) {
        final yoga = ProfessionalMuhurthaEngine.calculateNamaYoga(weekday, i);
        if (prabala.contains(i)) {
          expect(yoga, SubhaNamaYogaType.prabalaArishta, reason: 'Friday nakIdx $i');
        } else if (amirtha.contains(i)) {
          expect(yoga, SubhaNamaYogaType.amirtha, reason: 'Friday nakIdx $i');
        } else if (marana.contains(i)) {
          expect(yoga, SubhaNamaYogaType.marana, reason: 'Friday nakIdx $i');
        } else if (siddha.contains(i)) {
          expect(yoga, SubhaNamaYogaType.siddha, reason: 'Friday nakIdx $i');
        } else {
          fail('Nakshatra index $i not covered on Friday');
        }
      }
    });

    // -------------------------------------------------------------------------
    // 8. SATURDAY (சனி - weekdayNum = 6)
    // -------------------------------------------------------------------------
    test('Saturday (சனி) 27 Nakshatras partition correctly', () {
      const weekday = 6;
      final prabala = {26}; // Revati
      final amirtha = {3, 9, 23}; // Rohini, Magha, Shatabhisha
      final marana = {8, 11, 12, 13, 24}; // Ashlesha, Uttara Phalguni, Hasta, Chitra, Purva Bhadrapada
      final siddha = {0, 1, 2, 4, 5, 6, 7, 10, 14, 15, 16, 17, 18, 19, 20, 21, 22, 25}; // Ashwini, Bharani, Krittika, Mrigashirsha, Ardra, Punarvasu, Pushya, Purva Phalguni, Swati, Vishakha, Anuradha, Jyeshtha, Mula, Purva Ashadha, Uttara Ashadha, Shravana, Dhanishta, Uttara Bhadrapada

      expect(prabala.length + amirtha.length + marana.length + siddha.length, 27);

      for (int i = 0; i < 27; i++) {
        final yoga = ProfessionalMuhurthaEngine.calculateNamaYoga(weekday, i);
        if (prabala.contains(i)) {
          expect(yoga, SubhaNamaYogaType.prabalaArishta, reason: 'Saturday nakIdx $i');
        } else if (amirtha.contains(i)) {
          expect(yoga, SubhaNamaYogaType.amirtha, reason: 'Saturday nakIdx $i');
        } else if (marana.contains(i)) {
          expect(yoga, SubhaNamaYogaType.marana, reason: 'Saturday nakIdx $i');
        } else if (siddha.contains(i)) {
          expect(yoga, SubhaNamaYogaType.siddha, reason: 'Saturday nakIdx $i');
        } else {
          fail('Nakshatra index $i not covered on Saturday');
        }
      }
    });

    // -------------------------------------------------------------------------
    // 9. NAKSHATRA TRANSITIONS & DYNAMIC RECALCULATION
    // -------------------------------------------------------------------------
    test('calculateMuhurtha dynamically calculates and displays transition when Nakshatra changes', () {
      final engine = ProfessionalMuhurthaEngine();
      const location = GeoLocation(
        name: 'Chennai',
        latitude: 13.0827,
        longitude: 80.2707,
        timeZone: 5.5,
      );

      // 2026-10-25: Sunday (ஞாயிறு)
      final res = engine.calculate(
        date: DateTime(2026, 10, 25),
        location: location,
        category: MuhurthaCategory.generalSubha,
      );

      expect(res.angas.amirthathiYoga, isNotEmpty);
      expect(res.angas.yogaReason, isNotEmpty);

      // Check if primary and/or next yoga is populated
      expect(res.angas.primaryNamaYoga, isNotNull);
      final primary = res.angas.primaryNamaYoga!;
      expect(
        [
          SubhaNamaYogaType.amirtha,
          SubhaNamaYogaType.siddha,
          SubhaNamaYogaType.marana,
          SubhaNamaYogaType.prabalaArishta,
        ].contains(primary),
        isTrue,
      );

      // If transition occurs during the day, verify format
      if (res.angas.nextNamaYoga != null && res.angas.yogaTransitionTime != null) {
        expect(res.angas.amirthathiYoga, contains(primary.tamilLabel));
        expect(res.angas.amirthathiYoga, contains(res.angas.nextNamaYoga!.tamilLabel));
        expect(res.angas.amirthathiYoga, contains('பின்'));
        expect(res.angas.amirthathiYoga, contains('வரை'));
      } else {
        expect(res.angas.amirthathiYoga, equals(primary.tamilLabel));
      }
    });

    // -------------------------------------------------------------------------
    // 10. TIME SLOTS & ELIGIBILITY CALCULATIONS UNCHANGED
    // -------------------------------------------------------------------------
    test('Subha Muhurtham time slots and Abhijit calculations remain intact', () {
      final engine = ProfessionalMuhurthaEngine();
      const location = GeoLocation(
        name: 'Chennai',
        latitude: 13.0827,
        longitude: 80.2707,
        timeZone: 5.5,
      );

      final res = engine.calculate(
        date: DateTime(2026, 10, 25),
        location: location,
        category: MuhurthaCategory.generalSubha,
      );

      // Abhijit Muhurtham exists and is valid
      expect(res.abhijitMuhurtham, isNotNull);
      expect(res.abhijitMuhurtham!.timingFormatted, isNotEmpty);
      expect(res.abhijitMuhurtham!.durationFormatted, isNotEmpty);

      // Inauspicious periods (Rahu, Yama, Gulikai, Visha, Sandhya) exist and calculated
      expect(res.inauspiciousPeriods, isNotEmpty);
      expect(res.level2Avoidance.rahuKalam.timingFormatted, isNotEmpty);
      expect(res.level2Avoidance.yamagandam.timingFormatted, isNotEmpty);
      expect(res.level2Avoidance.kuligai.timingFormatted, isNotEmpty);
    });
  });
}
