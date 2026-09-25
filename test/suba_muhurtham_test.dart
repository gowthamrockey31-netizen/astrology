import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/suba_muhurtham_model.dart';
import 'package:astrocall/services/suba_muhurtham_service.dart';
import 'package:astrocall/screens/admin/admin_suba_muhurtham_cms_screen.dart';
import 'package:astrocall/modules/professional_muhurtha/professional_muhurtha_page.dart';

void main() {
  group('Suba Muhurtham Data Model & Service Tests', () {
    test('Default records are present and correctly populated', () {
      final defaults = SubaMuhurthamModel.defaultList();
      expect(defaults.isNotEmpty, isTrue);
      expect(defaults.length, greaterThanOrEqualTo(5));

      final first = defaults.first;
      expect(first.tamilDate, 'வைகாசி 02');
      expect(first.englishDate, 'மே 16');
      expect(first.dayOfWeek, 'வெள்ளி');
      expect(first.muhurthamTime, 'காலை 9:10 - 9:22');
    });

    test('Serialization and Deserialization works properly', () {
      const item = SubaMuhurthamModel(
        id: 'test_1',
        tamilDate: 'வைகாசி 04',
        englishDate: 'மே 18',
        dayOfWeek: 'ஞாயிறு',
        tithi: 'சப்தமி',
        nakshatra: 'உத்திராடம்',
        yoga: 'அமிர்த யோகம்',
        muhurthamTime: 'காலை 10:28 - 10:42',
        lagna: 'மிதுனம்',
        description: 'புது வண்டி வாங்க, தொழில் தொடங்க',
        displayOrder: 2,
        isActive: true,
      );

      final map = item.toMap();
      final fromMap = SubaMuhurthamModel.fromMap(map);

      expect(fromMap.id, item.id);
      expect(fromMap.tamilDate, item.tamilDate);
      expect(fromMap.englishDate, item.englishDate);
      expect(fromMap.muhurthamTime, item.muhurthamTime);
      expect(fromMap.description, item.description);
    });

    test('CRUD operations in SubaMuhurthamService work reliably', () async {
      await SubaMuhurthamService.resetToDefaults();
      final initialList = await SubaMuhurthamService.fetchList(includeInactive: true);
      final initialCount = initialList.length;

      // ADD
      const newItem = SubaMuhurthamModel(
        id: 'test_add_1',
        tamilDate: 'ஆனி 01',
        englishDate: 'ஜூன் 15',
        dayOfWeek: 'ஞாயிறு',
        tithi: 'துவிதியை',
        nakshatra: 'மிருகசீரிஷம்',
        yoga: 'சித்த யோகம்',
        muhurthamTime: 'காலை 9:00 - 10:00',
        lagna: 'சிம்மம்',
        description: 'புது மனை புகுவிழா',
        displayOrder: 100,
        isActive: true,
      );

      await SubaMuhurthamService.add(newItem);
      var updatedList = await SubaMuhurthamService.fetchList(includeInactive: true);
      expect(updatedList.length, initialCount + 1);

      // EDIT
      final editedItem = newItem.copyWith(muhurthamTime: 'காலை 9:30 - 10:30');
      await SubaMuhurthamService.edit(editedItem);
      updatedList = await SubaMuhurthamService.fetchList(includeInactive: true);
      final found = updatedList.firstWhere((e) => e.id == 'test_add_1');
      expect(found.muhurthamTime, 'காலை 9:30 - 10:30');

      // DELETE
      await SubaMuhurthamService.delete('test_add_1');
      updatedList = await SubaMuhurthamService.fetchList(includeInactive: true);
      expect(updatedList.length, initialCount);
    });
  });

  group('Suba Muhurtham UI Widget Tests', () {
    testWidgets('ProfessionalMuhurthaPage renders Suba Muhurtham Schedule Table', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfessionalMuhurthaPage(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      // Verify the Table Section Header
      expect(find.text('சுப முகூர்த்த அட்டவணை (Suba Muhurtham Schedule)'), findsOneWidget);

      // Verify Table Columns
      expect(find.text('தமிழ் தேதி'), findsOneWidget);
      expect(find.text('ஆங்கில தேதி'), findsOneWidget);
      expect(find.text('வாரம்'), findsOneWidget);
      expect(find.text('திதி'), findsOneWidget);
      expect(find.text('நட்சத்திரம்'), findsOneWidget);
      expect(find.text('யோகம்'), findsOneWidget);
      expect(find.text('முகூர்த்த நேரம் (தாலி நேரம்)'), findsOneWidget);
      expect(find.text('லக்னம்'), findsOneWidget);
      expect(find.text('சுப காரிய விவரம்'), findsOneWidget);

      // Verify sample data rendered
      expect(find.text('வைகாசி 02'), findsOneWidget);
      expect(find.text('மே 16'), findsOneWidget);
    });

    testWidgets('AdminSubaMuhurthamCmsScreen renders list and Add button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminSubaMuhurthamCmsScreen(),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      // Verify CMS title
      expect(find.text('சுப முகூர்த்த நேரம் CMS'), findsOneWidget);

      // Verify FAB Add button
      expect(find.text('புதிய முகூர்த்தம் சேர்க்க'), findsOneWidget);

      // Verify existing items in reorderable list
      expect(find.textContaining('வைகாசி 02'), findsOneWidget);
    });
  });
}
