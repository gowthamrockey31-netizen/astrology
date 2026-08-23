import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_colors.dart';

class SkeletonCardLoader extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const SkeletonCardLoader({
    super.key,
    this.height = 100,
    this.width = double.infinity,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundMid,
      highlightColor: AppColors.primaryGold.withOpacity(0.2),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
