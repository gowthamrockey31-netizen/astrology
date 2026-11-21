import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/suba_muhurtham_model.dart';
import '../../services/auth_service.dart';
import '../../services/suba_muhurtham_service.dart';
import '../../widgets/astro_card.dart';
import '../../widgets/cosmic_background.dart';
import 'professional_muhurtha_engine.dart';
import 'professional_muhurtha_models.dart';
import 'subha_muhurtham_rules.dart';

/// ===============================================================
/// SUBHA MUHURTHAM DAY SELECTION & TIME CALCULATION
/// Features 4-Level Evaluation Hierarchy:
/// 1. General Day Suitability (Vaaram, Tithi, Nakshatra, Yoga, Karana)
/// 2. Avoidance Rules (Aadi, Purattasi, Margazhi, Kari Naal, Rahu, Yama, Gulikai)
/// 3. Person-Specific Jathaga Checks (Chandrashtama, Tarabalam, Guru/Surya Balam)
/// 4. Muhurtham Time & Lagna Suitability (Lagna, Lagna Lord, 7th/8th house, Mars, Saturn, Rahu, Ketu)
/// Configurable Rule Presets (Standard / Extended) for Documented Source Conflicts
/// Date Range Search for finding upcoming Subha Muhurtham days
/// ===============================================================

class ProfessionalMuhurthaPage extends StatefulWidget {
  final GeoLocation location;

  const ProfessionalMuhurthaPage({
    super.key,
    this.location = const GeoLocation(
      name: 'Chennai',
      latitude: 13.0827,
      longitude: 80.2707,
      timeZone: 5.5,
    ),
  });

  @override
  State<ProfessionalMuhurthaPage> createState() =>
      _ProfessionalMuhurthaPageState();
}

class _ProfessionalMuhurthaPageState extends State<ProfessionalMuhurthaPage> {
  final ProfessionalMuhurthaEngine _engine = ProfessionalMuhurthaEngine();

  DateTime _selectedDate = DateTime.now();
  MuhurthaCategory _category = MuhurthaCategory.generalSubha;
  MuhurthamRulePreset _rulePreset = MuhurthamRulePreset.extended;

  bool _isPersonalized = false;
  int _birthNakshatra = 0; // Ashwini
  int _birthRasi = 0; // Mesham
  String _personName = 'அன்பர்';

  MuhurthaResult? _result;

  // Admin-Editable Suba Muhurtham Schedule Table
  List<SubaMuhurthamModel> _adminMuhurthamList = [];
  bool _isLoadingMuhurthamTable = true;

  // Date Range Search State
  bool _isSearchingRange = false;
  bool _rangeSearchExpanded = false;
  DateTime _rangeStartDate = DateTime.now();
  DateTime _rangeEndDate = DateTime.now().add(const Duration(days: 30));
  List<MuhurthaResult> _rangeResults = [];

  @override
  void initState() {
    super.initState();
    _initFromUser();
    _recalculate();
    _loadAdminMuhurthamData();
  }

  Future<void> _loadAdminMuhurthamData() async {
    final list = await SubaMuhurthamService.fetchList();
    if (mounted) {
      setState(() {
        _adminMuhurthamList = list;
        _isLoadingMuhurthamTable = false;
      });
    }
  }

  void _initFromUser() {
    final user = AuthService.currentUser;
    if (user != null) {
      if (user.name.trim().isNotEmpty) {
        _personName = user.name;
      }
    }
  }

  SubhaMuhurthamRules _getActiveRules() {
    return _rulePreset == MuhurthamRulePreset.standard
        ? SubhaMuhurthamRules.standard()
        : SubhaMuhurthamRules.extended();
  }

  void _recalculate() {
    BirthProfile? profile;
    if (_isPersonalized) {
      profile = BirthProfile(
        name: _personName,
        birthDate: DateTime(1995, 1, 1),
        birthNakshatra: _birthNakshatra,
        birthRasi: _birthRasi,
      );
    }

    final res = _engine.calculate(
      date: _selectedDate,
      location: widget.location,
      category: _category,
      birthProfile: profile,
      rules: _getActiveRules(),
    );

    setState(() {
      _result = res;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1970),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGold,
              onPrimary: AppColors.textDark,
              surface: AppColors.backgroundMid,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: AppColors.backgroundMid),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _recalculate();
    }
  }

  void _changeDay(int offset) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: offset));
    });
    _recalculate();
  }

  Future<void> _performRangeSearch() async {
    setState(() {
      _isSearchingRange = true;
      _rangeSearchExpanded = true;
    });

    BirthProfile? profile;
    if (_isPersonalized) {
      profile = BirthProfile(
        name: _personName,
        birthDate: DateTime(1995, 1, 1),
        birthNakshatra: _birthNakshatra,
        birthRasi: _birthRasi,
      );
    }

    final results = _engine.searchDateRange(
      startDate: _rangeStartDate,
      endDate: _rangeEndDate,
      location: widget.location,
      category: _category,
      birthProfile: profile,
      rules: _getActiveRules(),
      onlySuitable: true,
    );

    setState(() {
      _rangeResults = results;
      _isSearchingRange = false;
    });
  }

  IconData _categoryIcon(MuhurthaCategory cat) {
    switch (cat) {
      case MuhurthaCategory.generalSubha:
        return Icons.auto_awesome;
      case MuhurthaCategory.marriage:
        return Icons.favorite;
      case MuhurthaCategory.houseEntry:
        return Icons.home;
      case MuhurthaCategory.bhoomiPooja:
        return Icons.foundation;
      case MuhurthaCategory.earPiercing:
        return Icons.child_friendly;
      case MuhurthaCategory.newBusiness:
        return Icons.business_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        title: const Text(
          'சுப முகூர்த்த நாள் தேர்வு',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.backgroundDeep,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: AppColors.lightGold),
            tooltip: 'தேதி தேர்வு (Pick Date)',
            onPressed: _pickDate,
          ),
        ],
      ),
      body: CosmicBackground(
        child: r == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGold,
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Date & Navigation Header
                    _buildDateNavBar(r),
                    const SizedBox(height: 14),

                    // 2. Muhurtham Category Selector
                    _buildCategorySelector(),
                    const SizedBox(height: 14),

                    // 2b. Rule Configuration & Preset Selector (Resolves Source Conflicts)
                    _buildRulePresetSelector(),
                    const SizedBox(height: 14),

                    // 2c. Conflict Alert Notice Banner (if active date has Tithi or Nakshatra conflict)
                    if (r.conflictNote != null) ...[
                      _buildConflictBanner(r.conflictNote!),
                      const SizedBox(height: 14),
                    ],

                    // 3. Personalization Settings (Tara & Chandra Bala toggle)
                    _buildPersonalizationCard(),
                    const SizedBox(height: 16),

                    // 4. Overall Verdict Banner
                    _buildVerdictBanner(r),
                    const SizedBox(height: 16),

                    // 4b. Transparent 4-Level Subha Muhurtham Checklist
                    _buildFourLevelsChecklist(r),
                    const SizedBox(height: 18),

                    // 5. Continuous Subha Muhurtham Windows (Level 4 Detailed Breakdown)
                    _buildSubhaWindowsSection(r),
                    const SizedBox(height: 18),

                    // 5a. Date Range Search Section (Multi-Day Evaluation)
                    _buildDateRangeSearchSection(),
                    const SizedBox(height: 18),

                    // 5b. பஞ்சாங்க சுப முகூர்த்த அட்டவணை (Admin-Editable Suba Muhurtham Schedule Table)
                    _buildSubaMuhurthamTableSection(),
                    const SizedBox(height: 18),

                    // 6. Abhijit Muhurtham Alternative Card
                    if (r.abhijitMuhurtham != null) ...[
                      _buildAbhijitCard(r.abhijitMuhurtham!),
                      const SizedBox(height: 18),
                    ],

                    // 8. Automatically Excluded Inauspicious Periods (Rahu, Yama, Gulikai, Visha, Sandhya)
                    _buildInauspiciousPeriodsCard(r),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  // ===============================================================
  // WIDGET BUILDERS
  // ===============================================================

  /// Date selector with quick previous/next day buttons
  Widget _buildDateNavBar(MuhurthaResult r) {
    final dateStr = DateFormat('dd MMM yyyy, EEEE').format(r.date);
    final tamilDateStr = '${r.tamilMonth} ${r.tamilDay} - ${r.tamilYearName} வருடம்';

    return AstroCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.lightGold, size: 28),
            onPressed: () => _changeDay(-1),
            tooltip: 'முந்தைய நாள் (Previous Day)',
          ),
          Expanded(
            child: InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event, size: 16, color: AppColors.primaryGold),
                      const SizedBox(width: 6),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tamilDateStr,
                    style: const TextStyle(
                      color: AppColors.lightGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.lightGold, size: 28),
            onPressed: () => _changeDay(1),
            tooltip: 'அடுத்த நாள் (Next Day)',
          ),
        ],
      ),
    );
  }

  /// Category Selector
  Widget _buildCategorySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: MuhurthaCategory.values.map((cat) {
          final isSelected = _category == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: Icon(
                _categoryIcon(cat),
                size: 16,
                color: isSelected ? AppColors.textDark : AppColors.lightGold,
              ),
              label: Text(cat.tamilTitle),
              selected: isSelected,
              selectedColor: AppColors.primaryGold,
              backgroundColor: AppColors.cardSurface,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.textDark : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12.5,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.lightGold : AppColors.borderGold.withValues(alpha: 0.4),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _category = cat;
                  });
                  _recalculate();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Rule Preset Selector (Resolves Tithi & Nakshatra Conflicts Transparently)
  Widget _buildRulePresetSelector() {
    return AstroCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rule_folder_outlined, color: AppColors.primaryGold, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'விதிமுறை தொகுப்பு (Rule Preset)',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, color: AppColors.lightGold, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'விதிமுறை முரண்பாடு ஒப்பீடு',
                onPressed: _showRulesComparisonDialog,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _rulePreset = MuhurthamRulePreset.extended;
                    });
                    _recalculate();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: _rulePreset == MuhurthamRulePreset.extended
                          ? AppColors.primaryGold.withValues(alpha: 0.2)
                          : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _rulePreset == MuhurthamRulePreset.extended
                            ? AppColors.primaryGold
                            : AppColors.borderGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'விரிவாக்கப்பட்டது',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'மூலம் சேர்க்கை • சதுர்த்தி அனுமதி',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRulesComparisonDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primaryGold, width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primaryGold, size: 22),
            const SizedBox(width: 8),
            Text(
              'விதிமுறை முரண்பாட்டு ஒப்பீடு',
              style: GoogleFonts.cinzel(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'வழங்கப்பட்ட தேவைக் குறிப்பில் இரண்டு மாறுபட்ட விதிமுறைகள் உள்ளன. எந்த முடிவும் மறைக்கப்படாமல் வெளிப்படையாக கட்டமைக்கப்பட்டுள்ளது:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '1. திதி முரண்பாடு (Tithi Conflict):',
                      style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12.5),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• பாரம்பரிய விதி (List 1): சதுர்த்தி விலக்கப்பட்டுள்ளது (Avoid Chaturthi). உகந்த திதிகள்: 2, 3, 5, 7, 10, 11, 12, 13.\n• விரிவான விதி (List 2): சதுர்த்தி, சஷ்டி, சதுர்த்தசி சுபமாக ஏற்கப்பட்டுள்ளன: 2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14.',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 11.5, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '2. நட்சத்திர முரண்பாடு (Nakshatra Conflict):',
                      style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12.5),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• பாரம்பரிய விதி (List 1): சித்திரை மற்றும் சுவாதி அடங்கிய 16 நட்சத்திரங்கள் (மூலம் இல்லை).\n• விரிவான விதி (List 2): மூலம் சேர்க்கப்பட்டுள்ளது; சித்திரை, சுவாதி வெளிப்படையாக குறிப்பிடப்படவில்லை.',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 11.5, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('புரிந்தது (OK)', style: TextStyle(color: AppColors.primaryGold)),
          ),
        ],
      ),
    );
  }

  /// Conflict Notification Banner
  Widget _buildConflictBanner(String note) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.8), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'மூல விதிகளின்படி முரண்பாட்டு குறிப்பு (Conflict Note)',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  note,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Personal Profile Toggle & Selector Card
  Widget _buildPersonalizationCard() {
    return AstroCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'தனிநபர் பலன் (Personalized Tara & Chandra Bala)',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                value: _isPersonalized,
                activeThumbColor: AppColors.primaryGold,
                onChanged: (val) {
                  setState(() {
                    _isPersonalized = val;
                  });
                  _recalculate();
                },
              ),
            ],
          ),
          if (_isPersonalized) ...[
            const Divider(color: Colors.white24, height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'பிறந்த நட்சத்திரம்',
                        style: TextStyle(color: AppColors.lightGold, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _birthNakshatra,
                            isExpanded: true,
                            dropdownColor: AppColors.backgroundMid,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            items: List.generate(
                              ProfessionalMuhurthaEngine.nakshatrasTa.length,
                              (idx) => DropdownMenuItem(
                                value: idx,
                                child: Text('${idx + 1}. ${ProfessionalMuhurthaEngine.nakshatrasTa[idx]}'),
                              ),
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _birthNakshatra = val;
                                });
                                _recalculate();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'பிறந்த ராசி',
                        style: TextStyle(color: AppColors.lightGold, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _birthRasi,
                            isExpanded: true,
                            dropdownColor: AppColors.backgroundMid,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            items: List.generate(
                              ProfessionalMuhurthaEngine.rasiNamesTa.length,
                              (idx) => DropdownMenuItem(
                                value: idx,
                                child: Text('${idx + 1}. ${ProfessionalMuhurthaEngine.rasiNamesTa[idx]}'),
                              ),
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _birthRasi = val;
                                });
                                _recalculate();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Verdict Banner
  Widget _buildVerdictBanner(MuhurthaResult r) {
    final bool isChandrashtama = r.chandraBala?.isChandrashtama ?? false;
    final bool isDayPassed = r.level1Day.isLevel1Passed && r.level2Avoidance.isLevel2Passed;
    final bool hasWindows = r.validWindows.isNotEmpty;

    Color bannerColor;
    IconData iconData;
    String statusTitle;

    if (isChandrashtama) {
      bannerColor = const Color(0xFFEF4444);
      iconData = Icons.dangerous;
      statusTitle = 'சந்திராஷ்டமம் எச்சரிக்கை!';
    } else if (isDayPassed && hasWindows) {
      bannerColor = const Color(0xFF10B981);
      iconData = Icons.verified;
      statusTitle = 'உத்தம சுப முகூர்த்த நாள்';
    } else if (isDayPassed) {
      bannerColor = const Color(0xFF10B981);
      iconData = Icons.event_available;
      statusTitle = 'பொது சுப நாள் (முகூர்த்த லக்னம் தேவை)';
    } else {
      bannerColor = const Color(0xFFF59E0B);
      iconData = Icons.info_outline;
      statusTitle = 'முகூர்த்தத்திற்கு பரிந்துரைக்கப்படவில்லை';
    }

    return Container(
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bannerColor, width: 1.4),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, color: bannerColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  statusTitle,
                  style: TextStyle(
                    color: bannerColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bannerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasWindows ? '${r.validWindows.length} சுப நேரம்' : '0 சுப நேரம்',
                  style: TextStyle(
                    color: bannerColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            r.summaryVerdict,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🌅 உதயம்: ${DateFormat('hh:mm a').format(r.sunrise)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
              ),
              Text(
                '🌇 அஸ்தமனம்: ${DateFormat('hh:mm a').format(r.sunset)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
              ),
              Text(
                '📍 ${r.location.name}',
                style: const TextStyle(color: AppColors.lightGold, fontSize: 11.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Transparent 4-Level Subha Muhurtham Checklist Card
  Widget _buildFourLevelsChecklist(MuhurthaResult r) {
    final l1 = r.level1Day;
    final l2 = r.level2Avoidance;
    final l3 = r.level3Jathaga;

    return AstroCard(
      padding: const EdgeInsets.all(14),
      borderGoldColor: AppColors.primaryGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rtl_rounded, color: AppColors.primaryGold, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'சுப முகூர்த்த ஆய்வு நிலைப்படிகள் (4-Level Checklist)',
                  style: GoogleFonts.cinzel(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // LEVEL 1: GENERAL DAY SUITABILITY
          _buildChecklistGroupHeader(
            levelNumber: 1,
            title: 'பொது நாள் சுபத்தன்மை (General Day)',
            isPassed: l1.isLevel1Passed,
          ),
          const SizedBox(height: 8),
          _buildCheckItem(
            name: '1. கிழமை (Vaaram)',
            value: l1.vaaram.weekdayName,
            isPassed: l1.vaaram.isSuitable,
            detail: l1.vaaram.isValarpiraiSunday ? 'வளர்பிறை ஞாயிறு - விசேஷ பலன்' : l1.vaaram.reason,
          ),
          _buildCheckItem(
            name: '2. திதி (Tithi)',
            value: '${l1.tithi.tithiName} (${l1.tithi.paksha})',
            isPassed: l1.tithi.isSuitable,
            detail: l1.tithi.conflictNote ?? l1.tithi.reason,
          ),
          _buildCheckItem(
            name: '3. நட்சத்திரம் (Nakshatra)',
            value: l1.nakshatra.nakshatraName,
            isPassed: l1.nakshatra.isSuitable,
            detail: l1.nakshatra.conflictNote ?? l1.nakshatra.reason,
          ),
          _buildCheckItem(
            name: '4. யோகம் (Yoga)',
            value: l1.yoga.amirthathiYoga,
            isPassed: l1.yoga.isSuitable,
            detail: l1.yoga.reason,
          ),
          _buildCheckItem(
            name: '5. கரணம் (Karana)',
            value: l1.karana.karanaName,
            isPassed: l1.karana.isSuitable,
            detail: l1.karana.reason,
          ),

          const Divider(color: Colors.white12, height: 22),

          // LEVEL 2: AVOIDANCE RULES
          _buildChecklistGroupHeader(
            levelNumber: 2,
            title: 'விலக்கு விதிகள் (Avoidance Rules)',
            isPassed: l2.isLevel2Passed,
          ),
          const SizedBox(height: 8),
          _buildCheckItem(
            name: 'மாத விதி (Month Rule)',
            value: l2.monthCheck.tamilMonth,
            isPassed: l2.monthCheck.isSuitable,
            detail: l2.monthCheck.reason,
          ),
          _buildCheckItem(
            name: 'கரி நாள் (Kari Day)',
            value: l2.kariDayCheck.isKariDay ? 'கரி நாள் (Avoid)' : 'கரி நாள் இல்லை (Safe)',
            isPassed: l2.kariDayCheck.isSuitable,
            detail: l2.kariDayCheck.reason,
          ),
          _buildCheckItem(
            name: 'ராகுகாலம் (Rahu Kalam)',
            value: l2.rahuKalam.timingFormatted,
            isPassed: true,
            detail: 'முகூர்த்த கணிதத்திலிருந்து முழுமையாக விலக்கப்பட்டுள்ளது',
          ),
          _buildCheckItem(
            name: 'எமகண்டம் (Yamagandam)',
            value: l2.yamagandam.timingFormatted,
            isPassed: true,
            detail: 'முகூர்த்த கணிதத்திலிருந்து முழுமையாக விலக்கப்பட்டுள்ளது',
          ),
          _buildCheckItem(
            name: 'குளிகை (Kuligai)',
            value: l2.kuligai.timingFormatted,
            isPassed: true,
            detail: 'முகூர்த்த கணிதத்திலிருந்து முழுமையாக விலக்கப்பட்டுள்ளது',
          ),

          const Divider(color: Colors.white12, height: 22),

          // LEVEL 3: PERSON-SPECIFIC JATHAGA
          _buildChecklistGroupHeader(
            levelNumber: 3,
            title: 'தனிநபர் ஜாதகப் பொருத்தம் (Jathaga Checks)',
            isPassed: l3 == null || l3.isLevel3Passed,
          ),
          const SizedBox(height: 8),
          if (l3 != null) ...[
            _buildCheckItem(
              name: 'சந்திராஷ்டமம் (Chandrashtama)',
              value: l3.chandrashtama.isChandrashtama ? 'சந்திராஷ்டமம் உள்ளது (Avoid)' : 'சந்திராஷ்டமம் இல்லை (Clear)',
              isPassed: !l3.chandrashtama.isChandrashtama,
              detail: l3.chandrashtama.reason,
            ),
            _buildCheckItem(
              name: 'தாராபலம் (Tarabalam)',
              value: '${l3.tarabalam.taraName} (எண்: ${l3.tarabalam.taraNumber})',
              isPassed: l3.tarabalam.isAccepted,
              detail: l3.tarabalam.reason,
            ),
            if (l3.guruBalam != null)
              _buildCheckItem(
                name: 'குரு பலம் (Guru Balam)',
                value: l3.guruBalam!.status,
                isPassed: l3.guruBalam!.isAuspicious,
                detail: l3.guruBalam!.reason,
              ),
            if (l3.suryaBalam != null)
              _buildCheckItem(
                name: 'சூரிய பலம் (Surya Balam)',
                value: l3.suryaBalam!.status,
                isPassed: l3.suryaBalam!.isAuspicious,
                detail: l3.suryaBalam!.reason,
              ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'தனிநபர் சந்திராஷ்டமம் & தாராபலம் காண மேலே உள்ள சுவிட்சை இயக்கவும்.',
                style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8), fontSize: 11.5, fontStyle: FontStyle.italic),
              ),
            ),

          const Divider(color: Colors.white12, height: 22),

          // LEVEL 4: MUHURTHAM LAGNA
          _buildChecklistGroupHeader(
            levelNumber: 4,
            title: 'முகூர்த்த லக்னம் & பாப கிரக சுத்தி (Muhurtham Time)',
            isPassed: r.validWindows.isNotEmpty,
          ),
          const SizedBox(height: 8),
          _buildCheckItem(
            name: 'லக்ன ஆய்வு நிலை',
            value: r.validWindows.isNotEmpty ? '${r.validWindows.length} தூய நேரங்கள் கிடைத்துள்ளன' : 'உகந்த லக்ன நேரங்கள் அமையவில்லை',
            isPassed: r.validWindows.isNotEmpty,
            detail: '7-ம் இடம் (ஜாமித்ர தோஷம்), 8-ம் இடம் (அஷ்டம தோஷம்) மற்றும் செவ்வாய், சனி, ராகு, கேது சரிபார்க்கப்பட்டுள்ளது.',
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistGroupHeader({
    required int levelNumber,
    required String title,
    required bool isPassed,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: isPassed ? const Color(0x3310B981) : const Color(0x33EF4444),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444), width: 0.8),
          ),
          child: Text(
            'நிலை $levelNumber',
            style: TextStyle(
              color: isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              fontWeight: FontWeight.bold,
              fontSize: 10.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(
          isPassed ? Icons.check_circle : Icons.cancel,
          color: isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          size: 18,
        ),
      ],
    );
  }

  Widget _buildCheckItem({
    required String name,
    required String value,
    required bool isPassed,
    required String detail,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 8),
            child: Text(
              isPassed ? '✓' : '✗',
              style: TextStyle(
                color: isPassed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.lightGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        value,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: isPassed ? AppColors.textPrimary : const Color(0xFFEF4444),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (detail.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      detail,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Date Range Search Section (Multi-Day Evaluation)
  Widget _buildDateRangeSearchSection() {
    return AstroCard(
      padding: const EdgeInsets.all(14),
      borderGoldColor: Colors.tealAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _rangeSearchExpanded = !_rangeSearchExpanded;
              });
            },
            child: Row(
              children: [
                const Icon(Icons.date_range, color: Colors.tealAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'தேதி வரம்பு முகூர்த்த தேடல் (Find in Date Range)',
                    style: GoogleFonts.cinzel(
                      color: AppColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  _rangeSearchExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.tealAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'குறிப்பிட்ட கால இடைவெளியில் உள்ள அனைத்து நாட்களையும் தனித்தனியாக ஆய்வு செய்து சுப முகூர்த்த நாட்களைக் கண்டறிக.',
            style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.9), fontSize: 11.5),
          ),
          if (_rangeSearchExpanded) ...[
            const Divider(color: Colors.white12, height: 18),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _rangeStartDate,
                        firstDate: DateTime(1970),
                        lastDate: DateTime(2050),
                      );
                      if (picked != null) {
                        setState(() {
                          _rangeStartDate = picked;
                          if (_rangeEndDate.isBefore(_rangeStartDate)) {
                            _rangeEndDate = _rangeStartDate.add(const Duration(days: 30));
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ஆரம்ப தேதி (From)', style: TextStyle(color: AppColors.lightGold, fontSize: 10.5)),
                          const SizedBox(height: 2),
                          Text(DateFormat('dd/MM/yyyy').format(_rangeStartDate), style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _rangeEndDate,
                        firstDate: _rangeStartDate,
                        lastDate: DateTime(2050),
                      );
                      if (picked != null) {
                        setState(() {
                          _rangeEndDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('முடிவு தேதி (To)', style: TextStyle(color: AppColors.lightGold, fontSize: 10.5)),
                          const SizedBox(height: 2),
                          Text(DateFormat('dd/MM/yyyy').format(_rangeEndDate), style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isSearchingRange
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.search, size: 18),
                label: Text(
                  _isSearchingRange ? 'கணக்கிடப்படுகிறது...' : 'சுப முகூர்த்த நாட்களைத் தேடுக',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isSearchingRange ? null : _performRangeSearch,
              ),
            ),
            if (_rangeResults.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'கண்டறியப்பட்ட சுப முகூர்த்த நாட்கள் (${_rangeResults.length}):',
                style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              const SizedBox(height: 6),
              ..._rangeResults.map((item) {
                final isSelected = item.date.year == _selectedDate.year &&
                    item.date.month == _selectedDate.month &&
                    item.date.day == _selectedDate.day;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = item.date;
                    });
                    _recalculate();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal.withValues(alpha: 0.25) : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? Colors.tealAccent : Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy - EEEE').format(item.date),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(
                              '${item.tamilMonth} ${item.tamilDay} • ${item.angas.nakshatraName} • ${item.angas.tithiName}',
                              style: const TextStyle(color: AppColors.lightGold, fontSize: 11),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0x2210B981),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981)),
                          ),
                          child: Text(
                            '${item.validWindows.length} சுப நேரம்',
                            style: const TextStyle(color: Color(0xFF10B981), fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ],
      ),
    );
  }

  /// Continuous Subha Windows Section
  Widget _buildSubhaWindowsSection(MuhurthaResult r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.stars, color: AppColors.primaryGold, size: 22),
            const SizedBox(width: 8),
            const Text(
              'கணக்கிடப்பட்ட சுப முகூர்த்த நேரங்கள்',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (r.validWindows.isEmpty)
          AstroCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.event_busy, color: Colors.orangeAccent, size: 40),
                const SizedBox(height: 10),
                const Text(
                  'தேர்ந்தெடுக்கப்பட்ட நாளில் தூய சுப முகூர்த்த நேரம் அமையவில்லை.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'ராகு, எமகண்டம், குளிகை, விஷ கடிகை, சந்தியா காலம் அல்லது அசுப பஞ்சகம் ஆகியவற்றால் நேரங்கள் விலக்கப்பட்டுள்ளன.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        else
          ...r.validWindows.map((win) => _buildSubhaWindowCard(win)),
      ],
    );
  }

  /// Suba Muhurtham Schedule Table Section (Admin Editable)
  Widget _buildSubaMuhurthamTableSection() {
    return AstroCard(
      padding: const EdgeInsets.all(14),
      borderGoldColor: AppColors.primaryGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.table_chart_rounded, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'சுப முகூர்த்த அட்டவணை (Suba Muhurtham Schedule)',
                  style: GoogleFonts.cinzel(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_calendar_rounded, color: AppColors.lightGold, size: 20),
                tooltip: 'நிர்வாக திருத்தம் (Admin Edit / Manage)',
                onPressed: () async {
                  await Navigator.of(context).pushNamed('/admin_suba_muhurtham');
                  _loadAdminMuhurthamData();
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'திருமணம், சீமந்தம், உபநயனம், வாசல்கால், கிரக ஆரம்பம், புது வாகனம், தொழில் தொடங்க பஞ்சாங்க சுப முகூர்த்த காலங்கள்.',
            style: GoogleFonts.outfit(
              color: AppColors.textSecondary,
              fontSize: 11.5,
            ),
          ),
          const Divider(color: AppColors.borderGold, height: 16),
          if (_isLoadingMuhurthamTable)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
            )
          else if (_adminMuhurthamList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'தற்போது சுப முகூர்த்த விவரங்கள் பதிவு செய்யப்படவில்லை.',
                  style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: AppColors.borderGold.withValues(alpha: 0.25),
                ),
                child: DataTable(
                  headingRowHeight: 40,
                  dataRowMinHeight: 38,
                  dataRowMaxHeight: 52,
                  columnSpacing: 14,
                  horizontalMargin: 8,
                  headingRowColor: WidgetStateProperty.all(AppColors.backgroundMid),
                  columns: [
                    DataColumn(label: Text('எண்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11.5))),
                    DataColumn(label: Text('தமிழ் தேதி', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11.5))),
                    DataColumn(label: Text('ஆங்கில தேதி', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11.5))),
                    DataColumn(label: Text('வாரம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11.5))),
                    DataColumn(label: Text('திதி', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11.5))),
                    DataColumn(label: Text('நட்சத்திரம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11.5))),
                    DataColumn(label: Text('யோகம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11.5))),
                    DataColumn(label: Text('முகூர்த்த நேரம் (தாலி நேரம்)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11.5))),
                    DataColumn(label: Text('லக்னம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11.5))),
                    DataColumn(label: Text('சுப காரிய விவரம்', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 11.5))),
                  ],
                  rows: _adminMuhurthamList.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(Text('$idx', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11.5))),
                        DataCell(Text(item.tamilDate, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 12))),
                        DataCell(Text(item.englishDate, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(item.dayOfWeek, style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 10.5)),
                          ),
                        ),
                        DataCell(Text(item.tithi, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11.5))),
                        DataCell(Text(item.nakshatra, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11.5))),
                        DataCell(Text(item.yoga, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11.5))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.muhurthamTime,
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11.5),
                            ),
                          ),
                        ),
                        DataCell(Text(item.lagna, style: GoogleFonts.outfit(color: AppColors.cyanAccent, fontSize: 11.5))),
                        DataCell(
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 240),
                            child: Text(
                              item.description,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Single Auspicious Window Card (with transparent Level 4 Lagna Lord & Papa Graha inspection)
  Widget _buildSubhaWindowCard(SubhaTimeWindow win) {
    final eval = win.lagnaEvaluation;

    return AstroCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      borderGoldColor: AppColors.primaryGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_filled, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      win.timingFormatted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  win.durationFormatted,
                  style: const TextStyle(
                    color: AppColors.lightGold,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTag(Icons.account_balance, 'லக்னம்: ${win.lagnaName}', Colors.cyanAccent),
              const SizedBox(width: 8),
              _buildTag(Icons.shield, win.panchakaName, Colors.amberAccent),
              const Spacer(),
              Text(
                'மதிப்பெண்: ${win.suitabilityScore.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.lightGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Detailed Level 4 Papa Grahas & House Breakdown
          if (eval != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_outlined, color: AppColors.lightGold, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'லக்னாதிபதி: ${eval.lagnaLord} (${eval.lagnaLordStrength})',
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '7-ம் இடம்: ${eval.house7Checked ? "சுத்தி ✓" : "தோஷம் ✗"}',
                          style: TextStyle(
                            color: eval.house7Checked ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '8-ம் இடம்: ${eval.house8Checked ? "சுத்தி ✓" : "தோஷம் ✗"}',
                          style: TextStyle(
                            color: eval.house8Checked ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'பாப கிரகங்கள்: ${eval.marsCheck} • ${eval.saturnCheck} • ${eval.rahuCheck} • ${eval.ketuCheck}',
                    style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.8), fontSize: 10.5),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),
          const Divider(color: Colors.white12, height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: win.reasons
                .map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('✓ ', style: TextStyle(color: Color(0xFF10B981), fontSize: 13)),
                        Expanded(
                          child: Text(
                            r,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  /// Abhijit Muhurtham Alternative Card
  Widget _buildAbhijitCard(SubhaTimeWindow abhijit) {
    return AstroCard(
      padding: const EdgeInsets.all(14),
      borderGoldColor: Colors.deepPurpleAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'அபிஜித் முகூர்த்தம் (மாற்று உத்தம நேரம்)',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'சூரிய மத்தியான நேரம்',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                abhijit.timingFormatted,
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '(${abhijit.durationFormatted})',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'மற்ற பொதுவான சுப முகூர்த்த நேரங்கள் அமையாதபோது, அனைத்து தோஷங்களையும் போக்கவல்ல மகா விஷ்ணுவிற்குரிய அபிஜித் முகூர்த்தம் சிறந்த மாற்றாக அமையும்.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  /// Automatically Excluded Inauspicious Periods Card
  Widget _buildInauspiciousPeriodsCard(MuhurthaResult r) {
    return AstroCard(
      padding: const EdgeInsets.all(14),
      borderGoldColor: const Color(0xFFEF4444).withValues(alpha: 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.block, color: Color(0xFFEF4444), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'தானாக விலக்கப்பட்ட அசுப காலங்கள் (Excluded Periods)',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'இந்த கால இடைவெளிகள் முகூர்த்த கணிதத்திலிருந்து முழுமையாக விலக்கப்பட்டுள்ளன:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 10),
          ...r.inauspiciousPeriods.map((period) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 90,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x22EF4444),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      period.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          period.timingFormatted,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          period.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
