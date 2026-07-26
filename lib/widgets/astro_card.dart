import 'package:flutter/material.dart';
import 'package:astrocall/core/theme/app_colors.dart';

class AstroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final List<Color>? gradientColors;
  final Color borderGoldColor;
  final VoidCallback? onTap;
  final bool hasGlow;

  const AstroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 20,
    this.gradientColors,
    this.borderGoldColor = AppColors.borderGold,
    this.onTap,
    this.hasGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: gradientColors ?? [AppColors.cardSurface, AppColors.cardSurfaceLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: borderGoldColor.withOpacity(0.7),
          width: 1.2,
        ),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: borderGoldColor.withOpacity(0.2),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppColors.backgroundDeep.withOpacity(0.8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          splashColor: AppColors.primaryGold.withOpacity(0.1),
          highlightColor: AppColors.primaryGold.withOpacity(0.05),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
