import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/geocoding_service.dart';
import '../../widgets/astro_card.dart';
import '../../widgets/cosmic_background.dart';
import 'dhanishta_panchami_engine.dart';
import 'dhanishta_panchami_models.dart';

/// ===============================================================
/// DHANISHTA PANCHAMI / TITHI ADAIPPU MODULE UI
/// Date + Time + Location Input with Automated Astronomical Calculation
/// ===============================================================

class DhanishtaPanchamiTithiAdaippuModule extends StatefulWidget {
  const DhanishtaPanchamiTithiAdaippuModule({super.key});

  @override
  State<DhanishtaPanchamiTithiAdaippuModule> createState() =>
      _DhanishtaPanchamiTithiAdaippuModuleState();
}

class _DhanishtaPanchamiTithiAdaippuModuleState
    extends State<DhanishtaPanchamiTithiAdaippuModule> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCity = 'Chennai';
  double _latitude = 13.0827;
  double _longitude = 80.2707;
  DhanistaResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  DateTime get _selectedDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  void _calculate() {
    setState(() {
      _result = DhanishtaPanchamiEngine.calculate(
        dateTime: _selectedDateTime,
        place: _selectedCity,
        latitude: _latitude,
        longitude: _longitude,
      );
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGold,
              onPrimary: AppColors.textDark,
              surface: AppColors.backgroundMid,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.backgroundMid,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _calculate();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGold,
              onPrimary: AppColors.textDark,
              surface: AppColors.backgroundMid,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.backgroundMid,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
      _calculate();
    }
  }

  Future<void> _showCityPicker() async {
    final popular = GeocodingService.searchOffline('');
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'இறந்த இடம் தேர்ந்தெடுக்கவும்',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(color: AppColors.borderGold),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: popular.length,
                  itemBuilder: (context, idx) {
                    final loc = popular[idx];
                    final isSelected =
                        loc.cityName.toLowerCase() == _selectedCity.toLowerCase();
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.location_city_rounded,
                        color: isSelected ? AppColors.primaryGold : Colors.white54,
                        size: 20,
                      ),
                      title: Text(
                        loc.displayName,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primaryGold : Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        '${loc.latitude.toStringAsFixed(2)}° N, ${loc.longitude.toStringAsFixed(2)}° E',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primaryGold,
                              size: 18,
                            )
                          : null,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        setState(() {
                          _selectedCity = loc.cityName;
                          _latitude = loc.latitude;
                          _longitude = loc.longitude;
                          _calculate();
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: Text(
          'தனிஷ்டா பஞ்சமி / திதி அடைப்பு',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.backgroundDeep,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primaryGold),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CosmicBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. DATE, TIME & LOCATION INPUT CARD
              AstroCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'தேதி & நேரம்',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(
                              Icons.calendar_month,
                              color: AppColors.lightGold,
                              size: 18,
                            ),
                            label: Text(
                              '${_selectedDate.day.toString().padLeft(2, '0')}/'
                              '${_selectedDate.month.toString().padLeft(2, '0')}/'
                              '${_selectedDate.year}',
                              style: GoogleFonts.outfit(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.borderGold.withValues(alpha: 0.5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(
                              Icons.access_time,
                              color: AppColors.lightGold,
                              size: 18,
                            ),
                            label: Text(
                              _selectedTime.format(context),
                              style: GoogleFonts.outfit(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.borderGold.withValues(alpha: 0.5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Location Picker
                    InkWell(
                      onTap: _showCityPicker,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundMid.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.borderGold.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primaryGold,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'இறந்த இடம்: $_selectedCity (${_latitude.toStringAsFixed(2)}° N, ${_longitude.toStringAsFixed(2)}° E)',
                                style: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  color: AppColors.lightGold,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.lightGold,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _calculate,
                        icon: const Icon(Icons.calculate, color: AppColors.textDark),
                        label: Text(
                          'கணக்கிடுக',
                          style: GoogleFonts.outfit(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              if (r != null) ...[
                // 2. MAIN STATUS BANNER (Matching red warning card in user screenshot)
                _buildMainStatus(r),
                const SizedBox(height: 14),

                // 3. PANCHANGA STATUS
                _buildInfoCard(
                  'பஞ்சாங்க நிலை',
                  Icons.auto_stories,
                  [
                    _buildRow('திதி', r.tithi),
                    _buildRow('திதி எண்', '${r.tithiNumber}'),
                    _buildRow('பக்ஷம்', r.pakshaTamil),
                    _buildRow('நட்சத்திரம்', r.nakshatra),
                    _buildRow('நட்சத்திர எண்', '${r.nakshatraNumber}'),
                    _buildRow('பாதம்', '${r.pada} ஆம் பாதம்'),
                    _buildRow('சந்திரன் நிராயண degree', r.moonLongitudeDms),
                    _buildRow('சூரியன் நிராயண degree', r.sunLongitudeDms),
                  ],
                ),
                const SizedBox(height: 14),

                // 4. DHANISHTA PANCHAMI / PANCHAKA STATUS
                _buildInfoCard(
                  'தனிஷ்டா பஞ்சமி',
                  Icons.stars,
                  [
                    _buildRow(
                      'தனிஷ்டா பஞ்சமி சேர்க்கை',
                      r.isDhanishtaPanchami ? 'ஏற்பட்டுள்ளது' : 'ஏற்படவில்லை',
                      highlightValue: r.isDhanishtaPanchami,
                    ),
                    _buildRow(
                      'பஞ்சக நட்சத்திரமா?',
                      r.isPanchaka ? 'ஆம் (பஞ்சக காலம்)' : 'இல்லை',
                      highlightValue: r.isPanchaka,
                    ),
                    _buildRow(
                      'நிலை',
                      r.statusTamil,
                      highlightValue: r.isAdaippu || r.isPanchaka,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 5. TITHI ADAIPPU & CLOSURE END DATE
                _buildInfoCard(
                  'திதி அடைப்பு & முடிவு தேதி',
                  Icons.hourglass_top,
                  [
                    _buildRow(
                      'அடைப்பு நட்சத்திரமா?',
                      r.isAdaippu ? 'ஆம்' : 'இல்லை',
                      highlightValue: r.isAdaippu,
                    ),
                    _buildRow(
                      'அடைப்பு காலம்',
                      r.closureMonths > 0
                          ? '${r.closureMonths} மாதங்கள்'
                          : 'இல்லை',
                      highlightValue: r.closureMonths > 0,
                    ),
                    _buildRow(
                      'அடைப்பு வகை',
                      r.closureType,
                    ),
                    _buildRow(
                      'அடைப்பு முடிவு தேதி',
                      r.closureEndDate != null
                          ? '${r.closureEndDate!.day.toString().padLeft(2, '0')}/'
                            '${r.closureEndDate!.month.toString().padLeft(2, '0')}/'
                            '${r.closureEndDate!.year}'
                          : 'பொருந்தாது',
                      highlightValue: r.closureEndDate != null,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 6. DETAILED EXPLANATION
                _buildInfoCard(
                  'விளக்கம்',
                  Icons.info_outline,
                  [
                    Text(
                      r.explanation,
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 7. TRADITIONAL REMEDIES (பாரம்பரிய பரிகார வழிமுறைகள்)
                _buildInfoCard(
                  'பாரம்பரிய / சம்பிரதாய வழிமுறைகள்',
                  Icons.shield_outlined,
                  [
                    // Disclaimer Box
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_rounded, color: Colors.amberAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              r.disclaimer,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: Colors.amber.shade200,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Remedies List
                    ...r.remedies.map((remedy) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                color: AppColors.primaryGold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                remedy,
                                style: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Status Banner matching the red warning container in the user screenshot
  Widget _buildMainStatus(DhanistaResult r) {
    final bool hasWarning = r.isAdaippu || r.isPanchaka || r.isDhanishtaPanchami;
    final Color borderColor = hasWarning ? Colors.redAccent : Colors.greenAccent;
    final Color bgColor = hasWarning
        ? const Color(0xFF2A0A0E).withValues(alpha: 0.85)
        : const Color(0xFF0A2A14).withValues(alpha: 0.85);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            hasWarning ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
            color: borderColor,
            size: 38,
          ),
          const SizedBox(height: 8),
          Text(
            'அடைப்பு / தனிஷ்டா பஞ்சமி நிலை',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: borderColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${r.nakshatra} (எண்: ${r.nakshatraNumber}) • ${r.pakshaTamil} ${r.tithi}',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: hasWarning
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.green.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor.withValues(alpha: 0.6)),
            ),
            child: Text(
              r.closureType,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return AstroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.borderGold, height: 1),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool highlightValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: highlightValue ? Colors.amberAccent : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Screen alias for architectural consistency
typedef DhanistaPanchamiScreen = DhanishtaPanchamiTithiAdaippuModule;
