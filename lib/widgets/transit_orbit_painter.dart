import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/astrology_calculator.dart';

class TransitOrbitPainter extends CustomPainter {
  final Map<String, PlanetDetail>? transits;
  final Map<String, double>? transitPositions;
  final Color orbitColor;
  final Color badgeColor;
  final Color textColor;

  TransitOrbitPainter({
    this.transits,
    this.transitPositions,
    this.orbitColor = const Color(0xFF64B5F6),
    this.badgeColor = const Color(0xFF1565C0),
    this.textColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Radius of the transit orbit ring
    final radius = (math.min(size.width, size.height) / 2) - 12.0;
    if (radius <= 0) return;

    // Draw the circular transit orbit path
    final orbitPaint = Paint()
      ..color = orbitColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, radius, orbitPaint);

    // Draw outer perimeter border line
    const ringMargin = 2.0;
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(ringMargin, ringMargin, size.width - ringMargin * 2, size.height - ringMargin * 2),
      const Radius.circular(14),
    );
    canvas.drawRRect(outerRect, orbitPaint);

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

    // Group transit planets whose degrees are identical or within tolerance (2.5 degrees)
    final groups = _groupTransitPlanets(items, 2.5);

    // Render each group around its calculated orbital position
    for (final group in groups) {
      final count = group.length;
      final groupDegree = group.first.degree;
      final double radians = (groupDegree - 90.0) * math.pi / 180.0;
      final baseX = center.dx + radius * math.cos(radians);
      final baseY = center.dy + radius * math.sin(radians);
      final basePoint = Offset(baseX, baseY);

      for (int i = 0; i < count; i++) {
        final planetItem = group[i];
        // Calculate visual offset for collision avoidance
        final visualOffset = _calculateVisualOffset(i, count, radians);
        final markerPos = basePoint + visualOffset;

        // Draw planet circle marker
        _drawPlanetMarker(canvas, markerPos, size);

        // Draw planet label near the marker
        final labelOffset = _calculateLabelOffset(i, count, radians);
        _drawPlanetLabel(canvas, markerPos, labelOffset, planetItem.name, size);
      }
    }
  }

  /// Calculates visual offset around (baseX, baseY) for planets in the same group
  Offset _calculateVisualOffset(int index, int totalInGroup, double radians) {
    if (totalInGroup <= 1) return Offset.zero;

    final tan = Offset(-math.sin(radians), math.cos(radians));
    final rad = Offset(math.cos(radians), math.sin(radians));

    if (totalInGroup == 2) {
      // Offset the two markers slightly in opposite directions around the point
      final sign = (index == 0) ? 1.0 : -1.0;
      return Offset(
        tan.dx * 7.5 * sign + rad.dx * 3.0 * sign,
        tan.dy * 7.5 * sign + rad.dy * 3.0 * sign,
      );
    }

    if (totalInGroup == 3) {
      if (index == 0) return Offset(-tan.dx * 13.0, -tan.dy * 13.0);
      if (index == 1) return Offset(rad.dx * 6.0, rad.dy * 6.0);
      return Offset(tan.dx * 13.0, tan.dy * 13.0);
    }

    // 4 or more planets: arranged compactly without overlap
    final tanSign = (index % 2 == 0) ? 1.0 : -1.0;
    final radSign = (index < 2) ? 1.0 : -1.0;
    final step = (index ~/ 2) * 7.0;
    return Offset(
      tan.dx * (7.5 + step) * tanSign,
      tan.dy * (7.5 + step) * tanSign + rad.dy * 6.0 * radSign,
    );
  }

  /// Calculates label offset relative to marker position
  Offset _calculateLabelOffset(int index, int totalInGroup, double radians) {
    final tan = Offset(-math.sin(radians), math.cos(radians));
    final rad = Offset(math.cos(radians), math.sin(radians));

    if (totalInGroup <= 1) {
      return Offset(tan.dx * 11.0, tan.dy * 11.0);
    }

    if (totalInGroup == 2) {
      final sign = (index == 0) ? 1.0 : -1.0;
      return Offset(
        tan.dx * 13.0 * sign + rad.dx * 5.0 * sign,
        tan.dy * 13.0 * sign + rad.dy * 5.0 * sign,
      );
    }

    if (totalInGroup == 3) {
      if (index == 0) return Offset(-tan.dx * 12.0 - rad.dx * 4.0, -tan.dy * 12.0 - rad.dy * 4.0);
      if (index == 1) return Offset(rad.dx * 11.0, rad.dy * 11.0);
      return Offset(tan.dx * 12.0 - rad.dx * 4.0, tan.dy * 12.0 - rad.dy * 4.0);
    }

    final tanSign = (index % 2 == 0) ? 1.0 : -1.0;
    final radSign = (index < 2) ? 1.0 : -1.0;
    return Offset(
      tan.dx * 13.0 * tanSign,
      tan.dy * 13.0 * tanSign + rad.dy * 9.0 * radSign,
    );
  }

  /// Groups planets whose degrees are identical or within tolerance (2.5 degrees)
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
    const markerRadius = 4.0;
    final clampedX = pos.dx.clamp(markerRadius + 2.0, canvasSize.width - markerRadius - 2.0);
    final clampedY = pos.dy.clamp(markerRadius + 2.0, canvasSize.height - markerRadius - 2.0);
    final finalPos = Offset(clampedX, clampedY);

    final fillPaint = Paint()
      ..color = badgeColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = orbitColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(finalPos, markerRadius, fillPaint);
    canvas.drawCircle(finalPos, markerRadius, borderPaint);
    canvas.drawCircle(finalPos, 1.2, dotPaint);
  }

  void _drawPlanetLabel(Canvas canvas, Offset markerPos, Offset labelOffset, String name, Size canvasSize) {
    final textSpan = TextSpan(
      text: name,
      style: TextStyle(
        color: textColor,
        fontSize: 8.5,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(color: Colors.black, blurRadius: 3.0),
        ],
      ),
    );

    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final targetCenter = markerPos + labelOffset;
    final halfW = tp.width / 2 + 3.0;
    final halfH = tp.height / 2 + 1.5;

    final clampedX = targetCenter.dx.clamp(halfW + 1.0, canvasSize.width - halfW - 1.0);
    final clampedY = targetCenter.dy.clamp(halfH + 1.0, canvasSize.height - halfH - 1.0);
    final finalCenter = Offset(clampedX, clampedY);

    // Compact dark pill badge background for high readability
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: finalCenter, width: tp.width + 6, height: tp.height + 3),
      const Radius.circular(4),
    );

    final bgPaint = Paint()
      ..color = const Color(0xFF0D1B2A).withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = orbitColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

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
        oldDelegate.textColor != textColor;
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
