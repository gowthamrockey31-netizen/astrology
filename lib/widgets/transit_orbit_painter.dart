import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/astrology_calculator.dart';

class TransitOrbitPainter extends CustomPainter {
  final Map<String, PlanetDetail>? transits;
  final Map<String, double>? transitPositions;
  final Color orbitColor;
  final Color badgeColor;
  final Color textColor;

  final bool showOrbitLine;

  TransitOrbitPainter({
    this.transits,
    this.transitPositions,
    this.orbitColor = const Color(0xFF42A5F5),
    this.badgeColor = const Color(0xFF091422),
    this.textColor = Colors.white,
    this.showOrbitLine = false,
  });

  /// Grid margin matching SouthIndianJathagamWidget grid padding
  static const double gridMargin = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    final gridSize = math.min(size.width, size.height) - gridMargin * 2;
    if (gridSize <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    // Radius of the transit orbit positions - runs comfortably through the 12 rasi boxes,
    // safely inside the outer box borders and clear of the center 2x2 area
    final radius = gridSize * 0.385;

    // Draw the circular transit orbit path only if explicitly requested
    if (showOrbitLine) {
      final orbitPaint = Paint()
        ..color = orbitColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawCircle(center, radius, orbitPaint);
    }

    // Extract transit planet items from transitPositions or transits
    final items = <_TransitPlanetItem>[];
    if (transitPositions != null) {
      transitPositions!.forEach((planet, degree) {
        items.add(_TransitPlanetItem(name: planet, degree: degree));
      });
    } else if (transits != null) {
      transits!.forEach((key, val) {
        final name = val.tamilName.isNotEmpty ? val.tamilName : key;
        items.add(_TransitPlanetItem(name: name, degree: val.longitude, detail: val));
      });
    }

    if (items.isEmpty) return;

    // Group transit planets whose degrees are identical or within tolerance (5.5 degrees)
    final groups = _groupTransitPlanets(items, 5.5);

    // Render each group around its calculated orbital position inside the rasi boxes
    for (final group in groups) {
      final count = group.length;
      final groupDegree = group.first.degree;
      final double radians = degreeToRadians(groupDegree);
      final baseX = center.dx + radius * math.cos(radians);
      final baseY = center.dy + radius * math.sin(radians);
      final basePoint = Offset(baseX, baseY);

      for (int i = 0; i < count; i++) {
        final planetItem = group[i];
        // Calculate visual offset for collision avoidance
        final visualOffset = _calculateVisualOffset(i, count, radians);
        final markerPos = basePoint + visualOffset;

        // Draw planet circle marker strictly inside the box boundaries
        _drawPlanetMarker(canvas, markerPos, size);

        // Draw planet label near the marker, safely within the box
        final labelOffset = _calculateLabelOffset(i, count, radians);
        _drawPlanetLabel(canvas, markerPos, labelOffset, planetItem.name, size);
      }
    }
  }

  /// Converts celestial longitude (0° to 360°) to the exact angle in radians
  /// corresponding to each sign's box in the South Indian 4x4 chart layout:
  ///
  /// Row 0: Meenam (11), Mesham (0), Rishabam (1), Mithunam (2)
  /// Row 1: Kumbam (10),             Center,       Katakam (3)
  /// Row 2: Makaram (9),             Center,       Simham (4)
  /// Row 3: Dhanusu (8), Viruchigam (7), Thulam (6), Kanni (5)
  static double degreeToRadians(double degree) {
    final normDeg = (degree % 360.0 + 360.0) % 360.0;
    final int rasiIdx = (normDeg / 30.0).floor() % 12;
    final double frac = (normDeg % 30.0) / 30.0;

    const atan1_5 = 0.5880026035475675; // atan(1.0 / 1.5) = 33.69°
    const atan15_1 = 0.982793723247329; // atan(1.5 / 1.0) = 56.31°
    const halfPi = math.pi / 2.0;       // 90.0°
    const piVal = math.pi;

    double startAngle;
    double endAngle;

    switch (rasiIdx) {
      case 0: // Mesham (Col 1, Row 0)
        startAngle = -(piVal - atan15_1); // -123.69°
        endAngle = -halfPi;               // -90.0°
        break;
      case 1: // Rishabam (Col 2, Row 0)
        startAngle = -halfPi;             // -90.0°
        endAngle = -atan15_1;             // -56.31°
        break;
      case 2: // Mithunam (Col 3, Row 0)
        startAngle = -atan15_1;           // -56.31°
        endAngle = -atan1_5;              // -33.69°
        break;
      case 3: // Katakam (Col 3, Row 1)
        startAngle = -atan1_5;            // -33.69°
        endAngle = 0.0;                   // 0.0°
        break;
      case 4: // Simham (Col 3, Row 2)
        startAngle = 0.0;                 // 0.0°
        endAngle = atan1_5;               // +33.69°
        break;
      case 5: // Kanni (Col 3, Row 3)
        startAngle = atan1_5;             // +33.69°
        endAngle = atan15_1;              // +56.31°
        break;
      case 6: // Thulam (Col 2, Row 3)
        startAngle = atan15_1;            // +56.31°
        endAngle = halfPi;                // +90.0°
        break;
      case 7: // Viruchigam (Col 1, Row 3)
        startAngle = halfPi;              // +90.0°
        endAngle = piVal - atan15_1;      // +123.69°
        break;
      case 8: // Dhanusu (Col 0, Row 3)
        startAngle = piVal - atan15_1;    // +123.69°
        endAngle = piVal - atan1_5;       // +146.31°
        break;
      case 9: // Makaram (Col 0, Row 2)
        startAngle = piVal - atan1_5;     // +146.31°
        endAngle = piVal;                 // +180.0°
        break;
      case 10: // Kumbam (Col 0, Row 1)
        startAngle = -piVal;              // -180.0°
        endAngle = -(piVal - atan1_5);    // -146.31°
        break;
      case 11: // Meenam (Col 0, Row 0)
      default:
        startAngle = -(piVal - atan1_5);  // -146.31°
        endAngle = -(piVal - atan15_1);   // -123.69°
        break;
    }

    return startAngle + frac * (endAngle - startAngle);
  }

  /// Calculates visual offset around (baseX, baseY) for planets in the same group.
  /// Nudges slightly inward toward the center to avoid outer border collisions.
  Offset _calculateVisualOffset(int index, int totalInGroup, double radians) {
    if (totalInGroup <= 1) return Offset.zero;

    final tan = Offset(-math.sin(radians), math.cos(radians));
    final rad = Offset(math.cos(radians), math.sin(radians));

    if (totalInGroup == 2) {
      final sign = (index == 0) ? 1.0 : -1.0;
      return Offset(
        tan.dx * 7.5 * sign - rad.dx * 2.0,
        tan.dy * 7.5 * sign - rad.dy * 2.0,
      );
    }

    if (totalInGroup == 3) {
      if (index == 0) return Offset(-tan.dx * 12.0 - rad.dx * 2.0, -tan.dy * 12.0 - rad.dy * 2.0);
      if (index == 1) return Offset(-rad.dx * 4.0, -rad.dy * 4.0);
      return Offset(tan.dx * 12.0 - rad.dx * 2.0, tan.dy * 12.0 - rad.dy * 2.0);
    }

    // 4 or more planets: arranged compactly along tangent with slight inward bias
    final tanSign = (index % 2 == 0) ? 1.0 : -1.0;
    final step = (index ~/ 2) * 7.0;
    return Offset(
      tan.dx * (7.0 + step) * tanSign - rad.dx * 2.0,
      tan.dy * (7.0 + step) * tanSign - rad.dy * 2.0,
    );
  }

  /// Calculates label offset relative to marker position.
  /// Places labels along tangent and biased slightly inward towards the chart center.
  Offset _calculateLabelOffset(int index, int totalInGroup, double radians) {
    final tan = Offset(-math.sin(radians), math.cos(radians));
    final rad = Offset(math.cos(radians), math.sin(radians));
    const inward = 3.0;

    if (totalInGroup <= 1) {
      return Offset(tan.dx * 10.0 - rad.dx * inward, tan.dy * 10.0 - rad.dy * inward);
    }

    if (totalInGroup == 2) {
      final sign = (index == 0) ? 1.0 : -1.0;
      return Offset(
        tan.dx * 12.0 * sign - rad.dx * (inward + 2.0),
        tan.dy * 12.0 * sign - rad.dy * (inward + 2.0),
      );
    }

    if (totalInGroup == 3) {
      if (index == 0) return Offset(-tan.dx * 11.0 - rad.dx * inward, -tan.dy * 11.0 - rad.dy * inward);
      if (index == 1) return Offset(-rad.dx * (inward + 7.0), -rad.dy * (inward + 7.0));
      return Offset(tan.dx * 11.0 - rad.dx * inward, tan.dy * 11.0 - rad.dy * inward);
    }

    final tanSign = (index % 2 == 0) ? 1.0 : -1.0;
    return Offset(
      tan.dx * 12.0 * tanSign - rad.dx * inward,
      tan.dy * 12.0 * tanSign - rad.dy * inward,
    );
  }

  /// Groups planets whose degrees are identical or within tolerance (5.5 degrees)
  List<List<_TransitPlanetItem>> _groupTransitPlanets(List<_TransitPlanetItem> items, double tolerance) {
    final remaining = List<_TransitPlanetItem>.from(items);
    final groups = <List<_TransitPlanetItem>>[];

    while (remaining.isNotEmpty) {
      final current = remaining.removeAt(0);
      final group = <_TransitPlanetItem>[current];

      bool added = true;
      while (added) {
        added = false;
        for (int i = remaining.length - 1; i >= 0; i--) {
          final candidate = remaining[i];
          final isNear = group.any((item) => _angularDistance(item.degree, candidate.degree) <= tolerance);
          if (isNear) {
            group.add(candidate);
            remaining.removeAt(i);
            added = true;
          }
        }
      }

      groups.add(group);
    }

    return groups;
  }

  static double _angularDistance(double a, double b) {
    var diff = (a - b).abs() % 360.0;
    if (diff > 180.0) diff = 360.0 - diff;
    return diff;
  }

  void _drawPlanetMarker(Canvas canvas, Offset pos, Size canvasSize) {
    const markerRadius = 3.5;
    final minX = gridMargin + 2.0;
    final maxX = canvasSize.width - gridMargin - 2.0;
    final minY = gridMargin + 2.0;
    final maxY = canvasSize.height - gridMargin - 2.0;

    final clampedX = pos.dx.clamp(minX + markerRadius, maxX - markerRadius);
    final clampedY = pos.dy.clamp(minY + markerRadius, maxY - markerRadius);
    final finalPos = Offset(clampedX, clampedY);

    final glowPaint = Paint()
      ..color = const Color(0xFF29B6F6).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final fillPaint = Paint()
      ..color = const Color(0xFF0D47A1)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF40C4FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(finalPos, markerRadius + 1.0, glowPaint);
    canvas.drawCircle(finalPos, markerRadius, fillPaint);
    canvas.drawCircle(finalPos, markerRadius, borderPaint);
    canvas.drawCircle(finalPos, 1.2, dotPaint);
  }

  void _drawPlanetLabel(Canvas canvas, Offset markerPos, Offset labelOffset, String name, Size canvasSize) {
    final textSpan = TextSpan(
      text: name,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 8.5,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
    );

    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final targetCenter = markerPos + labelOffset;
    final halfW = tp.width / 2 + 4.0;
    final halfH = tp.height / 2 + 2.0;

    // Strictly clamp within rasi box grid boundary (inside the gridMargin)
    final minX = gridMargin + 2.0;
    final maxX = canvasSize.width - gridMargin - 2.0;
    final minY = gridMargin + 2.0;
    final maxY = canvasSize.height - gridMargin - 2.0;

    final clampedX = targetCenter.dx.clamp(minX + halfW, maxX - halfW);
    final clampedY = targetCenter.dy.clamp(minY + halfH, maxY - halfH);
    final finalCenter = Offset(clampedX, clampedY);

    // Compact dark pill badge background for high readability
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: finalCenter, width: tp.width + 9, height: tp.height + 4),
      const Radius.circular(5),
    );

    final bgPaint = Paint()
      ..color = const Color(0xFF091422).withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF42A5F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(bgRect, bgPaint);
    canvas.drawRRect(bgRect, borderPaint);

    tp.paint(canvas, Offset(finalCenter.dx - tp.width / 2, finalCenter.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant TransitOrbitPainter oldDelegate) {
    return oldDelegate.transits != transits ||
        oldDelegate.transitPositions != transitPositions ||
        oldDelegate.orbitColor != orbitColor ||
        oldDelegate.badgeColor != badgeColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.showOrbitLine != showOrbitLine;
  }
}

class _TransitPlanetItem {
  final String name;
  final double degree;
  final PlanetDetail? detail;

  _TransitPlanetItem({
    required this.name,
    required this.degree,
    this.detail,
  });
}
