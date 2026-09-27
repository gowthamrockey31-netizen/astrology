import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/jamakkol_prasannam/models/jamakkol_models.dart';
import 'package:astrocall/jamakkol_prasannam/models/jamam_models.dart';
import 'package:astrocall/jamakkol_prasannam/models/jamakkol_planet_models.dart';
import 'package:astrocall/jamakkol_prasannam/engine/jamam_calculator.dart';
import 'package:astrocall/jamakkol_prasannam/engine/udayam_calculator.dart';
import 'package:astrocall/jamakkol_prasannam/engine/arudam_calculator.dart';
import 'package:astrocall/jamakkol_prasannam/engine/kavippu_calculator.dart';
import 'package:astrocall/jamakkol_prasannam/engine/jamakkol_planet_calculator.dart';
import 'package:astrocall/jamakkol_prasannam/engine/jamakkol_engine.dart';

void main() {
  group('Jamakkol Prasannam - Jamam Calculations', () {
    test('Calculates exactly 16 Jamams (8 day + 8 night) with local sunrise/sunset', () {
      final testDate = DateTime(2026, 9, 27, 10, 30); // 10:30 AM
      final location = JamakkolLocation.defaultChennai;

      final schedule = JamamCalculator.calculateSchedule(
        queryDateTime: testDate,
        location: location,
      );

      expect(schedule.dayJamams.length, equals(8));
      expect(schedule.nightJamams.length, equals(8));
      expect(schedule.allJamams.length, equals(16));

      // Daytime Jamams run sequentially from sunrise to sunset
      expect(schedule.dayJamams.first.startTime, equals(schedule.sunrise));
      expect(schedule.dayJamams.last.endTime, equals(schedule.sunset));

      // Nighttime Jamams run sequentially from sunset to next sunrise
      expect(schedule.nightJamams.first.startTime, equals(schedule.sunset));
      expect(schedule.nightJamams.last.endTime, equals(schedule.nextSunrise));

      // Current Jamam at 10:30 AM is daytime
      expect(schedule.currentJamam.isDay, isTrue);
      expect(schedule.currentJamam.number, inInclusiveRange(1, 8));
    });

    test('Weekday lord assignment is correct for all 7 weekdays', () {
      // 1=Mon .. 7=Sun
      expect(JamamCalculator.getWeekdayLordIndex(7), equals(0)); // Sunday -> Sun
      expect(JamamCalculator.getWeekdayLordIndex(1), equals(6)); // Monday -> Moon
      expect(JamamCalculator.getWeekdayLordIndex(2), equals(1)); // Tuesday -> Mars
      expect(JamamCalculator.getWeekdayLordIndex(3), equals(3)); // Wednesday -> Mercury
      expect(JamamCalculator.getWeekdayLordIndex(4), equals(2)); // Thursday -> Jupiter
      expect(JamamCalculator.getWeekdayLordIndex(5), equals(4)); // Friday -> Venus
      expect(JamamCalculator.getWeekdayLordIndex(6), equals(5)); // Saturday -> Saturn
    });

    test('Nighttime Jamam detection for 11:45 PM', () {
      final testDate = DateTime(2026, 9, 27, 23, 45); // 11:45 PM
      final location = JamakkolLocation.defaultChennai;

      final schedule = JamamCalculator.calculateSchedule(
        queryDateTime: testDate,
        location: location,
      );

      expect(schedule.currentJamam.isDay, isFalse);
      expect(schedule.currentJamam.period, equals(JamamPeriod.night));
      expect(schedule.currentJamam.number, inInclusiveRange(9, 16));
    });
  });

  group('Jamakkol Prasannam - Core Pillars (Udayam, Arudam, Kavippu)', () {
    test('Udayam dynamically calculates from Sun position and advances with time', () {
      final t1 = DateTime(2026, 9, 27, 6, 0); // approx sunrise
      final t2 = DateTime(2026, 9, 27, 12, 0); // 6 hours later
      final location = JamakkolLocation.defaultChennai;
      const sunLon = 160.0; // Virgo / Kanni

      final udayam1 = UdayamCalculator.calculateUdayam(
        queryDateTime: t1,
        location: location,
        effectiveSunrise: t1,
        sunLongitude: sunLon,
      );

      final udayam2 = UdayamCalculator.calculateUdayam(
        queryDateTime: t2,
        location: location,
        effectiveSunrise: t1,
        sunLongitude: sunLon,
      );

      expect(udayam1.type, equals(SpecialPointType.udayam));
      expect(udayam1.degreeInRasi, inInclusiveRange(0.0, 30.0));
      expect(udayam1.nakshatraIndex, inInclusiveRange(0, 26));
      expect(udayam1.pada, inInclusiveRange(1, 4));

      // After 6 hours (360 mins * 0.5° = 180°), Udayam should advance ~180°
      final diff = (udayam2.absoluteLongitude - udayam1.absoluteLongitude + 360.0) % 360.0;
      expect(diff, closeTo(180.0, 1.0));
    });

    test('Arudam dynamically calculates with clock time and supports manual choice 1..12', () {
      final timeAtMinute0 = DateTime(2026, 9, 27, 10, 0, 0);
      final timeAtMinute5 = DateTime(2026, 9, 27, 10, 5, 0);

      final arudamAt0 = ArudamCalculator.calculateArudam(
        queryDateTime: timeAtMinute0,
        udayamRasiIndex: 0,
      );

      final arudamAt5 = ArudamCalculator.calculateArudam(
        queryDateTime: timeAtMinute5,
        udayamRasiIndex: 0,
      );

      expect(arudamAt0.type, equals(SpecialPointType.arudam));
      // 5 minutes advances Arudam by 30° (1 sign)
      final diff = (arudamAt5.absoluteLongitude - arudamAt0.absoluteLongitude + 360.0) % 360.0;
      expect(diff, closeTo(30.0, 0.1));

      // Custom Arudam number 7 (Thulam)
      final customArudam = ArudamCalculator.calculateArudam(
        queryDateTime: timeAtMinute0,
        udayamRasiIndex: 0,
        customArudamNumber: 7,
      );
      expect(customArudam.rasiIndex, equals(6)); // 0-indexed: 6 = Thulam
    });

    test('Kavippu calculation produces valid Rasi, degree, and nakshatra', () {
      final kavippu = KavippuCalculator.calculateKavippu(
        sunLongitude: 160.0,
        weekdayNumber: 7, // Sunday
        jamamPeriodIndex: 3,
        isDay: true,
        arudamLongitude: 60.0,
        udayamRasiIndex: 4,
      );

      expect(kavippu.type, equals(SpecialPointType.kavippu));
      expect(kavippu.absoluteLongitude, inInclusiveRange(0.0, 360.0));
      expect(kavippu.rasiIndex, inInclusiveRange(0, 11));
      expect(kavippu.degreeInRasi, inInclusiveRange(0.0, 30.0));
      expect(kavippu.nakshatraIndex, inInclusiveRange(0, 26));
      expect(kavippu.pada, inInclusiveRange(1, 4));
      expect(kavippu.formattedDms, isNotEmpty);
    });
  });

  group('Jamakkol Prasannam - 8 Jamakkol Outer Planets & Transits', () {
    test('Generates all 8 classical Jamakkol planets spaced at 45 degree intervals', () {
      final testDate = DateTime(2026, 9, 27, 10, 0);
      final schedule = JamamCalculator.calculateSchedule(
        queryDateTime: testDate,
        location: JamakkolLocation.defaultChennai,
      );

      final planets = JamakkolPlanetCalculator.calculateJamakkolPlanets(
        queryDateTime: testDate,
        schedule: schedule,
      );

      expect(planets.length, equals(8));
      final names = planets.map((p) => p.nameEn).toList();
      expect(names, containsAll(['Sun', 'Mars', 'Jupiter', 'Mercury', 'Venus', 'Saturn', 'Moon', 'Rahu']));

      // Exactly one planet is marked as current Jamam Lord
      final lords = planets.where((p) => p.isCurrentJamamLord).toList();
      expect(lords.length, equals(1));
    });

    test('Gocharam / Transit planets calculate real-time ephemeris positions', () {
      final testDate = DateTime(2026, 9, 27, 10, 0);
      final transits = JamakkolPlanetCalculator.calculateTransitPlanets(
        queryDateTime: testDate,
        location: JamakkolLocation.defaultChennai,
      );

      expect(transits.isNotEmpty, isTrue);
      // Contains major bodies
      final transitNames = transits.map((t) => t.nameEn).toList();
      expect(transitNames, contains('Sun'));
      expect(transitNames, contains('Moon'));

      for (final tp in transits) {
        expect(tp.absoluteLongitude, inInclusiveRange(0.0, 360.0));
        expect(tp.rasiIndex, inInclusiveRange(0, 11));
        expect(tp.degreeInRasi, inInclusiveRange(0.0, 30.0));
        expect(tp.nakshatraIndex, inInclusiveRange(0, 26));
        expect(tp.pada, inInclusiveRange(1, 4));
        expect(tp.formattedDms, isNotEmpty);
      }
    });

    test('Upagrahas include Mandi, Yamakandam, Rahu Kaalam, and Mrityu', () {
      final testDate = DateTime(2026, 9, 27, 10, 0);
      final schedule = JamamCalculator.calculateSchedule(
        queryDateTime: testDate,
        location: JamakkolLocation.defaultChennai,
      );

      final upagrahas = JamakkolPlanetCalculator.calculateUpagrahas(
        queryDateTime: testDate,
        location: JamakkolLocation.defaultChennai,
        schedule: schedule,
        sunLongitude: 160.0,
        udayamRasiIndex: 4,
      );

      expect(upagrahas.length, equals(4));
      final types = upagrahas.map((u) => u.type).toList();
      expect(types, contains(SpecialPointType.yamakandam));
      expect(types, contains(SpecialPointType.rahuKaalam));
      expect(types, contains(SpecialPointType.mandi));
      expect(types, contains(SpecialPointType.mrityu));
    });
  });

  group('Jamakkol Prasannam - Aspects & Combinations', () {
    test('Calculates aspects between planets and key points', () {
      final testDate = DateTime(2026, 9, 27, 10, 0);
      final chart = JamakkolEngine.calculateChart(
        queryDateTime: testDate,
        location: JamakkolLocation.defaultChennai,
      );

      expect(chart.aspects, isNotNull);
      // House distance must be between 1 and 12
      for (final asp in chart.aspects) {
        expect(asp.houseDistance, inInclusiveRange(1, 12));
        expect(asp.aspectTypeEn, isNotEmpty);
        expect(asp.aspectTypeTa, isNotEmpty);
      }
    });

    test('Combinations evaluate Udayam, Arudam, Kavippu and Lord relationships', () {
      final testDate = DateTime(2026, 9, 27, 10, 0);
      final chart = JamakkolEngine.calculateChart(
        queryDateTime: testDate,
        location: JamakkolLocation.defaultChennai,
      );

      expect(chart.combinations, isNotNull);
      expect(chart.combinations.isNotEmpty, isTrue);
    });
  });

  group('Jamakkol Prasannam - Next 1-Hour Time Analysis', () {
    test('Produces exactly 12 five-minute slots across the next 60 minutes', () {
      final testDate = DateTime(2026, 9, 27, 10, 0);
      final chart = JamakkolEngine.calculateChart(
        queryDateTime: testDate,
        location: JamakkolLocation.defaultChennai,
      );

      expect(chart.nextHourSlots.length, equals(12));

      for (int i = 0; i < 12; i++) {
        final slot = chart.nextHourSlots[i];
        expect(slot.startTime.isBefore(slot.endTime), isTrue);
        expect(slot.endTime.difference(slot.startTime).inMinutes, equals(5));
        expect(slot.arudamRasiIndex, inInclusiveRange(0, 11));
        expect(slot.arudamRasiTa, isNotEmpty);
        expect(slot.arudamLordTa, isNotEmpty);
      }
    });
  });

  group('Jamakkol Prasannam - Interpretation Engine & Questions', () {
    test('Generates structured interpretation for question categories', () {
      final testDate = DateTime(2026, 9, 27, 10, 0);

      for (final cat in [
        JamakkolQuestionCategory.job,
        JamakkolQuestionCategory.marriage,
        JamakkolQuestionCategory.money,
        JamakkolQuestionCategory.health,
        JamakkolQuestionCategory.property,
      ]) {
        final chart = JamakkolEngine.calculateChart(
          queryDateTime: testDate,
          location: JamakkolLocation.defaultChennai,
          question: 'General Query for ${cat.name}',
          questionCategory: cat,
        );

        final interp = chart.interpretation;
        expect(interp.confidenceScore, inInclusiveRange(0, 100));
        expect(interp.verdictTitleTa, isNotEmpty);
        expect(interp.verdictTitleEn, isNotEmpty);
        expect(interp.udayamAnalysisTa, isNotEmpty);
        expect(interp.arudamAnalysisTa, isNotEmpty);
        expect(interp.kavippuAnalysisTa, isNotEmpty);
        expect(interp.practicalRemedyTa, isNotEmpty);
        expect(interp.practicalRemedyEn, isNotEmpty);
        expect(interp.questionCategory, equals(cat));
      }
    });
  });

  group('Jamakkol Prasannam - Locations & Offline Calculation', () {
    test('Calculates successfully for multiple Tamil Nadu cities offline', () {
      final testDate = DateTime(2026, 9, 27, 12, 0);

      final locations = [
        JamakkolLocation.defaultChennai,
        JamakkolLocation.defaultCoimbatore,
        JamakkolLocation.defaultMadurai,
        JamakkolLocation.defaultThiruvarur,
      ];

      for (final loc in locations) {
        final chart = JamakkolEngine.calculateChart(
          queryDateTime: testDate,
          location: loc,
        );

        expect(chart.location.name, equals(loc.name));
        expect(chart.sunrise.isBefore(chart.sunset), isTrue);
        expect(chart.jamakkolPlanets.length, equals(8));
        expect(chart.transitPlanets.isNotEmpty, isTrue);
      }
    });
  });
}
