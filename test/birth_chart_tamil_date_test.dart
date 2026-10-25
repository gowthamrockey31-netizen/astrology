import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/daily_calendar_engine.dart';
import 'package:astrocall/services/astrology_calculator.dart';
import 'package:astrocall/services/panchanga_provider.dart';
import 'package:astrocall/models/user_model.dart';
import 'package:astrocall/widgets/south_indian_jathagam_widget.dart';
import 'package:flutter/material.dart';

void main() {
  group('Birth Chart & Daily Calendar Tamil Date Consistency Tests', () {
    const provider = AstronomicalPanchangaProvider();

    test('1. Verified Dates produce identical Tamil date in Daily Calendar and Birth Chart', () {
      final testDates = [
        DateTime(1992, 7, 23, 8, 30),  // Reported Test Case: Aadi 8
        DateTime(1992, 7, 16, 6, 0),   // Karka Sankranti 1992: Aadi 1
        DateTime(1998, 8, 4, 10, 30),  // Aadi 19
        DateTime(1998, 10, 21, 14, 0), // Aippasi 5
        DateTime(2026, 10, 21, 8, 30), // Aippasi 5
        DateTime(1995, 8, 15, 8, 30),  // Default seeker DOB: Aavani
        DateTime(2026, 4, 14, 6, 0),   // Chithirai 1
        DateTime(2026, 7, 17, 6, 0),   // Aadi 1
        DateTime(2027, 1, 14, 6, 0),   // Thai 1
        DateTime(2026, 9, 18, 6, 0),   // Purattasi 1
      ];

      for (final date in testDates) {
        // Daily Calendar calculation
        final dailyData = DailyCalendarEngine.calculate(targetDate: date);

        // Birth Chart / Horoscope calculation
        final astroData = AstrologyCalculator.calculateHoroscope(
          dateOfBirth: date,
          latitude: 13.0827,
          longitude: 80.2707,
          utcOffsetHours: 5.5,
        );

        expect(astroData.tamilMonthTa, equals(dailyData.tamilMonth),
            reason: 'Tamil month mismatch on $date');
        expect(astroData.tamilDay, equals(dailyData.tamilDay),
            reason: 'Tamil day mismatch on $date');
        expect(astroData.tamilDateFormatted, equals(dailyData.tamilDateFormatted),
            reason: 'Formatted Tamil date mismatch on $date');
      }
    });

    test('2. Reported Case: 23 July 1992 produces Aadi 8 in Birth Chart & Daily Calendar', () {
      final dob = DateTime(1992, 7, 23, 8, 30);
      final dailyData = DailyCalendarEngine.calculate(targetDate: dob);
      final astroData = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: dob,
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );
      final tamilDate = provider.getTamilDate(dob);

      // Verify Provider output
      expect(tamilDate.tamilMonth, equals('ஆடி'));
      expect(tamilDate.tamilDay, equals(8));
      expect(tamilDate.tamilYear, equals(1992));

      // Verify Daily Calendar output
      expect(dailyData.tamilMonth, equals('ஆடி'));
      expect(dailyData.tamilDay, equals(8));
      expect(dailyData.tamilDateFormatted, equals('ஆடி - 8'));

      // Verify Birth Chart output
      expect(astroData.tamilMonthTa, equals('ஆடி'));
      expect(astroData.tamilDay, equals(8));
      expect(astroData.tamilDateFormatted, equals('ஆடி - 8'));
    });

    test('3. Karka Sankranti 1992: 16 July 1992 is Aadi 1 under Tamil sunrise/sunset rule', () {
      final ingressDate = DateTime(1992, 7, 16, 6, 30);
      final dailyData = DailyCalendarEngine.calculate(targetDate: ingressDate);
      final astroData = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: ingressDate,
        latitude: 13.0827,
        longitude: 80.2707,
        utcOffsetHours: 5.5,
      );
      final tamilDate = provider.getTamilDate(ingressDate);

      expect(tamilDate.tamilMonth, equals('ஆடி'));
      expect(tamilDate.tamilDay, equals(1));

      expect(dailyData.tamilMonth, equals('ஆடி'));
      expect(dailyData.tamilDay, equals(1));
      expect(dailyData.tamilDateFormatted, equals('ஆடி - 1'));

      expect(astroData.tamilMonthTa, equals('ஆடி'));
      expect(astroData.tamilDay, equals(1));
      expect(astroData.tamilDateFormatted, equals('ஆடி - 1'));
    });

    test('4. Adjacent dates around July 1992 month transition form continuous progression', () {
      final expectedDates = {
        DateTime(1992, 7, 14): ('ஆனி', 30),
        DateTime(1992, 7, 15): ('ஆனி', 31),
        DateTime(1992, 7, 16): ('ஆடி', 1),
        DateTime(1992, 7, 17): ('ஆடி', 2),
        DateTime(1992, 7, 18): ('ஆடி', 3),
        DateTime(1992, 7, 22): ('ஆடி', 7),
        DateTime(1992, 7, 23): ('ஆடி', 8),
        DateTime(1992, 7, 24): ('ஆடி', 9),
      };

      for (final entry in expectedDates.entries) {
        final tDate = provider.getTamilDate(entry.key);
        expect(tDate.tamilMonth, equals(entry.value.$1),
            reason: 'Month mismatch for ${entry.key}');
        expect(tDate.tamilDay, equals(entry.value.$2),
            reason: 'Day mismatch for ${entry.key}');
      }
    });

    test('5. Historical leap and non-leap year month transitions are accurately computed', () {
      // 15 August 1947: Sarvajit year, Aadi 31 (Indian Independence Day)
      final indDate = provider.getTamilDate(DateTime(1947, 8, 15));
      expect(indDate.tamilMonth, equals('ஆடி'));
      expect(indDate.tamilDay, equals(31));

      // 26 January 1950: Virodhi year, Thai 13 (Indian Republic Day)
      final repDate = provider.getTamilDate(DateTime(1950, 1, 26));
      expect(repDate.tamilMonth, equals('தை'));
      expect(repDate.tamilDay, equals(13));

      // 4 August 1998 (Non-leap year): Aadi 19
      final aadi98 = provider.getTamilDate(DateTime(1998, 8, 4));
      expect(aadi98.tamilMonth, equals('ஆடி'));
      expect(aadi98.tamilDay, equals(19));

      // 21 October 1998: Aippasi 5
      final aippasi98 = provider.getTamilDate(DateTime(1998, 10, 21));
      expect(aippasi98.tamilMonth, equals('ஐப்பசி'));
      expect(aippasi98.tamilDay, equals(5));
    });

    test('6. Preserved 2020-2030 verified table results remain strictly identical', () {
      final verifiedSamples = [
        (DateTime(2020, 7, 16), 'ஆடி', 1),
        (DateTime(2024, 7, 16), 'ஆடி', 1),
        (DateTime(2026, 4, 14), 'சித்திரை', 1),
        (DateTime(2026, 5, 15), 'வைகாசி', 1),
        (DateTime(2026, 6, 15), 'ஆனி', 1),
        (DateTime(2026, 7, 17), 'ஆடி', 1),
        (DateTime(2026, 8, 17), 'ஆவணி', 1),
        (DateTime(2026, 9, 18), 'புரட்டாசி', 1),
        (DateTime(2026, 10, 18), 'ஐப்பசி', 1),
        (DateTime(2026, 11, 17), 'கார்த்திகை', 1),
        (DateTime(2026, 12, 16), 'மார்கழி', 1),
        (DateTime(2027, 1, 15), 'தை', 1),
        (DateTime(2027, 2, 13), 'மாசி', 1),
        (DateTime(2027, 3, 15), 'பங்குனி', 1),
      ];

      for (final sample in verifiedSamples) {
        final res = provider.getTamilDate(sample.$1);
        expect(res.tamilMonth, equals(sample.$2), reason: 'Mismatch on ${sample.$1}');
        expect(res.tamilDay, equals(sample.$3), reason: 'Mismatch on ${sample.$1}');
      }
    });

    testWidgets('7. SouthIndianJathagamWidget renders actual saved birth date (1992-07-23 -> ஆடி - 8)', (tester) async {
      final testUser1992 = UserModel(
        id: 'test_seeker_1992',
        name: 'Test Seeker 1992',
        mobile: '+919876543210',
        gender: 'Male',
        dob: '1992-07-23',
        timeOfBirth: '08:30 AM',
        placeOfBirth: 'Chennai',
        city: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Aries',
        nakshatra: 'Ashwini',
        lagna: 'Virgo',
        walletBalance: 500.0,
        profilePhoto: '',
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: 5.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SouthIndianJathagamWidget(user: testUser1992),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Expect to find 'ஆடி - 8' in the Panchanga Summary
      expect(find.text('ஆடி - 8'), findsWidgets);
    });

    testWidgets('8. SouthIndianJathagamWidget renders 1998-08-04 DOB as ஆடி - 19', (tester) async {
      final testUser1998 = UserModel(
        id: 'test_seeker_1998',
        name: 'Test Seeker 1998',
        mobile: '+919876543210',
        gender: 'Male',
        dob: '1998-08-04',
        timeOfBirth: '08:30 AM',
        placeOfBirth: 'Chennai',
        city: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Scorpio',
        nakshatra: 'Anusham',
        lagna: 'Virgo',
        walletBalance: 500.0,
        profilePhoto: '',
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: 5.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SouthIndianJathagamWidget(user: testUser1998),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ஆடி - 19'), findsWidgets);
    });
  });
}
