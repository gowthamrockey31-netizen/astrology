import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/terms/terms_conditions_screen.dart';
import 'screens/profile/user_horoscope_profile_screen.dart';
import 'screens/astrologer_module/astrologer_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_terms_cms_screen.dart';
import 'screens/admin/admin_panchang_cms_screen.dart';
import 'screens/admin/admin_planet_positions_cms_screen.dart';
import 'screens/magazine/magazine_feed_screen.dart';
import 'screens/horoscope/horoscope_screen.dart';
import 'screens/panchang/panchang_screen.dart';
import 'screens/planet_positions/planet_positions_screen.dart';
import 'screens/wallet/wallet_screen.dart';
import 'screens/ai/ai_horoscope_screen.dart';
import 'screens/birth_chart/birth_chart_screen.dart';
import 'screens/shop/shop_screen.dart';
import 'screens/marriage_porutham/marriage_porutham_screen.dart';
import 'screens/tara_balam/tara_balam_screen.dart';
import 'screens/jaathaga_kurippugal/jaathaga_kurippugal_screen.dart';
import 'screens/ashtakavarga/ashtakavarga_screen.dart';
import 'screens/panchapakshi/panchapakshi_screen.dart';
import 'screens/hora/live_hora_screen.dart';
import 'screens/nazhigai/nazhigai_screen.dart';
import 'screens/longevity/longevity_screen.dart';
import 'screens/jamakol_arudam/jamakol_arudam_screen.dart';
import 'screens/jamakol_arudam_model1_screen.dart';
import 'screens/kp_astrology/kp_astrology_screen.dart';
import 'screens/kp_horary/kp_horary_screen.dart';
import 'screens/daily_planet_positions/daily_planet_positions_screen.dart';
import 'screens/daily_calendar/daily_calendar_screen.dart';
import 'screens/tamil_month_calendar/tamil_month_calendar_screen.dart';
import 'screens/bhrigu_nandi_nadi/bhrigu_nandi_nadi_screen.dart';
import 'screens/bnn_method1_screen.dart';
import 'screens/numerology/numerology_screen.dart';
import 'screens/pdf_settings/customer_details_settings_screen.dart';
import 'screens/mundane_astrology/mundane_astrology_screen.dart';
import 'kp_method_model_1/kp_method_model_1.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Cosmic System UI Overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF050914),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const AstroDashaCareApp());
}

class AstroDashaCareApp extends StatelessWidget {
  const AstroDashaCareApp({super.key});

  Widget _guardedRoute({
    required BuildContext context,
    required String requiredRole,
    required Widget child,
  }) {
    final currentRole = AuthService.activeRole;
    if (requiredRole == 'Admin' && currentRole != 'Admin') {
      return Scaffold(
        backgroundColor: const Color(0xFF050914),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security_rounded, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  'Access Denied',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Only Administrators are authorized to access the Admin Control Center.\nYour active session role is "$currentRole".',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
                  onPressed: () => Navigator.of(context).pushReplacementNamed(
                    currentRole == 'Astrologer' ? '/astrologer_dashboard' : '/user_dashboard',
                  ),
                  child: const Text('Back to My Workspace', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (requiredRole == 'Astrologer' && currentRole == 'User') {
      return Scaffold(
        backgroundColor: const Color(0xFF050914),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded, size: 64, color: Colors.amber),
                const SizedBox(height: 16),
                const Text(
                  'Astrologer Portal Only',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This section is restricted to certified Astrologers.\nPlease log in with an Astrologer account.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/user_dashboard'),
                  child: const Text('Back to User Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstroDashaCare - Digital Consulting Center',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/user_dashboard': (context) => const DashboardScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/terms': (context) => TermsConditionsScreen(
              onAccepted: () => Navigator.of(context).pushReplacementNamed('/profile'),
            ),
        '/profile': (context) => UserHoroscopeProfileScreen(
              onSaved: () => Navigator.of(context).pushReplacementNamed('/user_dashboard'),
            ),
        '/astrologer_dashboard': (context) => _guardedRoute(
              context: context,
              requiredRole: 'Astrologer',
              child: AstrologerDashboardScreen(
                onNavigate: (route) => Navigator.of(context).pushNamed(route),
              ),
            ),
        '/admin_dashboard': (context) => _guardedRoute(
              context: context,
              requiredRole: 'Admin',
              child: AdminDashboardScreen(
                onNavigate: (route) => Navigator.of(context).pushNamed(route),
              ),
            ),
        '/admin_terms': (context) => _guardedRoute(
              context: context,
              requiredRole: 'Admin',
              child: const AdminTermsCmsScreen(),
            ),
        '/admin_panchang': (context) => _guardedRoute(
              context: context,
              requiredRole: 'Admin',
              child: const AdminPanchangCmsScreen(),
            ),
        '/admin_planet_positions': (context) => _guardedRoute(
              context: context,
              requiredRole: 'Admin',
              child: const AdminPlanetPositionsCmsScreen(),
            ),
        '/admin_astrologer_approvals': (context) => _guardedRoute(
              context: context,
              requiredRole: 'Admin',
              child: AdminDashboardScreen(
                onNavigate: (route) => Navigator.of(context).pushNamed(route),
              ),
            ),
        '/admin_magazine': (context) => _guardedRoute(
              context: context,
              requiredRole: 'Admin',
              child: const MagazineFeedScreen(),
            ),
        '/magazine': (context) => const MagazineFeedScreen(),
        '/horoscope': (context) => const HoroscopeScreen(),
        '/panchang': (context) => const PanchangScreen(),
        '/planet_positions': (context) => const PlanetPositionsScreen(),
        '/wallet': (context) => const WalletScreen(),
        '/ai_assistant': (context) => const AiHoroscopeScreen(),
        '/birth_chart': (context) => const BirthChartScreen(),
        '/shop': (context) => const ShopScreen(),
        '/marriage_porutham': (context) => const MarriagePoruthamScreen(),
        '/tara_balam': (context) => const TaraBalamScreen(),
        '/jaathaga_kurippugal': (context) => const JaathagaKurippugalScreen(),
        '/ashtakavarga': (context) => const AshtakavargaScreen(),
        '/panchapakshi': (context) => const PanchapakshiScreen(),
        '/hora': (context) => const LiveHoraScreen(),
        '/nazhigai': (context) => const NazhigaiScreen(),
        '/longevity': (context) => const LongevityScreen(),
        '/jamakol_arudam': (context) => const JamakolArudamScreen(),
        '/jamakol_arudam_model1': (context) => const JamakolArudamModel1Screen(),
        '/kp_astrology': (context) => const KpAstrologyScreen(),
        '/kp_method_model_1': (context) => const KPMethodModel1Page(),
        '/kp-method-model-1': (context) => const KPMethodModel1Page(),
        '/kp_horary': (context) => const KpHoraryScreen(),
        '/daily_planet_positions': (context) => const DailyPlanetPositionsScreen(),
        '/daily_calendar': (context) => const DailyCalendarScreen(),
        '/tamil_month_calendar': (context) => const TamilMonthCalendarScreen(),
        '/bhrigu_nandi_nadi': (context) => const BhriguNandiNadiScreen(),
        '/bnn_method1': (context) => const BnnMethod1Screen(),
        '/numerology': (context) => const NumerologyScreen(),
        '/pdf_settings': (context) => const CustomerDetailsSettingsScreen(),
        '/mundane_astrology': (context) => _guardedRoute(
              context: context,
              requiredRole: 'Admin',
              child: const MundaneAstrologyScreen(),
            ),
      },
    );
  }
}
