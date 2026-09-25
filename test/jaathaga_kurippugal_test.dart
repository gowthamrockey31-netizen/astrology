import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/screens/jaathaga_kurippugal/jaathaga_kurippugal_screen.dart';

void main() {
  testWidgets('JaathagaKurippugalScreen renders General Panchangam tab without live panchangam cards', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: JaathagaKurippugalScreen(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    // Verify Tab 0 is selected
    expect(find.text('பொது பஞ்சாங்க குறிப்புகள்'), findsWidgets);

    // Verify Birth Profile is displayed
    expect(find.text('பிறப்பு விவரங்கள் (Birth Profile)'), findsOneWidget);

    // Verify General Panchangam card is displayed
    expect(find.text('பொது பஞ்சாங்க குறிப்புகள் (General Panchangam)'), findsOneWidget);

    // Verify removed Live Panchangam and Live Jamakkol Prasannam details are NOT present
    expect(find.text('பஞ்ச அங்கம் (Core 5 Angas)'), findsNothing);
    expect(find.text('சுப & அசுப நேரங்கள்'), findsNothing);
    expect(find.text('ஜாமக்கோள் சிறப்பு புள்ளிகள் (Live Points)'), findsNothing);
    expect(find.text('ஜாமக்கோள் பிரசன்னம்'), findsNothing);
    expect(find.text('தற்போதைய கௌரி நிலை: '), findsNothing);
  });

  testWidgets('JaathagaKurippugalScreen displays Udayadhi Nazhigai between Planet Status and Nakshatra Duration', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 3600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: JaathagaKurippugalScreen(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    // Verify sections exist
    final planetStatusFinder = find.text('கிரக நிலைகள் & நட்பு (Planet Status & Dignity)');
    final udayadhiFinder = find.text('உதயாதினாழிகை (Udayadhi Nazhigai)');
    final nakshatraDurationFinder = find.text('ஆதி அந்த பரம நாழிகை (Nakshatra Duration Metrics)');

    expect(planetStatusFinder, findsOneWidget);
    expect(udayadhiFinder, findsOneWidget);
    expect(nakshatraDurationFinder, findsOneWidget);

    // Verify vertical order: Planet Status < Udayadhi Nazhigai < Nakshatra Duration
    final planetStatusY = tester.getTopLeft(planetStatusFinder).dy;
    final udayadhiY = tester.getTopLeft(udayadhiFinder).dy;
    final nakshatraDurationY = tester.getTopLeft(nakshatraDurationFinder).dy;

    expect(planetStatusY < udayadhiY, isTrue, reason: 'Planet Status should be above Udayadhi Nazhigai');
    expect(udayadhiY < nakshatraDurationY, isTrue, reason: 'Udayadhi Nazhigai should be above Nakshatra Duration');

    // Verify horizontal alignment: Udayadhi Nazhigai title is positioned at the top-left (< 100 px from screen left)
    final udayadhiX = tester.getTopLeft(udayadhiFinder).dx;
    expect(udayadhiX < 100, isTrue, reason: 'Udayadhi Nazhigai title should be left-aligned, not centered');
  });
}

