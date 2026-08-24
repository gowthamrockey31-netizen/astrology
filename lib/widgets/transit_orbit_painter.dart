import 'package:flutter/material.dart';
import '../services/astrology_calculator.dart';

class TransitOrbitPainter extends CustomPainter {
  final Map<String, PlanetDetail> transits;
  final Color orbitColor;
  final Color badgeColor;
  final Color textColor;

  TransitOrbitPainter({
    required this.transits,
    this.orbitColor = const Color(0xFF64B5F6),
    this.badgeColor = const Color(0xFF1565C0),
    this.textColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Outer perimeter ring line
    const ringMargin = 2.0;
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(ringMargin, ringMargin, size.width - ringMargin * 2, size.height - ringMargin * 2),
      const Radius.circular(14),
    );

    final orbitPaint = Paint()
      ..color = orbitColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRRect(outerRect, orbitPaint);

    if (transits.isEmpty) return;

    // Group transit planets by their Zodiac Rasi Index (0..11)
    final Map<int, List<PlanetDetail>> rasiTransits = {};
    for (final detail in transits.values) {
      rasiTransits.putIfAbsent(detail.rasiIndex, () => []).add(detail);
    }

    // Paint transit badges house-by-house with precise collision avoidance
    for (int rasiIdx = 0; rasiIdx < 12; rasiIdx++) {
      final houseTransits = rasiTransits[rasiIdx];
      if (houseTransits == null || houseTransits.isEmpty) continue;

      final count = houseTransits.length;
      final offsets = _calculateHouseBadgeOffsets(rasiIdx, count, size);

      for (int i = 0; i < count; i++) {
        _drawTransitBadge(canvas, offsets[i], houseTransits[i], size);
      }
    }
  }

  /// Calculates exact perimeter badge centers for N transit planets in a specific Rasi house
  List<Offset> _calculateHouseBadgeOffsets(int rasiIdx, int count, Size size) {
    final w = size.width;
    final h = size.height;
    const ringDepth = 13.0; // Center offset inside 26px outer ring channel

    // Helper to get evenly spaced points along [start, end]
    List<double> getSubPoints(double start, double end, int n) {
      if (n == 1) return [(start + end) / 2.0];
      final step = (end - start) / (n + 1);
      return List.generate(n, (i) => start + step * (i + 1));
    }

    final offsets = <Offset>[];

    switch (rasiIdx) {
      // Top Edge (Meenam, Mesham, Rishabam, Mithunam)
      case 11: // Meenam (0.0 -> 0.25)
        final xs = getSubPoints(6.0, w * 0.25 - 4.0, count);
        for (var x in xs) {
          offsets.add(Offset(x, ringDepth));
        }
        break;
      case 0: // Mesham (0.25 -> 0.50)
        final xs = getSubPoints(w * 0.25 + 4.0, w * 0.50 - 4.0, count);
        for (var x in xs) {
          offsets.add(Offset(x, ringDepth));
        }
        break;
      case 1: // Rishabam (0.50 -> 0.75)
        final xs = getSubPoints(w * 0.50 + 4.0, w * 0.75 - 4.0, count);
        for (var x in xs) {
          offsets.add(Offset(x, ringDepth));
        }
        break;
      case 2: // Mithunam (0.75 -> 1.0)
        final xs = getSubPoints(w * 0.75 + 4.0, w - 6.0, count);
        for (var x in xs) {
          offsets.add(Offset(x, ringDepth));
        }
        break;

      // Right Edge (Kadagam, Simmam, Kanni)
      case 3: // Kadagam (0.25 -> 0.50)
        final ys = getSubPoints(h * 0.25 + 4.0, h * 0.50 - 4.0, count);
        for (var y in ys) {
          offsets.add(Offset(w - ringDepth, y));
        }
        break;
      case 4: // Simmam (0.50 -> 0.75)
        final ys = getSubPoints(h * 0.50 + 4.0, h * 0.75 - 4.0, count);
        for (var y in ys) {
          offsets.add(Offset(w - ringDepth, y));
        }
        break;
      case 5: // Kanni (0.75 -> 1.0)
        final ys = getSubPoints(h * 0.75 + 4.0, h - 6.0, count);
        for (var y in ys) {
          offsets.add(Offset(w - ringDepth, y));
        }
        break;

      // Bottom Edge (Thulam, Viruchigam, Dhanusu)
      case 6: // Thulam (0.50 -> 0.75)
        final xs = getSubPoints(w * 0.75 - 4.0, w * 0.50 + 4.0, count);
        for (var x in xs) {
          offsets.add(Offset(x, h - ringDepth));
        }
        break;
      case 7: // Viruchigam (0.25 -> 0.50)
        final xs = getSubPoints(w * 0.50 - 4.0, w * 0.25 + 4.0, count);
        for (var x in xs) {
          offsets.add(Offset(x, h - ringDepth));
        }
        break;
      case 8: // Dhanusu (0.0 -> 0.25)
        final xs = getSubPoints(w * 0.25 - 4.0, 6.0, count);
        for (var x in xs) {
          offsets.add(Offset(x, h - ringDepth));
        }
        break;

      // Left Edge (Makaram, Kumbam)
      case 9: // Makaram (0.50 -> 0.75)
        final ys = getSubPoints(h * 0.75 - 4.0, h * 0.50 + 4.0, count);
        for (var y in ys) {
          offsets.add(Offset(ringDepth, y));
        }
        break;
      case 10: // Kumbam (0.25 -> 0.50)
        final ys = getSubPoints(h * 0.50 - 4.0, h * 0.25 + 4.0, count);
        for (var y in ys) {
          offsets.add(Offset(ringDepth, y));
        }
        break;
    }

    return offsets;
  }

  void _drawTransitBadge(Canvas canvas, Offset center, PlanetDetail detail, Size canvasSize) {
    final label = "${detail.symbol} ${detail.degreeInRasi.floor()}°";
    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: textColor,
        fontSize: 7.5,
        fontWeight: FontWeight.bold,
      ),
    );

    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final bgWidth = tp.width + 6;
    final bgHeight = tp.height + 4;

    // Clamp badge center to ensure it stays strictly within the outer ring bounds
    final clampedX = center.dx.clamp(bgWidth / 2 + 1.0, canvasSize.width - bgWidth / 2 - 1.0);
    final clampedY = center.dy.clamp(bgHeight / 2 + 1.0, canvasSize.height - bgHeight / 2 - 1.0);
    final finalCenter = Offset(clampedX, clampedY);

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: finalCenter, width: bgWidth, height: bgHeight),
      const Radius.circular(5),
    );

    final fillPaint = Paint()
      ..color = badgeColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = orbitColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawRRect(bgRect, fillPaint);
    canvas.drawRRect(bgRect, borderPaint);

    tp.paint(canvas, Offset(finalCenter.dx - tp.width / 2, finalCenter.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant TransitOrbitPainter oldDelegate) {
    return oldDelegate.transits != transits;
  }
}
