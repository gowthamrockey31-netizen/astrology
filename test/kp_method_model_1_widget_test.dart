import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/kp_method_model_1/kp_method_model_1.dart';

void main() {
  testWidgets('KPDashboardCard renders with title, icon, and button', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KPDashboardCard(onTap: () => tapped = true),
        ),
      ),
    );

    expect(find.text('KP Method Model 1'), findsOneWidget);
    expect(find.text('KP Astrology Calculation & Analysis'), findsOneWidget);
    expect(find.text('OPEN'), findsOneWidget);

    await tester.tap(find.text('OPEN'));
    expect(tapped, true);
  });

  testWidgets('KPMethodModel1Page calculates and renders tabs and tables', (tester) async {
    tester.view.physicalSize = const Size(1800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final testBirth = KPBirthData(
      dateTime: DateTime(1996, 6, 15, 8, 30),
      latitude: 13.0827,
      longitude: 80.2707,
      placeName: 'Chennai, India',
      timeZone: const Duration(hours: 5, minutes: 30),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: KPMethodModel1Page(initialBirthData: testBirth),
      ),
    );

    // Initial pump and wait for calculation
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('KP METHOD MODEL 1'), findsOneWidget);
    expect(find.text('Horoscope'), findsOneWidget);
    expect(find.text('Ruling Planets'), findsOneWidget);
    expect(find.text('12 Cusps'), findsOneWidget);
    expect(find.text('9 Planets'), findsOneWidget);
    expect(find.text('Planet Significators'), findsOneWidget);
    expect(find.text('House Significators'), findsOneWidget);

    // Switch to Ruling Planets tab
    await tester.tap(find.text('Ruling Planets'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('CURRENT RULING PLANETS (ஆளும் கிரகங்கள்)'), findsOneWidget);

    // Switch to 12 Cusps tab
    await tester.tap(find.text('12 Cusps'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('12 KP PLACIDUS CUSPS (பாவ ஆரம்பங்கள்)'), findsOneWidget);

    // Switch to 9 Planets tab
    await tester.tap(find.text('9 Planets'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('9 KP PLANETS (கிரக நிலைகள்)'), findsOneWidget);

    // Switch to Planet Significators tab
    await tester.tap(find.text('Planet Significators'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('KP ADVANTAGE FILTER — MODEL 1'), findsOneWidget);
    expect(find.text('PLANET SIGNIFICATORS (கிரக காரகத்துவங்கள்)'), findsOneWidget);

    // Switch to House Significators tab
    await tester.tap(find.text('House Significators'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('HOUSE SIGNIFICATORS (பாவ காரகத்துவங்கள்)'), findsOneWidget);

    // Drag tab bar left to reveal remaining tabs
    await tester.drag(find.text('House Significators'), const Offset(-350, 0));
    await tester.pump(const Duration(milliseconds: 200));

    final dashaFinder = find.text('Dasha / Bhukti');
    expect(dashaFinder, findsOneWidget);
    await tester.tap(dashaFinder);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('BIRTH DASHA BALANCE (இருப்பு தசை)'), findsOneWidget);

    final btrFinder = find.text('Birth Time Rectification');
    expect(btrFinder, findsOneWidget);
    await tester.tap(btrFinder);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('BIRTH TIME RECTIFICATION (BTR)'), findsOneWidget);
    expect(find.text('CANDIDATE RECTIFICATION TIMES'), findsOneWidget);
  });
}
