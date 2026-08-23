import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/jaathaga_kurippugal_model.dart';
import '../../models/user_model.dart';
import '../../services/astrology_calculator.dart';
import '../../services/auth_service.dart';
import '../../services/jaathaga_kurippugal_calculator.dart';
import '../../services/pdf_generator_service.dart';
import '../../widgets/astro_card.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/south_indian_jathagam_widget.dart';

class JaathagaKurippugalScreen extends StatefulWidget {
  const JaathagaKurippugalScreen({super.key});

  @override
  State<JaathagaKurippugalScreen> createState() => _JaathagaKurippugalScreenState();
}

class _JaathagaKurippugalScreenState extends State<JaathagaKurippugalScreen> {
  late UserModel _user;
  late JaathagaKurippugalResult _notes;
  late Map<String, String> _currentHora;

  @override
  void initState() {
    super.initState();
    _loadUserHoroscope();
  }

  void _loadUserHoroscope() {
    final currentUser = AuthService.currentUser;
    _user = currentUser ??
        UserModel(
          id: 'default_usr',
          name: 'Divine Seeker',
          mobile: '+919876543210',
          gender: 'Male',
          dob: '1996-06-15',
          timeOfBirth: '08:30 AM',
          placeOfBirth: 'Chennai',
          city: 'Chennai',
          state: 'Tamil Nadu',
          country: 'India',
          zodiac: 'Gemini (Mithuna)',
          nakshatra: 'Rohini',
          lagna: 'Mesha',
          walletBalance: 500.0,
          profilePhoto: '',
          latitude: 13.0827,
          longitude: 80.2707,
          timezone: 5.5,
        );

    _notes = JaathagaKurippugalCalculator.calculateNotes(user: _user);
    _currentHora = AstrologyCalculator.calculateHora(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold),
                    ),
                    Expanded(
                      child: Text(
                        'ஜாதக குறிப்புகள்',
                        style: GoogleFonts.cinzel(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderGold),
                      ),
                      child: Text(
                        'Horoscope Notes',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                    ),
                  ],
                ).animate().fade(duration: 400.ms),

                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    'பிறப்பு விவரங்கள் • பஞ்சாங்கம் • நட்சத்திர குணங்கள் • நாழிகை கணக்குகள்',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ).animate().fade(delay: 100.ms),

                const SizedBox(height: 18),

                // 1. Birth Profile Header Card
                _buildSummaryHeaderCard().animate().fade(delay: 150.ms),

                const SizedBox(height: 16),

                // 2. Birth Details Section
                _buildSectionCard(
                  title: 'பிறப்பு விவரங்கள்',
                  icon: Icons.person_rounded,
                  rows: [
                    _InfoRow('ஜாதகர் பெயர்', _notes.personName),
                    _InfoRow('பாலினம்', _notes.gender),
                    _InfoRow('வயது', _notes.age),
                    _InfoRow('பிறந்த ஆங்கில தேதி', _notes.englishDate),
                    _InfoRow('தமிழ் தேதி', _notes.tamilDate),
                    _InfoRow('கிழமை', _notes.weekday),
                    _InfoRow('பிறந்த நேரம்', _notes.timeOfBirth),
                    _InfoRow('பிறந்த இடம்', _notes.placeOfBirth),
                  ],
                ).animate().fade(delay: 200.ms),

                const SizedBox(height: 16),

                // 3. Panchangam Details Section
                _buildSectionCard(
                  title: 'பஞ்சாங்க விவரங்கள் (Birth Panchangam)',
                  icon: Icons.calendar_today_rounded,
                  rows: [
                    _InfoRow('லக்னம்', '${_notes.lagna} (${_notes.lagnaDegree})'),
                    _InfoRow('ராசி', _notes.rasi),
                    _InfoRow('நட்சத்திரம்', '${_notes.nakshatra} (${_notes.pada})'),
                    _InfoRow('நட்சத்திர நாதன்', _notes.starLord),
                    _InfoRow('திதி', '${_notes.paksha} ${_notes.thithi}'),
                    _InfoRow('யோகம்', _notes.yoga),
                    _InfoRow('கரணம்', _notes.karanam),
                    _InfoRow('அமிர்தாதி யோகம்', _notes.amirthathiYoga),
                    _InfoRow('முக்குண வேளை', _notes.mukkunaVelai),
                  ],
                ).animate().fade(delay: 250.ms),

                const SizedBox(height: 16),

                // 4. Sun Timings Section
                _buildSectionCard(
                  title: 'சூரிய நேரங்கள்',
                  icon: Icons.wb_sunny_rounded,
                  rows: [
                    _InfoRow('சூரிய உதயம்', _notes.sunrise),
                    _InfoRow('சூரிய அஸ்தமனம்', _notes.sunset),
                  ],
                ).animate().fade(delay: 300.ms),

                const SizedBox(height: 16),

                // 5. Special Astrology Details Section
                _buildSectionCard(
                  title: 'ஜோதிட சிறப்பு விவரங்கள்',
                  icon: Icons.auto_awesome_rounded,
                  rows: [
                    _InfoRow('திதி சூன்ய ராசிகள்', _notes.thithiSunyam),
                    _InfoRow('நாம எழுத்துக்கள்', _notes.nameLetters),
                    _InfoRow('அவ யோகி', _notes.avaYogi),
                    _InfoRow('அனு யோகி', _notes.anuYogi),
                    _InfoRow('கணம்', _notes.gana),
                    _InfoRow('யோனி', _notes.yoni),
                    _InfoRow('ரஜ்ஜு', _notes.rajju),
                    _InfoRow('பறவை', _notes.bird),
                    _InfoRow('மரம்', _notes.tree),
                    _InfoRow('மரம் வகை', _notes.treeType),
                  ],
                ).animate().fade(delay: 350.ms),

                const SizedBox(height: 16),

                // 6. Nazhigai Metrics & Hora Section
                _buildSectionCard(
                  title: 'நாழிகை கணக்குகள் & ஓரை',
                  icon: Icons.access_time_filled_rounded,
                  rows: [
                    _InfoRow('உதயாதி நாழிகை', _notes.udayathiNazhi),
                    _InfoRow('நட்சத்திர செல்லாகி நின்ற நாழிகை', _notes.nakshatraNazhi),
                    _InfoRow('பிறந்த நேர ஓரை (Birth Hora)', _notes.hora),
                    _InfoRow('தற்போதைய ஓரை (Current Hora)', '${_currentHora['ta']} (${_currentHora['en']})'),
                  ],
                ).animate().fade(delay: 400.ms),

                const SizedBox(height: 16),

                // 7. Akas, Nendhiram, Jeevan Section
                _buildSectionCard(
                  title: 'அகஸ் / நேந்திரம் / ஜீவன்',
                  icon: Icons.remove_red_eye_rounded,
                  rows: [
                    _InfoRow('அகஸ் (பகல் அளவு)', _notes.akas),
                    _InfoRow('நேந்திரம்', _notes.nendhiram),
                    _InfoRow('ஜீவன்', _notes.jeevan),
                  ],
                ).animate().fade(delay: 450.ms),

                const SizedBox(height: 20),

                // 8. South Indian Rasi Chart D1
                AstroCard(
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.grid_view_rounded, color: AppColors.primaryGold, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'ஜாதக ராசி சக்கரம் (Rasi Chart)',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightGold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SouthIndianJathagamWidget(user: _user),
                      ],
                    ),
                  ),
                ).animate().fade(delay: 500.ms),

                const SizedBox(height: 16),

                // 9. Quick Actions for Hora, Nazhigai, Longevity
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        title: 'நேரலை ஓரை',
                        icon: Icons.access_time_filled_rounded,
                        onTap: () => Navigator.pushNamed(context, '/hora'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        title: 'நாழிகை கணிப்பான்',
                        icon: Icons.timer_rounded,
                        onTap: () => Navigator.pushNamed(context, '/nazhigai'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  title: 'ஆயுள் கணிதம் (Pindayu Longevity)',
                  icon: Icons.health_and_safety_rounded,
                  onTap: () => Navigator.pushNamed(context, '/longevity'),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeaderCard() {
    return AstroCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGold.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.borderGold, width: 1.5),
                  ),
                  child: const Icon(Icons.stars_rounded, color: AppColors.lightGold, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _notes.personName,
                        style: GoogleFonts.cinzel(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'லக்னம்: ${_notes.lagna} • ராசி: ${_notes.rasi}',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                      ),
                      Text(
                        'நட்சத்திரம்: ${_notes.nakshatra} (${_notes.pada})',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'ஜாதகம் PDF உருவாகிறது... (Generating PDF...)',
                      style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.primaryGold,
                    duration: const Duration(seconds: 2),
                  ),
                );
                await PdfGeneratorService.downloadOrPrintPdf(user: _user);
              },
              icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.black, size: 18),
              label: Text(
                'ஜாதகம் PDF பதிவிறக்கம் (DOWNLOAD PDF)',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size.fromHeight(42),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.lightGold, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<_InfoRow> rows,
  }) {
    return AstroCard(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryGold, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 8),
            ...rows.map((r) => _buildDetailRow(r.label, r.value)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            ': ',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGold,
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String label;
  final String value;

  _InfoRow(this.label, this.value);
}
