import 'package:flutter/material.dart';
import 'package:astrocall/core/theme/app_colors.dart';

class GlowingIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color glowColor;
  final Color iconColor;
  final double containerSize;

  const GlowingIcon({
    super.key,
    required this.icon,
    this.size = 28,
    this.glowColor = AppColors.primaryGold,
    this.iconColor = AppColors.lightGold,
    this.containerSize = 54,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            glowColor.withOpacity(0.35),
            glowColor.withOpacity(0.08),
          ],
        ),
        border: Border.all(
          color: glowColor.withOpacity(0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: size,
          color: iconColor,
        ),
      ),
    );
  }
}
