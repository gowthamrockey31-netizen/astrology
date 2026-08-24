import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/customer_pdf_settings_model.dart';
import '../models/horoscope_calculation_result.dart';
import '../models/jaathaga_kurippugal_model.dart';
import '../models/user_model.dart';
import 'astrology_calculator.dart';
import 'jaathaga_kurippugal_calculator.dart';
import 'pdf_settings_service.dart';

class PdfGeneratorService {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  /// Loads Tamil Unicode font reliably
  static Future<void> _loadFonts() async {
    if (_regularFont != null && _boldFont != null) return;

    try {
      _regularFont = await PdfGoogleFonts.notoSansTamilRegular();
      _boldFont = await PdfGoogleFonts.notoSansTamilBold();
      if (_regularFont != null && _boldFont != null) return;
    } catch (_) {}

    try {
      final regRes = await http.get(Uri.parse(
          'https://raw.githubusercontent.com/google/fonts/main/ofl/notosanstamil/NotoSansTamil-Regular.ttf'));
      final boldRes = await http.get(Uri.parse(
          'https://raw.githubusercontent.com/google/fonts/main/ofl/notosanstamil/NotoSansTamil-Bold.ttf'));

      if (regRes.statusCode == 200 && boldRes.statusCode == 200) {
        _regularFont = pw.Font.ttf(Uint8List.fromList(regRes.bodyBytes).buffer.asByteData());
        _boldFont = pw.Font.ttf(Uint8List.fromList(boldRes.bodyBytes).buffer.asByteData());
        return;
      }
    } catch (_) {}

    _regularFont ??= pw.Font.helvetica();
    _boldFont ??= pw.Font.helveticaBold();
  }

  /// Generates the complete 1-page Tamil Sidereal Horoscope PDF with dynamic Customer / Astrologer details
  static Future<Uint8List> generateHoroscopePdf({
    required UserModel user,
  }) async {
    await _loadFonts();

    final pdf = pw.Document();
    final astroData = AstrologyCalculator.calculateHoroscope(
      dateOfBirth: DateTime.parse(user.dob),
      latitude: user.latitude,
      longitude: user.longitude,
      utcOffsetHours: user.timezone,
    );
    final notes = JaathagaKurippugalCalculator.calculateNotes(user: user);
    final settings = PdfSettingsService.currentSettings;

    final fontReg = _regularFont ?? pw.Font.helvetica();
    final fontBold = _boldFont ?? pw.Font.helveticaBold();

    final pdfTheme = pw.ThemeData.withFont(
      base: fontReg,
      bold: fontBold,
    );

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
                  child: pw.Text(
                    settings.invocationText,
                    style: pw.TextStyle(font: fontBold, fontSize: 10),
                  ),
                ),
              pw.SizedBox(height: 4),

              // 2. Main Title Banner Box (Dynamic Company Settings)
              _buildHeaderBanner(settings, fontReg, fontBold),
              pw.SizedBox(height: 6),

              // 3. Native Profile Box
              _buildNativeProfileBox(user, notes, fontReg, fontBold),
              pw.SizedBox(height: 6),

              // 4. Panchangam 3-Column Attributes Grid
              _buildPanchangamGrid(astroData, notes, fontReg, fontBold),
              pw.SizedBox(height: 6),

              // 5. Sidereal Planetary Longitudes Table Header Banner
              pw.Container(
                color: PdfColors.grey200,
                padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                child: pw.Center(
                  child: pw.Text(
                    'திருக் கணித நிராயன கிரக நிலைகள் ( அயனாம்சம் : Lahiri ${astroData.ayanamsaFormatted} )',
                    style: pw.TextStyle(font: fontBold, fontSize: 10),
                  ),
                ),
              ),
              pw.SizedBox(height: 4),

              // 6. Planetary Positions Table
              _buildPlanetsTable(astroData, fontReg, fontBold),
              pw.SizedBox(height: 10),

              // 7. Side-by-Side South Indian Rasi & Navamsha Charts
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: _buildSouthIndianChartBox('ராசி', astroData, isNavamsa: false, fontReg: fontReg, fontBold: fontBold),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: _buildSouthIndianChartBox('நவாம்சம்', astroData, isNavamsa: true, fontReg: fontReg, fontBold: fontBold),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),

              // 8. Dasha Summary & Footer
              _buildDashaFooterBlock(astroData, notes, settings, fontReg, fontBold),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// 2. Dynamic Header Banner
  static pw.Widget _buildHeaderBanner(CustomerPdfSettings settings, pw.Font fontReg, pw.Font fontBold) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.2),
      ),
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        children: [
          pw.Text(
            settings.companyName,
            style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColors.black),
          ),
          if (settings.astrologerName.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              settings.astrologerName,
              style: pw.TextStyle(font: fontBold, fontSize: 10),
            ),
          ],
          if (settings.address.isNotEmpty || settings.phone.isNotEmpty) ...[
            pw.Text(
              '${settings.address} ${settings.phone.isNotEmpty ? "செல்: ${settings.phone}" : ""}',
              style: pw.TextStyle(font: fontReg, fontSize: 8.5),
            ),
          ],
          if (settings.softwareFooter.isNotEmpty) ...[
            pw.Text(
              settings.softwareFooter,
              style: pw.TextStyle(font: fontBold, fontSize: 8.5),
            ),
          ],
          if (settings.slokaFooter.isNotEmpty) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              settings.slokaFooter,
              style: pw.TextStyle(font: fontReg, fontSize: 7.5, fontStyle: pw.FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  /// 3. Native Profile Box
  static pw.Widget _buildNativeProfileBox(UserModel user, JaathagaKurippugalResult notes, pw.Font fontReg, pw.Font fontBold) {
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
              child: pw.Text(
                'ஜாதகர்\n( ${user.gender == "Male" ? "ஆண்" : "பெண்"} )',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: fontBold, fontSize: 9),
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
                      pw.Text('பெயர் : ${user.name.isNotEmpty ? user.name : "Divine Seeker"}', style: pw.TextStyle(font: fontBold, fontSize: 9.5)),
                      pw.Text('வயது : ${user.calculatedAge} வருடம்', style: pw.TextStyle(font: fontBold, fontSize: 9.5)),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('பிறந்த தேதி : ${notes.englishDate} ( ${notes.tamilDate} )', style: pw.TextStyle(font: fontReg, fontSize: 8.5)),
                      pw.Text('கிழமை : ${notes.weekday}', style: pw.TextStyle(font: fontReg, fontSize: 8.5)),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('பிறந்த நேரம் : ${notes.timeOfBirth}', style: pw.TextStyle(font: fontReg, fontSize: 8.5)),
                      pw.Text('பிறந்த இடம் : ${notes.placeOfBirth}', style: pw.TextStyle(font: fontReg, fontSize: 8.5)),
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
  static pw.Widget _buildPanchangamGrid(HoroscopeCalculationResult astro, JaathagaKurippugalResult notes, pw.Font fontReg, pw.Font fontBold) {
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
                _gridText('உதய லக்னம்', '${notes.lagna} (${notes.lagnaDegree})', fontReg, fontBold),
                _gridText('ஜென்ம ராசி', notes.rasi, fontReg, fontBold),
                _gridText('நட்சத்திரம்', '${notes.nakshatra} (${notes.pada})', fontReg, fontBold),
                _gridText('நட்சத்திர நாதன்', notes.starLord, fontReg, fontBold),
                _gridText('திதி', '${notes.paksha} ${notes.thithi}', fontReg, fontBold),
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
                _gridText('யோகம்', notes.yoga, fontReg, fontBold),
                _gridText('கரணம்', notes.karanam, fontReg, fontBold),
                _gridText('அமிர்தாதி யோகம்', notes.amirthathiYoga, fontReg, fontBold),
                _gridText('சூரிய உதயம்', notes.sunrise, fontReg, fontBold),
                _gridText('சூரிய அஸ்தமனம்', notes.sunset, fontReg, fontBold),
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
                _gridText('உதயாதி நாழிகை', notes.udayathiNazhi, fontReg, fontBold),
                _gridText('திதி சூன்யம்', notes.thithiSunyam, fontReg, fontBold),
                _gridText('அவயோகி', notes.avaYogi, fontReg, fontBold),
                _gridText('அனுயோகி', notes.anuYogi, fontReg, fontBold),
                _gridText('கணம் / யோனி', '${notes.gana} / ${notes.yoni}', fontReg, fontBold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _gridText(String label, String value, pw.Font fontReg, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 75,
            child: pw.Text(label, style: pw.TextStyle(font: fontBold, fontSize: 7.5)),
          ),
          pw.Text(' : ', style: pw.TextStyle(font: fontReg, fontSize: 7.5)),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: fontReg, fontSize: 7.5), maxLines: 1),
          ),
        ],
      ),
    );
  }

  /// 6. Planets Table
  static pw.Widget _buildPlanetsTable(HoroscopeCalculationResult astro, pw.Font fontReg, pw.Font fontBold) {
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
            _th('கிரகம்', fontBold),
            _th('ராசி', fontBold),
            _th('பாகை (Degree)', fontBold),
            _th('நட்சத்திரம் - பாதம்', fontBold),
            _th('சார நாதன்', fontBold),
            _th('உப நாதன்', fontBold),
          ],
        ),
        ...planets.map((key) {
          final p = astro.planets[key]!;
          return pw.TableRow(
            children: [
              _td(p.tamilName, fontBold),
              _td(p.rasiNameTa, fontReg),
              _td(p.degreeFormatted, fontReg),
              _td('${p.nakshatraNameTa}-${p.pada}', fontReg),
              _td(p.tamilStarLord, fontReg),
              _td(p.tamilSubLord, fontReg),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _th(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2.5),
      child: pw.Center(
        child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 7.5)),
      ),
    );
  }

  static pw.Widget _td(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.Center(
        child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 7)),
      ),
    );
  }

  /// 7. South Indian 4x4 Chart Box for PDF
  static pw.Widget _buildSouthIndianChartBox(String chartTitle, HoroscopeCalculationResult astro, {required bool isNavamsa, required pw.Font fontReg, required pw.Font fontBold}) {
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
              child: pw.Text(chartTitle, style: pw.TextStyle(font: fontBold, fontSize: 9)),
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
                          child: pw.Text(chartTitle, style: pw.TextStyle(font: fontBold, fontSize: 8)),
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
                        pw.Text(rasiName, style: pw.TextStyle(font: fontReg, fontSize: 5.5, color: PdfColors.grey700)),
                        pw.Center(
                          child: pw.Text(
                            symbols.join(' '),
                            style: pw.TextStyle(font: fontBold, fontSize: 6.5),
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

  /// 8. Dasha Footer
  static pw.Widget _buildDashaFooterBlock(HoroscopeCalculationResult astro, JaathagaKurippugalResult notes, CustomerPdfSettings settings, pw.Font fontReg, pw.Font fontBold) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.8)),
      padding: const pw.EdgeInsets.all(4),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('பிறந்த நேர தசா இருப்பு : ${notes.starLord} தசை - இருப்பு கணிதம்', style: pw.TextStyle(font: fontBold, fontSize: 8)),
              pw.Text('நட்சத்திர செல்லாகி நின்ற நாழிகை : ${notes.nakshatraNazhi}', style: pw.TextStyle(font: fontReg, fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }
}
