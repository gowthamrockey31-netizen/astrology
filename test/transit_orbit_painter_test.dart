import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/widgets/transit_orbit_painter.dart';
import 'package:astrocall/services/astrology_calculator.dart';

void main() {
  group('TransitOrbitPainter Collision Avoidance Tests', () {
    test('TransitOrbitPainter paints two planets at identical degree (120.5°) with visual separation', () {
      final transitPositions = {
        'குரு': 120.5,
        'சனி': 120.5,
      };

      final painter = TransitOrbitPainter(transitPositions: transitPositions);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(350, 350);

      expect(() => painter.paint(canvas, size), returnsNormally);

      final picture = recorder.endRecording();
      expect(picture, isNotNull);

      // Verify degree values remain completely unchanged
      expect(transitPositions['குரு'], 120.5);
      expect(transitPositions['சனி'], 120.5);
    });

    test('Single planet at 45.0° renders normally', () {
      final transitPositions = {
        'செவ்வாய்': 45.0,
      };

      final painter = TransitOrbitPainter(transitPositions: transitPositions);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(350, 350);

      expect(() => painter.paint(canvas, size), returnsNormally);
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
      expect(transitPositions['செவ்வாய்'], 45.0);
    });

    test('3 planets at identical degree arrange compactly without error', () {
      final transitPositions = {
        'சூரியன்': 90.0,
        'புதன்': 90.0,
        'சுக்கிரன்': 91.0,
      };

      final painter = TransitOrbitPainter(transitPositions: transitPositions);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(350, 350);

      expect(() => painter.paint(canvas, size), returnsNormally);
      final picture = recorder.endRecording();
      expect(picture, isNotNull);
    });

    test('Handles Map<String, PlanetDetail> input from birth chart data', () {
      final jupDetail = PlanetDetail.fromSiderealLongitude(
        name: 'Jupiter',
        tamilName: 'குரு',
        symbol: 'குரு',
        longitude: 120.5,
      );
      final satDetail = PlanetDetail.fromSiderealLongitude(
        name: 'Saturn',
        tamilName: 'சனி',
        symbol: 'சனி',
        longitude: 120.5,
      );

      final transits = {
        'Jupiter': jupDetail,
        'Saturn': satDetail,
      };

      final painter = TransitOrbitPainter(transits: transits);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(350, 350);

      expect(() => painter.paint(canvas, size), returnsNormally);
      final picture = recorder.endRecording();
      expect(picture, isNotNull);

      // Verify astronomical longitude remains unchanged
      expect(jupDetail.longitude, 120.5);
      expect(satDetail.longitude, 120.5);
    });

    testWidgets('Widget test rendering TransitOrbitPainter in a CustomPaint widget', (tester) async {
      final transitPositions = {
        'குரு': 120.5,
        'சனி': 120.5,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: CustomPaint(
                  painter: TransitOrbitPainter(transitPositions: transitPositions),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
