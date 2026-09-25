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

/// ===============================================================
/// SUBHA MUHURTHAM TIME CALCULATION (சுப முகூர்த்த நேரம் கணிதம்)
/// High Precision Classical Astrology Engine UI
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

  bool _isPersonalized = false;
  int _birthNakshatra = 0; // Ashwini
  int _birthRasi = 0; // Mesham
  String _personName = 'அன்பர்';

  MuhurthaResult? _result;

  List<SubaMuhurthamModel> _adminMuhurthamList = [];
  bool _isLoadingMuhurthamTable = true;

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
          'சுப முகூர்த்த நேரம்',
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

                    // 3. Personalization Settings (Tara & Chandra Bala toggle)
                    _buildPersonalizationCard(),
                    const SizedBox(height: 16),

                    // 4. Overall Verdict Banner
                    _buildVerdictBanner(r),
                    const SizedBox(height: 16),

                    // 5. Continuous Subha Muhurtham Windows (Primary Goal)
                    _buildSubhaWindowsSection(r),
                    const SizedBox(height: 18),

                    // 5b. பஞ்சாங்க சுப முகூர்த்த அட்டவணை (Admin-Editable Suba Muhurtham Schedule Table)
                    _buildSubaMuhurthamTableSection(),
                    const SizedBox(height: 18),

                    // 6. Abhijit Muhurtham Alternative Card
                    if (r.abhijitMuhurtham != null) ...[
                      _buildAbhijitCard(r.abhijitMuhurtham!),
                      const SizedBox(height: 18),
                    ],

                    // 7. Panchanga Five Angas (Tithi, Vara, Nakshatra, Yoga, Karana)
                    _buildFiveAngasCard(r),
                    const SizedBox(height: 18),

                    // 8. Automatically Excluded Inauspicious Periods (Rahu, Yama, Gulikai, Visha, Sandhya)
                    _buildInauspiciousPeriodsCard(r),
                    const SizedBox(height: 18),

                    // 9. Traditional Balas & Checks (Tara Bala, Chandra Bala, Guru Bala, Surya Bala, Month, Kathiri)
                    _buildSpecialBalasCard(r),
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
    final bool hasWindows = r.validWindows.isNotEmpty;

    Color bannerColor;
    IconData iconData;
    String statusTitle;

    if (isChandrashtama) {
      bannerColor = const Color(0xFFEF4444);
      iconData = Icons.dangerous;
      statusTitle = 'சந்திராஷ்டமம் எச்சரிக்கை!';
    } else if (hasWindows) {
      bannerColor = const Color(0xFF10B981);
      iconData = Icons.verified;
      statusTitle = 'சுப முகூர்த்த நாள்';
    } else {
      bannerColor = const Color(0xFFF59E0B);
      iconData = Icons.info_outline;
      statusTitle = 'முகூர்த்த இடைவெளிகள் இல்லை';
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

  /// Single Auspicious Window Card
  Widget _buildSubhaWindowCard(SubhaTimeWindow win) {
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

  /// Panchanga 5 Angas Card
  Widget _buildFiveAngasCard(MuhurthaResult r) {
    final a = r.angas;

    return AstroCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_stories, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'பஞ்சாங்க பஞ்ச அங்கங்கள் (Five Angas)',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAngaRow(
            title: '1. திதி',
            value: '${a.tithiName} (${a.paksha})',
            isGood: a.isTithiPreferred,
            reason: a.tithiReason,
          ),
          const Divider(color: Colors.white10, height: 16),
          _buildAngaRow(
            title: '2. வாரம் (கிழமை)',
            value: a.weekdayName,
            isGood: a.isVaraPreferred,
            reason: a.varaReason,
          ),
          const Divider(color: Colors.white10, height: 16),
          _buildAngaRow(
            title: '3. நட்சத்திரம்',
            value: a.nakshatraName,
            isGood: a.isNakshatraSuitable,
            reason: a.nakshatraReason,
          ),
          const Divider(color: Colors.white10, height: 16),
          _buildAngaRow(
            title: '4. யோகம்',
            value: '${a.yogaName} • ${a.amirthathiYoga}',
            isGood: a.isYogaAuspicious,
            reason: a.yogaReason,
          ),
          const Divider(color: Colors.white10, height: 16),
          _buildAngaRow(
            title: '5. கரணம்',
            value: a.karanaName,
            isGood: a.isKaranaAuspicious,
            reason: a.karanaReason,
          ),
        ],
      ),
    );
  }

  Widget _buildAngaRow({
    required String title,
    required String value,
    required bool isGood,
    required String reason,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.lightGold,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isGood ? const Color(0x3310B981) : const Color(0x33EF4444),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isGood ? 'உகந்தது' : 'தவிர்க்கவும்',
                style: TextStyle(
                  color: isGood ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          reason,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
          ),
        ),
      ],
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

  /// Traditional Balas and Checks Card
  Widget _buildSpecialBalasCard(MuhurthaResult r) {
    return AstroCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              const Text(
                'பாரம்பரிய முகூர்த்த பலன்கள் & விதிகள்',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Month Rule & Month Sunyam
          _buildBalaTile(
            title: 'மாத விதி & மாத சூன்யம்',
            badge: r.isMonthPreferred ? 'உகந்த மாதம்' : 'விலக்க வேண்டிய மாதம்',
            isGood: r.isMonthPreferred,
            description: '${r.monthRestrictionReason}\nமாத சூன்ய ராசிகள்: ${r.monthSunyamRasis.isEmpty ? "இல்லை" : r.monthSunyamRasis.join(", ")}',
          ),
          const Divider(color: Colors.white10, height: 16),

          // Kathiri / Agni Nakshatra
          _buildBalaTile(
            title: 'அக்னி நட்சத்திரம் (கத்திரி வெயில்)',
            badge: r.isKathiriAgniActive ? 'கத்திரி காலம்' : 'பாதிப்பு இல்லை',
            isGood: !r.isKathiriAgniActive,
            description: r.kathiriReason,
          ),

          if (_isPersonalized) ...[
            const Divider(color: Colors.white10, height: 16),

            // Tara Bala
            if (r.taraBala != null)
              _buildBalaTile(
                title: 'தாராபலம் (Tara Bala)',
                badge: r.taraBala!.status,
                isGood: r.taraBala!.isAccepted,
                description: '${r.taraBala!.taraName} (எண்: ${r.taraBala!.taraNumber}) - ${r.taraBala!.reason}',
              ),

            // Chandra Bala
            if (r.chandraBala != null) ...[
              const Divider(color: Colors.white10, height: 16),
              _buildBalaTile(
                title: 'சந்திரபலம் (Chandra Bala)',
                badge: r.chandraBala!.status,
                isGood: !r.chandraBala!.isChandrashtama && r.chandraBala!.isPreferred,
                description: 'பிறந்த ராசி: ${r.chandraBala!.birthRasi} → அன்றைய சந்திரன்: ${r.chandraBala!.moonRasi} (${r.chandraBala!.relativeHouse}-ம் இடம்) - ${r.chandraBala!.reason}',
              ),
            ],

            // Guru Bala (Marriage specific)
            if (r.guruBala != null && _category == MuhurthaCategory.marriage) ...[
              const Divider(color: Colors.white10, height: 16),
              _buildBalaTile(
                title: 'குருபலம் (திருமணத்திற்கு உகந்தது)',
                badge: r.guruBala!.status,
                isGood: r.guruBala!.isAuspicious,
                description: 'ஜென்ம ராசிக்கு குரு ${r.guruBala!.relativeHouse}-ம் இடத்தில் சஞ்சாரம் (${r.guruBala!.jupiterRasi}) - ${r.guruBala!.reason}',
              ),
            ],

            // Surya Bala
            if (r.suryaBala != null) ...[
              const Divider(color: Colors.white10, height: 16),
              _buildBalaTile(
                title: 'சூரிய பலம் (Surya Bala)',
                badge: r.suryaBala!.status,
                isGood: r.suryaBala!.isAuspicious,
                description: 'ஜென்ம ராசிக்கு சூரியன் ${r.suryaBala!.relativeHouse}-ம் இடத்தில் சஞ்சாரம் (${r.suryaBala!.sunRasi}) - ${r.suryaBala!.reason}',
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildBalaTile({
    required String title,
    required String badge,
    required bool isGood,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isGood ? const Color(0x3310B981) : const Color(0x33EF4444),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: isGood ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          description,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
            height: 1.3,
          ),
        ),
      ],
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
