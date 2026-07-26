import 'package:flutter/material.dart';

class AppColors {
  // Cosmic Dark Backgrounds
  static const Color backgroundDeep = Color(0xFF050914);
  static const Color backgroundMid = Color(0xFF07131F);
  static const Color backgroundLight = Color(0xFF0B1220);

  // Gold Palette
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color lightGold = Color(0xFFFFD86B);
  static const Color darkGold = Color(0xFFC58F22);
  static const Color brightGold = Color(0xFFF8D16A);
  static const Color borderGold = Color(0xFFD4AF37);

  // Cosmic Accents
  static const Color purpleAccent = Color(0xFF4A237A);
  static const Color blueAccent = Color(0xFF123A8A);
  static const Color cyanAccent = Color(0xFF00E5FF);
  static const Color violetAccent = Color(0xFF8F5CF7);

  // Surface & Overlay Colors
  static const Color cardSurface = Color(0xCC07131F); // Dark semi-transparent
  static const Color cardSurfaceLight = Color(0xDD0B1220);
  static const Color inputBackground = Color(0x80050914);
  static const Color overlayBlack = Color(0xAA000000);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFC2C9DB);
  static const Color textGold = Color(0xFFFFD86B);
  static const Color textDark = Color(0xFF050914);

  // Gradients
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [brightGold, darkGold],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cosmicGradient = LinearGradient(
    colors: [backgroundDeep, backgroundMid, backgroundLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldBorderGradient = LinearGradient(
    colors: [lightGold, primaryGold, darkGold, primaryGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x33D4AF37), Color(0x0507131F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
