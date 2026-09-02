import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/screens/jamakol_arudam_model1_screen.dart';

void main() {
  testWidgets('Navigation to /jamakol_arudam_model1 opens JamakolArudamModel1Screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/jamakol_arudam_model1'),
                    child: const Text('Open Model 1'),
                  ),
                ),
              ),
          '/jamakol_arudam_model1': (context) => const JamakolArudamModel1Screen(),
        },
      ),
    );

    await tester.pump();

    // Verify initial screen
    expect(find.text('Open Model 1'), findsOneWidget);

    // Tap button to navigate
    await tester.tap(find.text('Open Model 1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify JamakolArudamModel1Screen opened
    expect(find.text('ஜாமகோள் ஆருடம் – Model 1'), findsOneWidget);
    expect(find.text('முக்கிய புள்ளிகள் (Core Points)'), findsOneWidget);
  });
}
