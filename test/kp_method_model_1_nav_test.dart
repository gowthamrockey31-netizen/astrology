import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/kp_method_model_1/kp_method_model_1.dart';
import 'package:astrocall/widgets/cosmic_drawer.dart';

void main() {
  testWidgets('Navigation: Drawer contains KP Method Model 1 and navigates correctly', (tester) async {
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

    // Scroll down inside drawer if needed
    final drawerItem = find.text('🔮 KP Method Model 1');
    expect(drawerItem, findsOneWidget);

    await tester.ensureVisible(drawerItem);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(drawerItem);
    await tester.pump(const Duration(milliseconds: 100));

    expect(navigatedRoute, '/kp_method_model_1');
  });

  testWidgets('Navigation: Dashboard Card triggers route navigation', (tester) async {
    String? navigatedRoute;

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/kp_method_model_1': (context) {
            navigatedRoute = '/kp_method_model_1';
            return const Scaffold(body: Text('KP Method Page Loaded'));
          },
        },
        home: Scaffold(
          body: KPDashboardCard(
            onTap: () {
              navigatedRoute = '/kp_method_model_1';
            },
          ),
        ),
      ),
    );

    expect(find.text('KP Method Model 1'), findsOneWidget);
    await tester.tap(find.text('OPEN'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(navigatedRoute, '/kp_method_model_1');
  });
}
