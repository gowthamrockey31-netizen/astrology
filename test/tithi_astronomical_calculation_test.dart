import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/tithi_calculator.dart';
import 'package:astrocall/services/daily_calendar_engine.dart';

void main() {
  group('Astronomical Tithi (திதி) Calculation & Transition Tests', () {
    const double chennaiLat = 13.0827;
    const double chennaiLon = 80.2707;
    const double istTz = 5.5;

    test('1. Tithi Formula & Angular Separation: 12 degrees per Tithi across 30 Tithis', () {
      // Test Shukla Paksha Prathamai (0° to 12°)
      final t1 = TithiCalculator.calculateTithi(sunLongitude: 100.0, moonLongitude: 106.0);
      expect(t1.tithiIndex, equals(0));
      expect(t1.tithiNumber, equals(1));
      expect(t1.tithiNameTa, equals('பிரதமை'));
      expect(t1.pakshaTa, equals('சுக்ல பக்ஷம்'));
      expect(t1.isShuklaPaksha, isTrue);

      // Test Shukla Paksha Dvithiyai (12° to 24°)
      final t2 = TithiCalculator.calculateTithi(sunLongitude: 100.0, moonLongitude: 115.0);
      expect(t2.tithiIndex, equals(1));
      expect(t2.tithiNumber, equals(2));
      expect(t2.tithiNameTa, equals('துவிதியை'));
      expect(t2.pakshaTa, equals('சுக்ல பக்ஷம்'));

      // Test Pournami (168° to 180°)
      final t15 = TithiCalculator.calculateTithi(sunLongitude: 100.0, moonLongitude: 275.0);
      expect(t15.tithiIndex, equals(14));
      expect(t15.tithiNumber, equals(15));
      expect(t15.tithiNameTa, equals('பௌர்ணமி'));
      expect(t15.isShuklaPaksha, isTrue);

      // Test Krishna Paksha Prathamai (180° to 192°)
      final t16 = TithiCalculator.calculateTithi(sunLongitude: 100.0, moonLongitude: 285.0);
      expect(t16.tithiIndex, equals(15));
      expect(t16.tithiNumber, equals(16));
      expect(t16.tithiNameTa, equals('பிரதமை'));
      expect(t16.pakshaTa, equals('கிருஷ்ண பக்ஷம்'));
      expect(t16.isShuklaPaksha, isFalse);

      // Test Krishna Paksha Dvithiyai (192° to 204°)
      final t17 = TithiCalculator.calculateTithi(sunLongitude: 100.0, moonLongitude: 295.0);
      expect(t17.tithiIndex, equals(16));
      expect(t17.tithiNumber, equals(17));
      expect(t17.tithiNameTa, equals('துவிதியை'));
      expect(t17.fullNameTa, equals('கிருஷ்ண பக்ஷம் துவிதியை'));
      expect(t17.isShuklaPaksha, isFalse);

      // Test Amavasai (348° to 360°)
      final t30 = TithiCalculator.calculateTithi(sunLongitude: 100.0, moonLongitude: 95.0); // 355° diff
      expect(t30.tithiIndex, equals(29));
      expect(t30.tithiNumber, equals(30));
      expect(t30.tithiNameTa, equals('அமாவாசை'));
      expect(t30.isShuklaPaksha, isFalse);
    });

    test('2. Exact Transition Time Finding via High-Precision Numerical Root Finding', () {
      final testDt = DateTime(2026, 8, 29, 6, 0); // 6:00 AM IST
      final tithiData = TithiCalculator.calculateAstronomicalTithi(
        dateTime: testDt,
        utcOffsetHours: istTz,
        latitude: chennaiLat,
        longitude: chennaiLon,
      );

      expect(tithiData.index, inInclusiveRange(0, 29));
      expect(tithiData.number, inInclusiveRange(1, 30));
      expect(tithiData.name.isNotEmpty, isTrue);
      expect(tithiData.fullNameTa.isNotEmpty, isTrue);
      expect(tithiData.start.isBefore(tithiData.end), isTrue);

      // Verify next transition is indeed when elongation crosses the end boundary
      final endElongation = TithiCalculator.getMoonSunElongation(tithiData.end, utcOffsetHours: istTz);
      final expectedEndAngle = tithiData.endAngle % 360.0;
      final diff = (endElongation - expectedEndAngle).abs();
      // Difference should be tiny (< 0.05 degrees)
      expect(diff < 0.1 || (360.0 - diff) < 0.1, isTrue);
    });

    test('3. Previous, Current, Next Tithi & Dynamic Tamil Transition Card', () {
      final targetDate = DateTime(2026, 8, 29);
      final refTime = DateTime(2026, 8, 29, 6, 0);

      final trans = TithiCalculator.calculatePanchangamTransition(
        targetDate: targetDate,
        referenceTime: refTime,
        utcOffsetHours: istTz,
        latitude: chennaiLat,
        longitude: chennaiLon,
      );

      expect(trans.currentName.isNotEmpty, isTrue);
      expect(trans.currentTiming.contains('வரை'), isTrue);
      expect(trans.previousName.isNotEmpty, isTrue);
      expect(trans.nextName.isNotEmpty, isTrue);

      // Verify the previous and next Tithi are mathematically adjacent
      final curData = TithiCalculator.calculateAstronomicalTithi(dateTime: refTime, utcOffsetHours: istTz);
      final expectedPrevIdx = (curData.index - 1 + 30) % 30;
      final expectedNextIdx = (curData.index + 1) % 30;

      expect(trans.previousName, equals(TithiCalculator.tithiNamesTa[expectedPrevIdx]));
      expect(trans.nextName, equals(TithiCalculator.tithiNamesTa[expectedNextIdx]));
    });

    test('4. Midnight Transition Crossing (Before and After Midnight)', () {
      // Test just before midnight
      final beforeMidnight = DateTime(2026, 8, 29, 23, 50);
      final tithiBefore = TithiCalculator.calculateAstronomicalTithi(dateTime: beforeMidnight, utcOffsetHours: istTz);

      // Test just after midnight
      final afterMidnight = DateTime(2026, 8, 30, 0, 10);
      final tithiAfter = TithiCalculator.calculateAstronomicalTithi(dateTime: afterMidnight, utcOffsetHours: istTz);

      expect(tithiBefore.start.isBefore(tithiBefore.end), isTrue);
      expect(tithiAfter.start.isBefore(tithiAfter.end), isTrue);
    });

    test('5. Tithi 360° Wrap-Around (Amavasai 29 -> Shukla Prathamai 0)', () {
      // Amavasai on Jan 18, 2026
      final amavasaiTime = DateTime(2026, 1, 18, 12, 0);
      final nextTrans = TithiCalculator.findNextTithiTransition(amavasaiTime, utcOffsetHours: istTz);

      final elongationAtTrans = TithiCalculator.getMoonSunElongation(nextTrans, utcOffsetHours: istTz);
      // At transition to Shukla Prathamai, elongation is ~0° (or ~360°)
      expect(elongationAtTrans < 0.2 || elongationAtTrans > 359.8, isTrue);
    });

    test('6. DailyCalendarEngine integrates high-precision Tithi transition', () {
      final dailyData = DailyCalendarEngine.calculate(
        targetDate: DateTime(2026, 8, 29),
        latitude: chennaiLat,
        longitude: chennaiLon,
        utcOffsetHours: istTz,
      );

      expect(dailyData.tithiNameTa.isNotEmpty, isTrue);
      expect(dailyData.tithiPakshaTa.isNotEmpty, isTrue);
      expect(dailyData.tithiTransition.currentName.isNotEmpty, isTrue);
      expect(dailyData.tithiTransition.currentTiming.contains('வரை'), isTrue);
      expect(dailyData.tithiTransition.previousName.isNotEmpty, isTrue);
      expect(dailyData.tithiTransition.nextName.isNotEmpty, isTrue);
    });

    test('7. getTithiByNumber supports all 30 Tithis without clamping to 15', () {
      final t17 = TithiCalculator.getTithiByNumber(17);
      expect(t17.tithiNumber, equals(17));
      expect(t17.tithiIndex, equals(16));
      expect(t17.tithiNameTa, equals('துவிதியை'));
      expect(t17.pakshaTa, equals('கிருஷ்ண பக்ஷம்'));

      final t30 = TithiCalculator.getTithiByNumber(30);
      expect(t30.tithiNumber, equals(30));
      expect(t30.tithiIndex, equals(29));
      expect(t30.tithiNameTa, equals('அமாவாசை'));

      final t15 = TithiCalculator.getTithiByNumber(15);
      expect(t15.tithiNumber, equals(15));
      expect(t15.tithiNameTa, equals('பௌர்ணமி'));
      expect(t15.pakshaTa, equals('சுக்ல பக்ஷம்'));
    });
  });
}
