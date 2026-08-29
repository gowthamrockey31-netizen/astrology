import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/numerology_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/numerology_calculator.dart';
import '../../widgets/cosmic_background.dart';

/// Enhanced Numerology (எண்கணிதம்) Screen
class NumerologyScreen extends StatefulWidget {
  const NumerologyScreen({super.key});

  @override
  State<NumerologyScreen> createState() => _NumerologyScreenState();
}

class _NumerologyScreenState extends State<NumerologyScreen> {
  late TextEditingController _nameCtrl;
  DateTime _birthDate = DateTime(1996, 6, 15);
  NumerologySystem _system = NumerologySystem.chaldean;
  
  // Target date for Personal Cycles
  late int _targetYear;
  late int _targetMonth;
  late int _targetDay;

  late NumerologyResult _result;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _targetYear = now.year;
    _targetMonth = now.month;
    _targetDay = now.day;

    final u = AuthService.currentUser;
    _nameCtrl = TextEditingController(
      text: (u?.name.isNotEmpty == true) ? u!.name : 'GOWTHAM',
    );
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
      targetYear: _targetYear,
      targetMonth: _targetMonth,
      targetDay: _targetDay,
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

  void _showNumberDetailSheet({
    required String title,
    required String source,
    required int compoundNumber,
    required int reducedNumber,
    required String lord,
    required String trait,
    required String steps,
    String? additionalNote,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundDeep,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderGold.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryGold, AppColors.darkGold],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$reducedNumber',
                    style: GoogleFonts.cinzel(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cinzel(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                      Text(
                        'கணக்கீட்டு மூலம்: $source',
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
            const Divider(color: AppColors.borderGold, height: 24),
            _buildDetailRow('கூட்டு எண் (Compound No)', '$compoundNumber'),
            _buildDetailRow('மூல எண் (Reduced No)', '$reducedNumber'),
            _buildDetailRow('கிரக அதிபதி (Planet Lord)', lord),
            _buildDetailRow('கணக்கீட்டு முறை (Calculation)', steps),
            _buildDetailRow('பயன்படுத்தப்பட்ட முறை', _system.labelTa),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'பண்புகள் & குறிப்பு:',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trait,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                  ),
                  if (additionalNote != null && additionalNote.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      additionalNote,
                      style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('சரி (Close)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const Text(': ', style: TextStyle(color: AppColors.borderGold)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
                            'Birth, Life Path, Name, Personal Cycles & Compound Vibrations',
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fade(duration: 400.ms),

                const SizedBox(height: 14),

                // Input & Settings Card
                _buildInputCard(),

                const SizedBox(height: 16),

                // 1. Numerology Summary Card (Section E)
                _buildSummarySection(),

                const SizedBox(height: 16),

                // 2. Birth Date Numerology (Section A)
                _buildBirthDateSection(),

                const SizedBox(height: 16),

                // 3. Personal Cycles (Section A - Personal Year/Month/Day)
                _buildPersonalCyclesSection(),

                const SizedBox(height: 16),

                // 4. Name Numerology & Letter Breakdown (Section B)
                _buildNameNumerologySection(),

                const SizedBox(height: 16),

                // 5. Compound Number Details (Section C)
                _buildCompoundDetailsSection(),

                const SizedBox(height: 16),

                // 6. Number Compatibility & Lucky Attributes (Section F & G)
                _buildCompatibilityAndGuidanceSection(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
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
                          'DOB: ${_birthDate.day.toString().padLeft(2, '0')}-${_birthDate.month.toString().padLeft(2, '0')}-${_birthDate.year}',
                          style: GoogleFonts.outfit(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundMid,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<NumerologySystem>(
                    value: _system,
                    dropdownColor: AppColors.backgroundDeep,
                    items: NumerologySystem.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(
                          s == NumerologySystem.chaldean ? 'Chaldean' : 'Pythagorean',
                          style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.6)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardSurface,
            AppColors.backgroundMid.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'எண் கணித சுருக்கம் (Summary)',
                style: GoogleFonts.cinzel(
                  color: AppColors.lightGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                'தட்டினால் கூடுதல் விவரம்',
                style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
          const Divider(color: AppColors.borderGold, height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSummaryBadge(
                  title: 'பிறந்த எண்\n(Birth No)',
                  numStr: '${_result.birthNumber}',
                  compoundStr: _result.birthCompoundNumber > 9 ? '${_result.birthCompoundNumber}' : null,
                  lord: _result.birthNumberLordTa,
                  color: Colors.amberAccent,
                  onTap: () => _showNumberDetailSheet(
                    title: 'பிறந்த எண் (Birth Number)',
                    source: 'பிறந்த நாள் (${_birthDate.day})',
                    compoundNumber: _result.birthCompoundNumber,
                    reducedNumber: _result.birthNumber,
                    lord: _result.birthNumberLordTa,
                    trait: _result.birthNumberTraitTa,
                    steps: '${_birthDate.day} -> ${_result.birthNumber}',
                  ),
                ),
                const SizedBox(width: 8),
                _buildSummaryBadge(
                  title: 'வாழ்க்கைப் பாதை\n(Life Path)',
                  numStr: '${_result.lifePathNumber}',
                  compoundStr: '${_result.lifePathCompoundNumber}',
                  lord: _result.lifePathLordTa,
                  color: Colors.cyanAccent,
                  onTap: () => _showNumberDetailSheet(
                    title: 'வாழ்க்கைப் பாதை எண் (Life Path / Destiny)',
                    source: 'முழு பிறந்த தேதி (${_birthDate.day}-${_birthDate.month}-${_birthDate.year})',
                    compoundNumber: _result.lifePathCompoundNumber,
                    reducedNumber: _result.lifePathNumber,
                    lord: _result.lifePathLordTa,
                    trait: _result.lifePathTraitTa,
                    steps: '${_birthDate.day} + ${_birthDate.month} + ${_birthDate.year} = ${_birthDate.day + _birthDate.month + _birthDate.year} -> ${_result.lifePathCompoundNumber} -> ${_result.lifePathNumber}',
                  ),
                ),
                const SizedBox(width: 8),
                _buildSummaryBadge(
                  title: 'அணுகுமுறை\n(Attitude No)',
                  numStr: '${_result.attitudeNumber}',
                  compoundStr: (_birthDate.day + _birthDate.month) > 9 ? '${_birthDate.day + _birthDate.month}' : null,
                  lord: _result.attitudeLordTa,
                  color: Colors.orangeAccent,
                  onTap: () => _showNumberDetailSheet(
                    title: 'அணுகுமுறை எண் (Attitude Number)',
                    source: 'பிறந்த நாள் + மாதம் (${_birthDate.day} + ${_birthDate.month})',
                    compoundNumber: _birthDate.day + _birthDate.month,
                    reducedNumber: _result.attitudeNumber,
                    lord: _result.attitudeLordTa,
                    trait: _result.attitudeTraitTa,
                    steps: '${_birthDate.day} + ${_birthDate.month} = ${_birthDate.day + _birthDate.month} -> ${_result.attitudeNumber}',
                  ),
                ),
                const SizedBox(width: 8),
                _buildSummaryBadge(
                  title: 'பெயர் எண்\n(Name No)',
                  numStr: '${_result.nameNumber}',
                  compoundStr: '${_result.nameCompoundNumber}',
                  lord: _result.nameNumberLordTa,
                  color: Colors.greenAccent,
                  onTap: () => _showNumberDetailSheet(
                    title: 'பெயர் எண் (Name Number)',
                    source: 'பெயரின் எழுத்து மதிப்புகள் (${_result.personName})',
                    compoundNumber: _result.nameCompoundNumber,
                    reducedNumber: _result.nameNumber,
                    lord: _result.nameNumberLordTa,
                    trait: 'பெயர் அதிர்வு: ${_result.nameNumberVibrationTa}',
                    steps: 'எழுத்துக்களின் மொத்தம் = ${_result.nameCompoundNumber} -> ${_result.nameNumber}',
                  ),
                ),
                const SizedBox(width: 8),
                _buildSummaryBadge(
                  title: 'தனிப்பட்ட ஆண்டு\n(Personal Year)',
                  numStr: '${_result.personalCycles.personalYear.reducedValue}',
                  compoundStr: null,
                  lord: _result.personalCycles.targetYear.toString(),
                  color: Colors.purpleAccent,
                  onTap: () => _showNumberDetailSheet(
                    title: 'தனிப்பட்ட ஆண்டு எண் (${_result.personalCycles.targetYear})',
                    source: 'பிறந்த நாள் + மாதம் + $_targetYear',
                    compoundNumber: _result.personalCycles.personalYear.compoundValue,
                    reducedNumber: _result.personalCycles.personalYear.reducedValue,
                    lord: NumerologyCalculator.numberLordsTa[_result.personalCycles.personalYear.reducedValue] ?? '',
                    trait: _result.personalCycles.personalYearDescriptionTa,
                    steps: '${_birthDate.day} + ${_birthDate.month} + $_targetYear = ${_birthDate.day + _birthDate.month + _targetYear} -> ${_result.personalCycles.personalYear.reducedValue}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBadge({
    required String title,
    required String numStr,
    required String? compoundStr,
    required String lord,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 105,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.backgroundDeep,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 9.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  numStr,
                  style: GoogleFonts.cinzel(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (compoundStr != null) ...[
                  const SizedBox(width: 3),
                  Text(
                    '($compoundStr)',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              lord,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(fontSize: 9, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthDateSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cake_rounded, color: AppColors.primaryGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'பிறந்த தேதி கணிதம் (Birth Date Numerology)',
                style: GoogleFonts.cinzel(
                  color: AppColors.lightGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.borderGold, height: 16),
          _buildCalculationItem(
            label: 'பிறந்த எண் (Birth Number / Janmank)',
            formula: 'பிறந்த நாள் ${_birthDate.day} ${_birthDate.day > 9 ? '-> ${_birthDate.day ~/ 10} + ${_birthDate.day % 10} = ${_result.birthNumber}' : ''}',
            resultDisplay: _result.birthReduction.displayFormatted,
            lord: _result.birthNumberLordTa,
            trait: _result.birthNumberTraitTa,
            color: Colors.amberAccent,
          ),
          const SizedBox(height: 10),
          _buildCalculationItem(
            label: 'வாழ்க்கைப் பாதை எண் (Life Path / Destiny)',
            formula: 'நாள்(${_birthDate.day}) + மாதம்(${_birthDate.month}) + வருடம்(${_birthDate.year}) = ${_birthDate.day + _birthDate.month + _birthDate.year} -> கூட்டு எண் ${_result.lifePathCompoundNumber} -> மூல எண் ${_result.lifePathNumber}',
            resultDisplay: _result.lifePathReduction.displayFormatted,
            lord: _result.lifePathLordTa,
            trait: _result.lifePathTraitTa,
            color: Colors.cyanAccent,
          ),
          const SizedBox(height: 10),
          _buildCalculationItem(
            label: 'அணுகுமுறை எண் (Attitude / Sun Number)',
            formula: 'நாள்(${_birthDate.day}) + மாதம்(${_birthDate.month}) = ${_birthDate.day + _birthDate.month} -> மூல எண் ${_result.attitudeNumber}',
            resultDisplay: _result.attitudeReduction.displayFormatted,
            lord: _result.attitudeLordTa,
            trait: _result.attitudeTraitTa,
            color: Colors.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationItem({
    required String label,
    required String formula,
    required String resultDisplay,
    required String lord,
    required String trait,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color),
                ),
                child: Text(
                  resultDisplay,
                  style: GoogleFonts.cinzel(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'கணக்கீடு: $formula',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'அதிபதி: ',
                style: GoogleFonts.outfit(fontSize: 11, color: AppColors.lightGold, fontWeight: FontWeight.bold),
              ),
              Text(
                lord,
                style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            trait,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalCyclesSection() {
    final cycles = _result.personalCycles;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timelapse_rounded, color: AppColors.primaryGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'தனிப்பட்ட கால எண்கள் (Personal Cycles)',
                style: GoogleFonts.cinzel(
                  color: AppColors.lightGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'ஆண்டு, மாதம் மற்றும் தினசரி எண்கணித சுழற்சிகள்',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
          ),
          const Divider(color: AppColors.borderGold, height: 16),
          
          // Year / Month / Day Selectors
          Row(
            children: [
              // Target Year
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundMid,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _targetYear,
                      dropdownColor: AppColors.backgroundDeep,
                      items: List.generate(21, (i) => DateTime.now().year - 5 + i).map((y) {
                        return DropdownMenuItem(
                          value: y,
                          child: Text('$y ஆண்டு', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _targetYear = v;
                            _recalculate();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Target Month
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundMid,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _targetMonth,
                      dropdownColor: AppColors.backgroundDeep,
                      items: List.generate(12, (i) => i + 1).map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text('$m மாதம்', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _targetMonth = v;
                            _recalculate();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Target Day
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundMid,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _targetDay > 28 ? 28 : _targetDay,
                      dropdownColor: AppColors.backgroundDeep,
                      items: List.generate(31, (i) => i + 1).map((d) {
                        return DropdownMenuItem(
                          value: d,
                          child: Text('$d தேதி', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _targetDay = v;
                            _recalculate();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cycle Cards
          _buildCycleRow(
            title: 'தனிப்பட்ட ஆண்டு எண் (Personal Year $_targetYear)',
            numVal: cycles.personalYear.reducedValue,
            formula: 'பிறந்த நாள்(${_birthDate.day}) + மாதம்(${_birthDate.month}) + $_targetYear = ${_birthDate.day + _birthDate.month + _targetYear} -> ${cycles.personalYear.reducedValue}',
            desc: cycles.personalYearDescriptionTa,
            color: Colors.purpleAccent,
          ),
          const SizedBox(height: 8),
          _buildCycleRow(
            title: 'தனிப்பட்ட மாத எண் (Personal Month $_targetMonth)',
            numVal: cycles.personalMonth.reducedValue,
            formula: 'தனிப்பட்ட ஆண்டு(${cycles.personalYear.reducedValue}) + $_targetMonth மாதம் = ${cycles.personalYear.reducedValue + _targetMonth} -> ${cycles.personalMonth.reducedValue}',
            desc: cycles.personalMonthDescriptionTa,
            color: Colors.tealAccent,
          ),
          const SizedBox(height: 8),
          _buildCycleRow(
            title: 'தனிப்பட்ட நாள் எண் (Personal Day $_targetDay)',
            numVal: cycles.personalDay.reducedValue,
            formula: 'தனிப்பட்ட மாதம்(${cycles.personalMonth.reducedValue}) + $_targetDay தேதி = ${cycles.personalMonth.reducedValue + _targetDay} -> ${cycles.personalDay.reducedValue}',
            desc: cycles.personalDayDescriptionTa,
            color: Colors.lightGreenAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildCycleRow({
    required String title,
    required int numVal,
    required String formula,
    required String desc,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color),
            ),
            alignment: Alignment.center,
            child: Text(
              '$numVal',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  formula,
                  style: GoogleFonts.outfit(fontSize: 10.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameNumerologySection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.spellcheck_rounded, color: AppColors.primaryGold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'பெயர் கணிதம் (Name Numerology)',
                    style: GoogleFonts.cinzel(
                      color: AppColors.lightGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.backgroundMid,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _system == NumerologySystem.chaldean ? 'Chaldean System' : 'Pythagorean System',
                  style: GoogleFonts.outfit(fontSize: 10, color: AppColors.lightGold),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.borderGold, height: 16),
          
          Text(
            'பெயர்: ${_result.personName}',
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Letter-by-letter value chips
          if (_result.letterBreakdown.isNotEmpty) ...[
            Text(
              'எழுத்து வாரியான எண் மதிப்புகள்:',
              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _result.letterBreakdown.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundMid,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.letter,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '=',
                        style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.value}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundMid,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'எழுத்து மதிப்புகளின் மொத்தம்:',
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      '${_result.nameCompoundNumber}',
                      style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'கூட்டு பெயர் எண் (Compound Name No):',
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      '${_result.nameCompoundNumber}',
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'மூல பெயர் எண் (Reduced Name No):',
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    Text(
                      '${_result.nameNumber}',
                      style: GoogleFonts.cinzel(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                    ),
                  ],
                ),
                const Divider(color: AppColors.borderGold, height: 14),
                Text(
                  _result.nameNumberVibrationTa,
                  style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompoundDetailsSection() {
    final birthDetail = _result.birthCompoundDetail;
    final lifePathDetail = _result.lifePathCompoundDetail;
    final nameDetail = _result.nameCompoundDetail;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: AppColors.primaryGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'கூட்டு எண் விளக்கங்கள் (Compound Numbers)',
                style: GoogleFonts.cinzel(
                  color: AppColors.lightGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'கீரோ மற்றும் பாரம்பரிய எண்கணித கூட்டு எண் அதிர்வுகள்',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
          ),
          const Divider(color: AppColors.borderGold, height: 16),

          if (birthDetail != null) ...[
            _buildCompoundCard('பிறந்த நாள் கூட்டு எண்: ${birthDetail.number}', birthDetail, Colors.amberAccent),
            const SizedBox(height: 8),
          ],
          if (lifePathDetail != null) ...[
            _buildCompoundCard('விதி எண் கூட்டு எண்: ${lifePathDetail.number}', lifePathDetail, Colors.cyanAccent),
            const SizedBox(height: 8),
          ],
          if (nameDetail != null) ...[
            _buildCompoundCard('பெயர் கூட்டு எண்: ${nameDetail.number}', nameDetail, Colors.greenAccent),
          ],
        ],
      ),
    );
  }

  Widget _buildCompoundCard(String title, CompoundNumberDetail detail, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'மூலம்: ${detail.reducedNumber}',
                  style: GoogleFonts.outfit(fontSize: 11, color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            detail.titleTa,
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.lightGold),
          ),
          const SizedBox(height: 2),
          Text(
            detail.descriptionTa,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityAndGuidanceSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.handshake_rounded, color: AppColors.primaryGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'எண் பொருத்தம் & அதிர்ஷ்ட வழிகாட்டுதல்',
                style: GoogleFonts.cinzel(
                  color: AppColors.lightGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.borderGold, height: 16),
          
          // Friendly, Enemy, Neutral
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('நட்பு எண்கள் (Friendly):', style: GoogleFonts.outfit(fontSize: 11, color: Colors.greenAccent)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: _result.friendlyNumbers.map((n) => _buildNumberPill('$n', Colors.greenAccent)).toList(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('பகை எண்கள் (Challenging):', style: GoogleFonts.outfit(fontSize: 11, color: Colors.redAccent)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: _result.enemyNumbers.map((n) => _buildNumberPill('$n', Colors.redAccent)).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('சம எண்கள் (Neutral):', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: _result.neutralNumbers.map((n) => _buildNumberPill('$n', Colors.white70)).toList(),
              ),
            ],
          ),
          const Divider(color: AppColors.borderGold, height: 16),

          _buildGuidanceRow('அதிர்ஷ்ட தேதிகள் (Lucky Dates)', _result.luckyDates.join(", ")),
          _buildGuidanceRow('அதிர்ஷ்ட நிறங்கள் (Lucky Colors)', _result.luckyColorsTa.join(", ")),
          _buildGuidanceRow('அதிர்ஷ்ட ரத்தினங்கள் (Lucky Gems)', _result.luckyGemsTa.join(", ")),
          _buildGuidanceRow('அதிர்ஷ்ட கிழமைகள் (Lucky Days)', _result.luckyDaysTa.join(", ")),
          _buildGuidanceRow('பொருத்தமான தொழில் துறைகள்', _result.careerGuidanceTa),
        ],
      ),
    );
  }

  Widget _buildNumberPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildGuidanceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
          const Text(': ', style: TextStyle(color: AppColors.borderGold)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
