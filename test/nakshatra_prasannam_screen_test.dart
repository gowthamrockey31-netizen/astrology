import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/modules/nakshatra_prasannam/nakshatra_prasannam_screen.dart';

void main() {
  testWidgets('NakshatraPrasannaScreen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NakshatraPrasannaScreen(),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify title is rendered
    expect(find.text('நட்சத்திர பிரசன்னம்'), findsAtLeastNWidgets(1));
    expect(find.text('தின உதய சந்திரன் (DRM)'), findsOneWidget);
    expect(find.text('நட்சத்திர பிரசன்ன சந்திரன் (HRM)'), findsOneWidget);
    expect(find.text('நட்சத்திர பிரசன்ன லக்னம் (NPL)'), findsOneWidget);
    expect(find.text('ஜீவா – சரீரா'), findsOneWidget);
    expect(find.text('நட்சத்திர பிரசன்ன முடிவு'), findsOneWidget);
  });
}
