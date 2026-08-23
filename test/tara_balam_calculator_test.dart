import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/tara_balam_calculator.dart';
import 'package:astrocall/models/tara_balam_model.dart';

void main() {
  group('TaraBalaCalculator Unit Tests', () {
    test('Ashwini (1) to Ashwini (1) -> Count 1, Janma Tara', () {
      final TaraResult res = TaraBalaCalculator.calculate(
        birthNakshatra: 1,
        currentNakshatra: 1,
        isOneBased: true,
      );

      expect(res.count, equals(1));
      expect(res.taraNumber, equals(1));
      expect(res.taraName, equals('ஜன்ம தாரா'));
      expect(res.nature, equals('சாதாரணம்'));
      expect(res.result, contains('மனநிலை மற்றும் உடல்நிலையில் கவனம் தேவை.'));
    });

    test('Ashwini (1) to Bharani (2) -> Count 2, Sampat Tara', () {
      final TaraResult res = TaraBalaCalculator.calculate(
        birthNakshatra: 1,
        currentNakshatra: 2,
        isOneBased: true,
      );

      expect(res.count, equals(2));
      expect(res.taraNumber, equals(2));
      expect(res.taraName, equals('சம்பத் தாரா'));
      expect(res.nature, equals('நன்மை'));
      expect(res.result, contains('செல்வம், பொருளாதாரம் மற்றும் வளர்ச்சிக்கு சாதகம்.'));
    });

    test('Ashwini (1) to Krittika (3) -> Count 3, Vipat Tara', () {
      final TaraResult res = TaraBalaCalculator.calculate(
        birthNakshatra: 1,
        currentNakshatra: 3,
        isOneBased: true,
      );

      expect(res.count, equals(3));
      expect(res.taraNumber, equals(3));
      expect(res.taraName, equals('விபத் தாரா'));
      expect(res.nature, equals('தவிர்க்க வேண்டியது'));
    });

    test('Ashwini (1) to Magha (10) -> Count 10, Cycle repeats to Janma Tara (1)', () {
      final TaraResult res = TaraBalaCalculator.calculate(
        birthNakshatra: 1,
        currentNakshatra: 10,
        isOneBased: true,
      );

      expect(res.count, equals(10));
      expect(res.taraNumber, equals(1));
      expect(res.taraName, equals('ஜன்ம தாரா'));
    });

    test('Ashwini (1) to Revati (27) -> Count 27, Parama Mitra Tara (9)', () {
      final TaraResult res = TaraBalaCalculator.calculate(
        birthNakshatra: 1,
        currentNakshatra: 27,
        isOneBased: true,
      );

      expect(res.count, equals(27));
      expect(res.taraNumber, equals(9));
      expect(res.taraName, equals('பரம மித்ர தாரா'));
      expect(res.nature, equals('மிகவும் நன்மை'));
    });

    test('0-indexed: Rohini (index 3) to Anuradha (index 16) -> Count 14, Sadhasa Tara (5 -> Pratyak)', () {
      // (16 - 3 + 27) % 27 + 1 = 14
      // (14 - 1) % 9 = 4 -> index 4 is Pratyak Tara (5)
      final TaraResult res = TaraBalaCalculator.calculate(
        birthNakshatra: 3,
        currentNakshatra: 16,
        isOneBased: false,
      );

      expect(res.count, equals(14));
      expect(res.taraNumber, equals(5));
      expect(res.taraName, equals('பிரத்யக் தாரா'));
    });
  });
}
