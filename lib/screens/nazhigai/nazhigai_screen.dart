import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/nazhigai_result.dart';
import '../../services/astrology_calculator.dart';
import '../../services/auth_service.dart';
import '../../services/nazhigai_calculator.dart';
import '../../widgets/astro_card.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/golden_button.dart';

class NazhigaiScreen extends StatefulWidget {
  const NazhigaiScreen({super.key});

  @override
  State<NazhigaiScreen> createState() => _NazhigaiScreenState();
}

class _NazhigaiScreenState extends State<NazhigaiScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  double _latitude = 13.0827;
  double _longitude = 80.2707;
  double _timezone = 5.5;
  String _locationName = "Chennai";

  NazhigaiResult? _result;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _recalculate();
  }

  void _loadUserLocation() {
    final user = AuthService.currentUser;
    if (user != null) {
      _latitude = user.latitude;
      _longitude = user.longitude;
      _timezone = user.timezone;
      _locationName = user.city.isNotEmpty ? user.city : "User Location";
      final parsed = DateTime.tryParse(user.dob);
      if (parsed != null) _selectedDate = parsed;
    }
  }

  void _recalculate() {
    final eventDt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final res = NazhigaiCalculator.calculateUdayadhiNazhigaiForLocation(
      eventTime: eventDt,
      latitude: _latitude,
      longitude: _longitude,
      utcOffsetHours: _timezone,
    );

    setState(() {
      _result = res;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _recalculate();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      _recalculate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMMM yyyy');
    final timeFormatter = DateFormat('hh:mm a');
    final dtForFormatter = DateTime(2026, 1, 1, _selectedTime.hour, _selectedTime.minute);

    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryGold, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'உதயாதினாழிகை கணிப்பான்',
                        style: GoogleFonts.cinzel(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Form Pickers Card
                      AstroCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'நிகழ்வு நேரம் & இடம் (Event Time & Location)',
                              style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickDate,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundDeep,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today, color: AppColors.primaryGold, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              dateFormatter.format(_selectedDate),
                                              style: GoogleFonts.outfit(fontSize: 12, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    onTap: _pickTime,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundDeep,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time, color: AppColors.primaryGold, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              timeFormatter.format(dtForFormatter),
                                              style: GoogleFonts.outfit(fontSize: 12, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: AppColors.lightGold, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'இடம்: $_locationName (Lat: $_latitude, Lon: $_longitude)',
                                  style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 16),

                      if (_result != null) ...[
                        // Result Hero Card
                        AstroCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                'உதயாதினாழிகை (Udayadhi Nazhigai)',
                                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _result!.formattedValueTa,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cinzel(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGold,
                                ),
                              ),
                              Text(
                                _result!.formattedValueEn,
                                style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70),
                              ),
                              const SizedBox(height: 16),
                              const Divider(color: Colors.white12),
                              const SizedBox(height: 12),

                              // Grid Breakdown
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text('நாழிகை', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_result!.nazhigai}',
                                          style: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(width: 1, height: 36, color: Colors.white12),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text('விநாழிகை', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_result!.vinazhigai}',
                                          style: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                        const SizedBox(height: 16),

                        // Technical Details Card
                        AstroCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'கணித விவரங்கள் (Calculation Details)',
                                style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                              ),
                              const SizedBox(height: 10),
                              _buildDetailRow('சூரியோதயம் (Sunrise)', DateFormat('hh:mm:ss a').format(_result!.sunriseTime)),
                              _buildDetailRow('நிகழ்வு நேரம் (Event Time)', DateFormat('hh:mm:ss a').format(_result!.eventTime)),
                              _buildDetailRow('மொத்த வினாடிகள் (Elapsed Sec)', '${_result!.totalElapsedSeconds.toStringAsFixed(1)}s'),
                              _buildDetailRow('1 நாழிகை சமம் (Conversion)', '24 நிமிடங்கள் (1440 வினாடிகள்)'),
                              _buildDetailRow('1 விநாழிகை சமம் (Conversion)', '24 வினாடிகள்'),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
          Text(value, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
