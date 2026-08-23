import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
