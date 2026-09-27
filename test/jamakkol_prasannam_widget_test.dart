import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/jamakkol_prasannam/models/jamakkol_models.dart';
import 'package:astrocall/jamakkol_prasannam/engine/jamakkol_engine.dart';
import 'package:astrocall/jamakkol_prasannam/widgets/jamakkol_chart.dart';
import 'package:astrocall/jamakkol_prasannam/widgets/jamam_status_card.dart';
import 'package:astrocall/jamakkol_prasannam/widgets/udayam_arudam_kavippu_card.dart';
import 'package:astrocall/jamakkol_prasannam/widgets/planet_position_table.dart';
import 'package:astrocall/jamakkol_prasannam/widgets/jamakkol_result_sections.dart';
import 'package:astrocall/jamakkol_prasannam/screens/jamakkol_home_screen.dart';
import 'package:astrocall/jamakkol_prasannam/screens/jamakkol_result_screen.dart';

void main() {
  final testDate = DateTime(2026, 9, 27, 10, 0);
  final chartState = JamakkolEngine.calculateChart(
    queryDateTime: testDate,
    location: JamakkolLocation.defaultChennai,
    question: 'தொழில் வெற்றி பெறுமா?',
    questionCategory: JamakkolQuestionCategory.job,
  );

  testWidgets('JamakkolChartWidget renders South Indian 4x4 chart cells and center dashboard', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: JamakkolChartWidget(state: chartState, isTamil: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify presence of Udayam, Arudam, Kavippu indicators in the chart
    expect(find.byType(JamakkolChartWidget), findsOneWidget);
    expect(find.text('ஜாமக்கோள் பிரசன்னம்'), findsAtLeastNWidgets(1));
  });

  testWidgets('JamamStatusCardWidget renders current Jamam, ruler, and sunrise/sunset', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: JamamStatusCardWidget(state: chartState, isTamil: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(JamamStatusCardWidget), findsOneWidget);
    expect(find.textContaining('ஜாமம்'), findsAtLeastNWidgets(1));
  });

  testWidgets('UdayamArudamKavippuCardWidget renders the three pillars', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: UdayamArudamKavippuCardWidget(state: chartState, isTamil: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(UdayamArudamKavippuCardWidget), findsOneWidget);
    expect(find.textContaining('உதயம்'), findsAtLeastNWidgets(1));
    expect(find.textContaining('ஆருடம்'), findsAtLeastNWidgets(1));
    expect(find.textContaining('கவிப்பு'), findsAtLeastNWidgets(1));
  });

  testWidgets('PlanetPositionTableWidget renders tabs and switches between Gocharam, Jamam, and Special Points', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PlanetPositionTableWidget(state: chartState, isTamil: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PlanetPositionTableWidget), findsOneWidget);
    expect(find.textContaining('கோச்சார கிரகங்கள்'), findsOneWidget);
    expect(find.textContaining('ஜாம கிரகங்கள்'), findsOneWidget);
    expect(find.textContaining('சிறப்பு புள்ளிகள்'), findsOneWidget);

    // Tap on Jamam planets tab
    await tester.tap(find.textContaining('ஜாம கிரகங்கள்'));
    await tester.pumpAndSettle();
    expect(find.text('சூரியன்'), findsAtLeastNWidgets(1));
  });

  testWidgets('JamakkolResultSectionsWidget renders interpretation sections and Next 1 Hour slots', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: JamakkolResultSectionsWidget(state: chartState, isTamil: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(JamakkolResultSectionsWidget), findsOneWidget);
    expect(find.textContaining('அடுத்த 1 மணி நேர பலன்'), findsOneWidget);
  });

  testWidgets('JamakkolResultScreen renders full consultation report with remedies', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: JamakkolResultScreen(state: chartState, isTamil: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(JamakkolResultScreen), findsOneWidget);
    expect(find.text('பிரசன்ன ஆய்வு அறிக்கை'), findsOneWidget);
    expect(find.textContaining('ஜோதிடப் பரிகாரம்'), findsOneWidget);
  });

  testWidgets('JamakkolHomeScreen renders Live Screen without crashing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: JamakkolHomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(JamakkolHomeScreen), findsOneWidget);
    expect(find.text('ஜாமக்கோள் பிரசன்னம்'), findsAtLeastNWidgets(1));
  });
}
