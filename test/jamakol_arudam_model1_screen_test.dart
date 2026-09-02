import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/screens/jamakol_arudam_model1_screen.dart';

void main() {
  testWidgets('JamakolArudamModel1Screen renders core points and planet list without overflow', (WidgetTester tester) async {
    // Set typical mobile/desktop viewport
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: JamakolArudamModel1Screen(),
      ),
    );

    // Initial pump and frame pump
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // 1. Verify Header
    expect(find.text('ஜாமகோள் ஆருடம் – Model 1'), findsOneWidget);

    // 2. Verify 3 Core Cards (உதயம், ஆருடம், கவிப்பு)
    expect(find.text('உதயம்'), findsOneWidget);
    expect(find.text('ஆருடம்'), findsOneWidget);
    expect(find.text('கவிப்பு'), findsOneWidget);

    // 3. Verify Degree precision format exists on screen
    expect(find.textContaining('°'), findsWidgets);
    expect(find.textContaining('′'), findsWidgets);

    // 4. Verify Navagraha table
    expect(find.text('சூரியன்'), findsWidgets);
    expect(find.text('சந்திரன்'), findsWidgets);

    // 5. Verify Prediction and Analysis sections
    expect(find.text('காரிய சித்தி ஆய்வு (Question Success Analysis)'), findsOneWidget);
    expect(find.text('ஜாமகோள் Model 1 பலன்கள் (Predictions)'), findsOneWidget);

    // Verify no exceptions thrown
    expect(tester.takeException(), isNull);
  });
}
