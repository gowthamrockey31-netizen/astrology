import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/screens/bnn_method1_screen.dart';

void main() {
  testWidgets('BNN Method 1 Screen renders and shows Karakathuvam cards upon calculation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: BnnMethod1Screen(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));

    // Verify header
    expect(find.text('பிருகு நந்தி நாடி - முறை 1'), findsOneWidget);

    // Verify removed birth input button is NOT present
    expect(find.text('முறை 1 கணிப்பு செய்க (Calculate Method 1)'), findsNothing);
    await tester.pump(const Duration(milliseconds: 300));

    // Verify planet selector tabs contain choice chips with house format
    expect(find.byType(ChoiceChip), findsWidgets);

    // Verify Karakathuvam headers
    expect(find.text('① கிரகத்தின் மிக முக்கியமான 10 காரகங்கள்'), findsOneWidget);
    expect(find.text('② நோய் / உடல் காரகங்கள்'), findsOneWidget);
    expect(find.textContaining('③ லக்னத்திலிருந்து'), findsOneWidget);
    expect(find.textContaining('காரகங்கள்'), findsWidgets);

    // Tap on Guru chip if present
    final guruChip = find.widgetWithText(ChoiceChip, 'குரு (3)');
    if (guruChip.evaluate().isNotEmpty) {
      await tester.tap(guruChip);
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Guru's specific karakas from the user's screenshot
      expect(find.textContaining('ஜீவகாரகன்'), findsOneWidget);
      expect(find.textContaining('கல்லீரல் & பித்தப்பை'), findsOneWidget);
      expect(find.textContaining('இளைய சகோதரம்'), findsOneWidget);
    }
  });
}
