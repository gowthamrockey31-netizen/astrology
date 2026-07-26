import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astrocall/core/constants/app_constants.dart';
import 'package:astrocall/core/theme/app_colors.dart';
import 'package:astrocall/core/theme/app_theme.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final VoidCallback? onProfileTap;

  const PremiumAppBar({
    super.key,
    this.username = 'Divine Seeker',
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: GestureDetector(
        onTap: onProfileTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
          // Profile Avatar with Golden Frame
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
              radius: 20,
              backgroundColor: AppColors.backgroundMid,
              backgroundImage: const CachedNetworkImageProvider(AppConstants.userAvatarUrl),
            ),
          ),
          const SizedBox(width: 14),

          // Tamil Greeting & Username
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    AppConstants.tamilGreeting,
                    style: AppTheme.tamilTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: AppColors.lightGold,
                  ),
                ],
              ),
              Text(
                username,
                style: GoogleFonts.cinzel(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
      actions: [
        // Notification Badge Icon
        Container(
          margin: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardSurface,
            border: Border.all(color: AppColors.borderGold.withOpacity(0.6), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.lightGold,
                  size: 24,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("No new notifications"),
                      backgroundColor: AppColors.backgroundMid,
                    ),
                  );
                },
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
