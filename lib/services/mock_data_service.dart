import 'package:flutter/material.dart';
import '../models/astrologer_model.dart';
import '../models/horoscope_model.dart';
import '../models/magazine_model.dart';
import '../models/terms_model.dart';
import '../models/wallet_transaction_model.dart';
import '../models/service_model.dart';

class MockDataService {
  static Map<String, HoroscopePredictionModel> customPredictions = {};
  static Set<String> deletedPredictions = {};
  static List<ServiceItem> getQuickServices() {
    return [
      ServiceItem(
        id: 'daily_calendar',
        title: "Daily Calendar",
        tamilTitle: "தினசரி நாள்காட்டி",
        subtitle: "Daily Tithi, Nakshatra & Nalla Neram",
        icon: Icons.calendar_month_rounded,
        glowColor: const Color(0xFFFFD86B),
        gradientColors: [const Color(0xFF1E1500), const Color(0xFF0B1220)],
      ),
      ServiceItem(
        id: 'birth_chart',
        title: "Birth Chart",
        tamilTitle: "ஜாதக கணிப்பு",
        subtitle: "Detailed Kundli & Dasha",
        icon: Icons.brightness_7,
        glowColor: const Color(0xFF00E5FF),
        gradientColors: [const Color(0xFF00223E), const Color(0xFF0B1220)],
      ),
      ServiceItem(
        id: 'consult_astrologer',
        title: "Consult Astrologer",
        tamilTitle: "ஆலோசனை பெற",
        subtitle: "Live audio & video chat",
        icon: Icons.psychology,
        glowColor: const Color(0xFF8F5CF7),
        gradientColors: [const Color(0xFF22003E), const Color(0xFF0B1220)],
      ),
      ServiceItem(
        id: 'month_calendar',
        title: "Month Calendar",
        tamilTitle: "மாத நாள்காட்டி",
        subtitle: "Tamil Month Calendar & Festivals",
        icon: Icons.calendar_view_month_rounded,
        glowColor: const Color(0xFFFF5252),
        gradientColors: [const Color(0xFF3E0015), const Color(0xFF0B1220)],
      ),
    ];
  }

  static List<AstrologerModel> getFeaturedAstrologers() {
    return astrologers;
  }

  // In-memory dynamic Terms and Conditions
  static final List<TermItemModel> termsAndConditions = [
    TermItemModel(
      id: 'tc_1',
      title: '1. Service Scope & Consultation Ethics',
      description: 'AstroDashaCare connects users with professional astrologers for spiritual guidance, horoscopes, and remedies. Consultations do not replace legal, medical, or financial advice.',
      orderIndex: 1,
    ),
    TermItemModel(
      id: 'tc_2',
      title: '2. User Privacy & Data Protection',
      description: 'Your birth details, birth charts, contact information, and consultation history are strictly confidential and protected with enterprise-grade encryption.',
      orderIndex: 2,
    ),
    TermItemModel(
      id: 'tc_3',
      title: '3. Wallet Payments & Consultation Rates',
      description: 'Consultations are billed per minute or per fixed session using your AstroDashaCare Wallet. Sufficient balance is required to initiate Voice, Video, or Chat sessions.',
      orderIndex: 3,
    ),
    TermItemModel(
      id: 'tc_4',
      title: '4. Non-Disclosure & Anti-Contact Policy',
      description: 'Sharing personal phone numbers, bank details, or off-platform payment info between Users and Astrologers is strictly prohibited and subject to account suspension.',
      orderIndex: 4,
    ),
    TermItemModel(
      id: 'tc_5',
      title: '5. Refund & Cancellation Terms',
      description: 'If a consultation is disconnected within the first 60 seconds due to technical errors, full wallet refunds are automatically credited.',
      orderIndex: 5,
    ),
  ];

  // Fallback Default Astrologer when list is empty
  static final AstrologerModel defaultAstrologer = AstrologerModel(
    id: 'ast_default',
    name: 'Acharya Divine',
    photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
    mobile: '+919876543211',
    email: 'acharya@astrodashacare.com',
    gender: 'Male',
    city: 'Chennai',
    state: 'Tamil Nadu',
    experienceYears: 15,
    qualification: 'Master in Vedic Astrology',
    specializations: ['Vedic Astrology', 'Nadi Astrology'],
    languages: ['Tamil', 'English'],
    consultationFee: 30.0,
    rating: 4.9,
    totalReviews: 120,
    status: 'online',
    estimatedWaitMinutes: 0,
    verificationStatus: 'approved',
  );

  // Dynamic Astrologer List (Seeded with default astrologer)
  static final List<AstrologerModel> astrologers = [defaultAstrologer];

  // Magazine Articles
  static final List<MagazineArticleModel> magazineArticles = [
    MagazineArticleModel(
      id: 'mag_1',
      title: 'Planetary Transits of 2026: Financial & Spiritual Forecast',
      category: 'Vedic Predictions',
      summary: 'Explore how Jupiter and Saturn transits in 2026 shape global economy, personal wealth, and spiritual growth.',
      content: '''Jupiter enters a exalted placement this season, bringing financial wisdom and career promotions for Earth and Water zodiac signs. Saturn enforces discipline in debt management and long-term investments.

Key Takeaways for 2026:
• Aries & Leo: Prime time for business expansions.
• Taurus & Virgo: Exceptional real estate and gem alignment.
• Gemini & Libra: Spiritual travel and intellectual achievements.
• Scorpio & Pisces: Divine relationship harmony and emotional stability.''',
      imageUrl: 'https://images.unsplash.com/photo-1532693322450-2cb5c511067d?auto=format&fit=crop&w=800&q=80',
      author: 'Dr. K. Raman Acharya',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      likesCount: 342,
      commentsCount: 45,
      isBookmarked: true,
    ),
    MagazineArticleModel(
      id: 'mag_2',
      title: 'Understanding Rahu & Ketu in Kundli: Myths vs Reality',
      category: 'Kundli Deep Dive',
      summary: 'Demystifying shadow planets Rahu and Ketu to unlock hidden talents and karmic rewards.',
      content: '''Rahu and Ketu are often feared, but in authentic Vedic Astrology, Rahu represents worldly ambition and technological genius, while Ketu signifies intuition and moksha.

When placed in favorable houses (3rd, 6th, 10th, 11th), Rahu bestows sudden fame and international success. Ketu in the 8th or 12th house activates deep spiritual awakening and mystical insights.''',
      imageUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?auto=format&fit=crop&w=800&q=80',
      author: 'Pandit V. Sharma',
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      likesCount: 512,
      commentsCount: 88,
      isBookmarked: false,
    ),
    MagazineArticleModel(
      id: 'mag_3',
      title: 'Top 5 Vastu Remedies for Home Office & Financial Growth',
      category: 'Vastu Shastra',
      summary: 'Simple non-demolition Vastu tips to maximize prosperity and productivity in your living space.',
      content: '''Positioning your desk facing East or North invites positive solar energy. Placing a brass Kubera idol or emerald plant in the North zone stimulates continuous cash flow and career opportunities.''',
      imageUrl: 'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=800&q=80',
      author: 'Acharya Meenakshi',
      publishedAt: DateTime.now().subtract(const Duration(days: 8)),
      likesCount: 289,
      commentsCount: 19,
      isBookmarked: false,
    ),
  ];

  // Wallet Transactions
  static final List<WalletTransactionModel> walletTransactions = [
    WalletTransactionModel(
      id: 'txn_101',
      userId: 'usr_1',
      title: 'Wallet Recharge via Razorpay UPI',
      type: 'credit',
      amount: 500.0,
      paymentMethod: 'UPI (Razorpay)',
      status: 'success',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      referenceId: 'RZP_88920194',
    ),
    WalletTransactionModel(
      id: 'txn_102',
      userId: 'usr_1',
      title: 'Voice Call Consultation with Dr. K. Raman',
      type: 'debit',
      amount: 350.0,
      paymentMethod: 'AstroDashaCare Wallet',
      status: 'success',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      referenceId: 'CNS_44910283',
    ),
    WalletTransactionModel(
      id: 'txn_103',
      userId: 'usr_1',
      title: 'Auto Refund - Network Disconnect',
      type: 'credit',
      amount: 100.0,
      paymentMethod: 'AstroDashaCare Wallet',
      status: 'success',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      referenceId: 'RFD_99182374',
    ),
  ];
}
