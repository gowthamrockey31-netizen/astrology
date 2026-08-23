import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../services/auth_service.dart';

class CosmicDrawer extends StatelessWidget {
  final Function(String routeName) onSelectRoute;
  final VoidCallback? onLogout;

  const CosmicDrawer({
    super.key,
    required this.onSelectRoute,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final role = AuthService.activeRole;

    return Drawer(
      backgroundColor: AppColors.backgroundDeep,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header with Cosmic Logo & Active Role Badge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.purpleAccent, AppColors.backgroundMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.lightGold, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withOpacity(0.4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundColor: AppColors.backgroundDeep,
                      child: Icon(Icons.auto_awesome, color: AppColors.lightGold, size: 28),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Astrocare Seeker',
                          style: GoogleFonts.cinzel(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primaryGold.withOpacity(0.6)),
                          ),
                          child: Text(
                            'Active Role: $role',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.borderGold, height: 1),

            // Modules & Role Navigation List (Filtered strict by Role)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _buildSectionHeader('APPLICATION MODULES'),

                  // Role-Based Drawer Filtering
                  if (role == 'User') ...[
                    _buildDrawerItem(
                      icon: Icons.dashboard_rounded,
                      title: 'User Dashboard',
                      subtitle: 'Consultations, Horoscope & Panchang',
                      isSelected: true,
                      onTap: () {
                        onSelectRoute('/user_dashboard');
                      },
                    ),
                  ] else if (role == 'Astrologer') ...[
                    _buildDrawerItem(
                      icon: Icons.psychology_rounded,
                      title: 'Astrologer Workspace',
                      subtitle: 'Dashboard, Calls, Kundli & Earnings',
                      isSelected: true,
                      onTap: () {
                        onSelectRoute('/astrologer_dashboard');
                      },
                    ),
                  ] else if (role == 'Admin') ...[
                    _buildDrawerItem(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Admin Control Center',
                      subtitle: 'Approvals, CMS, T&C & Revenue',
                      isSelected: true,
                      onTap: () {
                        onSelectRoute('/admin_dashboard');
                      },
                    ),
                  ],

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(color: Colors.white12),
                  ),

                  _buildSectionHeader('EXPLORE ASTROCARE'),
                  if (role == 'User' || role == 'Admin') ...[
                    _buildDrawerItem(
                      icon: Icons.auto_stories_rounded,
                      title: 'Astrocare Magazine',
                      subtitle: 'Articles, Vedic insights & Videos',
                      onTap: () => onSelectRoute('/magazine'),
                    ),
                    _buildDrawerItem(
                      icon: Icons.brightness_7_rounded,
                      title: 'Daily Horoscope Predictions',
                      subtitle: '12 Zodiac Signs daily/weekly/yearly',
                      onTap: () => onSelectRoute('/horoscope'),
                    ),
                  ],
                  _buildDrawerItem(
                    icon: Icons.favorite_rounded,
                    title: 'திருமண ஜாதகப் பொருத்தம்',
                    subtitle: 'Marriage Porutham Analysis (11 Poruthams)',
                    onTap: () => onSelectRoute('/marriage_porutham'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.stars_rounded,
                    title: 'தாரா பலன்',
                    subtitle: 'Tara Balam Analysis & Nakshatra Strength',
                    onTap: () => onSelectRoute('/tara_balam'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.grid_on_rounded,
                    title: 'அஷ்ட வர்க்க சக்கரம்',
                    subtitle: 'Ashtakavarga BAV & SAV Calculations',
                    onTap: () => onSelectRoute('/ashtakavarga'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.flutter_dash_rounded,
                    title: 'பஞ்சபட்சி சாஸ்திரம்',
                    subtitle: 'Tamil Siddha Panchapakshi 5-Bird Science',
                    onTap: () => onSelectRoute('/panchapakshi'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.access_time_filled_rounded,
                    title: 'நேரலை ஓரை (Live Hora)',
                    subtitle: 'Live Hora Schedule & Planetary Countdown',
                    onTap: () => onSelectRoute('/hora'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.timer_rounded,
                    title: 'உதயாதினாழிகை கணிப்பு',
                    subtitle: 'Udayadhi Nazhigai & Vinazhigai Calculator',
                    onTap: () => onSelectRoute('/nazhigai'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.health_and_safety_rounded,
                    title: 'ஆயுள் கணிதம் (Pindayu Longevity)',
                    subtitle: 'Classical 7-Planet Longevity Calculation',
                    onTap: () => onSelectRoute('/longevity'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.description_rounded,
                    title: 'ஜாதக குறிப்புகள்',
                    subtitle: 'Horoscope Notes, Panchangam & Nazhigai',
                    onTap: () => onSelectRoute('/jaathaga_kurippugal'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_month_rounded,
                    title: 'Live Panchangam',
                    subtitle: 'Tithi, Nakshatra, Rahu Kalam',
                    onTap: () => onSelectRoute('/panchang'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.public_rounded,
                    title: 'Daily Planet Positions',
                    subtitle: 'Rasi chart & degrees overview',
                    onTap: () => onSelectRoute('/planet_positions'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.smart_toy_rounded,
                    title: 'AI Horoscope Assistant',
                    subtitle: 'Ask AI Astrology Assistant',
                    onTap: () => onSelectRoute('/ai_assistant'),
                  ),
                  if (role == 'User' || role == 'Admin') ...[
                    _buildDrawerItem(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Astrocare Wallet',
                      subtitle: 'Recharge, Invoice & Transactions',
                      onTap: () => onSelectRoute('/wallet'),
                    ),
                  ],
                  _buildDrawerItem(
                    icon: Icons.description_rounded,
                    title: 'Terms & Conditions',
                    subtitle: 'Dynamic Firestore T&C guidelines',
                    onTap: () => onSelectRoute('/terms'),
                  ),
                ],
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Colors.red.withOpacity(0.1),
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: Text(
                  'Log Out Session',
                  style: GoogleFonts.outfit(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  AuthService.logout();
                  if (onLogout != null) {
                    onLogout!();
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryGold.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: AppColors.primaryGold, width: 1) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.lightGold : AppColors.textSecondary,
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? AppColors.lightGold : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
