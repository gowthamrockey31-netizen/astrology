import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/modules/bnn_method_2/bnn_method_2.dart';
import 'package:astrocall/widgets/cosmic_drawer.dart';

void main() {
  testWidgets('Navigation: Drawer contains BNN Method 2 and navigates correctly', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    String? navigatedRoute;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          drawer: CosmicDrawer(
            onSelectRoute: (route) {
              navigatedRoute = route;
            },
          ),
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open Drawer'),
              );
            },
          ),
        ),
      ),
    );

    // Open drawer and let drawer slide into view
    await tester.tap(find.text('Open Drawer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Find BNN Method 2 item in drawer
    final drawerItem = find.text('பிருகு நந்தி நாடி - BNN Method 2');
    expect(drawerItem, findsOneWidget);

    await tester.ensureVisible(drawerItem);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(drawerItem);
    await tester.pump(const Duration(milliseconds: 100));

    expect(navigatedRoute, '/bnn_method_2');
  });

  testWidgets('Direct route to BhriguNandiNadiMethod2Screen renders correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BhriguNandiNadiMethod2Screen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('பிருகு நந்தி நாடி - Method 2'), findsOneWidget);
    expect(find.text('ஜாதக விவரங்கள் (Birth Input)'), findsOneWidget);
    expect(find.text('கணக்கீடு செய் (Calculate)'), findsOneWidget);
  });
}
