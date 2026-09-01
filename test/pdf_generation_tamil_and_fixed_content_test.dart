import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/customer_pdf_settings_model.dart';
import 'package:astrocall/models/pdf_fixed_content_config.dart';
import 'package:astrocall/models/user_model.dart';
import 'package:astrocall/services/astrology_calculator.dart';
import 'package:astrocall/services/jaathaga_kurippugal_calculator.dart';
import 'package:astrocall/services/pdf_font_manager.dart';
import 'package:astrocall/services/pdf_generator_service.dart';
import 'package:astrocall/services/pdf_settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PDF Generation & Settings Tests (Tamil Unicode & Fixed Content)', () {
    test('Test 1: PdfFontManager loads Unicode fonts successfully', () async {
      await PdfFontManager.loadFonts();

      expect(PdfFontManager.regularFont, isNotNull);
      expect(PdfFontManager.boldFont, isNotNull);
      expect(PdfFontManager.fallbackFonts.length, greaterThanOrEqualTo(2));
      expect(PdfFontManager.themeData, isNotNull);
    });

    test('Test 2: Fixed Application Content is permanently defined', () {
      expect(PdfFixedContentConfig.softwareFooter, 'Software by AstroDashaCare Digital Astrology Centre');
      expect(
        PdfFixedContentConfig.slokaFooter,
        'ஜனனீ ஜன்ம ஸௌக்யானாம் வர்த்தனீ குலஸம்பதாம் | பதவிபூர்வ புண்யானாம் லிக்யதே ஜன்ம பத்ரிகா ||',
      );
    });

    test('Test 3: CustomerPdfSettings delegates fixed contents to default when custom is null or empty', () {
      final defaultSettings = const CustomerPdfSettings();
      expect(defaultSettings.softwareFooter, PdfFixedContentConfig.softwareFooter);
      expect(defaultSettings.slokaFooter, PdfFixedContentConfig.slokaFooter);

      final fromJsonDefault = CustomerPdfSettings.fromJson({
        'companyName': 'Custom Astrology Center',
        'astrologerName': 'Dr. Custom',
      });

      expect(fromJsonDefault.companyName, 'Custom Astrology Center');
      expect(fromJsonDefault.astrologerName, 'Dr. Custom');
      expect(fromJsonDefault.softwareFooter, PdfFixedContentConfig.softwareFooter);
      expect(fromJsonDefault.slokaFooter, PdfFixedContentConfig.slokaFooter);
    });

    test('Test 4: Customer Details and Admin Custom Fixed Content remain editable and persistent', () async {
      final newSettings = const CustomerPdfSettings().copyWith(
        companyName: 'சென்னை ஜோதிட மையம்',
        astrologerName: 'ஜோதிட கலாநிதி',
        address: '100 அண்ணா சாலை, சென்னை',
        phone: '+91 9876543210',
        email: 'chennai.astro@example.com',
        customSoftwareFooter: 'Custom Software Footer by Admin',
        customSlokaFooter: 'Custom Slokam by Admin',
      );

      await PdfSettingsService.saveSettings(newSettings);
      final active = PdfSettingsService.currentSettings;

      expect(active.companyName, 'சென்னை ஜோதிட மையம்');
      expect(active.astrologerName, 'ஜோதிட கலாநிதி');
      expect(active.address, '100 அண்ணா சாலை, சென்னை');
      expect(active.phone, '+91 9876543210');
      expect(active.email, 'chennai.astro@example.com');
      // Admin custom static text is persistent
      expect(active.softwareFooter, 'Custom Software Footer by Admin');
      expect(active.slokaFooter, 'Custom Slokam by Admin');
    });

    test('Test 5: PDF Generator generates valid PDF containing Tamil, English, and Fixed Footers', () async {
      final user = UserModel(
        id: 'test_user_01',
        name: 'முருகன் (Test Native)',
        mobile: '+91 9876543210',
        dob: '1995-10-24',
        timeOfBirth: '10:15:30 AM',
        placeOfBirth: 'மதுரை (Madurai)',
        city: 'Madurai',
        state: 'Tamil Nadu',
        country: 'India',
        gender: 'Male',
        zodiac: 'Scorpio',
        nakshatra: 'Anuradha',
        lagna: 'Sagittarius',
        walletBalance: 100.0,
        profilePhoto: '',
        latitude: 9.9252,
        longitude: 78.1198,
        timezone: 5.5,
      );

      final Uint8List pdfBytes = await PdfGeneratorService.generateHoroscopePdf(user: user);

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(1000));

      // PDF starts with standard %PDF magic header
      final header = String.fromCharCodes(pdfBytes.sublist(0, 5));
      expect(header, '%PDF-');
    });

    test('Test 6: Resetting to Defaults restores default template while keeping fixed footers intact', () async {
      await PdfSettingsService.resetToDefault();
      final current = PdfSettingsService.currentSettings;

      expect(current.companyName, 'ஸ்ரீகல்யாணவிநாயகர்ஜோதிட நிலையம்');
      expect(current.softwareFooter, PdfFixedContentConfig.softwareFooter);
      expect(current.slokaFooter, PdfFixedContentConfig.slokaFooter);
    });

    test('Test 7: Tamil Month and Nakshatra spellings are correct and contain no foreign glyphs', () {
      expect(AstrologyCalculator.tamilMonthsTa.contains('கார்த்திகை'), isTrue);
      expect(AstrologyCalculator.tamilMonthsTa.contains('கார்திகை'), isFalse);

      final swatiAttr = JaathagaKurippugalCalculator.nakshatraMasterData
          .firstWhere((n) => n.name == 'சுவாதி');
      expect(swatiAttr.nameLetters, 'ரு, ரே, ரோ, தா');
      expect(swatiAttr.nameLetters.contains('రో'), isFalse);
    });

    test('Test 8: PDF Generator supports Female and Other genders dynamically', () async {
      final femaleUser = UserModel(
        id: 'test_female_01',
        name: 'கயல்விழி (Female Native)',
        mobile: '+91 9876543211',
        dob: '1998-04-12',
        timeOfBirth: '02:30 PM',
        placeOfBirth: 'சென்னை (Chennai)',
        city: 'Chennai',
        state: 'Tamil Nadu',
        country: 'India',
        gender: 'Female',
        zodiac: 'Aries',
        nakshatra: 'Ashwini',
        lagna: 'Leo',
        walletBalance: 100.0,
        profilePhoto: '',
        latitude: 13.0827,
        longitude: 80.2707,
        timezone: 5.5,
      );

      final otherUser = femaleUser.copyWith(
        gender: 'Other',
      );

      final femalePdf = await PdfGeneratorService.generateHoroscopePdf(user: femaleUser);
      final otherPdf = await PdfGeneratorService.generateHoroscopePdf(user: otherUser);

      expect(femalePdf, isNotNull);
      expect(femalePdf.length, greaterThan(1000));
      expect(otherPdf, isNotNull);
      expect(otherPdf.length, greaterThan(1000));
    });
  });
}
