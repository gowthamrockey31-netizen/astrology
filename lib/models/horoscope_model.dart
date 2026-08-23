class HoroscopePredictionModel {
  final String zodiacSign;
  final String daily;
  final String weekly;
  final String monthly;
  final String yearly;
  final int luckyNumber;
  final String luckyColor;
  final String luckyGem;
  final int compatibilityScore;

  HoroscopePredictionModel({
    required this.zodiacSign,
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.yearly,
    required this.luckyNumber,
    required this.luckyColor,
    required this.luckyGem,
    required this.compatibilityScore,
  });

  factory HoroscopePredictionModel.forSign(String sign) {
    return HoroscopePredictionModel(
      zodiacSign: sign,
      daily: 'Jupiter and Venus form a harmonious alignment in your chart today. Divine clarity and financial prosperity await your decisive actions. Focus on major consultations and family harmony.',
      weekly: 'This week highlights career growth and spiritual breakthroughs. High energy alignment on Wednesday will lead to favorable news regarding investments.',
      monthly: 'A powerful transit in your ascendant house brings long-awaited stability. Relationship bonds strengthen, and cosmic energy favors new learning.',
      yearly: '2026 brings transformative growth. Major achievements in finance, overseas travels, and spiritual wisdom unfold under Saturnian blessings.',
      luckyNumber: 7,
      luckyColor: 'Golden Yellow',
      luckyGem: 'Yellow Sapphire (Pukhraj)',
      compatibilityScore: 92,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'zodiacSign': zodiacSign,
      'daily': daily,
      'weekly': weekly,
      'monthly': monthly,
      'yearly': yearly,
      'luckyNumber': luckyNumber,
      'luckyColor': luckyColor,
      'luckyGem': luckyGem,
      'compatibilityScore': compatibilityScore,
    };
  }

  factory HoroscopePredictionModel.fromMap(Map<String, dynamic> map) {
    return HoroscopePredictionModel(
      zodiacSign: map['zodiacSign'] ?? '',
      daily: map['daily'] ?? map['generalPrediction'] ?? '',
      weekly: map['weekly'] ?? map['careerPrediction'] ?? '',
      monthly: map['monthly'] ?? map['lovePrediction'] ?? '',
      yearly: map['yearly'] ?? map['healthPrediction'] ?? '',
      luckyNumber: map['luckyNumber'] is int ? map['luckyNumber'] : (int.tryParse(map['luckyNumber']?.toString() ?? '') ?? 7),
      luckyColor: map['luckyColor'] ?? 'Golden Yellow',
      luckyGem: map['luckyGem'] ?? 'Yellow Sapphire',
      compatibilityScore: map['compatibilityScore'] is int ? map['compatibilityScore'] : (int.tryParse(map['compatibilityScore']?.toString() ?? '') ?? 90),
    );
  }
}
