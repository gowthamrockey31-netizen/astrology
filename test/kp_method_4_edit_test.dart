import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/kp_method_4/kp_method_4.dart';
import 'package:astrocall/services/auth_service.dart';
import 'package:astrocall/models/user_model.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('KP Method 4 Edit Option Tests', () {
    testWidgets('Edit profile bottom sheet opens with pre-populated data and cancels safely', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final initialProfile = Kp4BirthData(
        dateTime: DateTime(1995, 8, 15, 8, 30),
        time: '08:30 AM',
        place: 'Chennai, TN',
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: 5.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: KPMethod4Page(
            initialBirthData: initialProfile,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // 1. Verify edit profile icon button exists
      final editButton = find.byTooltip('சுயவிவரம் திருத்து (Edit Profile)');
      expect(editButton, findsOneWidget);

      // 2. Tap edit button to open modal bottom sheet
      await tester.tap(editButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 200));

      // 3. Verify modal header and fields are displayed matching Birth Chart edit
      expect(find.text('சுயவிவரம் திருத்து (Edit Profile)'), findsWidgets);
      expect(find.text('பெயர் (Name)'), findsOneWidget);
      expect(find.text('பிறந்த தேதி (Date / Month / Year)'), findsOneWidget);
      expect(find.text('15 / 08 / 1995'), findsOneWidget);
      expect(find.text('பிறந்த நேரம் (Time of Birth)'), findsOneWidget);
      expect(find.textContaining('8:30 AM'), findsWidgets);
      expect(find.text('பிறந்த ஊர் (Place of Birth)'), findsOneWidget);
      expect(find.text('Chennai, TN'), findsOneWidget);
      expect(find.text('அட்சரேகை (Latitude)'), findsOneWidget);
      expect(find.text('13.0827'), findsOneWidget);
      expect(find.text('தீர்க்கரேகை (Longitude)'), findsOneWidget);
      expect(find.text('80.2707'), findsOneWidget);
      expect(find.text('Timezone'), findsOneWidget);
      expect(find.text('5.5'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);
      expect(find.text('சேமி & மறு கணக்கீடு செய் (Update Chart)'), findsOneWidget);

      // 4. Cancel by tapping the close (X) button
      final closeButton = find.byIcon(Icons.close_rounded);
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      // 5. Verify modal dismissed and profile unchanged
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('பெயர் (Name)'), findsNothing);
      expect(find.textContaining('Chennai, TN'), findsWidgets);
    });

    testWidgets('Edit profile bottom sheet updates birth data, recalculates chart, and displays SnackBar', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      AuthService.updateCurrentUser(UserModel(
        id: 'test_user_1',
        name: 'Arun Kumar',
        mobile: '9876543210',
        gender: 'Male',
        dob: '1995-08-15',
        timeOfBirth: '08:30 AM',
        placeOfBirth: 'Chennai',
        city: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Leo',
        nakshatra: 'Magha',
        lagna: 'Virgo',
        walletBalance: 0.0,
        profilePhoto: '',
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: 5.5,
      ));

      final initialProfile = Kp4BirthData(
        dateTime: DateTime(1995, 8, 15, 8, 30),
        time: '08:30 AM',
        place: 'Chennai',
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: 5.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: KPMethod4Page(
            initialBirthData: initialProfile,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // Open edit modal
      await tester.tap(find.byTooltip('சுயவிவரம் திருத்து (Edit Profile)'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 200));

      // Edit City / Place
      final placeFinder = find.widgetWithText(TextField, 'Chennai');
      expect(placeFinder, findsOneWidget);
      await tester.enterText(placeFinder, 'Madurai');

      // Edit Lat & Lon
      final latFinder = find.widgetWithText(TextField, '13.0827');
      expect(latFinder, findsOneWidget);
      await tester.enterText(latFinder, '9.9252');

      final lonFinder = find.widgetWithText(TextField, '80.2707');
      expect(lonFinder, findsOneWidget);
      await tester.enterText(lonFinder, '78.1198');

      // Drag bottom sheet up to ensure Save button is fully within view
      await tester.drag(find.byType(SingleChildScrollView).last, const Offset(0, -500));
      await tester.pump(const Duration(milliseconds: 200));

      // Tap Save & Update Chart
      final saveButton = find.text('சேமி & மறு கணக்கீடு செய் (Update Chart)');
      await tester.tap(saveButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify modal is closed
      expect(find.byType(BottomSheet), findsNothing);

      // Verify SnackBar confirmation message appears
      expect(find.text('பிறப்பு விவரங்கள் புதுப்பிக்கப்பட்டன. ஜாதகம் மறு கணக்கீடு செய்யப்பட்டது!'), findsOneWidget);

      // Verify updated place appears in the screen header
      expect(find.textContaining('Madurai'), findsWidgets);
    });
  });
}
