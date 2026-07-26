import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astrocall/core/constants/app_constants.dart';
import 'package:astrocall/models/astrologer_model.dart';
import 'package:astrocall/models/service_model.dart';
import 'package:astrocall/services/mock_data_service.dart';
import 'package:astrocall/core/theme/app_colors.dart';
import 'package:astrocall/core/theme/app_theme.dart';
import 'package:astrocall/widgets/astro_card.dart';
import 'package:astrocall/widgets/cosmic_background.dart';
import 'package:astrocall/widgets/glowing_icon.dart';
import 'package:astrocall/widgets/golden_button.dart';
import 'package:astrocall/widgets/premium_app_bar.dart';
import 'package:astrocall/screens/login/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String username;

  const DashboardScreen({
    super.key,
    this.username = 'Divine Seeker',
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;

  final List<ServiceItem> _quickServices = MockDataService.getQuickServices();
  final List<Astrologer> _astrologers = MockDataService.getFeaturedAstrologers();

  void _handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundMid,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderGold, width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.logout_rounded, color: AppColors.lightGold, size: 28),
              const SizedBox(width: 8),
              Text(
                "Logout",
                style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to log out from Astrocall Digital Astrology Centre?",
            style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel", style: GoogleFonts.poppins(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Logout", style: GoogleFonts.poppins(color: AppColors.textDark, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Logged out successfully. May divine energy guide you!",
          style: GoogleFonts.poppins(color: AppColors.lightGold, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.backgroundMid,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.primaryGold, width: 1.2),
        ),
      ),
    );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PremiumAppBar(
        username: widget.username,
        onProfileTap: () {
          setState(() {
            _selectedNavIndex = 3;
          });
        },
      ),
      extendBodyBehindAppBar: true,
      body: CosmicBackground(
        child: SafeArea(
          child: IndexedStack(
            index: _selectedNavIndex,
            children: [
              _buildHomeTab(),
              _buildConsultTab(),
              _buildMagazineTab(),
              _buildProfileTab(),
            ],
          ),
        ),
      ),

      // Premium Golden Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 0: Home
  // ---------------------------------------------------------------------------
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBannerCard().animate().fade(duration: 800.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          _buildSectionHeader(
            title: "Quick Services",
            tamilTitle: "விரைவு சேவைகள்",
          ).animate().fade(delay: 200.ms),
          const SizedBox(height: 12),
          _buildServicesGrid().animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          _buildSectionHeader(
            title: "Featured Astrologers",
            tamilTitle: "பிரபல ஜோதிடர்கள்",
            actionText: "View All",
            onActionTap: () => setState(() => _selectedNavIndex = 1),
          ).animate().fade(delay: 400.ms),
          const SizedBox(height: 12),
          _buildAstrologersHorizontalList().animate().fade(delay: 500.ms),
          const SizedBox(height: 24),
          _buildSectionHeader(
            title: "Today's Prediction",
            tamilTitle: "இன்றைய கணிப்பு",
          ).animate().fade(delay: 600.ms),
          const SizedBox(height: 12),
          _buildPredictionCard().animate().fade(delay: 700.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Consult
  // ---------------------------------------------------------------------------
  Widget _buildConsultTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: "Consult Astrologers",
            tamilTitle: "ஜோதிட ஆலோசனை",
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _astrologers.length,
            itemBuilder: (context, index) {
              final ast = _astrologers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: AstroCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryGold, width: 1.5),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: CachedNetworkImageProvider(ast.imageUrl),
                            ),
                          ),
                          if (ast.isOnline)
                            Positioned(
                              right: 2,
                              bottom: 2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.backgroundDeep, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ast.name,
                              style: GoogleFonts.cinzel(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              ast.title,
                              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.lightGold, size: 14),
                                const SizedBox(width: 4),
                                Text("${ast.rating} (${ast.reviewsCount})",
                                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.lightGold, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 12),
                                Text(ast.experience, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GoldenButton(
                        text: "Chat",
                        height: 36,
                        width: 75,
                        borderRadius: 12,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Initiating consultation with ${ast.name}..."), backgroundColor: AppColors.backgroundMid),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 2: Magazine
  // ---------------------------------------------------------------------------
  Widget _buildMagazineTab() {
    final articles = [
      {'title': 'Jupiter Transit 2026: Cosmic Effects', 'subtitle': 'Vedic Insight', 'tag': 'Astrology'},
      {'title': 'Secrets of Sri Yantra & Prosperity', 'subtitle': 'Spiritual Wisdom', 'tag': 'Sacred Geometry'},
      {'title': 'Rahu Dasha Remedies & Mantras', 'subtitle': 'Remedial Measures', 'tag': 'Remedies'},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: "Astrogen Magazine",
            tamilTitle: "ஆஸ்ட்ரோஜென் இதழ்",
          ),
          const SizedBox(height: 16),
          ...articles.map((art) => Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: AstroCard(
                  padding: const EdgeInsets.all(16),
                  gradientColors: const [Color(0xFF231038), Color(0xFF07131F)],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryGold, width: 1),
                        ),
                        child: Text(art['tag']!, style: GoogleFonts.poppins(color: AppColors.lightGold, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      Text(art['title']!, style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Text(art['subtitle']!, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text("Read Article →", style: GoogleFonts.poppins(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 3: Profile & Logout Tab
  // ---------------------------------------------------------------------------
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          // User Avatar & Golden Aura Ring
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.goldBorderGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.5),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 46,
                    backgroundImage: CachedNetworkImageProvider(AppConstants.userAvatarUrl),
                  ),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star, size: 16, color: AppColors.textDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.username,
            style: GoogleFonts.cinzel(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.lightGold,
            ),
          ),
          Text(
            "+91 98765 43210 • seeker.astro@gmail.com",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryGold, width: 1.2),
            ),
            child: Text(
              "VIP DIVINE MEMBER 🌟",
              style: GoogleFonts.poppins(
                color: AppColors.lightGold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Astrology Profile Details Card
          AstroCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAstroDetailItem("Sun Sign", "Aries ♈"),
                Container(width: 1, height: 35, color: AppColors.borderGold.withOpacity(0.4)),
                _buildAstroDetailItem("Moon Sign", "Taurus ♉"),
                Container(width: 1, height: 35, color: AppColors.borderGold.withOpacity(0.4)),
                _buildAstroDetailItem("Ascendant", "Leo ♌"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Profile Menu Items
          _buildProfileMenuItem(Icons.history_rounded, "My Consultations & History"),
          _buildProfileMenuItem(Icons.description_outlined, "Saved Birth Charts & Reports"),
          _buildProfileMenuItem(Icons.card_membership_rounded, "Astrogen VIP Membership"),
          _buildProfileMenuItem(Icons.notifications_none_rounded, "Notification Settings"),
          _buildProfileMenuItem(Icons.security_rounded, "Privacy & Security"),

          const SizedBox(height: 28),

          // LOGOUT Button
          GoldenButton(
            text: "LOGOUT",
            icon: Icons.logout_rounded,
            onPressed: _handleLogout,
          ).animate().scale(duration: 500.ms, curve: Curves.easeOut),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAstroDetailItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
      ],
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: AstroCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hasGlow: false,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Opening $title..."), backgroundColor: AppColors.backgroundMid),
          );
        },
        child: Row(
          children: [
            Icon(icon, color: AppColors.lightGold, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.lightGold, size: 14),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Banner Card Component
  // ---------------------------------------------------------------------------
  Widget _buildBannerCard() {
    return AstroCard(
      padding: EdgeInsets.zero,
      borderRadius: 22,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          image: const DecorationImage(
            image: AssetImage(AppConstants.astrologyWheelBanner),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [
                AppColors.backgroundDeep.withOpacity(0.95),
                AppColors.backgroundDeep.withOpacity(0.55),
                AppColors.purpleAccent.withOpacity(0.3),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGold, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 12, color: AppColors.lightGold),
                    const SizedBox(width: 4),
                    Text(
                      "DAILY COSMIC GUIDE",
                      style: GoogleFonts.poppins(
                        color: AppColors.lightGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Discover Today's\nHoroscope",
                style: GoogleFonts.cinzel(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.2,
                  shadows: [
                    Shadow(color: AppColors.primaryGold.withOpacity(0.6), blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GoldenButton(
                text: "View Horoscope",
                height: 38,
                width: 155,
                borderRadius: 14,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Opening Today's Horoscope..."),
                      backgroundColor: AppColors.backgroundMid,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section Header Component
  // ---------------------------------------------------------------------------
  Widget _buildSectionHeader({
    required String title,
    required String tamilTitle,
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tamilTitle,
                style: AppTheme.tamilTextStyle(
                  fontSize: 13,
                  color: AppColors.lightGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionText,
                  style: GoogleFonts.poppins(
                    color: AppColors.lightGold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.lightGold),
              ],
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Quick Services Grid
  // ---------------------------------------------------------------------------
  Widget _buildServicesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.15,
      ),
      itemCount: _quickServices.length,
      itemBuilder: (context, index) {
        final service = _quickServices[index];
        return AstroCard(
          padding: const EdgeInsets.all(14),
          borderRadius: 20,
          gradientColors: service.gradientColors,
          borderGoldColor: service.glowColor,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Selected ${service.title}"),
                backgroundColor: AppColors.backgroundMid,
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlowingIcon(
                    icon: service.icon,
                    glowColor: service.glowColor,
                    iconColor: service.glowColor,
                    containerSize: 46,
                    size: 24,
                  ),
                  Icon(
                    Icons.arrow_circle_right_outlined,
                    color: service.glowColor.withOpacity(0.7),
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.tamilTitle,
                    style: AppTheme.tamilTextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    service.title,
                    style: GoogleFonts.cinzel(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Featured Astrologers Horizontal List
  // ---------------------------------------------------------------------------
  Widget _buildAstrologersHorizontalList() {
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _astrologers.length,
        itemBuilder: (context, index) {
          final ast = _astrologers[index];
          return Container(
            width: 168,
            margin: const EdgeInsets.only(right: 14),
            child: AstroCard(
              padding: const EdgeInsets.all(12),
              borderRadius: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryGold, width: 1.5),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: CachedNetworkImageProvider(ast.imageUrl),
                        ),
                      ),
                      if (ast.isOnline)
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.backgroundDeep, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF00E676),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ast.name,
                    style: GoogleFonts.cinzel(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    ast.experience,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: AppColors.lightGold, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "${ast.rating}",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  GoldenButton(
                    text: "Consult",
                    height: 32,
                    borderRadius: 12,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Connecting with ${ast.name}..."),
                          backgroundColor: AppColors.backgroundMid,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Today's Prediction Card Component
  // ---------------------------------------------------------------------------
  Widget _buildPredictionCard() {
    return AstroCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 22,
      gradientColors: const [
        Color(0xFF190F2E),
        Color(0xFF07131F),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlowingIcon(
                icon: Icons.nightlight_round,
                glowColor: AppColors.lightGold,
                iconColor: AppColors.lightGold,
                containerSize: 46,
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cosmic Transit Insights",
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                      ),
                    ),
                    Text(
                      "Moon & Jupiter Conjunction",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "\"${AppConstants.dailyPredictionQuote}\"",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppColors.textPrimary.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Loading full horoscope forecast..."),
                    backgroundColor: AppColors.backgroundMid,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryGold, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              ),
              child: Text(
                "Read More",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Navigation Bar Component
  // ---------------------------------------------------------------------------
  Widget _buildBottomNavigationBar() {
    final navItems = [
      {'icon': Icons.home_filled, 'label': 'Home'},
      {'icon': Icons.psychology_rounded, 'label': 'Consult'},
      {'icon': Icons.menu_book_rounded, 'label': 'Magazine'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: AppColors.borderGold.withOpacity(0.5), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final isSelected = _selectedNavIndex == index;
          final item = navItems[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedNavIndex = index;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isSelected ? AppColors.primaryGold.withOpacity(0.15) : Colors.transparent,
                border: isSelected
                    ? Border.all(color: AppColors.primaryGold.withOpacity(0.6), width: 1)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: isSelected ? AppColors.lightGold : AppColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['label'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.lightGold : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
