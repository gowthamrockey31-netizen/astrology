import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astrocall/core/constants/app_constants.dart';
import 'package:astrocall/core/theme/app_colors.dart';
import 'package:astrocall/core/theme/app_theme.dart';
import 'package:astrocall/services/auth_service.dart';

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
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.backgroundMid,
                backgroundImage: CachedNetworkImageProvider(AppConstants.userAvatarUrl),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        AppConstants.tamilGreeting,
                        style: AppTheme.tamilTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: AppColors.lightGold,
                      ),
                    ],
                  ),
                  Text(
                    username,
                    style: GoogleFonts.cinzel(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.6,
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
        // Wallet Badge Shortcut
        GestureDetector(
          onTap: onWalletTap ?? () => Navigator.of(context).pushNamed('/wallet'),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGold.withOpacity(0.6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded, color: AppColors.lightGold, size: 16),
                const SizedBox(width: 4),
                Text(
                  '₹${(user?.walletBalance ?? 750.0).toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
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
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardSurface,
            border: Border.all(color: AppColors.borderGold.withOpacity(0.6), width: 1),
          ),
          child: IconButton(
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.lightGold,
              size: 20,
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
