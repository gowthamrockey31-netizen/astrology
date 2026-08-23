import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/hora_result.dart';
import '../../services/auth_service.dart';
import '../../services/hora_calculator.dart';
import '../../widgets/astro_card.dart';
import '../../widgets/cosmic_background.dart';

class LiveHoraScreen extends StatefulWidget {
  const LiveHoraScreen({super.key});

  @override
  State<LiveHoraScreen> createState() => _LiveHoraScreenState();
}

class _LiveHoraScreenState extends State<LiveHoraScreen> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  double _latitude = 13.0827; // Chennai default
  double _longitude = 80.2707;
  double _timezone = 5.5;
  String _locationName = "Chennai, Tamil Nadu";

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  void _loadUserLocation() {
    final user = AuthService.currentUser;
    if (user != null) {
      _latitude = user.latitude;
      _longitude = user.longitude;
      _timezone = user.timezone;
      _locationName = user.city.isNotEmpty ? "${user.city}, ${user.state}" : "User Location";
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hora = HoraCalculator.calculateHora(
      targetTime: _now,
      latitude: _latitude,
      longitude: _longitude,
      utcOffsetHours: _timezone,
    );

    final fullSchedule = HoraCalculator.getFullDayHoraSchedule(
      date: _now,
      latitude: _latitude,
      longitude: _longitude,
      utcOffsetHours: _timezone,
    );

    final timeFormatter = DateFormat('hh:mm:ss a');
    final dateFormatter = DateFormat('EEEE, dd MMMM yyyy');
    final horaTimeFormatter = DateFormat('hh:mm a');

    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom Bar
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
                        'நேரலை ஓரை (Live Hora)',
                        style: GoogleFonts.cinzel(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ).animate(onPlay: (c) => c.repeat()).fade(duration: 800.ms),
                          const SizedBox(width: 6),
                          Text(
                            'LIVE',
                            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
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
                      // Clock & Date Header Card
                      AstroCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              timeFormatter.format(_now),
                              style: GoogleFonts.cinzel(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormatter.format(_now),
                              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on, color: AppColors.lightGold, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _locationName,
                                  style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 16),

                      // Current Hora Hero Card
                      AstroCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    'ஓரை #${hora.horaNumber}',
                                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: hora.isDaytime ? Colors.amber.shade900.withValues(alpha: 0.4) : Colors.indigo.shade900.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: hora.isDaytime ? Colors.amber : Colors.indigoAccent),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        hora.isDaytime ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                                        size: 14,
                                        color: hora.isDaytime ? Colors.amber : Colors.indigoAccent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        hora.isDaytime ? 'பகல் (Day)' : 'இரவு (Night)',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: hora.isDaytime ? Colors.amber : Colors.indigoAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Planetary Icon Avatar
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: AppColors.primaryGold.withValues(alpha: 0.2),
                              child: Text(
                                hora.currentHoraSymbol,
                                style: GoogleFonts.cinzel(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryGold),
                              ),
                            ),
                            const SizedBox(height: 10),

                            Text(
                              '${hora.currentHoraNameTa} ஓரை',
                              style: GoogleFonts.cinzel(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightGold,
                              ),
                            ),
                            Text(
                              '${hora.currentHoraNameEn} Hora',
                              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),

                            // Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: hora.progressRatio,
                                minHeight: 8,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('தொடக்கம் (Start)', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                                    Text(horaTimeFormatter.format(hora.horaStartTime), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('மீதமுள்ள நேரம்', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                                    Text(hora.remainingFormatted, style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('முடிவு (End)', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary)),
                                    Text(horaTimeFormatter.format(hora.horaEndTime), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                      const SizedBox(height: 16),

                      // Next Hora Summary Card
                      AstroCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(Icons.skip_next_rounded, color: AppColors.lightGold, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'அடுத்த ஓரை (Next Hora)',
                                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    '${hora.nextHoraNameTa} (${hora.nextHoraNameEn} Hora)',
                                    style: GoogleFonts.cinzel(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Day Schedule Header
                      Row(
                        children: [
                          const Icon(Icons.schedule, color: AppColors.lightGold, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'இன்றைய 24 ஓரை அட்டவணை',
                            style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Schedule List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: fullSchedule.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final item = fullSchedule[index];
                          final isActive = index + 1 == hora.horaNumber && item.isDaytime == hora.isDaytime;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primaryGold.withValues(alpha: 0.25)
                                  : AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isActive ? AppColors.primaryGold : Colors.white10,
                                width: isActive ? 1.5 : 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isActive ? AppColors.primaryGold : Colors.white.withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${item.horaNumber}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isActive ? Colors.black : Colors.white70,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  item.isDaytime ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
                                  size: 16,
                                  color: item.isDaytime ? Colors.amber : Colors.indigoAccent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${item.currentHoraNameTa} (${item.currentHoraNameEn})',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                      color: isActive ? AppColors.lightGold : Colors.white70,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${horaTimeFormatter.format(item.horaStartTime)} - ${horaTimeFormatter.format(item.horaEndTime)}',
                                  style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
}
