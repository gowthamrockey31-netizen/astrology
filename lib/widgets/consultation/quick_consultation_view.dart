import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/horoscope_calculation_result.dart';
import '../../models/user_model.dart';
import '../../services/astrology_calculator.dart' as astro_svc;
import '../../services/auth_service.dart';
import '../../services/bnn_engine.dart';
import '../../services/profile_service.dart';
import '../../kp_method_4/engine/kp4_engine.dart';
import '../../kp_method_4/models/kp4_models.dart';
import '../../models/bnn_models.dart';
import '../profile/family_profiles_sheet.dart';

/// 4-Slot Quick Consultation View for mobile and compact desktop consultation.
/// Displays 4 high-priority consultation cards:
/// SLOT 1: Birth / Basic Information
/// SLOT 2: Rasi / Bhava Information
/// SLOT 3: KP Method 4 / Important KP Information
/// SLOT 4: Dasa / Bhukti / Key Information
/// With integrated Profile Switching Header for up to 5 family profiles.
class QuickConsultationView extends StatefulWidget {
  final VoidCallback? onProfileSwitched;

  const QuickConsultationView({
    super.key,
    this.onProfileSwitched,
  });

  @override
  State<QuickConsultationView> createState() => _QuickConsultationViewState();
}

class _QuickConsultationViewState extends State<QuickConsultationView> {
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _profileService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _profileService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  static const List<String> _rasiNamesTa = [
    'மேஷம்', 'ரிஷபம்', 'மிதுனம்', 'கடகம்',
    'சிம்மம்', 'கன்னி', 'துலாம்', 'விருச்சிகம்',
    'தனுசு', 'மகரம்', 'கும்பம்', 'மீனம்'
  ];

  static const List<String> _rasiNamesEn = [
    'Aries', 'Taurus', 'Gemini', 'Cancer',
    'Leo', 'Virgo', 'Libra', 'Scorpio',
    'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  static const Map<int, int> _southIndianGrid = {
    0: 11, // Meenam
    1: 0,  // Mesham
    2: 1,  // Rishabam
    3: 2,  // Mithunam
    7: 3,  // Katakam
    11: 4, // Simham
    15: 5, // Kanni
    14: 6, // Thulam
    13: 7, // Viruchigam
    12: 8, // Dhanusu
    8: 9,  // Makaram
    4: 10, // Kumbam
  };

  @override
  Widget build(BuildContext context) {
    final activeUser = _profileService.activeProfile ?? AuthService.currentUser;

    if (activeUser == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_rounded, size: 48, color: AppColors.lightGold),
              const SizedBox(height: 12),
              Text(
                'ஜாதக சுயவிவரம் தேர்வு செய்யப்படவில்லை',
                style: GoogleFonts.cinzel(color: AppColors.lightGold, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
                icon: const Icon(Icons.people_rounded, color: AppColors.backgroundDeep),
                label: Text('குடும்ப ஜாதகத்தைத் தேர்ந்தெடுக்க', style: GoogleFonts.outfit(color: AppColors.backgroundDeep, fontWeight: FontWeight.bold)),
                onPressed: () => FamilyProfilesSheet.show(context),
              ),
            ],
          ),
        ),
      );
    }

    // Compute existing astrology data for the active profile
    final birthDt = activeUser.birthDateTime;
    final astroData = astro_svc.AstrologyCalculator.calculateHoroscope(
      dateOfBirth: birthDt,
      latitude: activeUser.latitude,
      longitude: activeUser.longitude,
      utcOffsetHours: activeUser.timezone,
    );

    // Compute KP Method 4 data using existing calculation engine
    final kpResult = Kp4Engine.calculate(Kp4BirthData.fromUserModel(activeUser));

    // Compute Vimshottari Dasa data using existing BNN calculation engine
    final dashaResult = BnnEngine.calculateVimshottariDasha(
      moonLongitude: astroData.moon.longitude,
      birthDateTime: birthDt,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Switching Header Bar (Requirements 16 & 17)
          _buildProfileSwitchBar(context),
          const SizedBox(height: 12),

          // SLOT 1: Birth / Basic Information
          _buildSlot1BasicInfo(activeUser, astroData),
          const SizedBox(height: 14),

          // SLOT 2: Rasi / Bhava Information
          _buildSlot2RasiBhava(activeUser, astroData),
          const SizedBox(height: 14),

          // SLOT 3: KP Method 4 / Important KP Information
          _buildSlot3KpMethod4(activeUser, kpResult),
          const SizedBox(height: 14),

          // SLOT 4: Dasa / Bhukti / Key Information
          _buildSlot4DasaBhukti(activeUser, dashaResult),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Profile Switcher Header with Horizontal Chips (Max 5 Family Profiles)
  Widget _buildProfileSwitchBar(BuildContext context) {
    final profiles = _profileService.profiles;
    final activeId = _profileService.activeProfileId;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_alt_rounded, color: AppColors.lightGold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'ஜாதகர் தேர்வு (${profiles.length}/${ProfileService.maxProfiles})',
                    style: GoogleFonts.cinzel(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => FamilyProfilesSheet.show(context, onProfileChanged: () {
                  widget.onProfileSwitched?.call();
                  setState(() {});
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tune_rounded, size: 13, color: AppColors.lightGold),
                      const SizedBox(width: 4),
                      Text(
                        'மேலாண்மை',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Horizontal family profile chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...profiles.map((p) {
                  final isSelected = p.id == activeId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      selectedColor: AppColors.primaryGold,
                      backgroundColor: AppColors.backgroundMid,
                      side: BorderSide(
                        color: isSelected ? AppColors.primaryGold : Colors.white12,
                      ),
                      avatar: CircleAvatar(
                        radius: 10,
                        backgroundColor: isSelected ? AppColors.backgroundDeep : AppColors.primaryGold,
                        child: Icon(
                          isSelected ? Icons.check : Icons.person,
                          size: 11,
                          color: isSelected ? AppColors.primaryGold : AppColors.backgroundDeep,
                        ),
                      ),
                      label: Text(
                        '${p.name} (${p.relationship.isNotEmpty ? p.relationship : "Self"})',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.backgroundDeep : Colors.white,
                        ),
                      ),
                      onSelected: (val) async {
                        if (val) {
                          await _profileService.selectProfile(p.id);
                          widget.onProfileSwitched?.call();
                          setState(() {});
                        }
                      },
                    ),
                  );
                }),
                if (profiles.length < ProfileService.maxProfiles)
                  ActionChip(
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: AppColors.primaryGold.withOpacity(0.5)),
                    avatar: const Icon(Icons.add, size: 14, color: AppColors.lightGold),
                    label: Text(
                      'சேர்க்க',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.lightGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () => FamilyProfilesSheet.show(context, onProfileChanged: () {
                      widget.onProfileSwitched?.call();
                      setState(() {});
                    }),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// SLOT 1: Birth / Basic Information
  Widget _buildSlot1BasicInfo(UserModel user, HoroscopeCalculationResult astro) {
    return _buildCardWrapper(
      slotBadge: 'SLOT 1',
      title: 'அடிப்படை & பிறப்பு விபரம் (Basic Info)',
      icon: Icons.badge_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name, Age & Relationship
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: GoogleFonts.cinzel(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                      ),
                    ),
                    Text(
                      '${user.relationship} • ${user.calculatedAge} வயது (${user.gender})',
                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
                ),
                child: Text(
                  astro.tamilDateFormatted.isNotEmpty ? astro.tamilDateFormatted : 'தமிழ் வருடம்',
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 10),

          // Two-Column Grid for Birth & Astrological Essentials
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Birth Parameters
              Expanded(
                child: Column(
                  children: [
                    _buildInfoRow('பிறந்த தேதி', user.dob),
                    _buildInfoRow('பிறந்த நேரம்', user.timeOfBirth),
                    _buildInfoRow('பிறந்த இடம்', user.city.isNotEmpty ? user.city : user.placeOfBirth),
                    _buildInfoRow('அட்சரேகை', '${user.latitude.toStringAsFixed(4)}° N'),
                    _buildInfoRow('தீர்க்கரேகை', '${user.longitude.toStringAsFixed(4)}° E'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right Column: Natal Key Astrological Signatures
              Expanded(
                child: Column(
                  children: [
                    _buildInfoRow('லக்னம் (Asc)', '${astro.lagna.rasiNameTa} (${astro.lagna.degreeInRasi.toStringAsFixed(1)}°)'),
                    _buildInfoRow('ராசி (Moon)', '${astro.moon.rasiNameTa} (${astro.moon.rasiNameEn})'),
                    _buildInfoRow('நட்சத்திரம்', '${astro.moon.nakshatraNameTa} - பாதம் ${astro.moon.pada}'),
                    _buildInfoRow('நட்சத்திர நாதன்', astro.moon.tamilStarLord),
                    _buildInfoRow('திதி & யோகம்', '${astro.tithi.tithiNameTa} • ${astro.yogaNameTa}'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// SLOT 2: Rasi / Bhava Information
  Widget _buildSlot2RasiBhava(UserModel user, HoroscopeCalculationResult astro) {
    // Map planets by Rasi index
    final Map<int, List<String>> rasiPlanets = {};
    for (int i = 0; i < 12; i++) {
      rasiPlanets[i] = [];
    }

    astro.planets.forEach((_, p) {
      final shortName = _getPlanetShortTamil(p.name);
      final retroStr = p.isRetrograde ? '(வ)' : '';
      rasiPlanets[p.rasiIndex]?.add('$shortName$retroStr');
    });

    return _buildCardWrapper(
      slotBadge: 'SLOT 2',
      title: 'ராசி & பாவ விபரம் (Rasi & Bhava)',
      icon: Icons.grid_on_rounded,
      child: Column(
        children: [
          // Compact South Indian 4x4 Chart
          AspectRatio(
            aspectRatio: 1.05,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundDeep,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGold, width: 1.5),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 16,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, gridIdx) {
                  // Center 4 cells (5, 6, 9, 10)
                  if (gridIdx == 5) {
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: AppColors.primaryGold, width: 0.5)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'ராசி',
                        style: GoogleFonts.cinzel(
                          color: AppColors.lightGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                  if (gridIdx == 6) {
                    return Container(
                      alignment: Alignment.center,
                      child: Text(
                        astro.lagna.rasiNameTa,
                        style: GoogleFonts.outfit(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  if (gridIdx == 9) {
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(right: BorderSide(color: AppColors.primaryGold, width: 0.5)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        astro.moon.nakshatraNameTa,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  if (gridIdx == 10) {
                    return Container(
                      alignment: Alignment.center,
                      child: Text(
                        'சக்கரம்',
                        style: GoogleFonts.cinzel(
                          color: AppColors.lightGold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }

                  // 12 Outer perimeter boxes
                  final rasiIdx = _southIndianGrid[gridIdx]!;
                  final isLagna = astro.lagna.rasiIndex == rasiIdx;
                  final planetsInSign = rasiPlanets[rasiIdx] ?? [];

                  return Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isLagna ? AppColors.primaryGold.withOpacity(0.08) : Colors.transparent,
                      border: Border.all(color: AppColors.primaryGold.withOpacity(0.6), width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _rasiNamesTa[rasiIdx],
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isLagna)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'லக்',
                                  style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        Wrap(
                          spacing: 2,
                          runSpacing: 1,
                          children: planetsInSign.map((p) {
                            final isBenefic = p.contains('குரு') || p.contains('சுக்') || p.contains('சந்');
                            return Text(
                              p,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isBenefic ? AppColors.lightGold : Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Bhava Summary Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundMid,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('லக்னாதிபதி: ${astro.lagna.tamilStarLord}', style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70)),
                Text('ராசி அதிபதி: ${astro.moon.tamilStarLord}', style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70)),
                Text('சூரியன்: ${_rasiNamesTa[astro.sun.rasiIndex]}', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.lightGold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// SLOT 3: KP Method 4 / Important KP Information
  Widget _buildSlot3KpMethod4(UserModel user, KpResult kp) {
    final lagnaCusp = kp.cuspPositions.isNotEmpty ? kp.cuspPositions[0] : null;

    // Filter key cusps: 1 (Lagna), 2 (Dhana), 6 (Roga/Job), 7 (Kalathra), 10 (Karma/Career), 11 (Labha)
    final keyCusps = kp.cuspPositions.where((c) => [1, 2, 6, 7, 10, 11].contains(c.cuspNumber)).toList();

    return _buildCardWrapper(
      slotBadge: 'SLOT 3',
      title: 'கே.பி. முறை 4 (KP Method 4 Cuspal Lords)',
      icon: Icons.hub_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lagna Cusp Key Sub-Lord Card
          if (lagnaCusp != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.backgroundMid,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1-ஆம் பாவம் (லக்ன முனை): ${lagnaCusp.signNameTa}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                      Text(
                        '${lagnaCusp.degreeInRasi.toStringAsFixed(2)}°',
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildKpLordBadge('நட்சத்திரம்', lagnaCusp.nakshatraNameTa),
                      _buildKpLordBadge('நட்சத்திர நாதன்', lagnaCusp.starLordTa),
                      _buildKpLordBadge('உப நாதன் (Sub)', lagnaCusp.subLordTa, isHighlight: true),
                      _buildKpLordBadge('உப-உப நாதன்', lagnaCusp.subSubLordTa),
                    ],
                  ),
                ],
              ),
            ),

          // Key Cusps Summary Table
          Text(
            'முக்கிய பாவங்களின் உப நாதர்கள் (Key Cusps):',
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 6),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 28,
              dataRowHeight: 28,
              horizontalMargin: 8,
              columnSpacing: 16,
              headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
              columns: const [
                DataColumn(label: Text('பாவம்', style: TextStyle(color: AppColors.lightGold, fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('ராசி', style: TextStyle(color: AppColors.lightGold, fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('நட்சத்திர நாதன்', style: TextStyle(color: AppColors.lightGold, fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('உப நாதன் (Sub)', style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(label: Text('உப-உப (SS)', style: TextStyle(color: AppColors.lightGold, fontSize: 11, fontWeight: FontWeight.bold))),
              ],
              rows: keyCusps.map((c) {
                return DataRow(
                  cells: [
                    DataCell(Text('பாவம் ${c.cuspNumber}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                    DataCell(Text(c.signNameTa, style: const TextStyle(color: Colors.white70, fontSize: 11))),
                    DataCell(Text(c.starLordTa, style: const TextStyle(color: Colors.white70, fontSize: 11))),
                    DataCell(Text(c.subLordTa, style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold))),
                    DataCell(Text(c.subSubLordTa, style: const TextStyle(color: Colors.white70, fontSize: 11))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// SLOT 4: Dasa / Bhukti / Key Information
  Widget _buildSlot4DasaBhukti(UserModel user, BnnDashaResult dasha) {
    final now = DateTime.now();

    // Find current Mahadasha
    BnnDashaPeriod? currentMaha;
    for (final m in dasha.mahadashas) {
      if (!now.isBefore(m.startDate) && now.isBefore(m.endDate)) {
        currentMaha = m;
        break;
      }
    }
    currentMaha ??= dasha.mahadashas.first;

    // Find current Bhukti
    BnnDashaPeriod? currentBhukti;
    for (final b in currentMaha.subPeriods) {
      if (!now.isBefore(b.startDate) && now.isBefore(b.endDate)) {
        currentBhukti = b;
        break;
      }
    }
    currentBhukti ??= currentMaha.subPeriods.isNotEmpty ? currentMaha.subPeriods.first : null;

    // Find current Anthara
    BnnDashaPeriod? currentAnthara;
    if (currentBhukti != null) {
      for (final a in currentBhukti.subPeriods) {
        if (!now.isBefore(a.startDate) && now.isBefore(a.endDate)) {
          currentAnthara = a;
          break;
        }
      }
      currentAnthara ??= currentBhukti.subPeriods.isNotEmpty ? currentBhukti.subPeriods.first : null;
    }

    final dateFormat = DateFormat('dd-MM-yyyy');

    return _buildCardWrapper(
      slotBadge: 'SLOT 4',
      title: 'விம்சோத்தரி தசா / புக்தி (Dasha & Bhukti)',
      icon: Icons.timeline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Birth Balance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundMid,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_outline_rounded, color: AppColors.lightGold, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dasha.balanceFormatted,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Current Running Period Highlight Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGold, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'தற்போது நடக்கும் தசா காலம் (Active):',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppColors.lightGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('RUNNING', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDashaHighlightItem(
                      'மகா தசை',
                      currentMaha.planetNameTa,
                      '${dateFormat.format(currentMaha.startDate)} வரை ${dateFormat.format(currentMaha.endDate)}',
                    ),
                    if (currentBhukti != null)
                      _buildDashaHighlightItem(
                        'புக்தி நாதன்',
                        currentBhukti.planetNameTa,
                        '${dateFormat.format(currentBhukti.startDate)} வரை ${dateFormat.format(currentBhukti.endDate)}',
                      ),
                    if (currentAnthara != null)
                      _buildDashaHighlightItem(
                        'அந்தரா',
                        currentAnthara.planetNameTa,
                        '${dateFormat.format(currentAnthara.startDate)} வரை ${dateFormat.format(currentAnthara.endDate)}',
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Mahadashas Sequence Bar
          Text('மகா தசா வரிசை (Sequence):', style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: dasha.mahadashas.map((m) {
                final isCurrent = m.planetKey == currentMaha?.planetKey;
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.primaryGold : AppColors.backgroundMid,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isCurrent ? AppColors.lightGold : Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        m.planetNameTa,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? AppColors.backgroundDeep : Colors.white,
                        ),
                      ),
                      Text(
                        '${m.startDate.year} - ${m.endDate.year}',
                        style: TextStyle(
                          fontSize: 9,
                          color: isCurrent ? AppColors.backgroundDeep.withOpacity(0.8) : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets

  Widget _buildCardWrapper({
    required String slotBadge,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slot Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.backgroundMid,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: const Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    slotBadge,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.backgroundDeep,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, color: AppColors.lightGold, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cinzel(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildKpLordBadge(String title, String name, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 9, color: isHighlight ? Colors.amber : Colors.white60)),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isHighlight ? AppColors.primaryGold.withOpacity(0.2) : Colors.white10,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isHighlight ? AppColors.primaryGold : Colors.white12),
          ),
          child: Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.amber : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashaHighlightItem(String title, String planet, String dates) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(
          planet,
          style: GoogleFonts.cinzel(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.lightGold,
          ),
        ),
        const SizedBox(height: 2),
        Text(dates, style: const TextStyle(fontSize: 9, color: Colors.white54)),
      ],
    );
  }

  String _getPlanetShortTamil(String name) {
    switch (name.toLowerCase()) {
      case 'sun':
      case 'சூரியன்':
        return 'சூ';
      case 'moon':
      case 'சந்திரன்':
        return 'சந்';
      case 'mars':
      case 'செவ்வாய்':
        return 'செவ்';
      case 'mercury':
      case 'புதன்':
        return 'புத';
      case 'jupiter':
      case 'குரு':
        return 'குரு';
      case 'venus':
      case 'சுக்கிரன்':
        return 'சுக்';
      case 'saturn':
      case 'சனி':
        return 'சனி';
      case 'rahu':
      case 'ராகு':
        return 'ராகு';
      case 'ketu':
      case 'கேது':
        return 'கேது';
      default:
        return name.length > 3 ? name.substring(0, 3) : name;
    }
  }
}
