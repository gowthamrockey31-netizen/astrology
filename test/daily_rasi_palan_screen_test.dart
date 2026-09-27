import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/daily_rasi_palan/screens/daily_rasi_palan_screen.dart';
import 'package:astrocall/screens/horoscope/horoscope_screen.dart';

void main() {
  group('DailyRasiPalanScreen Widget Tests', () {
    testWidgets('Renders screen with all key sections, Rasi selector, and header', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fixedDate = DateTime(2026, 9, 25);

      await tester.pumpWidget(
        MaterialApp(
          home: DailyRasiPalanScreen(
            initialDate: fixedDate,
            initialRasiIndex: 0, // Mesham
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Top title
      expect(find.text('இன்றைய ராசிபலன்'), findsOneWidget);
      expect(find.text('Daily Horoscope & Transit Predictions'), findsOneWidget);

      // Selected Rasi header (Mesham)
      expect(find.text('மேஷம் (Aries)'), findsOneWidget);

      // Star rating / Score badge
      expect(find.text('நாள் மதிப்பீடு: '), findsOneWidget);
      expect(find.text('மதிப்பெண்'), findsOneWidget);

      // Required content card headers
      expect(find.text('பொதுப்பலன் (General)'), findsOneWidget);
      expect(find.text('தொழில் / வேலை (Career & Job)'), findsOneWidget);
      expect(find.text('பணவரவு (Finance & Wealth)'), findsOneWidget);
      expect(find.text('காதல் / திருமணம் (Love & Marriage)'), findsOneWidget);
      expect(find.text('குடும்பம் (Family)'), findsOneWidget);
      expect(find.text('ஆரோக்கியம் (Health)'), findsOneWidget);
      expect(find.text('கல்வி (Education)'), findsOneWidget);
      expect(find.text('பயணம் (Travel)'), findsOneWidget);
      expect(find.text('அதிர்ஷ்ட நிறம்'), findsOneWidget);
      expect(find.text('அதிர்ஷ்ட எண்'), findsOneWidget);
      expect(find.text('கவனம் (Caution)'), findsOneWidget);
      expect(find.text('பரிகாரம் (Remedy)'), findsOneWidget);

      // Check lucky color for Mesham (சிவப்பு)
      expect(find.text('சிவப்பு'), findsOneWidget);

      // Check remedy for Mesham (முருகன் வழிபாடு செய்யவும்.)
      expect(find.text('முருகன் வழிபாடு செய்யவும்.'), findsOneWidget);
    });

    testWidgets('Switching Rasi updates selected Rasi and content cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fixedDate = DateTime(2026, 9, 25);

      await tester.pumpWidget(
        MaterialApp(
          home: DailyRasiPalanScreen(
            initialDate: fixedDate,
            initialRasiIndex: 0, // Mesham
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('மேஷம் (Aries)'), findsOneWidget);

      // Tap on Rishabam (ரிஷபம்)
      final rishabamChip = find.text('ரிஷபம்');
      expect(rishabamChip, findsOneWidget);
      await tester.tap(rishabamChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Now header should show Rishabam
      expect(find.text('ரிஷபம் (Taurus)'), findsOneWidget);

      // Remedy for Rishabam
      expect(find.text('லட்சுமி வழிபாடு செய்யவும்.'), findsOneWidget);

      // Lucky color for Rishabam
      expect(find.text('வெள்ளை'), findsOneWidget);
    });

    testWidgets('Date navigation controls advance day and recalculate', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fixedDate = DateTime(2026, 9, 25);

      await tester.pumpWidget(
        MaterialApp(
          home: DailyRasiPalanScreen(
            initialDate: fixedDate,
            initialRasiIndex: 0,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('25 September 2026 (Friday)'), findsOneWidget);

      // Tap next day button
      final nextDayBtn = find.byTooltip('Next Day');
      expect(nextDayBtn, findsOneWidget);
      await tester.tap(nextDayBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('26 September 2026 (Saturday)'), findsOneWidget);

      // Tap previous day button twice
      final prevDayBtn = find.byTooltip('Previous Day');
      await tester.tap(prevDayBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(prevDayBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('24 September 2026 (Thursday)'), findsOneWidget);
    });
  });

  group('HoroscopeScreen Daily Tab Dynamic Rasi Palan Tests', () {
    testWidgets('HoroscopeScreen Daily tab renders dynamic Daily Horoscope sections and switches signs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: HoroscopeScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Header title
      expect(find.text('Horoscope Predictions'), findsOneWidget);

      // Verify tabs exist
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);

      // Verify dynamic Daily Horoscope sections rendered
      expect(find.text('இன்றைய ராசிபலன்'), findsOneWidget);
      expect(find.text('மேஷம் (Aries)'), findsOneWidget);
      expect(find.text('⭐ பொதுப்பலன் (General)'), findsOneWidget);
      expect(find.text('💼 தொழில் / வேலை (Career & Job)'), findsOneWidget);
      expect(find.text('💰 பணவரவு (Finance & Wealth)'), findsOneWidget);
      expect(find.text('❤️ காதல் / திருமணம் (Love & Marriage)'), findsOneWidget);
      expect(find.text('🎨 அதிர்ஷ்ட நிறம்'), findsOneWidget);
      expect(find.text('🔢 அதிர்ஷ்ட எண்'), findsOneWidget);
      expect(find.text('🕉️ பரிகாரம் (Remedy)'), findsOneWidget);
      expect(find.text('முருகன் வழிபாடு செய்யவும்.'), findsOneWidget);

      // Switch to Taurus sign
      final taurusChip = find.text('Taurus');
      expect(taurusChip, findsOneWidget);
      await tester.tap(taurusChip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Taurus (Rishabam) content
      expect(find.text('ரிஷபம் (Taurus)'), findsOneWidget);
      expect(find.text('லட்சுமி வழிபாடு செய்யவும்.'), findsOneWidget);

      // Switch to Weekly tab
      final weeklyTab = find.text('Weekly');
      expect(weeklyTab, findsOneWidget);
      await tester.tap(weeklyTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Switch back to Daily tab
      final dailyTab = find.text('Daily');
      await tester.tap(dailyTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('இன்றைய ராசிபலன்'), findsOneWidget);
    });
  });
}

