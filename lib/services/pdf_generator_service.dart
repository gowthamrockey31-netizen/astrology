import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/customer_pdf_settings_model.dart';
import '../models/horoscope_calculation_result.dart';
import '../models/jaathaga_kurippugal_model.dart';
import '../models/user_model.dart';
import 'astrology_calculator.dart';
import 'jaathaga_kurippugal_calculator.dart';
import 'pdf_font_manager.dart';
import 'pdf_settings_service.dart';

class PdfGeneratorService {
  /// Generates the complete 1-page Tamil Sidereal Horoscope PDF with dynamic Customer / Astrologer details
  /// and permanent, immutable Software Footer and Slokam.
  static Future<Uint8List> generateHoroscopePdf({
    required UserModel user,
  }) async {
    await PdfFontManager.loadFonts();

    final pdf = pw.Document();
    final astroData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: DateTime.tryParse(user.dob) ?? DateTime(1996, 6, 15),
      latitude: user.latitude,
      longitude: user.longitude,
      utcOffsetHours: user.timezone,
    );
    final notes = JaathagaKurippugalCalculator.calculateNotes(user: user);
    final settings = PdfSettingsService.currentSettings;

    final fontReg = PdfFontManager.regularFont;
    final fontBold = PdfFontManager.boldFont;
    final fallbackFonts = PdfFontManager.fallbackFonts;

    final pdfTheme = PdfFontManager.themeData;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        theme: pdfTheme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 1. Top Header Invocation Line
              if (settings.invocationText.isNotEmpty)
                pw.Center(
                  child: _txt(
                    settings.invocationText,
                    style: pw.TextStyle(
                      font: fontBold,
                      fontFallback: fallbackFonts,
                      fontSize: 10,
                    ),
                  ),
                ),
              pw.SizedBox(height: 4),

              // 2. Main Title Banner Box (Dynamic Company Settings + Fixed Application Slokam/Footer)
              _buildHeaderBanner(settings, fontReg, fontBold, fallbackFonts),
              pw.SizedBox(height: 6),

              // 3. Native Profile Box
              _buildNativeProfileBox(user, notes, fontReg, fontBold, fallbackFonts),
              pw.SizedBox(height: 6),

              // 4. Panchangam 3-Column Attributes Grid
              _buildPanchangamGrid(astroData, notes, fontReg, fontBold, fallbackFonts),
              pw.SizedBox(height: 6),

              // 5. Sidereal Planetary Longitudes Table Header Banner
              pw.Container(
                color: PdfColors.grey200,
                padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                child: pw.Center(
                  child: _txt(
                    'திருக்கணித நிராயன கிரக நிலைகள் (அயனாம்சம் : Lahiri ${astroData.ayanamsaFormatted})',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontFallback: fallbackFonts,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 4),

              // 6. Planetary Positions Table
              _buildPlanetsTable(astroData, fontReg, fontBold, fallbackFonts),
              pw.SizedBox(height: 10),

              // 7. Side-by-Side South Indian Rasi & Navamsha Charts
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _buildSouthIndianChartBox(
                      'ராசி',
                      astroData,
                      isNavamsa: false,
                      fontReg: fontReg,
                      fontBold: fontBold,
                      fallbackFonts: fallbackFonts,
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: _buildSouthIndianChartBox(
                      'நவாம்சம்',
                      astroData,
                      isNavamsa: true,
                      fontReg: fontReg,
                      fontBold: fontBold,
                      fallbackFonts: fallbackFonts,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),

              // 8. Dasha Summary & Permanent Footer
              _buildDashaFooterBlock(settings, astroData, notes, fontReg, fontBold, fallbackFonts),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// 2. Dynamic Header Banner with Authoritative Fixed Slokam and Company Details
  static pw.Widget _buildHeaderBanner(
    CustomerPdfSettings settings,
    pw.Font fontReg,
    pw.Font fontBold,
    List<pw.Font> fallbackFonts,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.2),
      ),
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        children: [
          _txt(
            settings.companyName,
            style: pw.TextStyle(
              font: fontBold,
              fontFallback: fallbackFonts,
              fontSize: 14,
              color: PdfColors.black,
            ),
          ),
          if (settings.astrologerName.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            _txt(
              settings.astrologerName,
              style: pw.TextStyle(
                font: fontBold,
                fontFallback: fallbackFonts,
                fontSize: 10,
              ),
            ),
          ],
          if (settings.titleSubtitle.isNotEmpty) ...[
            pw.SizedBox(height: 1),
            _txt(
              settings.titleSubtitle,
              style: pw.TextStyle(
                font: fontReg,
                fontFallback: fallbackFonts,
                fontSize: 8.5,
              ),
            ),
          ],
          if (settings.address.isNotEmpty || settings.phone.isNotEmpty) ...[
            pw.SizedBox(height: 1),
            _txt(
              '${settings.address}${settings.phone.isNotEmpty ? " | செல்: ${settings.phone}" : ""}',
              style: pw.TextStyle(
                font: fontReg,
                fontFallback: fallbackFonts,
                fontSize: 8.5,
              ),
            ),
          ],
          // Fixed Slokam (Permanent Application Content with settings fallback)
          pw.SizedBox(height: 2),
          _txt(
            settings.slokaFooter,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              font: fontReg,
              fontFallback: fallbackFonts,
              fontSize: 7.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to convert dynamic user gender into professional Tamil label
  static String _formatGenderTa(String gender) {
    final g = gender.trim().toLowerCase();
    if (g == 'female' || g == 'பெண்') return 'பெண்';
    if (g == 'other' || g == 'மற்றவை') return 'மற்றவை';
    return 'ஆண்';
  }

  /// 3. Native Profile Box
  static pw.Widget _buildNativeProfileBox(
    UserModel user,
    JaathagaKurippugalResult notes,
    pw.Font fontReg,
    pw.Font fontBold,
    List<pw.Font> fallbackFonts,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 70,
            padding: const pw.EdgeInsets.all(6),
            child: pw.Center(
              child: _txt(
                'ஜாதகர்\n( ${_formatGenderTa(user.gender)} )',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  font: fontBold,
                  fontFallback: fallbackFonts,
                  fontSize: 9,
                ),
              ),
            ),
          ),
          pw.Container(width: 1, height: 65, color: PdfColors.black),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _txt(
                        'பெயர் : ${user.name.isNotEmpty ? user.name : "Divine Seeker"}',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontFallback: fallbackFonts,
                          fontSize: 9.5,
                        ),
                      ),
                      _txt(
                        'வயது : ${user.calculatedAge} வருடம்',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontFallback: fallbackFonts,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _txt(
                        'பிறந்த தேதி : ${notes.englishDate} (${notes.tamilDate})',
                        style: pw.TextStyle(
                          font: fontReg,
                          fontFallback: fallbackFonts,
                          fontSize: 8.5,
                        ),
                      ),
                      _txt(
                        'கிழமை : ${notes.weekday}',
                        style: pw.TextStyle(
                          font: fontReg,
                          fontFallback: fallbackFonts,
                          fontSize: 8.5,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _txt(
                        'பிறந்த நேரம் : ${notes.timeOfBirth}',
                        style: pw.TextStyle(
                          font: fontReg,
                          fontFallback: fallbackFonts,
                          fontSize: 8.5,
                        ),
                      ),
                      _txt(
                        'பிறந்த இடம் : ${notes.placeOfBirth}',
                        style: pw.TextStyle(
                          font: fontReg,
                          fontFallback: fallbackFonts,
                          fontSize: 8.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Panchangam 3-Column Grid
  static pw.Widget _buildPanchangamGrid(
    HoroscopeCalculationResult astro,
    JaathagaKurippugalResult notes,
    pw.Font fontReg,
    pw.Font fontBold,
    List<pw.Font> fallbackFonts,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.8),
      ),
      padding: const pw.EdgeInsets.all(4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Col 1
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _gridText('உதய லக்னம்', '${notes.lagna} (${notes.lagnaDegree})', fontReg, fontBold, fallbackFonts),
                _gridText('ஜென்ம ராசி', notes.rasi, fontReg, fontBold, fallbackFonts),
                _gridText('ஜென்ம நட்சத்திரம்', '${notes.nakshatra} (${notes.pada})', fontReg, fontBold, fallbackFonts),
                _gridText('நட்சத்திர நாதன்', notes.starLord, fontReg, fontBold, fallbackFonts),
                _gridText('திதி', '${notes.paksha} ${notes.thithi}', fontReg, fontBold, fallbackFonts),
              ],
            ),
          ),
          pw.Container(width: 0.8, height: 60, color: PdfColors.grey400),
          pw.SizedBox(width: 6),
          // Col 2
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _gridText('யோகம்', notes.yoga, fontReg, fontBold, fallbackFonts),
                _gridText('கரணம்', notes.karanam, fontReg, fontBold, fallbackFonts),
                _gridText('அமிர்தாதி யோகம்', notes.amirthathiYoga, fontReg, fontBold, fallbackFonts),
                _gridText('சூரிய உதயம்', notes.sunrise, fontReg, fontBold, fallbackFonts),
                _gridText('சூரிய அஸ்தமனம்', notes.sunset, fontReg, fontBold, fallbackFonts),
              ],
            ),
          ),
          pw.Container(width: 0.8, height: 60, color: PdfColors.grey400),
          pw.SizedBox(width: 6),
          // Col 3
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _gridText('உதயாதி நாழிகை', notes.udayathiNazhi, fontReg, fontBold, fallbackFonts),
                _gridText('திதி சூன்யம்', notes.thithiSunyam, fontReg, fontBold, fallbackFonts),
                _gridText('அவயோகி', notes.avaYogi, fontReg, fontBold, fallbackFonts),
                _gridText('அனுயோகி', notes.anuYogi, fontReg, fontBold, fallbackFonts),
                _gridText('கணம் / யோனி', '${notes.gana} / ${notes.yoni}', fontReg, fontBold, fallbackFonts),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _gridText(
    String label,
    String value,
    pw.Font fontReg,
    pw.Font fontBold,
    List<pw.Font> fallbackFonts,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 75,
            child: _txt(
              label,
              style: pw.TextStyle(
                font: fontBold,
                fontFallback: fallbackFonts,
                fontSize: 7.5,
              ),
            ),
          ),
          _txt(' : ', style: pw.TextStyle(font: fontReg, fontFallback: fallbackFonts, fontSize: 7.5)),
          pw.Expanded(
            child: _txt(
              value,
              style: pw.TextStyle(
                font: fontReg,
                fontFallback: fallbackFonts,
                fontSize: 7.5,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// 6. Planets Table
  static pw.Widget _buildPlanetsTable(
    HoroscopeCalculationResult astro,
    pw.Font fontReg,
    pw.Font fontBold,
    List<pw.Font> fallbackFonts,
  ) {
    final planets = ['Lagna', 'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu', 'Mandi'];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2.5),
        4: const pw.FlexColumnWidth(2),
        5: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _th('கிரகம்', fontBold, fallbackFonts),
            _th('ராசி', fontBold, fallbackFonts),
            _th('பாகை (Degree)', fontBold, fallbackFonts),
            _th('நட்சத்திரம் - பாதம்', fontBold, fallbackFonts),
            _th('சார நாதன்', fontBold, fallbackFonts),
            _th('உப நாதன்', fontBold, fallbackFonts),
          ],
        ),
        ...planets.map((key) {
          final p = astro.planets[key]!;
          return pw.TableRow(
            children: [
              _td(p.tamilName, fontBold, fallbackFonts),
              _td(p.rasiNameTa, fontReg, fallbackFonts),
              _td(p.degreeFormatted, fontReg, fallbackFonts),
              _td('${p.nakshatraNameTa} - ${p.pada}', fontReg, fallbackFonts),
              _td(p.tamilStarLord, fontReg, fallbackFonts),
              _td(p.tamilSubLord, fontReg, fallbackFonts),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _th(String text, pw.Font font, List<pw.Font> fallbackFonts) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2.5),
      child: pw.Center(
        child: _txt(
          text,
          style: pw.TextStyle(
            font: font,
            fontFallback: fallbackFonts,
            fontSize: 7.5,
          ),
        ),
      ),
    );
  }

  static pw.Widget _td(String text, pw.Font font, List<pw.Font> fallbackFonts) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.Center(
        child: _txt(
          text,
          style: pw.TextStyle(
            font: font,
            fontFallback: fallbackFonts,
            fontSize: 7,
          ),
        ),
      ),
    );
  }

  /// 7. South Indian 4x4 Chart Box for PDF
  static pw.Widget _buildSouthIndianChartBox(
    String chartTitle,
    HoroscopeCalculationResult astro, {
    required bool isNavamsa,
    required pw.Font fontReg,
    required pw.Font fontBold,
    required List<pw.Font> fallbackFonts,
  }) {
    final Map<int, List<String>> rasiSymbols = {};
    for (final p in astro.planets.values) {
      final idx = isNavamsa ? p.navamsaIndex : p.rasiIndex;
      rasiSymbols.putIfAbsent(idx, () => []).add(p.symbol);
    }

    final gridToRasi = [11, 0, 1, 2, 10, -1, -1, 3, 9, -1, -1, 4, 8, 7, 6, 5];

    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 1)),
      child: pw.Column(
        children: [
          pw.Container(
            color: PdfColors.grey200,
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            child: pw.Center(
              child: _txt(
                chartTitle,
                style: pw.TextStyle(
                  font: fontBold,
                  fontFallback: fallbackFonts,
                  fontSize: 9,
                ),
              ),
            ),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
            children: List.generate(4, (row) {
              return pw.TableRow(
                children: List.generate(4, (col) {
                  final idx = row * 4 + col;
                  final rasiIdx = gridToRasi[idx];
                  if (rasiIdx == -1) {
                    if (row == 1 && col == 1) {
                      return pw.Container(
                        height: 32,
                        child: pw.Center(
                          child: _txt(
                            chartTitle,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontFallback: fallbackFonts,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      );
                    }
                    return pw.Container(height: 32);
                  }

                  final rasiName = AstrologyCalculator.rasiNamesTa[rasiIdx];
                  final symbols = rasiSymbols[rasiIdx] ?? [];

                  return pw.Container(
                    height: 32,
                    padding: const pw.EdgeInsets.all(1.5),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        _txt(
                          rasiName,
                          style: pw.TextStyle(
                            font: fontReg,
                            fontFallback: fallbackFonts,
                            fontSize: 5.5,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Center(
                          child: _txt(
                            symbols.join(' '),
                            style: pw.TextStyle(
                              font: fontBold,
                              fontFallback: fallbackFonts,
                              fontSize: 6.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 8. Dasha Footer with Permanent Fixed Software Footer
  static pw.Widget _buildDashaFooterBlock(
    CustomerPdfSettings settings,
    HoroscopeCalculationResult astro,
    JaathagaKurippugalResult notes,
    pw.Font fontReg,
    pw.Font fontBold,
    List<pw.Font> fallbackFonts,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.8)),
      padding: const pw.EdgeInsets.all(4),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _txt(
                'பிறந்த நேர திசா இருப்பு : ${astro.moon.tamilStarLord} திசை இருப்பு',
                style: pw.TextStyle(
                  font: fontBold,
                  fontFallback: fallbackFonts,
                  fontSize: 8,
                ),
              ),
              _txt(
                'நட்சத்திரம் சென்ற நாழிகை : ${notes.nakshatraNazhi}',
                style: pw.TextStyle(
                  font: fontReg,
                  fontFallback: fallbackFonts,
                  fontSize: 8,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
          // Permanent Application Software Footer (Fixed / Dynamic Fallback)
          pw.Center(
            child: _txt(
              settings.softwareFooter,
              style: pw.TextStyle(
                font: fontBold,
                fontFallback: fallbackFonts,
                fontSize: 7.5,
                color: PdfColors.grey800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to format text with correct Tamil Unicode and ligatures for PDF rendering
  static pw.Text _txt(
    String text, {
    pw.TextStyle? style,
    pw.TextAlign? textAlign,
    int? maxLines,
  }) {
    return pw.Text(
      PdfFontManager.formatText(text),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}

