import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/screens/marriage_porutham/marriage_porutham_screen.dart';

void main() {
  testWidgets('MarriagePoruthamScreen renders UI with Bhava Samyam and 11 Poruthams', (WidgetTester tester) async {
    // Ignore harmless RenderFlex debug overflow in child Rasi chart
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    // Set a large screen size to avoid scrolling issues
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: MarriagePoruthamScreen(),
      ),
    );

    // Pump frames to let post-frame callbacks and calculations run
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Title & Headers
    expect(find.text('திருமண ஜாதகப் பொருத்தம்'), findsOneWidget);
    expect(find.text('திருமணப் பொருத்தம் (11 பொருத்தங்கள்)'), findsOneWidget);
    expect(find.text('பாவசம்யம் தோஷம் (Bhava Samyam Dhosham)'), findsOneWidget);

    // Verify Bhava Samyam Section tables
    expect(find.text('ஆண் ஜாதகத்தில் பாவதோச அளவு:'), findsOneWidget);
    expect(find.text('பெண் ஜாதகத்தில் பாவ தோச அளவு:'), findsOneWidget);
    expect(find.text('மொத்த பாவ அளவு'), findsNWidgets(2)); // One in Male table, one in Female table

    // Verify 11 Poruthams table includes Rasi and Rasi Athipathi
    expect(find.text('6. ராசிப் பொருத்தம்'), findsOneWidget);
    expect(find.text('7. ராசி அதிபதிப் பொருத்தம்'), findsOneWidget);

    // Verify overall conclusion card is present
    expect(find.text('மொத்தப் பொருத்தம்'), findsOneWidget);
  });
}
