import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/kp_method_4/kp_method_4.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = FlutterError.dumpErrorToConsole;
  });

  group('KP Method 4 Widget & Responsiveness Tests', () {
    testWidgets('1. Desktop Viewport (1200x800): Renders without overflow and shows all sections', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: KPMethod4Page(
            initialBirthData: Kp4BirthData.defaultProfile(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // Verify Title & Subtitle in AppBar
      expect(find.text('KP Method 4'), findsWidgets);
      expect(find.text('Swiss Ephemeris'), findsWidgets);

      // Verify Initial Overview content
      expect(find.text('முழுமையான பார்வை (All)'), findsOneWidget);
      expect(find.textContaining('Planet Positions'), findsOneWidget);
      expect(find.textContaining('12 Bhava Cusps'), findsOneWidget);
      expect(find.textContaining('Planet ➔ Bhava Mapping'), findsOneWidget);
      expect(find.textContaining('Graha Thodarbhu'), findsOneWidget);
      expect(find.textContaining('Bhava Graha Relations'), findsOneWidget);
      expect(find.textContaining('Dasha Relations'), findsOneWidget);

      // Verify no RenderFlex exception occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('2. Mobile Portrait Viewport (360x640): Initial "All" view renders without RenderFlex overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: KPMethod4Page(
            initialBirthData: Kp4BirthData.defaultProfile(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // Check header info
      expect(find.text('KP Method 4'), findsWidgets);
      expect(find.text('Swiss Ephemeris'), findsWidgets);

      // Scroll through entire page vertically on 360px mobile screen to layout all cards
      final scrollable = find.byType(Scrollable).at(1); // Main content scrollable
      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.drag(scrollable, const Offset(0, -800));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.drag(scrollable, const Offset(0, -1000));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify absolutely zero RenderFlex overflows occurred on mobile portrait
      final ex = tester.takeException();
      if (ex != null) {
        if (ex is FlutterError) {
          debugPrint('FLUTTER_ERROR_DEEP: ${ex.toStringDeep()}');
        } else {
          debugPrint('EXCEPTION: $ex');
        }
      }
      expect(ex, isNull);
    });

    testWidgets('3. Mobile Portrait (360x640): Tab switching works cleanly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: KPMethod4Page(
            initialBirthData: Kp4BirthData.defaultProfile(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // Scroll horizontal tab list to bring 2. Planets tab fully into view
      final planetTab = find.text('2. கிரக நிலைகள் (Planets)');
      expect(planetTab, findsOneWidget);
      await tester.ensureVisible(planetTab);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(planetTab);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Planet Positions'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Scroll horizontal tab list further to bring 4. Planet ➔ Bhava tab fully into view
      final mappingTab = find.text('4. கிரகம் ➔ பாவ தொடர்புகள்');
      expect(mappingTab, findsOneWidget);
      await tester.ensureVisible(mappingTab);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(mappingTab);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Planet ➔ Bhava Mapping'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('4. House 8 and 12 warning highlights are strictly RED (Color(0xFFFF5252))', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: KPMethod4Page(
            initialBirthData: Kp4BirthData.defaultProfile(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // Find Text widgets that display house numbers
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      
      bool found8Or12Red = false;
      for (final textWidget in textWidgets) {
        final text = textWidget.data ?? '';
        final cleanText = text.replaceAll('\$', '').replaceAll('*', '').trim();
        if (cleanText == '8' || cleanText == '12') {
          if (textWidget.style?.color == const Color(0xFFFF5252)) {
            found8Or12Red = true;
          }
        }
      }

      expect(found8Or12Red, isTrue, reason: 'House 8 and 12 must be highlighted in RED (Color(0xFFFF5252))');
      expect(find.text('8, 12 (தடை/மறைவு - RED)'), findsWidgets);
      expect(find.text('5, 9 (சுப பலன் - GREEN)'), findsWidgets);
    });

    testWidgets('5. Sub-Sub and Star Lord fallback legends and markers are displayed', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: KPMethod4Page(
            initialBirthData: Kp4BirthData.defaultProfile(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // Verify legend indicators
      expect(find.text('\$ = Sub-Sub Fallback'), findsWidgets);
      expect(find.text('* = Star Lord Fallback'), findsWidgets);
    });
  });
}
