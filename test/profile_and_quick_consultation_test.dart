import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/user_model.dart';
import 'package:astrocall/services/auth_service.dart';
import 'package:astrocall/services/profile_service.dart';
import 'package:astrocall/services/profile_storage.dart';
import 'package:astrocall/widgets/consultation/quick_consultation_view.dart';
import 'package:astrocall/widgets/south_indian_jathagam_widget.dart';
import 'package:astrocall/kp_method_4/engine/kp4_engine.dart';
import 'package:astrocall/kp_method_4/models/kp4_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Clear storage before each test
    ProfileStorage.saveData('');
    final service = ProfileService();
    service.resetForTesting();
  });

  group('Priority 4 — User Functionality Requirements', () {
    test('TEST 1 & 2: Offline saved profile and persistence across app restart', () async {
      final service = ProfileService();
      await service.initialize();

      // Ensure initial profile is created
      expect(service.profiles.length, equals(1));
      final originalId = service.profiles.first.id;

      // Add a custom profile
      final profile1 = UserModel(
        id: 'prof_test_1',
        name: 'Father Profile',
        mobile: '+919944001122',
        gender: 'Male',
        dob: '1965-03-12',
        timeOfBirth: '06:15 AM',
        placeOfBirth: 'Madurai, TN',
        city: 'Madurai',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Pisces',
        nakshatra: 'Uttara Bhadrapada',
        lagna: 'Pisces',
        walletBalance: 800.0,
        role: 'User',
        profilePhoto: '',
        latitude: 9.9252,
        longitude: 78.1198,
        timezone: 5.5,
        relationship: 'Father',
      );

      final result = await service.addProfile(profile1);
      expect(result.isSuccess, isTrue);
      expect(service.profiles.length, equals(2));
      expect(service.activeProfile?.name, equals('Father Profile'));

      // Simulate App Close & Restart (TEST 2)
      service.resetForTesting();
      expect(service.profiles.isEmpty, isTrue);

      // Re-initialize (simulating reopening the app offline)
      await service.initialize();
      expect(service.profiles.length, equals(2));
      final loadedFather = service.profiles.firstWhere((p) => p.id == 'prof_test_1');
      expect(loadedFather.name, equals('Father Profile'));
      expect(loadedFather.dob, equals('1965-03-12'));
      expect(loadedFather.relationship, equals('Father'));
      expect(service.activeProfileId, equals('prof_test_1'));
    });

    test('TEST 3 & 4: Maximum 5 family profiles and rejection of 6th profile with clear message', () async {
      final service = ProfileService();
      await service.initialize();

      // Profiles 1 is default seeded ("Self")
      expect(service.profiles.length, equals(1));

      // Add 4 more profiles to reach maximum limit of 5 (TEST 3)
      final relationships = ['Father', 'Mother', 'Spouse', 'Child'];
      for (int i = 0; i < 4; i++) {
        final res = await service.addProfile(
          UserModel(
            id: 'prof_member_${i + 1}',
            name: 'Family Member ${i + 1}',
            mobile: '+91987654321$i',
            gender: 'Male',
            dob: '199${i}-01-01',
            timeOfBirth: '08:00 AM',
            placeOfBirth: 'Chennai',
            city: 'Chennai',
            state: 'Tamil Nadu',
            country: 'India',
            zodiac: 'Aries',
            nakshatra: 'Ashwini',
            lagna: 'Aries',
            walletBalance: 500.0,
            role: 'User',
            profilePhoto: '',
            latitude: 13.0827,
            longitude: 80.2707,
            timezone: 5.5,
            relationship: relationships[i],
          ),
        );
        expect(res.isSuccess, isTrue);
      }

      // Exactly 5 profiles exist
      expect(service.profiles.length, equals(5));
      expect(service.isFull, isTrue);
      expect(service.canAddProfile, isFalse);

      // Attempt to add a 6th profile (TEST 4)
      final sixthResult = await service.addProfile(
        UserModel(
          id: 'prof_member_6',
          name: 'Extra Person 6',
          mobile: '+919999999999',
          gender: 'Female',
          dob: '2005-05-05',
          timeOfBirth: '10:00 AM',
          placeOfBirth: 'Trichy',
          city: 'Trichy',
          state: 'Tamil Nadu',
          country: 'India',
          zodiac: 'Leo',
          nakshatra: 'Magha',
          lagna: 'Leo',
          walletBalance: 0.0,
          role: 'User',
          profilePhoto: '',
          relationship: 'Other',
        ),
      );

      // Verification: 6th profile is prevented, length remains 5, clear Tamil message returned
      expect(sixthResult.isSuccess, isFalse);
      expect(service.profiles.length, equals(5));
      expect(sixthResult.message, contains('அதிகபட்ச வரம்பு: 5 குடும்ப ஜாதகங்கள்'));
      expect(service.profiles.any((p) => p.id == 'prof_member_6'), isFalse);
    });

    test('TEST 5 & 6: Profile switching and calculation state update', () async {
      final service = ProfileService();
      await service.initialize();

      // Profile 1
      final p1 = service.profiles.first;
      await service.selectProfile(p1.id);
      expect(AuthService.currentUser?.id, equals(p1.id));

      // Add Profile 2
      final p2 = UserModel(
        id: 'prof_mother',
        name: 'Mother Profile',
        mobile: '+919811223344',
        gender: 'Female',
        dob: '1970-11-20',
        timeOfBirth: '05:45 PM',
        placeOfBirth: 'Coimbatore, TN',
        city: 'Coimbatore',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Cancer',
        nakshatra: 'Pushya',
        lagna: 'Taurus',
        walletBalance: 500.0,
        role: 'User',
        profilePhoto: '',
        latitude: 11.0168,
        longitude: 76.9558,
        timezone: 5.5,
        relationship: 'Mother',
      );
      await service.addProfile(p2);

      // Switch back to Profile 1 (TEST 5)
      await service.selectProfile(p1.id);
      expect(service.activeProfileId, equals(p1.id));
      expect(AuthService.currentUser?.name, equals(p1.name));

      // Switch to Profile 2 (TEST 6)
      await service.selectProfile(p2.id);
      expect(service.activeProfileId, equals(p2.id));
      expect(AuthService.currentUser?.name, equals('Mother Profile'));
      expect(AuthService.currentUser?.placeOfBirth, equals('Coimbatore, TN'));
      expect(AuthService.currentUser?.dob, equals('1970-11-20'));
    });

    test('TEST 7 & 8: Dependent modules (Rasi & KP Method 4) use newly selected profile', () async {
      final service = ProfileService();
      await service.initialize();

      final childProfile = UserModel(
        id: 'prof_child',
        name: 'Baby Child',
        mobile: '',
        gender: 'Male',
        dob: '2018-09-15',
        timeOfBirth: '11:20 AM',
        placeOfBirth: 'Salem, TN',
        city: 'Salem',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Scorpio',
        nakshatra: 'Anuradha',
        lagna: 'Scorpio',
        walletBalance: 0.0,
        role: 'User',
        profilePhoto: '',
        latitude: 11.6643,
        longitude: 78.1460,
        timezone: 5.5,
        relationship: 'Child',
      );
      await service.addProfile(childProfile);
      await service.selectProfile(childProfile.id);

      // Verify AuthService is updated
      expect(AuthService.currentUser?.name, equals('Baby Child'));

      // Test KP Method 4 calculation data flow (TEST 8)
      final kpBirthData = Kp4BirthData.fromUserModel(AuthService.currentUser!);
      expect(kpBirthData.place, equals('Salem, TN'));
      expect(kpBirthData.dateTime.year, equals(2018));
      expect(kpBirthData.dateTime.month, equals(9));

      final kpResult = Kp4Engine.calculate(kpBirthData);
      expect(kpResult.cuspPositions.length, equals(12));
      expect(kpResult.planetPositions.length, equals(9));
      expect(kpResult.cuspPositions[0].cuspNumber, equals(1));
    });

    test('TEST 9 & 10: Persistent storage offline roundtrip without network', () async {
      // Create and persist 3 profiles
      final service = ProfileService();
      await service.initialize();

      await service.addProfile(UserModel(
        id: 'prof_p2',
        name: 'Sister Profile',
        mobile: '+919000000002',
        gender: 'Female',
        dob: '2002-04-10',
        timeOfBirth: '02:15 PM',
        placeOfBirth: 'Tirunelveli',
        city: 'Tirunelveli',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Aquarius',
        nakshatra: 'Shatabhisha',
        lagna: 'Leo',
        walletBalance: 100.0,
        role: 'User',
        profilePhoto: '',
        relationship: 'Sister',
      ));

      await service.addProfile(UserModel(
        id: 'prof_p3',
        name: 'Brother Profile',
        mobile: '+919000000003',
        gender: 'Male',
        dob: '2005-08-25',
        timeOfBirth: '09:40 AM',
        placeOfBirth: 'Thanjavur',
        city: 'Thanjavur',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Taurus',
        nakshatra: 'Rohini',
        lagna: 'Virgo',
        walletBalance: 100.0,
        role: 'User',
        profilePhoto: '',
        relationship: 'Brother',
      ));

      expect(service.profiles.length, equals(3));
      await service.selectProfile('prof_p2');

      // Verify the storage data directly without any network call
      final storedRaw = ProfileStorage.loadData();
      expect(storedRaw, isNotNull);
      final jsonMap = json.decode(storedRaw!) as Map<String, dynamic>;
      expect(jsonMap['activeProfileId'], equals('prof_p2'));
      final profilesList = jsonMap['profiles'] as List;
      expect(profilesList.length, equals(3));

      // Restart service
      service.resetForTesting();
      await service.initialize();

      expect(service.profiles.length, equals(3));
      expect(service.activeProfileId, equals('prof_p2'));
      expect(service.activeProfile?.name, equals('Sister Profile'));
    });

    testWidgets('TEST 11 & 12: 4-Slot Quick Consultation View displays all slots and updates on profile switch', (tester) async {
      final service = ProfileService();
      await service.initialize();

      final spouseProfile = UserModel(
        id: 'prof_spouse',
        name: 'Spouse Profile',
        mobile: '+919988776655',
        gender: 'Female',
        dob: '1997-12-05',
        timeOfBirth: '03:30 PM',
        placeOfBirth: 'Trichy, TN',
        city: 'Trichy',
        state: 'Tamil Nadu',
        country: 'India',
        zodiac: 'Sagittarius',
        nakshatra: 'Moola',
        lagna: 'Aries',
        walletBalance: 1200.0,
        role: 'User',
        profilePhoto: '',
        latitude: 10.7905,
        longitude: 78.7047,
        timezone: 5.5,
        relationship: 'Spouse',
      );
      await service.addProfile(spouseProfile);
      await service.selectProfile(spouseProfile.id);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuickConsultationView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // TEST 11: Verify 4-Slot Headers are rendered
      expect(find.textContaining('SLOT 1'), findsOneWidget);
      expect(find.textContaining('SLOT 2'), findsOneWidget);
      expect(find.textContaining('SLOT 3'), findsOneWidget);
      expect(find.textContaining('SLOT 4'), findsOneWidget);

      // Verify Active Profile name is rendered in Slot 1
      expect(find.text('Spouse Profile'), findsWidgets);
      expect(find.textContaining('Spouse'), findsWidgets);

      // Verify Slot 2 (Rasi box text 'ராசி' & 'சக்கரம்')
      expect(find.text('ராசி'), findsWidgets);
      expect(find.text('சக்கரம்'), findsOneWidget);

      // Verify Slot 3 (KP Method 4)
      expect(find.textContaining('KP Method 4'), findsOneWidget);

      // Verify Slot 4 (Dasa / Bhukti)
      expect(find.textContaining('Dasha & Bhukti'), findsOneWidget);

      // TEST 12: Switch Profile via the switcher chips and verify update
      final primaryProfile = service.profiles.first;
      await service.selectProfile(primaryProfile.id);
      await tester.pumpAndSettle();

      expect(service.activeProfileId, equals(primaryProfile.id));
      expect(find.text(primaryProfile.name), findsWidgets);
    });
  });
}
