class AppConstants {
  static const String appName = 'AstroDashaCare';
  static const String appSubtitle = 'Digital Consulting Center';

  // Platform Commission
  static const double platformCommissionRate = 0.20; // 20%

  // Consultation Defaults
  static const int defaultConsultationDurationMinutes = 30;
  static const int minAnalysisDurationMinutes = 3;
  static const int maxAnalysisDurationMinutes = 5;

  // Asset Images
  static const String appLogo = 'assets/images/app_logo.jpeg';
  static const String splashGanesha = 'assets/images/splash_ganesha.png';
  static const String astrologyWheelBanner = 'assets/images/app_logo.jpeg';
  static const String loginReferenceImage = 'assets/images/login_reference.jpg';
  static const String roleCardsReferenceImage = 'assets/images/role_cards_reference.jpg';

  // Default Network Avatars
  static const String defaultUserAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80';
  static const String userAvatarUrl = defaultUserAvatar;
  static const String defaultAstrologerAvatar = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80';

  // Tamil Strings & Quotes
  static const String tamilGreeting = 'வணக்கம்';
  static const String dailyPredictionQuote =
      'Jupiter and Venus form a harmonious alignment in your chart today. Divine clarity and financial prosperity await your decisive actions.';

  // Zodiac Signs
  static const List<String> zodiacSigns = [
    'Aries (Mesha)',
    'Taurus (Vrishabha)',
    'Gemini (Mithuna)',
    'Cancer (Karka)',
    'Leo (Simha)',
    'Virgo (Kanya)',
    'Libra (Tula)',
    'Scorpio (Vrishchika)',
    'Sagittarius (Dhanu)',
    'Capricorn (Makara)',
    'Aquarius (Kumbha)',
    'Pisces (Meena)',
  ];

  // 27 Nakshatras
  static const List<String> nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira', 'Ardra',
    'Punarvasu', 'Pushya', 'Ashlesha', 'Magha', 'Purva Phalguni', 'Uttara Phalguni',
    'Hasta', 'Chitra', 'Swati', 'Vishakha', 'Anuradha', 'Jyeshtha',
    'Mula', 'Purva Ashadha', 'Uttara Ashadha', 'Shravana', 'Dhanishta',
    'Shatabhisha', 'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati'
  ];

  // 12 Lagna (Ascendant) Signs
  static const List<String> lagnas = [
    'Mesha (Aries)',
    'Vrishabha (Taurus)',
    'Mithuna (Gemini)',
    'Karka (Cancer)',
    'Simha (Leo)',
    'Kanya (Virgo)',
    'Tula (Libra)',
    'Vrishchika (Scorpio)',
    'Dhanu (Sagittarius)',
    'Makara (Capricorn)',
    'Kumbha (Aquarius)',
    'Meena (Pisces)',
  ];

  // Specializations
  static const List<String> specializations = [
    'Vedic Astrology',
    'KP System',
    'Numerology',
    'Tarot Reading',
    'Vastu Shastra',
    'Palmistry',
    'Gemology',
    'Face Reading',
    'Nadi Astrology',
  ];

  // Languages
  static const List<String> supportedLanguages = [
    'English',
    'Hindi',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Bengali',
    'Marathi',
  ];

  // Role Names
  static const String roleUser = 'User';
  static const String roleAstrologer = 'Astrologer';
  static const String roleAdmin = 'Admin';
}
