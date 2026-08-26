import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/customer_pdf_settings_model.dart';
import 'package:astrocall/models/pdf_fixed_content_config.dart';
import 'package:astrocall/models/user_model.dart';
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
        'ஜெணனீஜென்ம ஸௌக்யானாம் ! வர்த்தனி குலஸம்பதாம் ! பதவிபூர்வ புண்யானாம்!! லிக்யதே ஜென்ம பத்திரிகா!!',
      );
    });

    test('Test 3: CustomerPdfSettings delegates fixed contents to PdfFixedContentConfig and ignores overrides', () {
      final defaultSettings = const CustomerPdfSettings();
      expect(defaultSettings.softwareFooter, PdfFixedContentConfig.softwareFooter);
      expect(defaultSettings.slokaFooter, PdfFixedContentConfig.slokaFooter);

      // Attempting to pass old JSON with modified footer/slokam should not override fixed values
      final fromJson = CustomerPdfSettings.fromJson({
        'companyName': 'Custom Astrology Center',
        'astrologerName': 'Dr. Custom',
        'softwareFooter': 'HACKED FOOTER',
        'slokaFooter': 'HACKED SLOKA',
      });

      expect(fromJson.companyName, 'Custom Astrology Center');
      expect(fromJson.astrologerName, 'Dr. Custom');
      expect(fromJson.softwareFooter, PdfFixedContentConfig.softwareFooter);
      expect(fromJson.slokaFooter, PdfFixedContentConfig.slokaFooter);
    });

    test('Test 4: Customer Details remain editable and persistent', () async {
      final newSettings = const CustomerPdfSettings().copyWith(
        companyName: 'சென்னை ஜோதிட மையம்',
        astrologerName: 'ஜோதிட கலாநிதி',
        address: '100 அண்ணா சாலை, சென்னை',
        phone: '+91 9876543210',
        email: 'chennai.astro@example.com',
      );

      await PdfSettingsService.saveSettings(newSettings);
      final active = PdfSettingsService.currentSettings;

      expect(active.companyName, 'சென்னை ஜோதிட மையம்');
      expect(active.astrologerName, 'ஜோதிட கலாநிதி');
      expect(active.address, '100 அண்ணா சாலை, சென்னை');
      expect(active.phone, '+91 9876543210');
      expect(active.email, 'chennai.astro@example.com');
      // Fixed content must remain unchanged
      expect(active.softwareFooter, PdfFixedContentConfig.softwareFooter);
      expect(active.slokaFooter, PdfFixedContentConfig.slokaFooter);
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

      expect(current.companyName, 'ஸ்ரீ கல்யாண விநாயகர் ஜோதிட நிலையம்');
      expect(current.softwareFooter, PdfFixedContentConfig.softwareFooter);
      expect(current.slokaFooter, PdfFixedContentConfig.slokaFooter);
    });
  });
}
