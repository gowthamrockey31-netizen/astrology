import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/numerology_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/numerology_calculator.dart';
import '../../widgets/cosmic_background.dart';

/// New Major Module 6: Numerology (எண்கணிதம்) Screen
class NumerologyScreen extends StatefulWidget {
  const NumerologyScreen({super.key});

  @override
  State<NumerologyScreen> createState() => _NumerologyScreenState();
}

class _NumerologyScreenState extends State<NumerologyScreen> {
  late TextEditingController _nameCtrl;
  DateTime _birthDate = DateTime(1996, 6, 15);
  NumerologySystem _system = NumerologySystem.chaldean;
  late NumerologyResult _result;

  @override
  void initState() {
    super.initState();
    final u = AuthService.currentUser;
    _nameCtrl = TextEditingController(text: u?.name.isNotEmpty == true ? u!.name : 'GOWTHAM');
    if (u != null) {
      _birthDate = DateTime.tryParse(u.dob) ?? DateTime(1996, 6, 15);
    }
    _recalculate();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _recalculate() {
    _result = NumerologyCalculator.calculate(
      birthDate: _birthDate,
      name: _nameCtrl.text.trim(),
      system: _system,
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGold,
              onPrimary: Colors.black,
              surface: AppColors.backgroundMid,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _recalculate();
      });
    }
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
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'எண்கணிதம் (Numerology)',
                            style: GoogleFonts.cinzel(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Birth Number, Life Path & Name Vibrations',
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fade(duration: 400.ms),

                const SizedBox(height: 14),

                // Input Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _nameCtrl,
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'பெயர் (Name in English)',
                          labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
                          prefixIcon: const Icon(Icons.badge_rounded, color: AppColors.lightGold, size: 18),
                          filled: true,
                          fillColor: AppColors.backgroundMid,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (_) => setState(() => _recalculate()),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickDate,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundMid,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, color: AppColors.lightGold, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'DOB: ${_birthDate.day}-${_birthDate.month}-${_birthDate.year}',
                                      style: GoogleFonts.outfit(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<NumerologySystem>(
                              value: _system,
                              dropdownColor: AppColors.backgroundDeep,
                              items: NumerologySystem.values.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(s == NumerologySystem.chaldean ? 'Chaldean' : 'Pythagorean',
                                      style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 12, fontWeight: FontWeight.bold)),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() {
                                    _system = v;
                                    _recalculate();
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3 Core Numbers Banner
                Row(
                  children: [
                    Expanded(child: _buildNumberCard('பிறவி எண் (Birth No)', '${_result.birthNumber}', _result.birthNumberLordTa, Colors.amberAccent)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberCard('விதி எண் (Destiny No)', '${_result.lifePathNumber}', _result.lifePathLordTa, Colors.cyanAccent)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberCard('பெயர் எண் (Name No)', '${_result.nameNumber} (${_result.nameCompoundNumber})', _result.nameNumberLordTa, Colors.greenAccent)),
                  ],
                ),
                const SizedBox(height: 16),

                // Traits Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('எண்கணித பண்புகள் & ஆளுமை', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13)),
                      const Divider(color: AppColors.borderGold, height: 16),
                      Text('பிறவி எண் ${_result.birthNumber} பண்பு: ${_result.birthNumberTraitTa}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text('விதி எண் ${_result.lifePathNumber} வழிகாட்டுதல்: ${_result.lifePathTraitTa}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Compatibility Numbers
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundMid,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('எண் பொருத்தம் & அதிர்ஷ்ட குறிப்புகள்', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13)),
                      const Divider(color: AppColors.borderGold, height: 16),
                      Text('நட்பு எண்கள் (Friendly): ${_result.friendlyNumbers.join(", ")}', style: GoogleFonts.outfit(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text('எதிரி எண்கள் (Enemy): ${_result.enemyNumbers.join(", ")}', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text('அதிர்ஷ்ட தேதிகள்: ${_result.luckyDates.join(", ")}', style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text('அதிர்ஷ்ட நிறங்கள்: ${_result.luckyColorsTa.join(", ")}', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text('அதிர்ஷ்ட ரத்தினங்கள்: ${_result.luckyGemsTa.join(", ")}', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text('பொருத்தமான தொழில் துறைகள்: ${_result.careerGuidanceTa}', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberCard(String title, String num, String lord, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Text(title, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 9.5, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(num, style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(lord, textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 9.5, color: Colors.white70)),
        ],
      ),
    );
  }
}
