import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Centralized Font Manager for high-fidelity Tamil Unicode PDF rendering.
/// Ensures proper font embedding, fallback handling, and consistent typography across English & Tamil.
class PdfFontManager {
  static pw.Font? _tamilRegularFont;
  static pw.Font? _tamilBoldFont;
  static pw.Font? _latinRegularFont;
  static pw.Font? _latinBoldFont;

  /// Get the active regular Tamil Unicode font
  static pw.Font get regularFont => _tamilRegularFont ?? pw.Font.helvetica();

  /// Get the active bold Tamil Unicode font
  static pw.Font get boldFont => _tamilBoldFont ?? pw.Font.helveticaBold();

  /// Get fallback fonts list for mixed language (Tamil + English + Numbers + Symbols)
  static List<pw.Font> get fallbackFonts => [
        ?_tamilRegularFont,
        ?_tamilBoldFont,
        ?_latinRegularFont,
        ?_latinBoldFont,
      ];

  /// Initialize and load Tamil & Latin Unicode TrueType fonts
  static Future<void> loadFonts() async {
    if (_tamilRegularFont != null && _tamilBoldFont != null && _latinRegularFont != null) return;

    // 1. Try loading from bundled Flutter assets (Primary & Offline-Safe)
    try {
      final tRegData = await rootBundle.load('assets/fonts/NotoSansTamil-Regular.ttf');
      final tBoldData = await rootBundle.load('assets/fonts/NotoSansTamil-Bold.ttf');
      final lRegData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final lBoldData = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');

      _tamilRegularFont = pw.Font.ttf(tRegData);
      _tamilBoldFont = pw.Font.ttf(tBoldData);
      _latinRegularFont = pw.Font.ttf(lRegData);
      _latinBoldFont = pw.Font.ttf(lBoldData);
      return;
    } catch (_) {}

    // 2. Try loading from local file system (for test environments)
    try {
      final tRegFile = File('assets/fonts/NotoSansTamil-Regular.ttf');
      final tBoldFile = File('assets/fonts/NotoSansTamil-Bold.ttf');
      final lRegFile = File('assets/fonts/NotoSans-Regular.ttf');
      final lBoldFile = File('assets/fonts/NotoSans-Bold.ttf');

      if (await tRegFile.exists() && await tBoldFile.exists()) {
        _tamilRegularFont = pw.Font.ttf((await tRegFile.readAsBytes()).buffer.asByteData());
        _tamilBoldFont = pw.Font.ttf((await tBoldFile.readAsBytes()).buffer.asByteData());
      }
      if (await lRegFile.exists() && await lBoldFile.exists()) {
        _latinRegularFont = pw.Font.ttf((await lRegFile.readAsBytes()).buffer.asByteData());
        _latinBoldFont = pw.Font.ttf((await lBoldFile.readAsBytes()).buffer.asByteData());
      }
      if (_tamilRegularFont != null && _tamilBoldFont != null) return;
    } catch (_) {}

    // 3. Try loading via PdfGoogleFonts
    try {
      _tamilRegularFont = await PdfGoogleFonts.notoSansTamilRegular();
      _tamilBoldFont = await PdfGoogleFonts.notoSansTamilBold();
      _latinRegularFont = await PdfGoogleFonts.notoSansRegular();
      _latinBoldFont = await PdfGoogleFonts.notoSansBold();
      if (_tamilRegularFont != null && _tamilBoldFont != null) return;
    } catch (_) {}

    // 4. Final safety fallback
    _tamilRegularFont ??= pw.Font.helvetica();
    _tamilBoldFont ??= pw.Font.helveticaBold();
  }

  /// Create a unified PDF ThemeData with embedded Tamil Unicode fonts and full fallbacks
  static pw.ThemeData get themeData {
    return pw.ThemeData.withFont(
      base: regularFont,
      bold: boldFont,
      fontFallback: fallbackFonts,
    );
  }

  /// Helper to generate consistent text style with automatic fallback
  static pw.TextStyle style({
    double fontSize = 8.5,
    bool isBold = false,
    PdfColor color = PdfColors.black,
    pw.FontStyle fontStyle = pw.FontStyle.normal,
  }) {
    final font = isBold ? boldFont : regularFont;
    return pw.TextStyle(
      font: font,
      fontFallback: fallbackFonts,
      fontSize: fontSize,
      color: color,
      fontStyle: fontStyle,
    );
  }

  /// Formats Tamil text for PDF rendering, preserving "ஸ்ரீ" as an authentic ligature glyph
  static String formatText(String text) {
    if (text.isEmpty) return text;
    return text
        .replaceAll('\u0BB8\u0BCD\u0BB0\u0BC0', '\uE000') // Sa + Virama + Ra + II
        .replaceAll('\u0BB6\u0BCD\u0BB0\u0BC0', '\uE000') // Sha + Virama + Ra + II
        .replaceAll('ஸ்ரீ', '\uE000')
        .replaceAll('ஶ்ரீ', '\uE000');
  }
}

