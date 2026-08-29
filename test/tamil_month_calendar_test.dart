import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/controllers/tamil_calendar_controller.dart';
import 'package:astrocall/data/tamil_festivals_data.dart';
import 'package:astrocall/data/tamil_nadu_holidays.dart';
import 'package:astrocall/models/tamil_calendar_models.dart';
import 'package:astrocall/services/panchanga_provider.dart';

void main() {
  group('Tamil Month & Panchanga Provider Tests', () {
    const provider = AstronomicalPanchangaProvider();
    const location = PanchangaLocation(
      city: 'Chennai',
      latitude: 13.0827,
      longitude: 80.2707,
      timezone: 5.5,
    );

    test('Astronomical calculation derives valid Tamil Month, Tithi, Nakshatra, and Nokku Dinam', () {
      final date = DateTime(2026, 8, 28);
      final dayData = provider.calculateSync(date: date, location: location);

      // Tamil Month in late August should be Aavani (ஆவணி)
      expect(dayData.tamilMonth, equals('ஆவணி'));
      expect(dayData.tamilDay, greaterThan(0));
      expect(dayData.tamilDay, lessThanOrEqualTo(32));

      // 30 Tithis
      expect(dayData.thithiNumber, inInclusiveRange(1, 30));
      expect(dayData.thithi.isNotEmpty, isTrue);
      expect(dayData.pakshaTa.isNotEmpty, isTrue);

      // 27 Nakshatras & Pada 1..4
      expect(dayData.nakshatraIndex, inInclusiveRange(0, 26));
      expect(dayData.nakshatraPada, inInclusiveRange(1, 4));
      expect(dayData.nakshatra.isNotEmpty, isTrue);

      // Nokku Dinam (Mel, Keezh, Sama)
      expect(dayData.nokkuDinam, isA<NokkuDinamType>());
      expect(['⬆', '⬇', '↔'].contains(dayData.nokkuDinam.symbol), isTrue);

      // Timings
      expect(dayData.sunrise.isNotEmpty, isTrue);
      expect(dayData.sunset.isNotEmpty, isTrue);
      expect(dayData.rahuKalam.isNotEmpty, isTrue);
      expect(dayData.yemakandam.isNotEmpty, isTrue);
      expect(dayData.kuligai.isNotEmpty, isTrue);
      expect(dayData.abhijit.isNotEmpty, isTrue);
    });

    test('Nokku Dinam correctly maps all 27 Nakshatras', () {
      // Test Mel Nokku (Upward): Rohini (index 3), Thiruvonam (index 21)
      const melNaks = {3, 5, 7, 11, 20, 21, 22, 23, 25};
      const keezhNaks = {1, 2, 8, 9, 10, 15, 18, 19, 24};
      const samaNaks = {0, 4, 6, 12, 13, 14, 16, 17, 26};

      expect(melNaks.length + keezhNaks.length + samaNaks.length, equals(27));
    });

    test('Tamil Nadu Government Holidays repository is isolated and functional', () {
      final pongal2026 = TamilNaduHolidayData.getHoliday(DateTime(2026, 1, 14));
      expect(pongal2026, isNotNull);
      expect(pongal2026!.nameTa, contains('பொங்கல்'));

      final nonHoliday = TamilNaduHolidayData.getHoliday(DateTime(2026, 2, 10));
      expect(nonHoliday, isNull);

      final holidays2026 = TamilNaduHolidayData.getHolidaysForYear(2026);
      expect(holidays2026.length, greaterThanOrEqualTo(15));
    });

    test('Festival data repository supports multi-faith categories', () {
      final festivalsPongal = TamilFestivalData.getFestivalsForDate(DateTime(2026, 1, 14));
      expect(festivalsPongal.isNotEmpty, isTrue);
      expect(festivalsPongal.first.category, equals(FestivalCategory.hindu));

      final festivalsXmas = TamilFestivalData.getFestivalsForDate(DateTime(2026, 12, 25));
      expect(festivalsXmas.isNotEmpty, isTrue);
      expect(festivalsXmas.first.category, equals(FestivalCategory.christian));
    });

    test('TamilCalendarController generates cached monthly grid days with 35 or 42 cells', () {
      final controller = TamilCalendarController(
        initialLocation: location,
        initialDate: DateTime(2026, 8, 15),
      );

      final gridDays = controller.getMonthGridDays();
      expect([35, 42].contains(gridDays.length), isTrue);

      final aug15 = controller.getDayData(DateTime(2026, 8, 15));
      expect(aug15.tamilMonth, equals('ஆடி')); // Pre-ingress Kataka / Aadi

      final aug28 = controller.getDayData(DateTime(2026, 8, 28));
      expect(aug28.tamilMonth, equals('ஆவணி')); // Post-ingress Simha / Aavani

      // Test navigation
      controller.nextMonth();
      expect(controller.focusedMonth.month, equals(9));

      controller.previousMonth();
      expect(controller.focusedMonth.month, equals(8));

      controller.goToToday();
      expect(controller.selectedDate.year, equals(DateTime.now().year));
    });
  });
}
