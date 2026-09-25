import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/astro_card.dart';
import '../../widgets/cosmic_background.dart';
import 'dhanishta_panchami_calculator.dart';
import 'dhanishta_panchami_models.dart';

/// ===============================================================
/// DHANISHTA PANCHAMI / TITHI ADAIPPU MODULE UI
/// Date + Time Input
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
  TithiResult? _result;

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
      _result = DhanishtaCalculator.calculate(_selectedDateTime);
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

  @override
  Widget build(BuildContext context) {
    final r = _result;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: const Text(
          'தனிஷ்டா பஞ்சமி / திதி அடைப்பு',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.backgroundDeep,
        elevation: 0,
        centerTitle: true,
      ),
      body: CosmicBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. DATE & TIME INPUT CARD
              AstroCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'தேதி & நேரம்',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGold,
                      ),
                    ),
                    const SizedBox(height: 14),
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
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
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
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _calculate,
                        icon: const Icon(Icons.calculate, color: AppColors.textDark),
                        label: const Text(
                          'கணக்கிடுக',
                          style: TextStyle(
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

              const SizedBox(height: 16),

              if (r != null) ...[
                // 2. MAIN STATUS BANNER
                _buildMainStatus(r),
                const SizedBox(height: 14),

                // 3. PANCHANGA STATUS
                _buildInfoCard(
                  'பஞ்சாங்க நிலை',
                  Icons.auto_stories,
                  [
                    _buildRow('திதி', r.tithiTamil),
                    _buildRow('திதி எண்', '${r.tithiNumber}'),
                    _buildRow('பக்ஷம்', r.pakshaTamil),
                    _buildRow('நட்சத்திரம்', r.nakshatraTamil),
                    _buildRow('நட்சத்திர எண்', '${r.nakshatraNumber}'),
                  ],
                ),
                const SizedBox(height: 14),

                // 4. DHANISHTA PANCHAMI
                _buildInfoCard(
                  'தனிஷ்டா பஞ்சமி',
                  Icons.stars,
                  [
                    _buildRow(
                      'நிலை',
                      r.isDhanishtaPanchami ? 'ஏற்பட்டுள்ளது' : 'ஏற்படவில்லை',
                      highlightValue: r.isDhanishtaPanchami,
                    ),
                    _buildRow(
                      'விளக்கம்',
                      r.isDhanishtaPanchami
                          ? 'அவிட்டம் (23) + பஞ்சமி சேர்க்கை'
                          : 'அவிட்டம் + பஞ்சமி சேர்க்கை இல்லை',
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 5. TITHI ADAIPPU
                _buildInfoCard(
                  'திதி அடைப்பு',
                  Icons.hourglass_top,
                  [
                    _buildRow(
                      'அடைப்பு நட்சத்திரமா?',
                      r.isAdaippuNakshatra ? 'ஆம்' : 'இல்லை',
                      highlightValue: r.isAdaippuNakshatra,
                    ),
                    _buildRow(
                      'அடைப்பு காலம்',
                      r.adaippuMonths > 0
                          ? '${r.adaippuMonths} மாதங்கள்'
                          : 'இல்லை',
                      highlightValue: r.adaippuMonths > 0,
                    ),
                    _buildRow(
                      'அடைப்பு வகை',
                      r.adaippuType,
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 7. REMEDY NOTE
                _buildInfoCard(
                  'பரிகார குறிப்பு',
                  Icons.shield_outlined,
                  [
                    Text(
                      r.remedy,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainStatus(TithiResult r) {
    final bool active = r.isDhanishtaPanchami || r.isAdaippuNakshatra;
    final Color bannerColor =
        active ? const Color(0xFFEF4444) : const Color(0xFF10B981);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bannerColor, width: 1.4),
      ),
      child: Column(
        children: [
          Icon(
            active ? Icons.warning_amber_rounded : Icons.check_circle,
            color: bannerColor,
            size: 48,
          ),
          const SizedBox(height: 10),
          Text(
            active
                ? 'அடைப்பு / தனிஷ்டா பஞ்சமி நிலை'
                : 'அடைப்பு இல்லை (சுபம்)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: bannerColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${r.nakshatraTamil} (எண்: ${r.nakshatraNumber}) • ${r.pakshaTamil} ${r.tithiTamil}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.5,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (active) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: bannerColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                r.isDhanishtaPanchami
                    ? 'தனிஷ்டா பஞ்சமி (${r.adaippuType})'
                    : r.adaippuType,
                style: TextStyle(
                  color: bannerColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
              Icon(icon, color: AppColors.primaryGold, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value, {bool highlightValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.lightGold,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(
                color: highlightValue
                    ? const Color(0xFFEF4444)
                    : AppColors.textPrimary,
                fontWeight: highlightValue ? FontWeight.bold : FontWeight.w500,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
