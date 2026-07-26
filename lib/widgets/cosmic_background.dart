import 'dart:math';
import 'package:flutter/material.dart';
import 'package:astrocall/core/theme/app_colors.dart';

class CosmicBackground extends StatefulWidget {
  final Widget child;
  final bool showNebula;

  const CosmicBackground({
    super.key,
    required this.child,
    this.showNebula = true,
  });

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<StarParticle> _stars = List.generate(80, (index) => StarParticle.random());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark Base Deep Space Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.backgroundDeep,
                AppColors.backgroundMid,
                AppColors.backgroundLight,
                AppColors.backgroundDeep,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Glowing Purple & Gold Nebula Blobs
        if (widget.showNebula) ...[
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.purpleAccent.withOpacity(0.35),
                    AppColors.purpleAccent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -80,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.blueAccent.withOpacity(0.3),
                    AppColors.blueAccent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 250,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryGold.withOpacity(0.12),
                    AppColors.primaryGold.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],

        // Animated Custom Painter Starfield
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: StarfieldPainter(_stars, _controller.value),
              size: Size.infinite,
            );
          },
        ),

        // Content Child
        widget.child,
      ],
    );
  }
}

class StarParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double maxOpacity;
  final Color color;

  StarParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.maxOpacity,
    required this.color,
  });

  factory StarParticle.random() {
    final random = Random();
    final isGold = random.nextDouble() < 0.25;
    return StarParticle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      size: random.nextDouble() * 2.2 + 0.6,
      speed: random.nextDouble() * 1.5 + 0.5,
      maxOpacity: random.nextDouble() * 0.7 + 0.3,
      color: isGold ? AppColors.lightGold : Colors.white,
    );
  }
}

class StarfieldPainter extends CustomPainter {
  final List<StarParticle> stars;
  final double progress;

  StarfieldPainter(this.stars, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var star in stars) {
      // Twinkle calculation
      final twinkle = sin((progress * star.speed * 2 * pi) + (star.x * 100));
      final opacity = ((twinkle + 1) / 2 * star.maxOpacity).clamp(0.1, 1.0);

      paint.color = star.color.withOpacity(opacity);

      final dx = star.x * size.width;
      final dy = (star.y * size.height - (progress * star.speed * 20)) % size.height;

      canvas.drawCircle(Offset(dx, dy < 0 ? dy + size.height : dy), star.size, paint);

      // Extra glow for gold stars
      if (star.color == AppColors.lightGold && star.size > 1.8) {
        final glowPaint = Paint()
          ..color = AppColors.primaryGold.withOpacity(opacity * 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(dx, dy < 0 ? dy + size.height : dy), star.size * 2, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StarfieldPainter oldDelegate) => true;
}
