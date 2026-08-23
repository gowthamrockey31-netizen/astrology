import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

class BottomNotificationBar extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;
  final IconData icon;

  const BottomNotificationBar({
    super.key,
    this.message = '✨ Jupiter and Venus in divine alignment today. Tap to check your daily prediction!',
    this.onTap,
    this.icon = Icons.auto_awesome,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.backgroundMid,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          border: const Border(
            top: BorderSide(color: AppColors.borderGold, width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGold.withOpacity(0.2),
              ),
              child: Icon(icon, color: AppColors.lightGold, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.lightGold, size: 14),
          ],
        ),
      ),
    );
  }
}
