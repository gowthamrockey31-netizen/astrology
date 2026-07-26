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
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : "Divine Seeker";
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty) {
      _showSnackBar("Please enter your phone number.", isError: true);
      return;
    }
    if (password.isEmpty) {
      _showSnackBar("Please enter your password.", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.login(phone, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      final userGreetingName = (result.userName != null && result.userName != 'Divine Seeker') ? result.userName! : name;
      _showSnackBar("Welcome back, $userGreetingName!", isError: false);
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(username: userGreetingName),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      _showSnackBar(result.message, isError: true);
    }
  }

  void _handleRegister() async {
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : "Divine Seeker";
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in Phone Number and Password to register.", isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.register(phone, password, name: name);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      final userGreetingName = result.userName ?? name;
      _showSnackBar(result.message, isError: false);
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(username: userGreetingName),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
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

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.loginWithGoogle(email, currentName);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      final userGreetingName = result.userName ?? currentName;
      _showSnackBar(result.message, isError: false);
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(username: userGreetingName),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
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

                    // Circular Astrologer Illustration Header
                    Container(
                      width: 100,
                      height: 100,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.goldBorderGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGold.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.backgroundMid,
                        ),
                        child: const CircleAvatar(
                          backgroundColor: AppColors.backgroundDeep,
                          child: Icon(
                            Icons.person,
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

                    const SizedBox(height: 28),

                    // Input Fields Container (Full Name, Phone Number, Password)
                    Column(
                      children: [
                        GoldenTextField(
                          controller: _nameController,
                          hintText: "Enter your full name / username",
                          prefixIcon: Icons.person_outline,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Full name / username is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        GoldenTextField(
                          controller: _phoneController,
                          hintText: "+91 Enter your phone number",
                          prefixIcon: Icons.phone_android,
                          keyboardType: TextInputType.phone,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Phone number is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        GoldenTextField(
                          controller: _passwordController,
                          hintText: "Enter your password",
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Password is required";
                            }
                            return null;
                          },
                        ),
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
                            _showSnackBar("Demo Account Credentials:\nPhone: +919876543210\nPassword: password123");
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
                          "Don't have an account? ",
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: _handleRegister,
                          child: Text(
                            "Register",
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
