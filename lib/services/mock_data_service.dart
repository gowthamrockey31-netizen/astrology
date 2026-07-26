import 'package:flutter/material.dart';
import '../models/astrologer_model.dart';
import '../models/service_model.dart';

class MockDataService {
  static List<ServiceItem> getQuickServices() {
    return [
      ServiceItem(
        id: 'daily_horoscope',
        title: "Daily Horoscope",
        tamilTitle: "தினசரி ராசிபலன்",
        subtitle: "Personalized transit analysis",
        icon: Icons.auto_awesome,
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
        id: 'panchangam',
        title: "Panchangam",
        tamilTitle: "பஞ்சாங்கம்",
        subtitle: "Auspicious Tithi & Nakshatra",
        icon: Icons.calendar_today,
        glowColor: const Color(0xFFFF5252),
        gradientColors: [const Color(0xFF3E0015), const Color(0xFF0B1220)],
      ),
    ];
  }

  static List<Astrologer> getFeaturedAstrologers() {
    return [
      Astrologer(
        id: 'ast_1',
        name: 'Dr. K. Raman',
        title: 'Vedic & Nadi Specialist',
        experience: '18+ Yrs',
        rating: 4.9,
        reviewsCount: 1420,
        languages: ['Tamil', 'English', 'Hindi'],
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
        isOnline: true,
        pricePerMin: 35.0,
      ),
      Astrologer(
        id: 'ast_2',
        name: 'Acharya Meenakshi',
        title: 'Numerology & Tarot Reader',
        experience: '14+ Yrs',
        rating: 4.8,
        reviewsCount: 980,
        languages: ['Tamil', 'Malayalam'],
        imageUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=300&q=80',
        isOnline: true,
        pricePerMin: 30.0,
      ),
      Astrologer(
        id: 'ast_3',
        name: 'Pandit V. Sharma',
        title: 'KP System & Gemology',
        experience: '22+ Yrs',
        rating: 5.0,
        reviewsCount: 2150,
        languages: ['Tamil', 'Telugu', 'English'],
        imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
        isOnline: false,
        pricePerMin: 45.0,
      ),
      Astrologer(
        id: 'ast_4',
        name: 'Swami Ananda',
        title: 'Vastu Shastra & Palmistry',
        experience: '16+ Yrs',
        rating: 4.9,
        reviewsCount: 1100,
        languages: ['Tamil', 'Kannada'],
        imageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=300&q=80',
        isOnline: true,
        pricePerMin: 40.0,
      ),
    ];
  }
}
