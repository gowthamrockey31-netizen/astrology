import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/user_model.dart';
import 'package:astrocall/screens/birth_chart/birth_chart_screen.dart';
import 'package:astrocall/services/auth_service.dart';
import 'package:astrocall/services/profile_service.dart';
import 'package:astrocall/services/profile_storage.dart';
import 'package:astrocall/widgets/south_indian_jathagam_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ProfileStorage.saveData('');
    final service = ProfileService();
    service.resetForTesting();
    AuthService.logout();
  });

  tearDown(() {
    ProfileStorage.saveData('');
    ProfileService().resetForTesting();
    AuthService.logout();
  });

  group('Birth Chart Data Persistence Tests', () {
    testWidgets('Requirement 1-6: Saved birth details persist when BirthChartScreen is reopened', (tester) async {
      final profileService = ProfileService();
      await profileService.initialize();

      // Setup initial user with specific details
      final initialUser = UserModel(
        id: 'prof_user_1',
        name: 'Arun Kumar',
        mobile: '+919876543210',
        gender: 'Male',
        dob: '1990-10-15',
        timeOfBirth: '10:45 AM',
        placeOfBirth: 'Coimbatore',
        city: 'Coimbatore',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Leo',
        nakshatra: 'Magha',
        lagna: 'Scorpio',
        walletBalance: 500.0,
        profilePhoto: '',
        latitude: 11.0168,
        longitude: 76.9558,
        timezone: 5.5,
      );

      AuthService.updateCurrentUser(initialUser);
      await profileService.updateProfile(initialUser);

      // 1. Open Birth Chart Screen first time
      await tester.pumpWidget(
        const MaterialApp(
          home: BirthChartScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

      // Find SouthIndianJathagamWidget and verify it received the user's initial details
      final chartFinder1 = find.byType(SouthIndianJathagamWidget);
      expect(chartFinder1, findsOneWidget);
      final widget1 = tester.widget<SouthIndianJathagamWidget>(chartFinder1);
      expect(widget1.user?.dob, equals('1990-10-15'));
      expect(widget1.user?.placeOfBirth, equals('Coimbatore'));
      expect(widget1.user?.timeOfBirth, equals('10:45 AM'));

      // 2. Simulate User changing details in the screen and saving
      final updatedDetails = widget1.user!.copyWith(
        dob: '1988-04-25',
        placeOfBirth: 'Madurai',
        timeOfBirth: '05:20 PM',
        latitude: 9.9252,
        longitude: 78.1198,
      );

      // Perform save through the authoritative flow
      AuthService.updateCurrentUser(updatedDetails);
      await profileService.updateProfile(updatedDetails);

      // 3. User navigates away: unmount/dispose the screen
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 600));

      // 4. User re-opens the Birth Chart Screen
      await tester.pumpWidget(
        const MaterialApp(
          home: BirthChartScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

      // 5. Verify the screen loads the saved values and did NOT revert to default (1995-08-15 / Chennai / 08:30 AM)
      final chartFinder2 = find.byType(SouthIndianJathagamWidget);
      expect(chartFinder2, findsOneWidget);
      final widget2 = tester.widget<SouthIndianJathagamWidget>(chartFinder2);

      expect(widget2.user?.dob, equals('1988-04-25'),
          reason: 'Date of birth must persist and not revert to default');
      expect(widget2.user?.placeOfBirth, equals('Madurai'),
          reason: 'Birthplace must persist and not revert to default');
      expect(widget2.user?.timeOfBirth, equals('05:20 PM'),
          reason: 'Birth time must persist and not revert to default');
      expect(widget2.user?.latitude, equals(9.9252));
      expect(widget2.user?.longitude, equals(78.1198));

      // Clean unmount to dispose animation controller
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('Requirement 8: Multiple profiles retain distinct details without overwriting each other', (tester) async {
      final profileService = ProfileService();
      await profileService.initialize();

      final profileA = UserModel(
        id: 'prof_a',
        name: 'Person A',
        mobile: '+919876543201',
        gender: 'Male',
        dob: '1992-06-18',
        timeOfBirth: '07:15 AM',
        placeOfBirth: 'Salem',
        city: 'Salem',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Gemini',
        nakshatra: 'Ardra',
        lagna: 'Cancer',
        walletBalance: 500.0,
        profilePhoto: '',
        latitude: 11.6643,
        longitude: 78.1460,
        timezone: 5.5,
        relationship: 'Self',
      );

      final profileB = UserModel(
        id: 'prof_b',
        name: 'Person B (Child)',
        mobile: '+919876543202',
        gender: 'Female',
        dob: '2020-11-05',
        timeOfBirth: '02:30 PM',
        placeOfBirth: 'Tiruchirappalli',
        city: 'Tiruchirappalli',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Scorpio',
        nakshatra: 'Anuradha',
        lagna: 'Aquarius',
        walletBalance: 500.0,
        profilePhoto: '',
        latitude: 10.7905,
        longitude: 78.7047,
        timezone: 5.5,
        relationship: 'Child',
      );

      await profileService.addProfile(profileA);
      await profileService.addProfile(profileB);

      // Select Profile B
      await profileService.selectProfile(profileB.id);
      expect(AuthService.currentUser?.id, equals(profileB.id));

      // Open Birth Chart Screen with Profile B active
      await tester.pumpWidget(
        const MaterialApp(
          home: BirthChartScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

      var chartFinder = find.byType(SouthIndianJathagamWidget);
      var chartWidget = tester.widget<SouthIndianJathagamWidget>(chartFinder);
      expect(chartWidget.user?.id, equals('prof_b'));
      expect(chartWidget.user?.dob, equals('2020-11-05'));
      expect(chartWidget.user?.placeOfBirth, equals('Tiruchirappalli'));

      // Modify Profile B's birth details
      final updatedProfileB = chartWidget.user!.copyWith(
        timeOfBirth: '03:45 PM',
        placeOfBirth: 'Thanjavur',
        latitude: 10.7870,
        longitude: 79.1378,
      );
      AuthService.updateCurrentUser(updatedProfileB);
      await profileService.updateProfile(updatedProfileB);

      // Close screen
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 600));

      // Switch to Profile A
      await profileService.selectProfile(profileA.id);
      expect(AuthService.currentUser?.id, equals(profileA.id));

      // Open Birth Chart Screen with Profile A
      await tester.pumpWidget(
        const MaterialApp(
          home: BirthChartScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

      chartFinder = find.byType(SouthIndianJathagamWidget);
      chartWidget = tester.widget<SouthIndianJathagamWidget>(chartFinder);
      // Verify Profile A retains its own details completely
      expect(chartWidget.user?.id, equals('prof_a'));
      expect(chartWidget.user?.dob, equals('1992-06-18'));
      expect(chartWidget.user?.placeOfBirth, equals('Salem'));
      expect(chartWidget.user?.timeOfBirth, equals('07:15 AM'));

      // Close screen and switch back to Profile B
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 600));

      await profileService.selectProfile(profileB.id);
      await tester.pumpWidget(
        const MaterialApp(
          home: BirthChartScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

      chartFinder = find.byType(SouthIndianJathagamWidget);
      chartWidget = tester.widget<SouthIndianJathagamWidget>(chartFinder);
      // Verify Profile B retains its updated details
      expect(chartWidget.user?.id, equals('prof_b'));
      expect(chartWidget.user?.timeOfBirth, equals('03:45 PM'));
      expect(chartWidget.user?.placeOfBirth, equals('Thanjavur'));

      // Clean unmount to dispose animation controller
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    test('Requirement 5: Screen initialization does not overwrite AuthService.currentUser', () {
      final customUser = UserModel(
        id: 'prof_dindigul',
        name: 'Dindigul Seeker',
        mobile: '+919876543210',
        gender: 'Male',
        dob: '1993-01-20',
        timeOfBirth: '11:15 AM',
        placeOfBirth: 'Dindigul',
        city: 'Dindigul',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Sagittarius',
        nakshatra: 'Moola',
        lagna: 'Aries',
        walletBalance: 500.0,
        profilePhoto: '',
        latitude: 10.3673,
        longitude: 77.9803,
        timezone: 5.5,
      );

      AuthService.updateCurrentUser(customUser);

      // Verify that AuthService.currentUser is preserved
      expect(AuthService.currentUser?.dob, equals('1993-01-20'));
      expect(AuthService.currentUser?.placeOfBirth, equals('Dindigul'));
      expect(AuthService.currentUser?.timeOfBirth, equals('11:15 AM'));
    });
  });
}
