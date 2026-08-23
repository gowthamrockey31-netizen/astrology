import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/horoscope_calculation_result.dart';
import '../models/jaathaga_kurippugal_model.dart';
import '../models/user_model.dart';
import 'astrology_calculator.dart';
import 'jaathaga_kurippugal_calculator.dart';

class PdfGeneratorService {
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  /// Loads Tamil NotoSans font dynamically for crisp PDF rendering
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

  /// Generates the complete 1-page Tamil Sidereal Horoscope PDF
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
              pw.Center(
                child: pw.Text(
                  'ஸ்ரீ பொம்மமையசுவாமி துணை',
                  style: pw.TextStyle(font: fontBold, fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 4),

              // 2. Main Title Banner Box
              _buildHeaderBanner(fontReg, fontBold),
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
              _buildDashaFooterBlock(astroData, notes, fontReg, fontBold),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// 2. Header Banner
  static pw.Widget _buildHeaderBanner(pw.Font fontReg, pw.Font fontBold) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.2),
      ),
      padding: const pw.EdgeInsets.all(6),
      child: pw.Column(
        children: [
          pw.Text(
            'ஸ்ரீ கல்யாண விநாயகர் ஜோதிட நிலையயம்',
            style: pw.TextStyle(font: fontBold, fontSize: 14, color: PdfColors.black),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'ஜோதிஷ ஆதித்யா: R.செந்தில்குமார்',
            style: pw.TextStyle(font: fontBold, fontSize: 10),
          ),
          pw.Text(
            '12/5-24b பெத்தல் சுப்பையன் தெரு, மேட்டுப்பட்டி, சின்னாளபட்டி-624301 செல்:9500813709',
            style: pw.TextStyle(font: fontReg, fontSize: 8.5),
          ),
          pw.Text(
            'Software by AcharyaPaththathi Mobile App. For purchase, call @ 91-7200044010',
            style: pw.TextStyle(font: fontBold, fontSize: 8.5),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'ஜெணனீஜென்ம ஸௌக்யானாம் ! வர்த்தனி குலஸம்பதாம் ! பதவிபூர்வ புண்யானாம்!! லிக்யதே ஜென்ம பத்திரிகா!!',
            style: pw.TextStyle(font: fontReg, fontSize: 7.5, fontStyle: pw.FontStyle.italic),
          ),
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
                  pw.Text(user.name, style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  pw.Text(
                    '${user.dob} ${user.timeOfBirth} | ${notes.weekday} | ${notes.tamilDate} ( வருடம் )',
                    style: pw.TextStyle(font: fontReg, fontSize: 8.5),
                  ),
                  pw.Text(
                    '${user.placeOfBirth},Tamilnadu,India | ${user.latitude} N, ${user.longitude} E | GMT+5:30',
                    style: pw.TextStyle(font: fontReg, fontSize: 8.5),
                  ),
                  pw.Text(
                    'லக்னம் : ${notes.lagna} | ராசி : ${notes.rasi} | நட்சத்திரம் : ${notes.nakshatra} | பாதம் : ${notes.pada}',
                    style: pw.TextStyle(font: fontBold, fontSize: 9),
                  ),
                  pw.Text(
                    'வயது : ${notes.age}',
                    style: pw.TextStyle(font: fontReg, fontSize: 8.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Panchangam 3-Column Attributes Grid
  static pw.Widget _buildPanchangamGrid(HoroscopeCalculationResult astroData, JaathagaKurippugalResult notes, pw.Font fontReg, pw.Font fontBold) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      padding: const pw.EdgeInsets.all(6),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _kvRow('திதி (வளர்பிறை)', ': ${notes.thithi}', fontReg, fontBold),
                _kvRow('நாமயோகம்', ': ${notes.yoga}', fontReg, fontBold),
                _kvRow('கரணம்', ': ${notes.karanam}', fontReg, fontBold),
                _kvRow('அமிர்தாதி யோகம்', ': ${notes.amirthathiYoga}', fontReg, fontBold),
                _kvRow('முக்குண வேளை', ': ${notes.mukkunaVelai}', fontReg, fontBold),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _kvRow('சூரிய உதயம்', ': ${notes.sunrise}', fontReg, fontBold),
                _kvRow('சூரிய அஸ்தமனம்', ': ${notes.sunset}', fontReg, fontBold),
                _kvRow('திதி சூன்யம்', ': ${notes.thithiSunyam}', fontReg, fontBold),
                _kvRow('நாம எழுத்து', ': ${notes.nameLetters}', fontReg, fontBold),
                _kvRow('அவ/அனு/யோகி', ': ${notes.avaYogi} / ${notes.anuYogi}', fontReg, fontBold),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _kvRow('கணம்', ': ${notes.gana}', fontReg, fontBold),
                _kvRow('யோனி', ': ${notes.yoni}', fontReg, fontBold),
                _kvRow('ரஜ்ஜு', ': ${notes.rajju}', fontReg, fontBold),
                _kvRow('பறவை', ': ${notes.bird}', fontReg, fontBold),
                _kvRow('மரம்', ': ${notes.tree}', fontReg, fontBold),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _kvRow(String k, String v, pw.Font fontReg, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 80, child: pw.Text(k, style: pw.TextStyle(font: fontReg, fontSize: 8))),
          pw.Expanded(child: pw.Text(v, style: pw.TextStyle(font: fontBold, fontSize: 8))),
        ],
      ),
    );
  }

  /// 6. Planetary Positions Table
  static pw.Widget _buildPlanetsTable(HoroscopeCalculationResult astroData, pw.Font fontReg, pw.Font fontBold) {
    final planetKeys = ['Lagna', 'Sun', 'Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Rahu', 'Ketu'];

    final rows = <pw.TableRow>[
      // Table Header
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          _cell('கிரகம்', fontBold, isHeader: true),
          _cell('ராசி ஸ்புடம்', fontBold, isHeader: true),
          _cell('நட்சத்திரம்', fontBold, isHeader: true),
          _cell('ராசி', fontBold, isHeader: true),
          _cell('சார நாதன்', fontBold, isHeader: true),
          _cell('வீட்டு நாதன்', fontBold, isHeader: true),
          _cell('பாவக மாற்றம் / கீலம்', fontBold, isHeader: true),
        ],
      ),
    ];

    for (var k in planetKeys) {
      final p = k == 'Lagna' ? astroData.lagna : astroData.planets[k]!;
      final formattedDms = "${p.degreeInRasi.toInt()}°${((p.degreeInRasi - p.degreeInRasi.toInt()) * 60).toInt()}'";
      final starName = "${p.nakshatraNameTa}-${p.pada}";

      rows.add(
        pw.TableRow(
          children: [
            _cell(p.tamilName, fontBold),
            _cell(formattedDms, fontReg),
            _cell(starName, fontReg),
            _cell(p.rasiNameTa, fontBold),
            _cell(p.starLord, fontReg),
            _cell(p.subLord, fontReg),
            _cell('-- / ------', fontReg),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
      children: rows,
    );
  }

  static pw.Widget _cell(String txt, pw.Font font, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 3),
      child: pw.Text(
        txt,
        style: pw.TextStyle(font: font, fontSize: isHeader ? 8 : 7.5),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  /// 7. Side-by-Side South Indian Rasi & Navamsha Charts
  static pw.Widget _buildSouthIndianChartBox(
    String title,
    HoroscopeCalculationResult astroData, {
    required bool isNavamsa,
    required pw.Font fontReg,
    required pw.Font fontBold,
  }) {
    final Map<int, List<String>> gridPlanets = {for (var i = 0; i < 12; i++) i: <String>[]};

    if (!isNavamsa) {
      gridPlanets[astroData.lagna.rasiIndex]?.add('லக்');
      astroData.planets.forEach((_, p) {
        gridPlanets[p.rasiIndex]?.add(p.symbol);
      });
    } else {
      gridPlanets[astroData.lagna.navamsaIndex]?.add('லக்');
      astroData.planets.forEach((_, p) {
        gridPlanets[p.navamsaIndex]?.add(p.symbol);
      });
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(3),
            color: PdfColors.grey200,
            child: pw.Center(
              child: pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 9)),
            ),
          ),
          pw.Container(height: 0.8, color: PdfColors.black),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
            children: [
              pw.TableRow(children: [
                _chartCell(gridPlanets[11]!, fontReg),
                _chartCell(gridPlanets[0]!, fontReg),
                _chartCell(gridPlanets[1]!, fontReg),
                _chartCell(gridPlanets[2]!, fontReg),
              ]),
              pw.TableRow(children: [
                _chartCell(gridPlanets[10]!, fontReg),
                pw.Container(
                  height: 24,
                  child: pw.Center(
                    child: pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 9)),
                  ),
                ),
                pw.Container(height: 24),
                _chartCell(gridPlanets[3]!, fontReg),
              ]),
              pw.TableRow(children: [
                _chartCell(gridPlanets[9]!, fontReg),
                pw.Container(height: 24),
                pw.Container(height: 24),
                _chartCell(gridPlanets[4]!, fontReg),
              ]),
              pw.TableRow(children: [
                _chartCell(gridPlanets[8]!, fontReg),
                _chartCell(gridPlanets[7]!, fontReg),
                _chartCell(gridPlanets[6]!, fontReg),
                _chartCell(gridPlanets[5]!, fontReg),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _chartCell(List<String> planets, pw.Font font) {
    return pw.Container(
      height: 24,
      padding: const pw.EdgeInsets.all(2),
      child: pw.Center(
        child: pw.Text(
          planets.join(' '),
          style: pw.TextStyle(font: font, fontSize: 7.5),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  /// 8. Dasha Summary & Footer
  static pw.Widget _buildDashaFooterBlock(HoroscopeCalculationResult astroData, JaathagaKurippugalResult notes, pw.Font fontReg, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'ஜெணன தசா சனி இருப்பு : 14 வ, 05 மா, 06 நா',
              style: pw.TextStyle(font: fontReg, fontSize: 8),
            ),
            pw.Text(
              'நடப்பு தசா சுக்கிரன் இருப்பு : 19 வ, 06 மா, 09 நா',
              style: pw.TextStyle(font: fontReg, fontSize: 8),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'ஜெணன ஓரைநாதன் : ${astroData.birthHoraLordTa}',
              style: pw.TextStyle(font: fontBold, fontSize: 8.5),
            ),
            pw.Text(
              'நடப்பு புக்தி சுக்ரன் இருப்பு : 02 வ, 10 மா, 09 நா',
              style: pw.TextStyle(font: fontReg, fontSize: 8),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Center(
          child: pw.Text(
            '!!! வாழ்க வளமுடன் !!!',
            style: pw.TextStyle(font: fontBold, fontSize: 10),
          ),
        ),
      ],
    );
  }

  /// Downloads or Opens Printing/Sharing Dialog for the PDF
  static Future<void> downloadOrPrintPdf({
    required UserModel user,
  }) async {
    try {
      final pdfBytes = await generateHoroscopePdf(user: user);
      final filename = '${user.name}_Horoscope_Jathagam.pdf';

      if (kIsWeb) {
        // Web: Opens browser native print & save-as-PDF preview overlay
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes,
          name: filename,
        );
      } else {
        // Android APK / Mobile / Desktop: Opens native system Share/Save sheet
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: filename,
        );
      }
    } catch (e) {
      final pdfBytes = await generateHoroscopePdf(user: user);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: '${user.name}_Horoscope_Jathagam.pdf',
      );
    }
  }
}
