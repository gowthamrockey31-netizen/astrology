import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astrocall/core/constants/app_constants.dart';
import 'package:astrocall/core/theme/app_colors.dart';
import 'package:astrocall/core/theme/app_theme.dart';
import 'package:astrocall/services/auth_service.dart';
import 'package:astrocall/services/profile_service.dart';
import 'profile/family_profiles_sheet.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final VoidCallback? onProfileTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onWalletTap;

  const PremiumAppBar({
    super.key,
    this.username = 'Divine Seeker',
    this.onProfileTap,
    this.onMenuTap,
    this.onWalletTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardSurface,
            border: Border.all(color: AppColors.borderGold.withOpacity(0.6)),
          ),
          child: const Icon(Icons.menu_rounded, color: AppColors.lightGold, size: 20),
        ),
        onPressed: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
      ),
      titleSpacing: 8,
      title: GestureDetector(
        onTap: onProfileTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightGold, width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.backgroundMid,
                backgroundImage: const AssetImage(AppConstants.appLogo),
                onBackgroundImageError: (_, __) {},
                child: const Icon(Icons.person, color: AppColors.lightGold, size: 17),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppConstants.tamilGreeting,
                        style: AppTheme.tamilTextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.auto_awesome,
                        size: 11,
                        color: AppColors.lightGold,
                      ),
                    ],
                  ),
                  Text(
                    username,
                    style: GoogleFonts.cinzel(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Family Profiles Switcher Shortcut
        GestureDetector(
          onTap: () => FamilyProfilesSheet.show(context),
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryGold, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_alt_rounded, color: AppColors.lightGold, size: 14),
                const SizedBox(width: 3),
                Text(
                  '${ProfileService().count}/5',
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 4-Slot Quick Consultation Shortcut
        Container(
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardSurface,
            border: Border.all(color: AppColors.primaryGold.withOpacity(0.8), width: 1.2),
          ),
          child: IconButton(
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            tooltip: '4-Slot Quick Consultation View',
            icon: const Icon(
              Icons.dashboard_customize_rounded,
              color: AppColors.lightGold,
              size: 16,
            ),
            onPressed: () => Navigator.of(context).pushNamed('/quick_consultation'),
          ),
        ),

        // Wallet Badge Shortcut
        GestureDetector(
          onTap: onWalletTap ?? () => Navigator.of(context).pushNamed('/wallet'),
          child: Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGold.withOpacity(0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet_rounded, color: AppColors.lightGold, size: 14),
                const SizedBox(width: 3),
                Text(
                  '₹${(user?.walletBalance ?? 750.0).toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Notification Icon
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardSurface,
            border: Border.all(color: AppColors.borderGold.withOpacity(0.6), width: 1),
          ),
          child: IconButton(
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.lightGold,
              size: 18,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Notifications: Your consultation queue is active!"),
                  backgroundColor: AppColors.backgroundMid,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
