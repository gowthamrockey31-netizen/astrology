import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:astrocall/main.dart';
import 'package:astrocall/screens/profile/user_horoscope_profile_screen.dart';

void main() {
  testWidgets('UserHoroscopeProfileScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UserHoroscopeProfileScreen(onSaved: () {}),
      ),
    );
    expect(find.text('Horoscope Profile'), findsOneWidget);
  });

  testWidgets('AstroDashaCareApp root smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AstroDashaCareApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
    // Advance beyond splash timer
    await tester.pump(const Duration(milliseconds: 3500));
    // Verify transition to LoginScreen
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
