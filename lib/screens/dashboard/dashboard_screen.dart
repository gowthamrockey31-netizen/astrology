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
import 'package:astrocall/widgets/cosmic_drawer.dart';
import 'package:astrocall/widgets/bottom_notification_bar.dart';
import 'package:astrocall/services/auth_service.dart';
import 'package:astrocall/services/firestore_service.dart';
import 'package:astrocall/screens/login/login_screen.dart';
import 'package:astrocall/screens/magazine/magazine_feed_screen.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedNavIndex = 0;

  List<ServiceItem> get _quickServices => MockDataService.getQuickServices();
  List<AstrologerModel> _astrologers = MockDataService.getFeaturedAstrologers();

  @override
  void initState() {
    super.initState();
    _loadAstrologers();
  }

  Future<void> _loadAstrologers() async {
    final list = await FirestoreService.fetchAstrologers();
    if (mounted) {
      setState(() {
        _astrologers = list.isNotEmpty ? list : [MockDataService.defaultAstrologer];
        _sortAstrologers();
      });
    }
  }

  void _sortAstrologers() {
    _astrologers.sort((a, b) {
      final aPinned = AuthService.isAstrologerPinned(a.id);
      final bPinned = AuthService.isAstrologerPinned(b.id);
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      return 0;
    });
  }

  Future<void> _togglePin(AstrologerModel ast) async {
    final wasPinned = AuthService.isAstrologerPinned(ast.id);
    await AuthService.togglePinAstrologer(ast.id);
    if (mounted) {
      setState(() {
        _sortAstrologers();
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                wasPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                color: AppColors.lightGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  wasPinned
                      ? '${ast.name} unpinned from your favorites.'
                      : '📌 ${ast.name} pinned to top of your favorites!',
                  style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.backgroundMid,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

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
      key: _scaffoldKey,
      drawer: CosmicDrawer(
        onSelectRoute: (routeName) {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(routeName);
        },
        onLogout: _handleLogout,
      ),
      appBar: PremiumAppBar(
        username: widget.username,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        onProfileTap: () {
          setState(() {
            _selectedNavIndex = 3;
          });
        },
        onWalletTap: () => Navigator.of(context).pushNamed('/wallet'),
      ),
      extendBodyBehindAppBar: true,
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _selectedNavIndex,
                  children: [
                    _buildHomeTab(),
                    _buildConsultTab(),
                    const MagazineFeedScreen(),
                    _buildProfileTab(),
                  ],
                ),
              ),
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
          const SizedBox(height: 20),
          _buildModuleSwitchSection().animate().fade(delay: 150.ms),
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildModuleSwitchSection() {
    final role = AuthService.activeRole;
    final List<Map<String, dynamic>> allModules = [
      if (role == 'Astrologer' || role == 'Admin')
        {'title': 'Astrologer Workspace', 'sub': 'Calls & Earnings', 'icon': Icons.psychology_rounded, 'route': '/astrologer_dashboard', 'color': AppColors.purpleAccent},
      if (role == 'Admin')
        {'title': 'Admin Control Panel', 'sub': 'CMS & Approvals', 'icon': Icons.admin_panel_settings_rounded, 'route': '/admin_dashboard', 'color': AppColors.blueAccent},
      {'title': 'ஜாதக / பஞ்சாங்க குறிப்புகள்', 'sub': 'பஞ்சாங்கம், தினசுத்தி, அஷ்டவர்க்கம்', 'icon': Icons.description_rounded, 'route': '/jaathaga_kurippugal', 'color': Colors.indigo.shade800},
      {'title': 'ஜாமகோள் ஆருடம்', 'sub': 'Jamakol Arudam', 'icon': Icons.compass_calibration_rounded, 'route': '/jamakol_arudam', 'color': Colors.deepPurple.shade800},
      {'title': 'KP Astrology', 'sub': 'Sub Lord Analysis', 'icon': Icons.hub_rounded, 'route': '/kp_astrology', 'color': Colors.amber.shade900},
      {'title': 'KP Horary / பிரசன்னம்', 'sub': '1-249 Horary Kundali', 'icon': Icons.help_center_rounded, 'route': '/kp_horary', 'color': Colors.blue.shade900},
      {'title': 'பிருகு நந்தி நாடி', 'sub': 'Bhrigu Nandi Nadi', 'icon': Icons.auto_awesome_motion_rounded, 'route': '/bhrigu_nandi_nadi', 'color': Colors.teal.shade800},
      {'title': 'எண்கணிதம்', 'sub': 'Numerology Calculator', 'icon': Icons.calculate_rounded, 'route': '/numerology', 'color': Colors.pink.shade800},
      {'title': 'தினசரி கிரக நிலைகள்', 'sub': 'Daily Ephemeris', 'icon': Icons.wb_sunny_rounded, 'route': '/daily_planet_positions', 'color': Colors.orange.shade800},
      {'title': 'தினசரி நாள்காட்டி', 'sub': 'Daily Calendar & Panchangam', 'icon': Icons.calendar_month_rounded, 'route': '/daily_calendar', 'color': Colors.deepOrange.shade800},
      {'title': 'PDF அமைப்புகள்', 'sub': 'Customer Details', 'icon': Icons.picture_as_pdf_rounded, 'route': '/pdf_settings', 'color': Colors.cyan.shade800},
      {'title': 'திருமணப் பொருத்தம்', 'sub': 'Marriage Matching', 'icon': Icons.favorite_rounded, 'route': '/marriage_porutham', 'color': Colors.pink.shade800},
      {'title': 'தாரா பலன்', 'sub': 'Tara Balam Analysis', 'icon': Icons.stars_rounded, 'route': '/tara_balam', 'color': Colors.amber.shade800},
      {'title': 'பஞ்சபட்சி', 'sub': '5-Bird Science', 'icon': Icons.flutter_dash_rounded, 'route': '/panchapakshi', 'color': Colors.orange.shade800},
      {'title': 'நேரலை ஓரை', 'sub': 'Live Hora Schedule', 'icon': Icons.access_time_filled_rounded, 'route': '/hora', 'color': Colors.blue.shade900},
      {'title': 'உதயாதினாழிகை', 'sub': 'Udayadhi Nazhigai', 'icon': Icons.timer_rounded, 'route': '/nazhigai', 'color': Colors.purple.shade800},
      {'title': 'ஆயுள் கணிதம்', 'sub': 'Pindayu Longevity', 'icon': Icons.health_and_safety_rounded, 'route': '/longevity', 'color': Colors.green.shade800},
      {'title': 'Daily Horoscopes', 'sub': '12 Zodiac Signs', 'icon': Icons.brightness_7_rounded, 'route': '/horoscope', 'color': Colors.amber.shade900},
      {'title': 'Live Panchangam', 'sub': 'Tithi & Rahu Kalam', 'icon': Icons.calendar_month_rounded, 'route': '/panchang', 'color': Colors.deepOrange.shade900},
      {'title': 'AI Horoscope Guru', 'sub': 'Ask AI Assistant', 'icon': Icons.smart_toy_rounded, 'route': '/ai_assistant', 'color': Colors.indigo.shade900},
      {'title': 'Birth Chart', 'sub': 'Vedic Kundali', 'icon': Icons.brightness_5_rounded, 'route': '/birth_chart', 'color': Colors.cyan.shade900},
      {'title': 'AstroDashaCare Shop', 'sub': 'Gems & Yantras', 'icon': Icons.shopping_bag_rounded, 'route': '/shop', 'color': Colors.pink.shade900},
      if (role == 'User' || role == 'Admin')
        {'title': 'AstroDashaCare Wallet', 'sub': 'Recharge & Invoices', 'icon': Icons.account_balance_wallet_rounded, 'route': '/wallet', 'color': Colors.green.shade900},
    ];

    final modules = allModules;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AstroDashaCare Modules',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.lightGold,
              ),
            ),
            GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: Row(
                children: [
                  Text(
                    'All Modules',
                    style: GoogleFonts.outfit(fontSize: 12, color: AppColors.lightGold, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.lightGold),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final m = modules[index];
              return GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(m['route'] as String),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(m['icon'] as IconData, color: AppColors.lightGold, size: 24),
                      const SizedBox(height: 6),
                      Text(
                        m['title'] as String,
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        m['sub'] as String,
                        style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tab 1: Consult
  // ---------------------------------------------------------------------------
  Widget _buildConsultTab() {
    return RefreshIndicator(
      onRefresh: _loadAstrologers,
      color: AppColors.primaryGold,
      backgroundColor: AppColors.backgroundMid,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          _buildSectionHeader(
            title: "Consult Astrologers",
            tamilTitle: "ஜோதிட ஆலோசனை",
          ),
          const SizedBox(height: 16),
          if (_astrologers.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.psychology_outlined, color: AppColors.lightGold, size: 48),
                  const SizedBox(height: 12),
                  Text("No Astrologers Available", style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("Astrologers added by Admin will appear here.", style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            )
          else
            ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _astrologers.length,
            itemBuilder: (context, index) {
              final ast = _astrologers[index];
              final isPinned = AuthService.isAstrologerPinned(ast.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                child: AstroCard(
                  padding: const EdgeInsets.all(14),
                  hasGlow: isPinned,
                  borderGoldColor: isPinned ? AppColors.primaryGold : AppColors.borderGold,
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: isPinned ? AppColors.lightGold : AppColors.primaryGold, width: isPinned ? 2.5 : 1.5),
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ast.name,
                                    style: GoogleFonts.cinzel(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isPinned)
                                  Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGold.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.primaryGold.withOpacity(0.6)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.push_pin_rounded, size: 10, color: AppColors.lightGold),
                                        const SizedBox(width: 2),
                                        Text(
                                          'PINNED',
                                          style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              ast.title,
                              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            Row(
                              children: [
                                Text("₹${ast.consultationFee.toInt()}/min",
                                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.lightGold, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 12),
                                Text(ast.experience, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                          color: isPinned ? AppColors.lightGold : Colors.white38,
                          size: 20,
                        ),
                        tooltip: isPinned ? 'Unpin Astrologer' : 'Pin Favourite Astrologer',
                        onPressed: () => _togglePin(ast),
                      ),
                      GoldenButton(
                        text: "Chat",
                        height: 36,
                        width: 65,
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

          // Support Section
          _buildSectionHeader(title: 'Support', tamilTitle: 'உதவி மையம்'),
          const SizedBox(height: 12),
          _buildSupportCard(),

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

  Widget _buildSupportCard() {
    final supportItems = [
      {
        'icon': Icons.email_outlined,
        'title': 'Email Support',
        'subtitle': 'support@astrodashacare.com',
        'color': AppColors.blueAccent,
      },
      {
        'icon': Icons.chat_bubble_outline_rounded,
        'title': 'WhatsApp Support',
        'subtitle': '+91 98765 43210',
        'color': const Color(0xFF25D366),
      },
      {
        'icon': Icons.help_outline_rounded,
        'title': 'FAQ & Help Center',
        'subtitle': 'Browse common questions',
        'color': AppColors.purpleAccent,
      },
    ];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.cardSurface,
        border: Border.all(color: AppColors.borderGold.withOpacity(0.4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
        children: supportItems.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final color = item['color'] as Color;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData, color: color, size: 20),
                ),
                title: Text(item['title'] as String,
                    style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text(item['subtitle'] as String,
                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.lightGold, size: 13),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening ${item["title"]}...', style: GoogleFonts.poppins(color: AppColors.lightGold)),
                      backgroundColor: AppColors.backgroundMid,
                    ),
                  );
                },
              ),
              if (i < supportItems.length - 1)
                Divider(height: 0, color: AppColors.borderGold.withOpacity(0.2), indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
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
                onPressed: () => Navigator.of(context).pushNamed('/horoscope'),
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
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: _quickServices.length,
      itemBuilder: (context, index) {
        final service = _quickServices[index];
        return AstroCard(
          padding: const EdgeInsets.all(12),
          borderRadius: 16,
          gradientColors: service.gradientColors,
          borderGoldColor: service.glowColor,
          onTap: () {
            if (service.id == 'daily_horoscope') {
              Navigator.of(context).pushNamed('/horoscope');
            } else if (service.id == 'consult_astrologer') {
              setState(() => _selectedNavIndex = 1);
            } else if (service.id == 'panchangam') {
              Navigator.of(context).pushNamed('/panchang');
            } else if (service.id == 'birth_chart') {
              Navigator.of(context).pushNamed('/birth_chart');
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlowingIcon(
                icon: service.icon,
                glowColor: service.glowColor,
                iconColor: service.glowColor,
                containerSize: 38,
                size: 20,
              ),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.tamilTitle,
                    style: AppTheme.tamilTextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      service.title,
                      style: GoogleFonts.cinzel(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
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
    if (_astrologers.isEmpty) {
      return Container(
        height: 110,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGold.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology_outlined, color: AppColors.lightGold, size: 28),
            const SizedBox(height: 6),
            Text(
              "No Astrologers Listed Yet",
              style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              "Astrologers added by Admin will appear here",
              style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _astrologers.length,
        itemBuilder: (context, index) {
          final ast = _astrologers[index];
          final isPinned = AuthService.isAstrologerPinned(ast.id);
          return Container(
            width: 168,
            margin: const EdgeInsets.only(right: 14),
            child: AstroCard(
              padding: const EdgeInsets.all(12),
              borderRadius: 20,
              hasGlow: isPinned,
              borderGoldColor: isPinned ? AppColors.primaryGold : AppColors.borderGold,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _togglePin(ast),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isPinned ? AppColors.primaryGold.withOpacity(0.3) : Colors.black26,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isPinned ? AppColors.lightGold : Colors.white24,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                          size: 14,
                          color: isPinned ? AppColors.lightGold : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: isPinned ? AppColors.lightGold : AppColors.primaryGold, width: isPinned ? 2.5 : 1.5),
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
                  Text(
                    "₹${ast.consultationFee.toInt()}/min",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
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
