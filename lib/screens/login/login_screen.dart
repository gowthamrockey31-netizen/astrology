import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astrocall/core/constants/app_constants.dart';
import 'package:astrocall/core/theme/app_colors.dart';
import 'package:astrocall/services/auth_service.dart';
import 'package:astrocall/widgets/astro_divider.dart';
import 'package:astrocall/widgets/cosmic_background.dart';
import 'package:astrocall/widgets/golden_button.dart';
import 'package:astrocall/widgets/golden_text_field.dart';
import 'package:astrocall/screens/dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Divine Seeker');
  final _phoneController = TextEditingController(text: '+919876543210');
  final _passwordController = TextEditingController(text: 'password123');
  final _cellController = TextEditingController();
  bool _rememberMe = true;
  bool _isLoading = false;
  bool _showRegister = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _cellController.dispose();
    super.dispose();
  }

  String _selectedRole = 'User';

  bool _isAdminCredential(String input) {
    final clean = input.trim().toLowerCase();
    return clean == 'admin@astrodashacare.com' ||
        clean == 'admin@astrocare.com' ||
        clean == 'admin@astro.com' ||
        clean == 'admin' ||
        (clean.contains('admin') && clean.contains('@'));
  }

  void _handleLogin() async {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : "Divine Seeker";
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty) {
      _showSnackBar("Please enter your phone number or email.", isError: true);
      return;
    }
    if (password.isEmpty) {
      _showSnackBar("Please enter your password.", isError: true);
      return;
    }

    final effectiveRole = _isAdminCredential(phone) ? 'Admin' : _selectedRole;

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.login(phone, password, role: effectiveRole);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      final userGreetingName = (result.userName != null && result.userName != 'Divine Seeker') ? result.userName! : name;
      _showSnackBar("Welcome back, $userGreetingName ($effectiveRole Mode)!", isError: false);

      if (effectiveRole == 'Astrologer') {
        Navigator.of(context).pushReplacementNamed('/astrologer_dashboard');
      } else if (effectiveRole == 'Admin') {
        Navigator.of(context).pushReplacementNamed('/admin_dashboard');
      } else {
        // Show Terms popup first, then navigate
        await _showTermsDialog(userGreetingName);
      }
    } else {
      _showSnackBar(result.message, isError: true);
    }
  }

  Future<void> _showTermsDialog(String userName) async {
    if (!mounted) return;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool localAccepted = false;
        return StatefulBuilder(
          builder: (context, setDlgState) => AlertDialog(
            backgroundColor: AppColors.backgroundMid,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: AppColors.borderGold, width: 1.5),
            ),
            title: Row(
              children: [
                const Icon(Icons.gavel_rounded, color: AppColors.lightGold, size: 26),
                const SizedBox(width: 10),
                Text('Terms & Conditions',
                    style: GoogleFonts.cinzel(
                        color: AppColors.lightGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 320,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome to AstroDashaCare Digital Astrology Centre!',
                              style: GoogleFonts.cinzel(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          const SizedBox(height: 10),
                          _termsPoint('1. All astrological consultations are for entertainment and guidance purposes only.'),
                          _termsPoint('2. Payments made for consultations are non-refundable once the session has started.'),
                          _termsPoint('3. Your personal birth chart data is kept strictly confidential and never shared.'),
                          _termsPoint('4. AI Horoscope predictions are generated using Vedic algorithms and may vary.'),
                          _termsPoint('5. Users must be 18+ years of age to use paid consultation services.'),
                          _termsPoint('6. AstroDashaCare reserves the right to modify services and pricing at any time.'),
                          _termsPoint('7. By using this platform you agree to our Privacy Policy and Data Protection guidelines.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: localAccepted,
                        activeColor: AppColors.primaryGold,
                        checkColor: AppColors.textDark,
                        onChanged: (v) => setDlgState(() => localAccepted = v ?? false),
                      ),
                      Expanded(
                        child: Text('I have read and accept the Terms & Conditions',
                            style: GoogleFonts.poppins(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: localAccepted ? AppColors.primaryGold : Colors.grey.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 46),
                ),
                onPressed: localAccepted ? () => Navigator.of(context).pop(true) : null,
                child: Text('✅ Accept & Continue',
                    style: GoogleFonts.poppins(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted) return;
    if (accepted == true) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, anim, _) => DashboardScreen(username: userName),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  }

  Widget _termsPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.primaryGold, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: GoogleFonts.poppins(
                    color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
          ),
        ],
      ),
    );
  }

  void _handleRegister() async {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : "Divine Seeker";
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in User ID and Password to register.", isError: true);
      return;
    }

    setState(() { _isLoading = true; });

    final result = await AuthService.register(phone, password, name: name);

    if (!mounted) return;
    setState(() { _isLoading = false; });

    if (result.isSuccess) {
      final greetingName = result.userName ?? name;
      _showSnackBar(result.message, isError: false);
      _showSnackBar('Welcome, $greetingName! Please accept our terms.', isError: false);
      // Show terms then go to profile setup
      final accepted = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          bool localAccepted = false;
          return StatefulBuilder(
            builder: (context, setDlgState) => AlertDialog(
              backgroundColor: AppColors.backgroundMid,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: AppColors.borderGold, width: 1.5),
              ),
              title: Row(
                children: [
                  const Icon(Icons.gavel_rounded, color: AppColors.lightGold, size: 26),
                  const SizedBox(width: 10),
                  Text('Terms & Conditions',
                      style: GoogleFonts.cinzel(
                          color: AppColors.lightGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome to AstroDashaCare!',
                                style: GoogleFonts.cinzel(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _termsPoint('All astrological consultations are for guidance purposes only.'),
                            _termsPoint('Payments made are non-refundable once consultation has started.'),
                            _termsPoint('Your personal data is kept strictly confidential.'),
                            _termsPoint('Users must be 18+ to use paid services.'),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: localAccepted,
                          activeColor: AppColors.primaryGold,
                          checkColor: AppColors.textDark,
                          onChanged: (v) => setDlgState(() => localAccepted = v ?? false),
                        ),
                        Expanded(
                          child: Text('I accept the Terms & Conditions',
                              style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: localAccepted ? AppColors.primaryGold : Colors.grey.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 46),
                  ),
                  onPressed: localAccepted ? () => Navigator.of(context).pop(true) : null,
                  child: Text('✅ Accept & Continue',
                      style: GoogleFonts.poppins(
                          color: AppColors.textDark, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      );
      if (!mounted) return;
      if (accepted == true) {
        Navigator.of(context).pushReplacementNamed('/profile');
      }
    } else {
      _showSnackBar(result.message, isError: true);
    }
  }

  void _handleGoogleLogin() async {
    final currentName = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : "Google Seeker";
    final googleEmailController = TextEditingController(text: 'seeker.astro@gmail.com');

    final bool? shouldProceed = await showDialog<bool>(
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
              const Icon(Icons.g_mobiledata_rounded, color: AppColors.lightGold, size: 36),
              const SizedBox(width: 8),
              Text(
                "Google Sign-In",
                style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sign in with your Google account to create or sync your Astrocall profile:",
                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: googleEmailController,
                style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  labelText: "Google Email",
                  labelStyle: GoogleFonts.poppins(color: AppColors.lightGold),
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryGold),
                ),
              ),
            ],
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
              child: Text("Authenticate", style: GoogleFonts.poppins(color: AppColors.textDark, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (shouldProceed != true) return;

    final email = googleEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar("Please enter a valid Google Account email.", isError: true);
      return;
    }

    final effectiveRole = _isAdminCredential(email) ? 'Admin' : _selectedRole;

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.loginWithGoogle(email, currentName, role: effectiveRole);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      final userGreetingName = result.userName ?? currentName;
      _showSnackBar(result.message, isError: false);
      if (effectiveRole == 'Admin') {
        Navigator.of(context).pushReplacementNamed('/admin_dashboard');
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(username: userGreetingName),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } else {
      _showSnackBar(result.message, isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            color: isError ? const Color(0xFFFF8A8A) : AppColors.lightGold,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.backgroundMid,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isError ? Colors.redAccent : AppColors.primaryGold,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Brand Logo Header
                    Text(
                      AppConstants.appName,
                      style: GoogleFonts.cinzel(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                        letterSpacing: 2.5,
                        shadows: [
                          Shadow(
                            color: AppColors.primaryGold.withOpacity(0.6),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 800.ms).slideY(begin: -0.2, end: 0),

                    const SizedBox(height: 4),

                    Text(
                      AppConstants.appSubtitle,
                      style: GoogleFonts.cinzel(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ).animate().fade(duration: 800.ms, delay: 200.ms),

                    const SizedBox(height: 24),

                    // Circular App Logo Header
                    Container(
                      width: 110,
                      height: 110,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.goldBorderGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGold.withOpacity(0.5),
                            blurRadius: 22,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.backgroundMid,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          AppConstants.appLogo,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.auto_awesome,
                            size: 56,
                            color: AppColors.lightGold,
                          ),
                        ),
                      ),
                    ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack, delay: 300.ms),

                    const SizedBox(height: 20),

                    // Heading & Subtitle
                    Text(
                      "Welcome Back",
                      style: GoogleFonts.cinzel(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                        letterSpacing: 1.2,
                      ),
                    ).animate().fade(duration: 600.ms, delay: 400.ms),

                    const SizedBox(height: 6),

                    Text(
                      "Continue your divine journey",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fade(duration: 600.ms, delay: 500.ms),

                    const SizedBox(height: 18),

                    // Choose Module / Role Pills
                    Text(
                      "Choose Login Module",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['User', 'Astrologer'].map((roleName) {
                        final isSel = _selectedRole == roleName;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = roleName;
                                if (_selectedRole == 'Astrologer' && _phoneController.text == '+919876543210') {
                                  _phoneController.text = 'acharya@astrodashacare.com';
                                } else if (_selectedRole == 'User' && (_phoneController.text == 'acharya@astrodashacare.com' || _phoneController.text == 'acharya@astrocare.com')) {
                                  _phoneController.text = '+919876543210';
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.primaryGold.withOpacity(0.2) : AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSel ? AppColors.lightGold : Colors.white12,
                                  width: isSel ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  roleName,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? AppColors.lightGold : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Input Fields
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GoldenTextField(
                          controller: _nameController,
                          hintText: "Enter your full name",
                          label: "Full Name",
                          prefixIcon: Icons.person_outline,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Full name is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        GoldenTextField(
                          controller: _phoneController,
                          hintText: _selectedRole == 'Astrologer' ? "Unique Assigned Email or Mobile" : "Phone number or Email",
                          label: _selectedRole == 'Astrologer' ? "Astrologer Email / Mobile" : "User ID",
                          prefixIcon: _selectedRole == 'Astrologer' ? Icons.email_outlined : Icons.badge_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return _selectedRole == 'Astrologer' ? "Assigned email is required" : "User ID is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        GoldenTextField(
                          controller: _passwordController,
                          hintText: "Enter your password",
                          label: "Password",
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Password is required";
                            }
                            return null;
                          },
                        ),
                        if (_showRegister) ...[
                          const SizedBox(height: 16),
                            GoldenTextField(
                            controller: _cellController,
                            hintText: "Enter your mobile number",
                            label: "Cell No",
                            prefixIcon: Icons.phone_android_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ],
                    ).animate().slideY(begin: 0.15, end: 0, duration: 600.ms, delay: 600.ms).fade(),

                    const SizedBox(height: 12),

                    // Remember Me & Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Theme(
                              data: ThemeData(unselectedWidgetColor: AppColors.primaryGold),
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.primaryGold,
                                checkColor: AppColors.textDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val ?? true;
                                  });
                                },
                              ),
                            ),
                            Text(
                              "Remember Me",
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            _showSnackBar("Demo Credentials:\nPhone: +919876543210 (Password: password123)\nSpecial Admin Email: admin@astrodashacare.com");
                          },
                          child: Text(
                            "Forgot Password?",
                            style: GoogleFonts.poppins(
                              color: AppColors.lightGold,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fade(delay: 700.ms),

                    const SizedBox(height: 24),

                    // Large Golden LOGIN Button
                    GoldenButton(
                      text: "LOGIN",
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ).animate().scale(duration: 500.ms, delay: 800.ms, curve: Curves.easeOut),

                    const SizedBox(height: 24),

                    // Divider OR
                    const AstroDivider(label: 'OR').animate().fade(delay: 900.ms),

                    const SizedBox(height: 20),

                    // Google Login Button with Overflow Protection
                    OutlinedButton(
                      onPressed: _handleGoogleLogin,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        side: BorderSide(color: AppColors.borderGold.withOpacity(0.8), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        backgroundColor: AppColors.cardSurface,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.g_mobiledata_rounded,
                            color: AppColors.lightGold,
                            size: 32,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "Continue with Google",
                              style: GoogleFonts.poppins(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 1000.ms),

                    const SizedBox(height: 28),

                    // Bottom Prompt: Don't have account? Register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showRegister ? "Already have an account? " : "Don't have an account? ",
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_showRegister) {
                              setState(() => _showRegister = false);
                            } else {
                              setState(() => _showRegister = true);
                            }
                          },
                          child: Text(
                            _showRegister ? "Login" : "Register",
                            style: GoogleFonts.poppins(
                              color: AppColors.lightGold,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fade(delay: 1100.ms),

                    if (_showRegister) ...[
                      const SizedBox(height: 12),
                      GoldenButton(
                        text: "CREATE ACCOUNT",
                        isLoading: _isLoading,
                        onPressed: _handleRegister,
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
