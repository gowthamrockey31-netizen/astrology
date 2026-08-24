import 'dart:convert';
import '../models/customer_pdf_settings_model.dart';

/// Persistence and Settings Manager for Customer / Astrologer PDF Details
class PdfSettingsService {
  static CustomerPdfSettings _currentSettings = const CustomerPdfSettings();

  /// Get current active PDF settings
  static CustomerPdfSettings get currentSettings => _currentSettings;

  /// Save and update PDF settings
  static Future<void> saveSettings(CustomerPdfSettings settings) async {
    _currentSettings = settings;
  }

  /// Reset to default template details
  static Future<void> resetToDefault() async {
    _currentSettings = const CustomerPdfSettings();
  }
}
