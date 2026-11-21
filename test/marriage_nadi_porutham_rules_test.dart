import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/porutham_calculator.dart';
import 'package:astrocall/models/porutham_model.dart';

void main() {
  group('AstroDashaCare – Nadi Porutham Nakshatra Classification and Tamil Spelling Tests', () {
    test('1. Confirm that exactly 9 Nakshatras belong to each Nadi and all 27 are assigned once', () {
      final aadiStars = <int>[];
      final madhyaStars = <int>[];
      final anthiyaStars = <int>[];

      for (int i = 0; i < 27; i++) {
        final nadi = PoruthamCalculator.getNadi(i);
        if (nadi == 0) {
          aadiStars.add(i);
        } else if (nadi == 1) {
          madhyaStars.add(i);
        } else if (nadi == 2) {
          anthiyaStars.add(i);
        }
      }

      expect(aadiStars.length, equals(9), reason: 'Aadi Nadi must contain exactly 9 Nakshatras');
      expect(madhyaStars.length, equals(9), reason: 'Madhya Nadi must contain exactly 9 Nakshatras');
      expect(anthiyaStars.length, equals(9), reason: 'Anthiya Nadi must contain exactly 9 Nakshatras');

      final allStars = [...aadiStars, ...madhyaStars, ...anthiyaStars]..sort();
      expect(allStars, equals(List.generate(27, (i) => i)), reason: 'All 27 Nakshatras must be covered exactly once');
    });

    test('2. Aadi Nadi – Vatha (ஆதி நாடி / பார்சுவ நாடி - வாதம்) exact 9 Nakshatras', () {
      // 1. Ashwini (0), 2. Thiruvathirai (5), 3. Punarpoosam (6), 4. Uthiram (11),
      // 5. Hastham (12), 6. Kettai (17), 7. Moolam (18), 8. Sathayam (23), 9. Poorattathi (24)
      const expectedAadi = [0, 5, 6, 11, 12, 17, 18, 23, 24];

      for (final starIdx in expectedAadi) {
        expect(PoruthamCalculator.getNadi(starIdx), equals(0),
            reason: 'Star $starIdx (${PoruthamCalculator.nakshatraNamesTa[starIdx]}) must be Aadi Nadi (0)');
      }
    });

    test('3. Madhya Nadi – Pitha (மத்திய நாடி - பித்தம்) exact 9 Nakshatras', () {
      // 1. Bharani (1), 2. Mirugasirisham (4), 3. Poosam (7), 4. Pooram (10),
      // 5. Chithirai (13), 6. Anusham (16), 7. Pooradam (19), 8. Avittam (22), 9. Uthirattathi (25)
      const expectedMadhya = [1, 4, 7, 10, 13, 16, 19, 22, 25];

      for (final starIdx in expectedMadhya) {
        expect(PoruthamCalculator.getNadi(starIdx), equals(1),
            reason: 'Star $starIdx (${PoruthamCalculator.nakshatraNamesTa[starIdx]}) must be Madhya Nadi (1)');
      }
    });

    test('4. Anthiya Nadi – Kapha (அந்திய நாடி / சமான நாடி - கபம் / சிலேத்துமம்) exact 9 Nakshatras', () {
      // 1. Karthigai (2), 2. Rohini (3), 3. Ayilyam (8), 4. Magam (9),
      // 5. Swathi (14), 6. Visakam (15), 7. Uthiradam (20), 8. Thiruvonam (21), 9. Revathi (26)
      const expectedAnthiya = [2, 3, 8, 9, 14, 15, 20, 21, 26];

      for (final starIdx in expectedAnthiya) {
        expect(PoruthamCalculator.getNadi(starIdx), equals(2),
            reason: 'Star $starIdx (${PoruthamCalculator.nakshatraNamesTa[starIdx]}) must be Anthiya Nadi (2)');
      }
    });

    test('5. Verify all 27 Tamil Nakshatra names match exact spelling requirements', () {
      const expectedNames = [
        'அசுவினி',
        'பரணி',
        'கார்த்திகை',
        'ரோகிணி',
        'மிருகசீரிஷம்',
        'திருவாதிரை',
        'புனர்பூசம்',
        'பூசம்',
        'ஆயில்யம்',
        'மகம்',
        'பூரம்',
        'உத்திரம்',
        'அஸ்தம்',
        'சித்திரை',
        'சுவாதி',
        'விசாகம்',
        'அனுஷம்',
        'கேட்டை',
        'மூலம்',
        'பூராடம்',
        'உத்திராடம்',
        'திருவோணம்',
        'அவிட்டம்',
        'சதயம்',
        'பூரட்டாதி',
        'உத்திரட்டாதி',
        'ரேவதி',
      ];

      for (int i = 0; i < 27; i++) {
        expect(PoruthamCalculator.nakshatraNamesTa[i], equals(expectedNames[i]),
            reason: 'Nakshatra $i spelling mismatch');
      }
    });

    test('6. Verify Tamil and English Nadi display names', () {
      expect(PoruthamCalculator.getNadiNameTa(0), equals('ஆதி நாடி / பார்சுவ நாடி (வாதம்)'));
      expect(PoruthamCalculator.getNadiNameTa(1), equals('மத்திய நாடி (பித்தம்)'));
      expect(PoruthamCalculator.getNadiNameTa(2), equals('அந்திய நாடி / சமான நாடி (கபம் / சிலேத்துமம்)'));

      expect(PoruthamCalculator.getNadiNameEn(0), equals('Aadi Nadi (Vatha)'));
      expect(PoruthamCalculator.getNadiNameEn(1), equals('Madhya Nadi (Pitha)'));
      expect(PoruthamCalculator.getNadiNameEn(2), equals('Anthiya Nadi (Kapha / Sleshma)'));
    });

    test('7. Same-Nadi combinations evaluate to NOT MATCHED (நாடி தோஷம்)', () {
      // Female: Ashwini (0 - Aadi), Male: Punarpoosam (6 - Aadi)
      final resAadi = PoruthamCalculator.calculateNadiPorutham(0, 6);
      expect(resAadi.isMatched, isFalse);
      expect(resAadi.status, equals(PoruthamStatus.notMatched));
      expect(resAadi.metricInfoTa, equals('ஒரே நாடி (தோஷம்)'));
      expect(resAadi.femaleInfoTa, contains('அசுவினி'));
      expect(resAadi.maleInfoTa, contains('புனர்பூசம்'));
      expect(resAadi.descriptionTa, contains('இருவருக்கும் ஒரே நாடி'));

      // Female: Bharani (1 - Madhya), Male: Pooradam (19 - Madhya)
      final resMadhya = PoruthamCalculator.calculateNadiPorutham(1, 19);
      expect(resMadhya.isMatched, isFalse);
      expect(resMadhya.metricInfoTa, equals('ஒரே நாடி (தோஷம்)'));

      // Female: Karthigai (2 - Anthiya), Male: Ayilyam (8 - Anthiya)
      final resAnthiya = PoruthamCalculator.calculateNadiPorutham(2, 8);
      expect(resAnthiya.isMatched, isFalse);
      expect(resAnthiya.metricInfoTa, equals('ஒரே நாடி (தோஷம்)'));
    });

    test('8. Different-Nadi combinations evaluate to MATCHED (வெவ்வேறு நாடி)', () {
      // Benchmark from user screenshot:
      // Female: Pooradam (19 - Madhya), Male: Ayilyam (8 - Anthiya)
      final res = PoruthamCalculator.calculateNadiPorutham(19, 8);
      expect(res.isMatched, isTrue);
      expect(res.status, equals(PoruthamStatus.matched));
      expect(res.metricInfoTa, equals('வெவ்வேறு நாடி'));
      expect(res.femaleInfoTa, contains('பூராடம் (மத்திய நாடி (பித்தம்))'));
      expect(res.maleInfoTa, contains('ஆயில்யம் (அந்திய நாடி / சமான நாடி (கபம் / சிலேத்துமம்))'));
      expect(res.descriptionTa, contains('சந்தான பாக்கியம் உண்டு'));

      // Female: Ashwini (0 - Aadi), Male: Bharani (1 - Madhya)
      final res2 = PoruthamCalculator.calculateNadiPorutham(0, 1);
      expect(res2.isMatched, isTrue);
      expect(res2.metricInfoTa, equals('வெவ்வேறு நாடி'));

      // Female: Ashwini (0 - Aadi), Male: Revathi (26 - Anthiya)
      final res3 = PoruthamCalculator.calculateNadiPorutham(0, 26);
      expect(res3.isMatched, isTrue);
      expect(res3.metricInfoTa, equals('வெவ்வேறு நாடி'));
    });

    test('9. Full PoruthamCalculator run maintains 11 items and produces correct Nadi Item', () {
      final fullResult = PoruthamCalculator.calculatePorutham(
        femaleStarIndex: 19, // Pooradam
        femalePada: 1,
        femaleRasiIndex: 8, // Dhanusu
        maleStarIndex: 8, // Ayilyam
        malePada: 1,
        maleRasiIndex: 3, // Kadagam
      );

      expect(fullResult.items.length, equals(11));
      final nadiItem = fullResult.items.firstWhere((i) => i.id == 'nadi');
      expect(nadiItem.nameTa, equals('நாடிப் பொருத்தம்'));
      expect(nadiItem.nameEn, equals('Nadi Porutham'));
      expect(nadiItem.isMatched, isTrue);
      expect(nadiItem.metricInfoTa, equals('வெவ்வேறு நாடி'));
      expect(nadiItem.femaleInfoTa, equals('பெண்: பூராடம் (மத்திய நாடி (பித்தம்))'));
      expect(nadiItem.maleInfoTa, equals('ஆண்: ஆயில்யம் (அந்திய நாடி / சமான நாடி (கபம் / சிலேத்துமம்))'));
    });
  });
}
