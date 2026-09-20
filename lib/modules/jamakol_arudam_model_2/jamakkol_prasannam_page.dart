import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosmic_background.dart';
import 'jamakkol_calculator.dart';
import 'jamakkol_models.dart';

/// Screen for ஜாமகோள் ஆருடம் — Model 2 (Jamakkol Prasannam Model 2)
class JamakkolPrasannamPage extends StatefulWidget {
  const JamakkolPrasannamPage({super.key});

  @override
  State<JamakkolPrasannamPage> createState() => _JamakkolPrasannamPageState();
}

class _JamakkolPrasannamPageState extends State<JamakkolPrasannamPage> {
  late DateTime _queryTime;
  int _selectedAarudamNumber = 0; // 0 = Auto, 1..12 = Custom Rasi
  String _locationName = 'Chennai';
  double _latitude = 13.0827;
  double _longitude = 80.2707;
  late JamakkolResult _result;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _queryTime = DateTime.now();
    _initFromProfile();
    _recalculate();
  }

  void _initFromProfile() {
    final user = AuthService.currentUser;
    if (user != null) {
      if (user.city.isNotEmpty) _locationName = user.city;
      if (user.placeOfBirth.isNotEmpty && _locationName.isEmpty) {
        _locationName = user.placeOfBirth;
      }
      if (user.latitude != 0.0) {
        _latitude = user.latitude;
      }
      if (user.longitude != 0.0) {
        _longitude = user.longitude;
      }
    }
  }

  void _recalculate() {
    setState(() {
      _isLoading = true;
    });

    final snapshot = JamakkolCalculator.createLiveSnapshot(
      queryTime: _queryTime,
      latitude: _latitude,
      longitude: _longitude,
      location: _locationName,
      customAarudamNumber: _selectedAarudamNumber > 0 ? _selectedAarudamNumber : null,
    );

    _result = JamakkolCalculator.calculate(snapshot);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _queryTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGold,
              onPrimary: Colors.black,
              surface: AppColors.cardSurface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_queryTime),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.primaryGold,
                onPrimary: Colors.black,
                surface: AppColors.cardSurface,
                onSurface: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _queryTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
        _recalculate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 12),
                      _buildQueryControls(),
                      const SizedBox(height: 14),
                      _buildMarkCards(),
                      const SizedBox(height: 14),
                      _buildLegend(),
                      const SizedBox(height: 14),
                      _buildChartSection(),
                      const SizedBox(height: 16),
                      _buildOuterPlanetsTable(),
                      const SizedBox(height: 16),
                      _buildTransitPlanetsTable(),
                      const SizedBox(height: 16),
                      _buildPredictionsSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold, size: 20),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ஜாமகோள் பிரசன்னம்',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'ஜாமகோள் ஆருடம் — Model 2',
                style: GoogleFonts.notoSansTamil(
                  fontSize: 11.5,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _queryTime = DateTime.now();
            });
            _recalculate();
          },
          icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
          tooltip: 'தற்போதைய நேரம் (Now)',
        ),
      ],
    );
  }

  Widget _buildQueryControls() {
    final dtStr =
        "${_queryTime.day.toString().padLeft(2, '0')}/${_queryTime.month.toString().padLeft(2, '0')}/${_queryTime.year} "
        "${_queryTime.hour.toString().padLeft(2, '0')}:${_queryTime.minute.toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: AppColors.lightGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dtStr,
                  style: GoogleFonts.cinzel(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              InkWell(
                onTap: _selectDateTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_calendar_rounded, color: AppColors.lightGold, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'மாற்று',
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 11,
                          color: AppColors.lightGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.lightGold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'இடம்: $_locationName (${_latitude.toStringAsFixed(2)}°N, ${_longitude.toStringAsFixed(2)}°E)',
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 11.5,
                    color: Colors.white70,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade900.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${_result.jamamNumber}-ஆம் சாமம் (${_result.jamamLord})',
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 10.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.explore_rounded, color: AppColors.lightGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'ஆருடத் தேர்வு: ',
                style: GoogleFonts.notoSansTamil(
                  fontSize: 11.5,
                  color: Colors.white70,
                ),
              ),
              DropdownButton<int>(
                value: _selectedAarudamNumber,
                dropdownColor: AppColors.cardSurface,
                isDense: true,
                style: GoogleFonts.notoSansTamil(
                  fontSize: 11.5,
                  color: AppColors.lightGold,
                  fontWeight: FontWeight.bold,
                ),
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem(value: 0, child: Text('தானியங்கி (Auto)')),
                  for (int i = 1; i <= 12; i++)
                    DropdownMenuItem(value: i, child: Text('$i - ${kJamakkolRasiNamesTa[i - 1]}')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedAarudamNumber = val;
                    });
                    _recalculate();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarkCards() {
    return Row(
      children: [
        Expanded(child: _buildMarkCard(_result.udhayam, const Color(0xFF00E676))),
        const SizedBox(width: 8),
        Expanded(child: _buildMarkCard(_result.arudham, const Color(0xFFFFD700))),
        const SizedBox(width: 8),
        Expanded(child: _buildMarkCard(_result.kavippu, const Color(0xFFFF3D00))),
      ],
    );
  }

  Widget _buildMarkCard(MarkPosition mark, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withValues(alpha: 0.7), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: accentColor, width: 0.8),
                ),
                child: Text(
                  mark.symbol,
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  mark.tamilName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            mark.rasiName,
            style: GoogleFonts.notoSansTamil(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            mark.formattedDegree,
            style: GoogleFonts.cinzel(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${mark.house}-ஆம் பாவம்',
            style: GoogleFonts.notoSansTamil(
              fontSize: 10,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          _buildLegendItem('வெளிவட்டம்', const Color(0xFFBA68C8), isCircle: false),
          _buildLegendItem('கோச்சாரம்', const Color(0xFF29B6F6), isCircle: false),
          _buildLegendItem('உதயம்', const Color(0xFF00E676), isCircle: true),
          _buildLegendItem('ஆருடம்', const Color(0xFFFFD700), isCircle: true),
          _buildLegendItem('கவிப்பு', const Color(0xFFFF3D00), isCircle: true),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool isCircle = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.notoSansTamil(
            fontSize: 10.5,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: _JamakkolChart(result: _result),
        ),
      ),
    );
  }

  Widget _buildOuterPlanetsTable() {
    return _buildSectionCard(
      title: 'வெளிவட்ட கிரகநிலைகள்',
      icon: Icons.track_changes_rounded,
      color: const Color(0xFFBA68C8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 36,
          dataRowMinHeight: 32,
          dataRowMaxHeight: 34,
          horizontalMargin: 8,
          columnSpacing: 16,
          columns: [
            DataColumn(
              label: Text(
                'கிரகம்',
                style: GoogleFonts.notoSansTamil(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
              ),
            ),
            DataColumn(
              label: Text(
                'ராசி',
                style: GoogleFonts.notoSansTamil(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
              ),
            ),
            DataColumn(
              label: Text(
                'பாகை',
                style: GoogleFonts.notoSansTamil(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
              ),
            ),
            DataColumn(
              label: Text(
                'உதய பாவம்',
                style: GoogleFonts.notoSansTamil(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
              ),
            ),
          ],
          rows: _result.outerPlanets.map((planet) {
            final rasi = kJamakkolRasiNamesTa[planet.rasiIndex];
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    planet.tamilName,
                    style: GoogleFonts.notoSansTamil(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(
                  Text(
                    rasi,
                    style: GoogleFonts.notoSansTamil(fontSize: 11, color: Colors.white70),
                  ),
                ),
                DataCell(
                  Text(
                    planet.formattedDegree,
                    style: GoogleFonts.cinzel(fontSize: 10.5, color: Colors.white),
                  ),
                ),
                DataCell(
                  Text(
                    '${planet.house}-ஆம் இடம்',
                    style: GoogleFonts.notoSansTamil(fontSize: 10.5, color: const Color(0xFFBA68C8)),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTransitPlanetsTable() {
    return _buildSectionCard(
      title: 'கோச்சார கிரகநிலைகள்',
      icon: Icons.stars_rounded,
      color: const Color(0xFF29B6F6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 36,
          dataRowMinHeight: 32,
          dataRowMaxHeight: 34,
          horizontalMargin: 8,
          columnSpacing: 14,
          columns: [
            DataColumn(
              label: Text(
                'கிரகம்',
                style: GoogleFonts.notoSansTamil(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
              ),
            ),
            DataColumn(
              label: Text(
                'ராசி',
                style: GoogleFonts.notoSansTamil(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
              ),
            ),
            DataColumn(
              label: Text(
                'பாகை',
                style: GoogleFonts.notoSansTamil(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
              ),
            ),
            DataColumn(
              label: Text(
                'வக்ரம்',
                style: GoogleFonts.notoSansTamil(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
              ),
            ),
            DataColumn(
              label: Text(
                'உதய பாவம்',
                style: GoogleFonts.notoSansTamil(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
              ),
            ),
          ],
          rows: _result.transitPlanets.map((planet) {
            final rasi = kJamakkolRasiNamesTa[planet.rasiIndex];
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    planet.tamilName,
                    style: GoogleFonts.notoSansTamil(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                DataCell(
                  Text(
                    rasi,
                    style: GoogleFonts.notoSansTamil(fontSize: 11, color: Colors.white70),
                  ),
                ),
                DataCell(
                  Text(
                    planet.formattedDegree,
                    style: GoogleFonts.cinzel(fontSize: 10.5, color: Colors.white),
                  ),
                ),
                DataCell(
                  planet.isRetrograde
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.red.shade900.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'வக்ரம் (R)',
                            style: GoogleFonts.notoSansTamil(fontSize: 9.5, color: Colors.redAccent, fontWeight: FontWeight.bold),
                          ),
                        )
                      : Text(
                          'நேர்கதி',
                          style: GoogleFonts.notoSansTamil(fontSize: 10, color: Colors.white54),
                        ),
                ),
                DataCell(
                  Text(
                    '${planet.house}-ஆம் இடம்',
                    style: GoogleFonts.notoSansTamil(fontSize: 10.5, color: const Color(0xFF29B6F6)),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPredictionsSection() {
    return _buildSectionCard(
      title: 'கிரகநிலைகளின் அடிப்படையிலான பலன்கள்',
      icon: Icons.psychology_rounded,
      color: AppColors.primaryGold,
      child: Column(
        children: _result.predictions.map((p) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.circle, size: 6, color: AppColors.primaryGold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    p,
                    style: GoogleFonts.notoSansTamil(
                      fontSize: 12,
                      height: 1.45,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cinzel(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

/// Custom South Indian Chart Widget for Jamakkol Model 2
class _JamakkolChart extends StatelessWidget {
  final JamakkolResult result;

  const _JamakkolChart({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF07131F),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryGold, width: 1.5),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          return Stack(
            children: [
              CustomPaint(
                size: size,
                painter: _JamakkolPainter(result: result),
              ),
              ..._buildCells(size),
              _buildCenterSection(size),
            ],
          );
        },
      ),
    );
  }

  /// South Indian Chart Coordinates:
  /// Row 0: Meenam (11), Mesham (0), Rishabam (1), Mithunam (2)
  /// Row 1: Kumbam (10), Kadagam (3)
  /// Row 2: Makaram (9), Simmam (4)
  /// Row 3: Dhanusu (8), Viruchigam (7), Thulam (6), Kanni (5)
  List<Widget> _buildCells(Size size) {
    final cellW = size.width / 4;
    final cellH = size.height / 4;

    final cellGrid = [
      (0, 0, 11), // Meenam
      (1, 0, 0), // Mesham
      (2, 0, 1), // Rishabam
      (3, 0, 2), // Mithunam
      (3, 1, 3), // Kadagam
      (3, 2, 4), // Simmam
      (3, 3, 5), // Kanni
      (2, 3, 6), // Thulam
      (1, 3, 7), // Viruchigam
      (0, 3, 8), // Dhanusu
      (0, 2, 9), // Makaram
      (0, 1, 10), // Kumbam
    ];

    return cellGrid.map((c) {
      final col = c.$1;
      final row = c.$2;
      final rasiIdx = c.$3;
      final x = col * cellW;
      final y = row * cellH;

      final marks = result.marksByRasi[rasiIdx] ?? [];

      // Calculate house number from Udhayam
      final house = (((rasiIdx - result.udhayam.rasiIndex) % 12 + 12) % 12) + 1;

      return Positioned(
        left: x,
        top: y,
        width: cellW,
        height: cellH,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cell Header: Rasi name & House number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      kJamakkolRasiNamesTa[rasiIdx],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansTamil(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$house',
                    style: GoogleFonts.cinzel(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),

              // Marks (உ, ஆ, கவி)
              if (marks.isNotEmpty)
                Wrap(
                  spacing: 2,
                  runSpacing: 1,
                  children: marks.map((m) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
                      decoration: BoxDecoration(
                        color: m.color.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: m.color, width: 0.8),
                      ),
                      child: Text(
                        "${m.symbol} ${m.formattedDegree}",
                        style: GoogleFonts.notoSansTamil(
                          fontSize: 7.5,
                          fontWeight: FontWeight.bold,
                          color: m.color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCenterSection(Size size) {
    final cellW = size.width / 4;
    final cellH = size.height / 4;

    return Positioned(
      left: cellW,
      top: cellH,
      width: cellW * 2,
      height: cellH * 2,
      child: Container(
        padding: const EdgeInsets.all(6),
        color: const Color(0xDD0B1220),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ஜாமகோள் பிரசன்னம்',
                style: GoogleFonts.cinzel(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Model 2',
                style: GoogleFonts.cinzel(
                  fontSize: 9.5,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${result.jamamNumber}-ஆம் சாமம்",
                style: GoogleFonts.notoSansTamil(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                ),
              ),
              Text(
                "சாம நாதன்: ${result.jamamLord}",
                style: GoogleFonts.notoSansTamil(
                  fontSize: 8.5,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                result.location,
                style: GoogleFonts.notoSansTamil(
                  fontSize: 8,
                  color: Colors.white54,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// CustomPainter for the Jamakkol Prasannam Circular Chart with
/// exact-degree Inner Circle (Kochara) and Outer Circle (Jamam) planet positions.
class _JamakkolPainter extends CustomPainter {
  final JamakkolResult result;

  const _JamakkolPainter({required this.result});


  /// Normalizes celestial longitude strictly into 0.0 <= lon < 360.0
  static double normalizeLongitude(double longitude) {
    double lon = longitude % 360.0;
    if (lon < 0) lon += 360.0;
    return lon;
  }

  /// Centralized angle conversion: converts celestial longitude (0° to 360°)
  /// to the exact continuous angle in radians for the South Indian 4x4 chart layout:
  ///
  /// Row 0: Meenam (11), Mesham (0), Rishabam (1), Mithunam (2)
  /// Row 1: Kumbam (10),             Center,       Katakam (3)
  /// Row 2: Makaram (9),             Center,       Simham (4)
  /// Row 3: Dhanusu (8), Viruchigam (7), Thulam (6), Kanni (5)
  static double longitudeToChartAngle(double longitude) {
    final normDeg = normalizeLongitude(longitude);
    final int rasiIdx = (normDeg / 30.0).floor() % 12;
    final double frac = (normDeg % 30.0) / 30.0;

    const atan1_5 = 0.5880026035475675; // atan(1.0 / 1.5) = 33.69°
    const atan15_1 = 0.982793723247329; // atan(1.5 / 1.0) = 56.31°
    const halfPi = math.pi / 2.0;       // 90.0°
    const piVal = math.pi;

    double startAngle;
    double endAngle;

    switch (rasiIdx) {
      case 0: // Mesham (Col 1, Row 0)
        startAngle = -(piVal - atan15_1); // -123.69°
        endAngle = -halfPi;               // -90.0°
        break;
      case 1: // Rishabam (Col 2, Row 0)
        startAngle = -halfPi;             // -90.0°
        endAngle = -atan15_1;             // -56.31°
        break;
      case 2: // Mithunam (Col 3, Row 0)
        startAngle = -atan15_1;           // -56.31°
        endAngle = -atan1_5;              // -33.69°
        break;
      case 3: // Kadagam (Col 3, Row 1)
        startAngle = -atan1_5;            // -33.69°
        endAngle = 0.0;                   // 0.0°
        break;
      case 4: // Simmam (Col 3, Row 2)
        startAngle = 0.0;                 // 0.0°
        endAngle = atan1_5;               // +33.69°
        break;
      case 5: // Kanni (Col 3, Row 3)
        startAngle = atan1_5;             // +33.69°
        endAngle = atan15_1;              // +56.31°
        break;
      case 6: // Thulam (Col 2, Row 3)
        startAngle = atan15_1;            // +56.31°
        endAngle = halfPi;                // +90.0°
        break;
      case 7: // Viruchigam (Col 1, Row 3)
        startAngle = halfPi;              // +90.0°
        endAngle = piVal - atan15_1;      // +123.69°
        break;
      case 8: // Dhanusu (Col 0, Row 3)
        startAngle = piVal - atan15_1;    // +123.69°
        endAngle = piVal - atan1_5;       // +146.31°
        break;
      case 9: // Makaram (Col 0, Row 2)
        startAngle = piVal - atan1_5;     // +146.31°
        endAngle = piVal;                 // +180.0°
        break;
      case 10: // Kumbam (Col 0, Row 1)
        startAngle = -piVal;              // -180.0°
        endAngle = -(piVal - atan1_5);    // -146.31°
        break;
      case 11: // Meenam (Col 0, Row 0)
      default:
        startAngle = -(piVal - atan1_5);  // -146.31°
        endAngle = -(piVal - atan15_1);   // -123.69°
        break;
    }

    return startAngle + frac * (endAngle - startAngle);
  }


  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / 4;
    final cellH = size.height / 4;
    final chartSize = math.min(size.width, size.height);
    if (chartSize <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);

    // 1. Draw Grid Lines
    final gridPaint = Paint()
      ..color = AppColors.primaryGold.withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final centerBorderPaint = Paint()
      ..color = AppColors.primaryGold.withValues(alpha: 0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(0, i * cellH),
        Offset(size.width, i * cellH),
        gridPaint,
      );
    }

    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(i * cellW, 0),
        Offset(i * cellW, size.height),
        gridPaint,
      );
    }

    // Center 2x2 box outline
    canvas.drawRect(
      Rect.fromLTWH(cellW, cellH, cellW * 2, cellH * 2),
      centerBorderPaint,
    );

    // 2. Dual Concentric Circular Orbits
    // innerRadius runs comfortably through the inner section of the 12 boxes, strictly outside center 2x2
    // outerRadius runs through the outer section of the 12 boxes, strictly inside chart border
    final innerRadius = chartSize * 0.358;
    final outerRadius = chartSize * 0.435;

    // Draw subtle orbit tracks matching legend colors
    final innerOrbitPaint = Paint()
      ..color = const Color(0xFF29B6F6).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final outerOrbitPaint = Paint()
      ..color = const Color(0xFFBA68C8).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, innerRadius, innerOrbitPaint);
    canvas.drawCircle(center, outerRadius, outerOrbitPaint);

    // 3. Render Outer Circle (Jamam Planets - வெளிவட்டம்)
    _renderPlanetGroup(
      canvas: canvas,
      planets: result.outerPlanets,
      radius: outerRadius,
      center: center,
      canvasSize: size,
      badgeColor: const Color(0xFF1E0B2B),
      borderColor: const Color(0xFFBA68C8),
      textColor: const Color(0xFFE1BEE7),
      isOuter: true,
    );

    // 4. Render Inner Circle (Transit / Kochara Planets - கோச்சாரம்)
    _renderPlanetGroup(
      canvas: canvas,
      planets: result.transitPlanets,
      radius: innerRadius,
      center: center,
      canvasSize: size,
      badgeColor: const Color(0xFF091B2C),
      borderColor: const Color(0xFF29B6F6),
      textColor: const Color(0xFFB3E5FC),
      isOuter: false,
    );
  }

  void _renderPlanetGroup({
    required Canvas canvas,
    required List<JamakkolPlanetInfo> planets,
    required double radius,
    required Offset center,
    required Size canvasSize,
    required Color badgeColor,
    required Color borderColor,
    required Color textColor,
    required bool isOuter,
  }) {
    if (planets.isEmpty) return;

    // Group planets whose longitudes are within collision tolerance (4.5 degrees)
    final groups = _groupPlanets(planets, 4.5);

    for (final group in groups) {
      final count = group.length;

      for (int i = 0; i < count; i++) {
        final planet = group[i];
        final normLon = normalizeLongitude(planet.longitude);
        final radians = longitudeToChartAngle(normLon);

        // Calculate exact astronomical Canvas position
        final baseX = center.dx + radius * math.cos(radians);
        final baseY = center.dy + radius * math.sin(radians);
        final basePos = Offset(baseX, baseY);

        // Visual collision offset for marker
        final visualOffset = _calculateVisualOffset(i, count, radians);
        final markerPos = basePos + visualOffset;

        // Draw planet marker dot on orbit
        _drawPlanetMarker(
          canvas: canvas,
          pos: markerPos,
          badgeColor: badgeColor,
          borderColor: borderColor,
        );

        // Label offset nudges slightly inward/outward along orbit tangent
        final labelOffset = _calculateLabelOffset(i, count, radians, isOuter);
        final labelText = isOuter
            ? "${planet.symbol} ${planet.formattedDegree}"
            : "${planet.symbol}${planet.isRetrograde ? '(R)' : ''} ${planet.formattedDegree}";

        _drawPlanetBadge(
          canvas: canvas,
          markerPos: markerPos,
          labelOffset: labelOffset,
          text: labelText,
          badgeColor: badgeColor,
          borderColor: borderColor,
          textColor: textColor,
          canvasSize: canvasSize,
        );
      }
    }
  }

  List<List<JamakkolPlanetInfo>> _groupPlanets(
    List<JamakkolPlanetInfo> items,
    double tolerance,
  ) {
    final remaining = List<JamakkolPlanetInfo>.from(items);
    final groups = <List<JamakkolPlanetInfo>>[];

    while (remaining.isNotEmpty) {
      final current = remaining.removeAt(0);
      final group = <JamakkolPlanetInfo>[current];

      bool added = true;
      while (added) {
        added = false;
        for (int i = remaining.length - 1; i >= 0; i--) {
          final candidate = remaining[i];
          final isNear = group.any(
            (item) => _angularDistance(item.longitude, candidate.longitude) <= tolerance,
          );
          if (isNear) {
            group.add(candidate);
            remaining.removeAt(i);
            added = true;
          }
        }
      }

      groups.add(group);
    }

    return groups;
  }

  static double _angularDistance(double a, double b) {
    var diff = (a - b).abs() % 360.0;
    if (diff > 180.0) diff = 360.0 - diff;
    return diff;
  }

  Offset _calculateVisualOffset(int index, int totalInGroup, double radians) {
    if (totalInGroup <= 1) return Offset.zero;

    final tan = Offset(-math.sin(radians), math.cos(radians));
    final sign = (index % 2 == 0) ? 1.0 : -1.0;
    final step = (index ~/ 2) * 5.0;

    return Offset(
      tan.dx * (5.0 + step) * sign,
      tan.dy * (5.0 + step) * sign,
    );
  }

  Offset _calculateLabelOffset(
    int index,
    int totalInGroup,
    double radians,
    bool isOuter,
  ) {
    final tan = Offset(-math.sin(radians), math.cos(radians));
    final rad = Offset(math.cos(radians), math.sin(radians));

    // Bias outer labels slightly outward, inner labels slightly inward
    final radialBias = isOuter ? 2.5 : -2.5;

    if (totalInGroup <= 1) {
      return Offset(
        rad.dx * radialBias,
        rad.dy * radialBias,
      );
    }

    final sign = (index % 2 == 0) ? 1.0 : -1.0;
    final step = (index ~/ 2) * 6.0;

    return Offset(
      tan.dx * (7.0 + step) * sign + rad.dx * radialBias,
      tan.dy * (7.0 + step) * sign + rad.dy * radialBias,
    );
  }

  void _drawPlanetMarker({
    required Canvas canvas,
    required Offset pos,
    required Color badgeColor,
    required Color borderColor,
  }) {
    const markerRadius = 3.0;

    final fillPaint = Paint()
      ..color = badgeColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pos, markerRadius, fillPaint);
    canvas.drawCircle(pos, markerRadius, borderPaint);
    canvas.drawCircle(pos, 1.0, dotPaint);
  }

  void _drawPlanetBadge({
    required Canvas canvas,
    required Offset markerPos,
    required Offset labelOffset,
    required String text,
    required Color badgeColor,
    required Color borderColor,
    required Color textColor,
    required Size canvasSize,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: textColor,
        fontSize: 7.2,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(color: Colors.black, blurRadius: 2.0),
        ],
      ),
    );

    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final targetCenter = markerPos + labelOffset;
    final halfW = tp.width / 2 + 2.5;
    final halfH = tp.height / 2 + 1.0;

    final clampedX = targetCenter.dx.clamp(halfW + 1.0, canvasSize.width - halfW - 1.0);
    final clampedY = targetCenter.dy.clamp(halfH + 1.0, canvasSize.height - halfH - 1.0);
    final finalCenter = Offset(clampedX, clampedY);

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: finalCenter, width: tp.width + 4.0, height: tp.height + 2.0),
      const Radius.circular(3.5),
    );

    final bgPaint = Paint()
      ..color = badgeColor.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    canvas.drawRRect(bgRect, bgPaint);
    canvas.drawRRect(bgRect, borderPaint);

    tp.paint(canvas, Offset(finalCenter.dx - tp.width / 2, finalCenter.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _JamakkolPainter oldDelegate) {
    return oldDelegate.result != result;
  }
}

