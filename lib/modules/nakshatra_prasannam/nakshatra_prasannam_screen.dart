import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../services/astrology_calculator.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosmic_background.dart';
import 'nakshatra_prasannam_calculator.dart';
import 'nakshatra_prasannam_data.dart';
import 'nakshatra_prasannam_engine.dart';
import 'nakshatra_prasannam_models.dart';

/// Screen for நட்சத்திர பிரசன்னம் (Nakshatra Prasannam)
/// Standalone module implementing Stellar Horary Prasna (Meena 2 Naadi method).
class NakshatraPrasannaScreen extends StatefulWidget {
  const NakshatraPrasannaScreen({super.key});

  @override
  State<NakshatraPrasannaScreen> createState() => _NakshatraPrasannaScreenState();
}

class _NakshatraPrasannaScreenState extends State<NakshatraPrasannaScreen> {
  // Input fields
  late DateTime _questionDate;
  late TimeOfDay _questionTime;
  late TimeOfDay _sunriseTime;
  String _place = 'Chennai';
  double _latitude = 13.0827;
  double _longitude = 80.2707;

  // Controllers for degrees
  final TextEditingController _moonSunriseLonController = TextEditingController();
  final TextEditingController _moonQuestionLonController = TextEditingController();
  final TextEditingController _ascendantLonController = TextEditingController();

  final Map<Planet, TextEditingController> _planetControllers = {
    Planet.sun: TextEditingController(),
    Planet.moon: TextEditingController(),
    Planet.mars: TextEditingController(),
    Planet.mercury: TextEditingController(),
    Planet.jupiter: TextEditingController(),
    Planet.venus: TextEditingController(),
    Planet.saturn: TextEditingController(),
    Planet.rahu: TextEditingController(),
    Planet.ketu: TextEditingController(),
  };

  // State
  List<String> _validationErrors = [];
  NakshatraPrasannaResult? _result;
  bool _isTimelineExpanded = false;
  bool _isUttamaExpanded = false;
  bool _isPlanetsExpanded = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _questionDate = now;
    _questionTime = TimeOfDay.fromDateTime(now);
    _sunriseTime = const TimeOfDay(hour: 6, minute: 0);

    _initFromProfile();
    _loadLiveTransitPositions();
    _runCalculation();
  }

  @override
  void dispose() {
    _moonSunriseLonController.dispose();
    _moonQuestionLonController.dispose();
    _ascendantLonController.dispose();
    for (final c in _planetControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initFromProfile() {
    final user = AuthService.currentUser;
    if (user != null) {
      if (user.city.isNotEmpty) _place = user.city;
      if (user.placeOfBirth.isNotEmpty && _place.isEmpty) {
        _place = user.placeOfBirth;
      }
      if (user.latitude != 0.0) _latitude = user.latitude;
      if (user.longitude != 0.0) _longitude = user.longitude;
    }
  }

  /// Load live transit planetary longitudes and astronomical sunrise
  void _loadLiveTransitPositions() {
    final qDateTime = DateTime(
      _questionDate.year,
      _questionDate.month,
      _questionDate.day,
      _questionTime.hour,
      _questionTime.minute,
    );

    try {
      // 1. Calculate astronomical sunrise
      final sunTimes = AstrologyCalculator.calculateSunriseSunset(
        qDateTime,
        _latitude,
        _longitude,
        5.5,
      );
      final sunriseDt = sunTimes['sunrise'] ?? DateTime(qDateTime.year, qDateTime.month, qDateTime.day, 6, 0);
      _sunriseTime = TimeOfDay.fromDateTime(sunriseDt);

      // 2. Ephemeris at Question Time
      final horoscopeNow = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: qDateTime,
        latitude: _latitude,
        longitude: _longitude,
        utcOffsetHours: 5.5,
      );

      // 3. Ephemeris at Sunrise
      final horoscopeSunrise = AstrologyCalculator.calculateHoroscope(
        dateOfBirth: sunriseDt,
        latitude: _latitude,
        longitude: _longitude,
        utcOffsetHours: 5.5,
      );

      final moonSunriseLon = horoscopeSunrise.moon.longitude;
      final moonQuestionLon = horoscopeNow.moon.longitude;
      final ascLon = horoscopeNow.lagna.longitude;

      _moonSunriseLonController.text = moonSunriseLon.toStringAsFixed(4);
      _moonQuestionLonController.text = moonQuestionLon.toStringAsFixed(4);
      _ascendantLonController.text = ascLon.toStringAsFixed(4);

      // Populate planet controllers
      _planetControllers[Planet.sun]?.text = horoscopeNow.sun.longitude.toStringAsFixed(4);
      _planetControllers[Planet.moon]?.text = moonQuestionLon.toStringAsFixed(4);
      _planetControllers[Planet.mars]?.text =
          (horoscopeNow.planets['Mars']?.longitude ?? 0.0).toStringAsFixed(4);
      _planetControllers[Planet.mercury]?.text =
          (horoscopeNow.planets['Mercury']?.longitude ?? 0.0).toStringAsFixed(4);
      _planetControllers[Planet.jupiter]?.text =
          (horoscopeNow.planets['Jupiter']?.longitude ?? 0.0).toStringAsFixed(4);
      _planetControllers[Planet.venus]?.text =
          (horoscopeNow.planets['Venus']?.longitude ?? 0.0).toStringAsFixed(4);
      _planetControllers[Planet.saturn]?.text =
          (horoscopeNow.planets['Saturn']?.longitude ?? 0.0).toStringAsFixed(4);
      _planetControllers[Planet.rahu]?.text =
          (horoscopeNow.planets['Rahu']?.longitude ?? 0.0).toStringAsFixed(4);
      _planetControllers[Planet.ketu]?.text =
          (horoscopeNow.planets['Ketu']?.longitude ?? 0.0).toStringAsFixed(4);
    } catch (_) {
      // Fallback sensible defaults if offline/ephemeris fails
      _moonSunriseLonController.text = "45.2500";
      _moonQuestionLonController.text = "48.5000";
      _ascendantLonController.text = "120.0000";
      for (final p in Planet.values) {
        _planetControllers[p]?.text = "100.0000";
      }
    }
  }

  void _runCalculation() {
    final questionDateTime = DateTime(
      _questionDate.year,
      _questionDate.month,
      _questionDate.day,
      _questionTime.hour,
      _questionTime.minute,
    );

    final sunriseDateTime = DateTime(
      _questionDate.year,
      _questionDate.month,
      _questionDate.day,
      _sunriseTime.hour,
      _sunriseTime.minute,
    );

    final moonSunriseLon = double.tryParse(_moonSunriseLonController.text.trim()) ?? 0.0;
    final moonQuestionLon = double.tryParse(_moonQuestionLonController.text.trim());
    final ascLon = double.tryParse(_ascendantLonController.text.trim());

    final planetLons = <Planet, double>{};
    for (final entry in _planetControllers.entries) {
      final val = double.tryParse(entry.value.text.trim());
      if (val != null) {
        planetLons[entry.key] = val;
      }
    }

    final input = PrasannaInput(
      questionDateTime: questionDateTime,
      sunriseDateTime: sunriseDateTime,
      place: _place,
      latitude: _latitude,
      longitude: _longitude,
      moonSunriseLongitude: moonSunriseLon,
      moonQuestionLongitude: moonQuestionLon,
      planetLongitudes: planetLons,
      ascendantLongitude: ascLon,
    );

    final errors = NakshatraPrasannaEngine.validateInput(input);
    setState(() {
      _validationErrors = errors;
      if (errors.isEmpty) {
        _result = NakshatraPrasannaEngine.calculate(input);
      } else {
        _result = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: Text(
          'நட்சத்திர பிரசன்னம்',
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.lightGold,
          ),
        ),
        backgroundColor: AppColors.backgroundMid,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
            tooltip: 'தற்போதைய கிரக நிலைகளை ஏற்று',
            onPressed: () {
              setState(() {
                final now = DateTime.now();
                _questionDate = now;
                _questionTime = TimeOfDay.fromDateTime(now);
                _loadLiveTransitPositions();
                _runCalculation();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('தற்போதைய கோட்சார கிரக நிலைகள் புதுப்பிக்கப்பட்டன.'),
                  backgroundColor: AppColors.backgroundMid,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderBadge(),
                const SizedBox(height: 16),
                _buildInputSection(),
                const SizedBox(height: 16),
                if (_validationErrors.isNotEmpty) _buildValidationErrorsCard(),
                if (_result != null) ...[
                  const SizedBox(height: 16),
                  _buildFinalResultCard(_result!),
                  const SizedBox(height: 16),
                  _buildDrmCard(_result!),
                  const SizedBox(height: 16),
                  _buildHrmCard(_result!),
                  const SizedBox(height: 16),
                  _buildNplCard(_result!),
                  const SizedBox(height: 16),
                  _buildJeevaSareeraCard(_result!),
                  const SizedBox(height: 16),
                  _buildGunaCard(_result!),
                  const SizedBox(height: 16),
                  _buildUttamaCard(_result!),
                  const SizedBox(height: 16),
                  _buildDrmHrmRelationCard(_result!),
                  const SizedBox(height: 16),
                  _buildEventTimingCard(_result!),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header Banner
  Widget _buildHeaderBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGold.withValues(alpha: 0.15),
            AppColors.purpleAccent.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGold.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.primaryGold),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.lightGold, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'நட்சத்திர பிரசன்னம் (Nakshatra Prasannam)',
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'DRM • HRM • NPL • ஜீவா • சரீரா • காலக்கணிப்பு முறை',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Input Card
  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'பிரசன்ன உள்ளீட்டு விவரங்கள்',
                style: GoogleFonts.cinzel(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _loadLiveTransitPositions();
                    _runCalculation();
                  });
                },
                icon: const Icon(Icons.flash_on_rounded, color: AppColors.primaryGold, size: 16),
                label: Text(
                  'Live Now',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 16),

          // Date and Time Row
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildDateTimeTile(
                label: 'கேள்வி தேதி (Date)',
                value: DateFormat('dd/MM/yyyy').format(_questionDate),
                icon: Icons.calendar_today_rounded,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _questionDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _questionDate = picked;
                      _loadLiveTransitPositions();
                      _runCalculation();
                    });
                  }
                },
              ),
              _buildDateTimeTile(
                label: 'கேள்வி நேரம் (Time)',
                value: _questionTime.format(context),
                icon: Icons.access_time_rounded,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _questionTime,
                  );
                  if (picked != null) {
                    setState(() {
                      _questionTime = picked;
                      _loadLiveTransitPositions();
                      _runCalculation();
                    });
                  }
                },
              ),
              _buildDateTimeTile(
                label: 'சூரிய உதயம் (Sunrise)',
                value: _sunriseTime.format(context),
                icon: Icons.wb_sunny_rounded,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _sunriseTime,
                  );
                  if (picked != null) {
                    setState(() {
                      _sunriseTime = picked;
                      _runCalculation();
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Place & Coords Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  label: 'இடம் (Place)',
                  initialValue: _place,
                  onChanged: (val) => _place = val,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  label: 'அட்சரேகை (Lat)',
                  initialValue: _latitude.toStringAsFixed(4),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) {
                    final d = double.tryParse(val);
                    if (d != null) _latitude = d;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTextField(
                  label: 'தீர்க்கரேகை (Lon)',
                  initialValue: _longitude.toStringAsFixed(4),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) {
                    final d = double.tryParse(val);
                    if (d != null) _longitude = d;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Moon at Sunrise & Question Time & Ascendant
          Row(
            children: [
              Expanded(
                child: _buildControllerTextField(
                  label: 'உதய சந்திரன் பாகை (°)',
                  controller: _moonSunriseLonController,
                  helperText: 'Sunrise Moon (DRM)',
                  onChanged: (_) => _runCalculation(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildControllerTextField(
                  label: 'கேள்வி சந்திரன் பாகை (°)',
                  controller: _moonQuestionLonController,
                  helperText: 'Question Moon',
                  onChanged: (_) => _runCalculation(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildControllerTextField(
                  label: 'லக்னம் பாகை (°)',
                  controller: _ascendantLonController,
                  helperText: 'Ascendant (Lagna)',
                  onChanged: (_) => _runCalculation(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Expandable Planet Longitudes Section
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: Material(
              color: Colors.transparent,
              child: ExpansionTile(
                initiallyExpanded: _isPlanetsExpanded,
                onExpansionChanged: (v) => setState(() => _isPlanetsExpanded = v),
                tilePadding: EdgeInsets.zero,
              title: Text(
                'கிரக பாகை விவரங்கள் (Planet Longitudes)',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGold,
                ),
              ),
              subtitle: Text(
                'சூரியன் முதல் கேது வரை 9 கிரக பாகைகள்',
                style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
              ),
              children: [
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: Planet.values.map((p) {
                    return SizedBox(
                      width: 105,
                      child: _buildControllerTextField(
                        label: kPlanetTamilNames[p] ?? '',
                        controller: _planetControllers[p]!,
                        onChanged: (_) => _runCalculation(),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
          const SizedBox(height: 14),

          // Calculate Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.textDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
              ),
              icon: const Icon(Icons.calculate_rounded, size: 22),
              label: Text(
                'பிரசன்னம் கணிக்க (Calculate)',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _runCalculation,
            ),
          ),
        ],
      ),
    );
  }

  // Error Card
  Widget _buildValidationErrorsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'உள்ளீட்டுப் பிழை (Validation Errors)',
                style: GoogleFonts.outfit(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._validationErrors.map((err) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.redAccent)),
                    Expanded(
                      child: Text(
                        err,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // 13. FINAL RESULT CARD
  Widget _buildFinalResultCard(NakshatraPrasannaResult res) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purpleAccent.withValues(alpha: 0.25),
            AppColors.backgroundMid,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars_rounded, color: AppColors.lightGold, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'நட்சத்திர பிரசன்ன முடிவு',
                    style: GoogleFonts.cinzel(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                  ),
                ],
              ),
              _buildBadge(
                label: NakshatraPrasannaCalculator.timingInterpretation(res.answerPeriod).split(' ')[0],
                color: _getAnswerPeriodColor(res.answerPeriod),
              ),
            ],
          ),
          const Divider(color: AppColors.borderGold, height: 20),

          // Two-column grid of key highlights
          _buildResultRow('கேள்வி Lock நேரம்', DateFormat('dd/MM/yyyy hh:mm a').format(res.lockTime)),
          _buildResultRow('DRM (உதய சந்திரன்)', '${res.drm.nakshatraNameTamil} (${res.drm.lordTamil}) பாதம் ${res.drm.pada}'),
          _buildResultRow('HRM (பிரசன்ன சந்திரன்)', '${res.hrm.planetTamil} (${res.hrm.planetEnglish})'),
          if (res.npl != null)
            _buildResultRow('NPL (பிரசன்ன லக்னம்)', '${res.npl!.rasiTamil} (${res.npl!.bhava}-ம் பாவம்)'),
          if (res.jeevaSareera != null) ...[
            _buildResultRow('ஜீவா', res.jeevaSareera!.jeevaPlanetTamil),
            _buildResultRow('சரீரா', res.jeevaSareera!.sareeraPlanetTamil),
          ],
          _buildResultRow('DRM–HRM தொடர்பு', res.drmHrmRelation.relationTamil),
          if (res.jeevaSareera != null)
            _buildResultRow('ஜீவா–சரீரா தொடர்பு', res.jeevaSareera!.relationTamil),
          _buildResultRow('குணம்', res.guna),
          _buildResultRow('உத்தம திரேக்காணம்', res.uttama.isVargottama ? 'ஆம் (உத்தமம்)' : 'சாதாரணம்'),
          _buildResultRow('நிகழ்வு காலம்', res.timingDescription, isHighlight: true),
        ],
      ),
    );
  }

  // 5. DRM CARD
  Widget _buildDrmCard(NakshatraPrasannaResult res) {
    final drm = res.drm;
    final remTime = DashaTime.fromMinutes(res.drmRemainingMinutes);

    return _buildSectionCard(
      title: 'தின உதய சந்திரன் (DRM)',
      icon: Icons.wb_sunny_rounded,
      child: Column(
        children: [
          _buildDetailRow('நட்சத்திரம்:', '${drm.nakshatraNameTamil} (${drm.nakshatraNameEnglish})'),
          _buildDetailRow('நட்சத்திர அதிபதி:', '${drm.lordTamil} (${drm.lordEnglish})'),
          _buildDetailRow('பாதம்:', '${drm.pada}'),
          _buildDetailRow('சென்ற பாகை:', NakshatraPrasannaCalculator.formatDegreeMinutes(drm.traversedDegrees, includeSeconds: true)),
          _buildDetailRow('மீதமுள்ள பாகை:', NakshatraPrasannaCalculator.formatDegreeMinutes(drm.remainingDegrees, includeSeconds: true)),
          _buildDetailRow('மீதமுள்ள நேரம்:', remTime.toTamilDurationString(), highlightValue: true),
        ],
      ),
    );
  }

  // 6. HRM CARD with expandable Timeline
  Widget _buildHrmCard(NakshatraPrasannaResult res) {
    final hrm = res.hrm;
    final totalDuration = DashaTime.fromMinutes(hrm.totalDurationMinutes);
    final elapsed = DashaTime.fromMinutes(hrm.elapsedMinutes);
    final remaining = DashaTime.fromMinutes(hrm.remainingMinutes);

    return _buildSectionCard(
      title: 'நட்சத்திர பிரசன்ன சந்திரன் (HRM)',
      icon: Icons.dark_mode_rounded,
      child: Column(
        children: [
          _buildDetailRow('HRM கிரகம்:', '${hrm.planetTamil} (${hrm.planetEnglish})', highlightValue: true),
          _buildDetailRow('HRM தொடங்கிய நேரம்:', DateFormat('hh:mm:ss a').format(hrm.startTime)),
          _buildDetailRow('HRM முடியும் நேரம்:', DateFormat('hh:mm:ss a').format(hrm.endTime)),
          _buildDetailRow('HRM மொத்த நேரம்:', totalDuration.toTamilDurationString()),
          _buildDetailRow('கேள்வி நேரத்தில் சென்ற நேரம்:', elapsed.toTamilDurationString()),
          _buildDetailRow('மீதமுள்ள நேரம்:', remaining.toTamilDurationString(), highlightValue: true),
          const SizedBox(height: 12),

          // HRM Dasha Timeline (Expandable)
          InkWell(
            onTap: () => setState(() => _isTimelineExpanded = !_isTimelineExpanded),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timeline_rounded, color: AppColors.lightGold, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'HRM Dasha Timeline (${hrm.timeline.length} காலப்பிரிவுகள்)',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isTimelineExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: AppColors.lightGold,
                  ),
                ],
              ),
            ),
          ),

          if (_isTimelineExpanded) ...[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: hrm.timeline.length,
                separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                itemBuilder: (context, idx) {
                  final seg = hrm.timeline[idx];
                  final segDur = DashaTime.fromMinutes(seg.durationMinutes);
                  return Container(
                    color: seg.isCurrentSegment ? AppColors.primaryGold.withValues(alpha: 0.2) : Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        if (seg.isCurrentSegment) ...[
                          const Icon(Icons.arrow_right_rounded, color: AppColors.primaryGold, size: 20),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${seg.planetTamil} (${seg.planetEnglish})',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: seg.isCurrentSegment ? FontWeight.bold : FontWeight.w500,
                              color: seg.isCurrentSegment ? AppColors.lightGold : Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            '${DateFormat('hh:mm a').format(seg.startTime)} - ${DateFormat('hh:mm a').format(seg.endTime)}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: seg.isCurrentSegment ? AppColors.lightGold : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            segDur.toTamilDurationString(),
                            textAlign: TextAlign.right,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: seg.isCurrentSegment ? AppColors.lightGold : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 7. NPL CARD
  Widget _buildNplCard(NakshatraPrasannaResult res) {
    final npl = res.npl;
    return _buildSectionCard(
      title: 'நட்சத்திர பிரசன்ன லக்னம் (NPL)',
      icon: Icons.explore_rounded,
      child: npl == null
          ? const Text('லக்ன தகவல்கள் கிடைக்கவில்லை.', style: TextStyle(color: Colors.white70))
          : Column(
              children: [
                _buildDetailRow('பிரசன்ன நட்சத்திர அதிபதி:', '${npl.hrmPlanetTamil} (${kPlanetEnglishNames[npl.hrmPlanet]})'),
                _buildDetailRow('அவர் இருக்கும் ராசி:', '${npl.rasiTamil} (${npl.rasiEnglish})'),
                _buildDetailRow('அவர் இருக்கும் பாவம்:', '${npl.bhava}-ம் பாவம் (${npl.bhava}th House)', highlightValue: true),
                _buildDetailRow('கிரக பாகை:', NakshatraPrasannaCalculator.formatDegreeMinutes(npl.planetLongitude, includeSeconds: true)),
              ],
            ),
    );
  }

  // 8. JEEVA / SAREERA CARD
  Widget _buildJeevaSareeraCard(NakshatraPrasannaResult res) {
    final js = res.jeevaSareera;
    return _buildSectionCard(
      title: 'ஜீவா – சரீரா',
      icon: Icons.accessibility_new_rounded,
      child: js == null
          ? const Text('கிரக பாகை தகவல்கள் முழுமையாக இல்லை.', style: TextStyle(color: Colors.white70))
          : Column(
              children: [
                _buildDetailRow('Source Planet:', '${js.sourcePlanetTamil} (${kPlanetEnglishNames[js.sourcePlanet]})'),
                _buildDetailRow('ஜீவா:', '${js.jeevaPlanetTamil} (${kPlanetEnglishNames[js.jeevaPlanet]})'),
                _buildDetailRow('சரீரா:', '${js.sareeraPlanetTamil} (${kPlanetEnglishNames[js.sareeraPlanet]})'),
                _buildDetailRow('தொடர்பு:', js.relationTamil, highlightValue: true),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    js.relationDescription,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                  ),
                ),
              ],
            ),
    );
  }

  // 9. GUNA CARD
  Widget _buildGunaCard(NakshatraPrasannaResult res) {
    Color gunaColor = Colors.greenAccent;
    if (res.guna == 'ராஜசம்') gunaColor = Colors.orangeAccent;
    if (res.guna == 'தாமசம்') gunaColor = Colors.redAccent;

    return _buildSectionCard(
      title: 'குணம் (Guna)',
      icon: Icons.psychology_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'குணம்:',
                style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary),
              ),
              _buildBadge(label: res.guna, color: gunaColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            res.guna == 'சாத்வீகம்'
                ? 'சாத்வீக குணம்: காரிய வெற்றி, அமைதி, தர்ம சிந்தனை மற்றும் உடனடி சுப பலன்களைக் குறிக்கிறது.'
                : (res.guna == 'ராஜசம்'
                    ? 'ராஜச குணம்: வேகமான முயற்சி, அதிகார ஈடுபாடு மற்றும் சராசரி வேகத்தில் கைகூடும் காரியத்தைக் குறிக்கிறது.'
                    : 'தாமச குணம்: மந்தநிலை, தாமதம் மற்றும் கூடுதல் பொறுமையுடன் காரியத்தை முன்னெடுக்க வேண்டிய நிலையை உணர்த்துகிறது.'),
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // 10. UTTAMA DREKKANA CARD (Expandable)
  Widget _buildUttamaCard(NakshatraPrasannaResult res) {
    final ut = res.uttama;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isUttamaExpanded = !_isUttamaExpanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.military_tech_rounded, color: AppColors.primaryGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'உத்தம திரேக்காணம் (Optional)',
                      style: GoogleFonts.cinzel(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _isUttamaExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: AppColors.lightGold,
                ),
              ],
            ),
          ),
          if (_isUttamaExpanded) ...[
            const Divider(color: Colors.white12, height: 16),
            _buildDetailRow('வர்க்கோத்தமம்:', ut.isVargottama ? 'ஆம் (உத்தம வர்க்கோத்தமம்)' : 'இல்லை'),
            _buildDetailRow('பரிவர்த்தனம்:', ut.isParivarthana ? 'ஆம்' : 'இல்லை'),
            _buildDetailRow('விளக்கம்:', ut.summary, highlightValue: ut.isVargottama),
            if (ut.vargottamaDescription.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ut.vargottamaDescription,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // 11. DRM–HRM RELATIONSHIP CARD
  Widget _buildDrmHrmRelationCard(NakshatraPrasannaResult res) {
    final rel = res.drmHrmRelation;
    return _buildSectionCard(
      title: 'DRM – HRM தொடர்பு',
      icon: Icons.compare_arrows_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('தொடர்பு:', rel.relationTamil, highlightValue: true),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              rel.explanation,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // 12. EVENT TIMING CARD
  Widget _buildEventTimingCard(NakshatraPrasannaResult res) {
    final color = _getAnswerPeriodColor(res.answerPeriod);
    return _buildSectionCard(
      title: 'நிகழ்வு காலக் கணிப்பு',
      icon: Icons.hourglass_full_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'கால அவகாசம்:',
                style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary),
              ),
              _buildBadge(label: _getAnswerPeriodTamil(res.answerPeriod), color: color),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              res.timingDescription,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Card Builder
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cinzel(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 16),
          child,
        ],
      ),
    );
  }

  // Row builder for detail cards
  Widget _buildDetailRow(String label, String value, {bool highlightValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: highlightValue ? FontWeight.bold : FontWeight.w500,
                color: highlightValue ? AppColors.primaryGold : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                color: isHighlight ? AppColors.lightGold : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryGold, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary),
                ),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      style: GoogleFonts.outfit(fontSize: 13, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white12),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildControllerTextField({
    required String label,
    required TextEditingController controller,
    String? helperText,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: GoogleFonts.outfit(fontSize: 13, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
        helperText: helperText,
        helperStyle: GoogleFonts.outfit(fontSize: 9, color: Colors.white38),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white12),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getAnswerPeriodColor(AnswerPeriod period) {
    switch (period) {
      case AnswerPeriod.sameDay:
        return Colors.greenAccent;
      case AnswerPeriod.withinOneMonth:
        return Colors.lightGreenAccent;
      case AnswerPeriod.oneToTwoMonths:
        return Colors.amberAccent;
      case AnswerPeriod.delayed:
        return Colors.orangeAccent;
    }
  }

  String _getAnswerPeriodTamil(AnswerPeriod period) {
    switch (period) {
      case AnswerPeriod.sameDay:
        return 'ஒரே நாள்';
      case AnswerPeriod.withinOneMonth:
        return 'ஒரு மாதத்திற்குள்';
      case AnswerPeriod.oneToTwoMonths:
        return '1 அல்லது 2 மாதங்கள்';
      case AnswerPeriod.delayed:
        return 'தாமதம்';
    }
  }
}
