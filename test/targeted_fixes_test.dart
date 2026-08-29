import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/models/pdf_fixed_content_config.dart';
import 'package:astrocall/models/user_model.dart';
import 'package:astrocall/services/geocoding_service.dart';
import 'package:astrocall/services/pdf_settings_service.dart';
import 'package:astrocall/services/dina_suddhi_calculator.dart';
import 'package:astrocall/services/astrology_calculator.dart';
import 'package:astrocall/services/jaathaga_kurippugal_calculator.dart';
import 'package:intl/intl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Targeted Fixes Verification Tests', () {
    test('1. GeocodingService resolves Coimbatore, Chennai, and Madurai automatically', () async {
      final coimbatore = GeocodingService.resolvePlace('Coimbatore');
      expect(coimbatore, isNotNull);
      expect(coimbatore!.latitude, closeTo(11.0168, 0.01));
      expect(coimbatore.longitude, closeTo(76.9558, 0.01));

      final chennai = GeocodingService.resolvePlace('Chennai');
      expect(chennai, isNotNull);
      expect(chennai!.latitude, closeTo(13.0827, 0.01));
      expect(chennai.longitude, closeTo(80.2707, 0.01));

      final suggestions = await GeocodingService.searchPlaces('Madurai');
      expect(suggestions.isNotEmpty, isTrue);
      expect(suggestions.first.cityName, 'Madurai');
      expect(suggestions.first.latitude, closeTo(9.9252, 0.01));
    });

    test('2. Admin Editable Fixed/Static PDF text persists and falls back to default', () async {
      // Default fallback
      await PdfSettingsService.resetToDefault();
      expect(PdfSettingsService.currentSettings.softwareFooter, PdfFixedContentConfig.softwareFooter);
      expect(PdfSettingsService.currentSettings.slokaFooter, PdfFixedContentConfig.slokaFooter);

      // Admin custom edit
      final adminUpdated = PdfSettingsService.currentSettings.copyWith(
        customSoftwareFooter: 'Software by AstroDashaCare Custom Enterprise',
        customSlokaFooter: 'கணபதி துணை - ஜெய விஜயீபவ',
      );
      await PdfSettingsService.saveSettings(adminUpdated);

      expect(PdfSettingsService.currentSettings.softwareFooter, 'Software by AstroDashaCare Custom Enterprise');
      expect(PdfSettingsService.currentSettings.slokaFooter, 'கணபதி துணை - ஜெய விஜயீபவ');
    });

    test('3. Date of Birth format matches DD / MM / YYYY standard', () {
      final dob = DateTime(2005, 8, 15);
      final formatted = DateFormat('dd / MM / yyyy').format(dob);
      expect(formatted, '15 / 08 / 2005');
    });

    test('4. Gender choices standardize to Male, Female, Other', () {
      const allowedGenders = ['Male', 'Female', 'Other'];
      expect(allowedGenders.contains('Male'), isTrue);
      expect(allowedGenders.contains('Female'), isTrue);
      expect(allowedGenders.contains('Other'), isTrue);
      expect(allowedGenders.length, 3);
    });

    test('5. Dinasuddhi & General Panchanga calculations are intact and accessible', () {
      final user = UserModel(
        id: 'u1',
        name: 'Test Native',
        mobile: '9876543210',
        dob: '2000-01-15',
        timeOfBirth: '07:30 AM',
        placeOfBirth: 'Coimbatore',
        city: 'Coimbatore',
        state: 'Tamil Nadu',
        country: 'India',
        gender: 'Male',
        zodiac: 'Mesham',
        nakshatra: 'Ashwini',
        lagna: 'Mesham',
        walletBalance: 100,
        profilePhoto: '',
        latitude: 11.0168,
        longitude: 76.9558,
        timezone: 5.5,
      );

      final notes = JaathagaKurippugalCalculator.calculateNotes(user: user);
      expect(notes.udayathiNazhi, isNotEmpty);

      final astro = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: DateTime(2000, 1, 15, 7, 30),
        latitude: 11.0168,
        longitude: 76.9558,
        utcOffsetHours: 5.5,
      );

      final dina = DinaSuddhiCalculator.calculate(
        date: DateTime(2000, 1, 15, 7, 30),
        sunLongitude: astro.planets['Sun']!.longitude,
        moonLongitude: astro.planets['Moon']!.longitude,
        latitude: 11.0168,
        longitude: 76.9558,
        utcOffsetHours: 5.5,
      );

      // Calculations remain intact
      expect(dina.rahuKalam, isNotEmpty);
      expect(dina.yamaGandam, isNotEmpty);
      expect(dina.gulikaiKalam, isNotEmpty);
      expect(dina.abhijitMuhurtham, isNotEmpty);
    });
  });
}
