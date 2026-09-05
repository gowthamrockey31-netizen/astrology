import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/kp_method_2/kp_method_2.dart';

void main() {
  testWidgets('KPMethod2Page renders properly with tabs and tables', (WidgetTester tester) async {
    // Set a large display size to avoid overflows in test environment
    tester.view.physicalSize = const Size(2000, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: KPMethod2Page(
          initialBirthData: KP2BirthData.defaultTestProfile(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));

    // Verify Title & Subtitle in AppBar
    expect(find.text('KP METHOD 2'), findsWidgets);
    expect(find.text('கே.பி முறை 2 - துல்லிய பிளாசிடஸ் & அட்வான்டேஜ்'), findsOneWidget);

    // Verify Tabs
    expect(find.text('சுருக்கம் (Overview)'), findsOneWidget);
    expect(find.text('கிரகங்கள் (9 Planets)'), findsOneWidget);
    expect(find.text('பாவங்கள் (12 Cusps)'), findsOneWidget);
    expect(find.text('ஆளும் கிரகங்கள் (Ruling)'), findsOneWidget);
    expect(find.text('காரகங்கள் & அட்வான்டேஜ்'), findsOneWidget);
    expect(find.text('தசா புக்தி (Dasha)'), findsOneWidget);

    // Verify Summary contents
    expect(find.text('சித்ரபக்ஷ லஹரி அயனாம்சம்'), findsOneWidget);
    expect(find.textContaining('தசா இருப்பு'), findsWidgets);

    // Tap on 9 Planets tab
    await tester.tap(find.text('கிரகங்கள் (9 Planets)'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('9 KP கிரக நிலைகள் (Planetary Positions)'), findsOneWidget);
    expect(find.text('சூரியன்'), findsWidgets);
    expect(find.text('சந்திரன்'), findsWidgets);

    // Tap on 12 Cusps tab
    await tester.tap(find.text('பாவங்கள் (12 Cusps)'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('12 பாவ ஆரம்ப முனைகள் (Placidus Cusps)'), findsOneWidget);
    expect(find.text('(லக்னம்)'), findsOneWidget);

    // Tap on Ruling Planets tab
    await tester.tap(find.text('ஆளும் கிரகங்கள் (Ruling)'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('ஆளும் கிரகங்கள் (KP Ruling Planets)'), findsOneWidget);
    expect(find.text('கிழமை நாதன் (Day Lord)'), findsOneWidget);

    // Tap on Significators tab
    await tester.tap(find.text('காரகங்கள் & அட்வான்டேஜ்'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('கிரக தொடர்புகள் (Planet Significators)'), findsOneWidget);
    expect(find.textContaining('ADVANTAGE HOUSES'), findsOneWidget);

    // Tap on Dasha tab
    await tester.tap(find.text('தசா புக்தி (Dasha)'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('விம்சோத்தரி தசா இருப்பு & காலங்கள்'), findsOneWidget);
  });
}
