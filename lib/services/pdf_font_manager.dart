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

  /// Comprehensive Tamil Ligature mapping to PUA glyphs in patched NotoSansTamil
  static const Map<String, String> _tamilLigatures = {
    // Sri ligatures
    'ஸ்ரீ': '\uE000',
    'ஶ்ரீ': '\uE000',

    // Grantha clusters
    'க்ஷ': '\uE04C',
    'க்ஷீ': '\uE0A2',

    // Long II ligatures
    'கீ': '\uE065',
    'ஙீ': '\uE068',
    'சீ': '\uE06B',
    'ஜீ': '\uE06E',
    'ஞீ': '\uE06F',
    'டீ': '\uE073',
    'ணீ': '\uE076',
    'தீ': '\uE079',
    'நீ': '\uE07C',
    'னீ': '\uE07F',
    'பீ': '\uE082',
    'மீ': '\uE085',
    'யீ': '\uE088',
    'ரீ': '\uE08B',
    'றீ': '\uE08E',
    'லீ': '\uE092',
    'ளீ': '\uE095',
    'ழீ': '\uE098',
    'வீ': '\uE09B',
    'ஷீ': '\uE09E',
    'ஸீ': '\uE0A0',
    'ஹீ': '\uE0A1',

    // Short I ligatures with unique shapes
    'டி': '\uE072',
    'லி': '\uE091',
    'ஸி': '\uE09F',

    // U and UU ligatures
    'கூ': '\uE067',
    'கு': '\uE066',
    'ஙூ': '\uE06A',
    'ஙு': '\uE069',
    'சூ': '\uE06D',
    'சு': '\uE06C',
    'ஞூ': '\uE071',
    'ஞு': '\uE070',
    'டூ': '\uE075',
    'டு': '\uE074',
    'ணூ': '\uE078',
    'ணு': '\uE077',
    'தூ': '\uE07B',
    'து': '\uE07A',
    'நூ': '\uE07E',
    'நு': '\uE07D',
    'னூ': '\uE081',
    'னு': '\uE080',
    'பூ': '\uE084',
    'பு': '\uE083',
    'மூ': '\uE087',
    'மு': '\uE086',
    'யூ': '\uE08A',
    'யு': '\uE089',
    'ரூ': '\uE08D',
    'ரு': '\uE08C',
    'றூ': '\uE090',
    'று': '\uE08F',
    'லூ': '\uE094',
    'லு': '\uE093',
    'ளூ': '\uE097',
    'ளு': '\uE096',
    'ழூ': '\uE09A',
    'ழு': '\uE099',
    'வூ': '\uE09D',
    'வு': '\uE09C',
  };

  /// Formats Tamil text for PDF rendering with accurate ligature shaping
  /// and left-side Kombu reordering so that letters appear correctly in PDF output.
  static String formatText(String text) {
    if (text.isEmpty) return text;

    var s = text;

    // 1. Substitute all precomposed ligatures
    _tamilLigatures.forEach((k, v) {
      s = s.replaceAll(k, v);
    });

    // 2. Reorder two-part vowels (ொ, ோ, ௌ)
    // consonant + ொ -> ெ + consonant + ா
    s = s.replaceAllMapped(
      RegExp('([\u0B95-\u0BB9\uE04C])\u0BCA'),
      (m) => '\u0BC6${m[1]}\u0BBE',
    );
    // consonant + ோ -> ே + consonant + ா
    s = s.replaceAllMapped(
      RegExp('([\u0B95-\u0BB9\uE04C])\u0BCB'),
      (m) => '\u0BC7${m[1]}\u0BBE',
    );
    // consonant + ௌ -> ெ + consonant + ௗ
    s = s.replaceAllMapped(
      RegExp('([\u0B95-\u0BB9\uE04C])\u0BCC'),
      (m) => '\u0BC6${m[1]}\u0BD7',
    );

    // 3. Reorder single left-side kombus (ெ, ே, ை)
    // consonant + ெ -> ெ + consonant
    s = s.replaceAllMapped(
      RegExp('([\u0B95-\u0BB9\uE04C])\u0BC6'),
      (m) => '\u0BC6${m[1]}',
    );
    // consonant + ே -> ே + consonant
    s = s.replaceAllMapped(
      RegExp('([\u0B95-\u0BB9\uE04C])\u0BC7'),
      (m) => '\u0BC7${m[1]}',
    );
    // consonant + ை -> ை + consonant
    s = s.replaceAllMapped(
      RegExp('([\u0B95-\u0BB9\uE04C])\u0BC8'),
      (m) => '\u0BC8${m[1]}',
    );

    return s;
  }
}
