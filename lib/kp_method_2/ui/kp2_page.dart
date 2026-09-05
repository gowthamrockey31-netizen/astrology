import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosmic_background.dart';
import '../engine/kp2_complete_engine.dart';
import '../models/kp2_birth_data.dart';
import '../models/kp2_result.dart';
import 'kp2_summary.dart';
import 'kp2_planets.dart';
import 'kp2_cusps.dart';
import 'kp2_ruling_planets.dart';
import 'kp2_significators.dart';
import 'kp2_dasha.dart';

/// KP Method 2 Main Page (கே.பி முறை 2)
/// Fully independent and isolated module with Swiss Ephemeris Placidus cusps and Advantage rule
class KPMethod2Page extends StatefulWidget {
  final KP2BirthData? initialBirthData;

  const KPMethod2Page({super.key, this.initialBirthData});

  @override
  State<KPMethod2Page> createState() => _KPMethod2PageState();
}

class _KPMethod2PageState extends State<KPMethod2Page> {
  late KP2BirthData _birthData;
  KP2Result? _result;
  bool _isLoading = true;
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'சுருக்கம் (Overview)',
    'கிரகங்கள் (9 Planets)',
    'பாவங்கள் (12 Cusps)',
    'ஆளும் கிரகங்கள் (Ruling)',
    'காரகங்கள் & அட்வான்டேஜ்',
    'தசா புக்தி (Dasha)',
    'அனைத்தும் (All In One)',
  ];

  @override
  void initState() {
    super.initState();
    _initBirthData();
    _computeResults();
  }

  void _initBirthData() {
    if (widget.initialBirthData != null) {
      _birthData = widget.initialBirthData!;
    } else {
      final user = AuthService.currentUser;
      if (user != null) {
        _birthData = KP2BirthData.fromUserModel(user);
      } else {
        _birthData = KP2BirthData.defaultTestProfile();
      }
    }
  }

  void _computeResults() {
    setState(() => _isLoading = true);
    try {
      final res = KP2CompleteEngine.calculate(_birthData);
      setState(() {
        _result = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showEditProfileDialog() {
    final dateCtrl = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(_birthData.date),
    );
    final timeCtrl = TextEditingController(text: _birthData.time);
    final placeCtrl = TextEditingController(text: _birthData.place);
    final latCtrl = TextEditingController(text: _birthData.latitude.toString());
    final lonCtrl = TextEditingController(text: _birthData.longitude.toString());
    final tzCtrl = TextEditingController(text: _birthData.timezone.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.primaryGold, width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(Icons.edit_calendar_rounded, color: AppColors.primaryGold),
            const SizedBox(width: 8),
            Text(
              'சுயவிவரம் திருத்து (Edit Profile)',
              style: GoogleFonts.notoSansTamil(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.lightGold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField('பிறந்த தேதி (DD-MM-YYYY)', dateCtrl),
              _buildDialogField('பிறந்த நேரம் (e.g. 01:25 PM)', timeCtrl),
              _buildDialogField('இடம் (Place)', placeCtrl),
              _buildDialogField('அட்சரேகை (Latitude)', latCtrl, isNum: true),
              _buildDialogField('தீர்க்கரேகை (Longitude)', lonCtrl, isNum: true),
              _buildDialogField('டைம்ஜோன் (Timezone e.g. 5.5)', tzCtrl, isNum: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ரத்து செய்', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              DateTime parsedDate;
              try {
                parsedDate = DateFormat('dd-MM-yyyy').parse(dateCtrl.text);
              } catch (_) {
                parsedDate = _birthData.date;
              }

              setState(() {
                _birthData = KP2BirthData(
                  date: parsedDate,
                  time: timeCtrl.text.trim().isNotEmpty ? timeCtrl.text.trim() : _birthData.time,
                  place: placeCtrl.text.trim().isNotEmpty ? placeCtrl.text.trim() : _birthData.place,
                  latitude: double.tryParse(latCtrl.text) ?? _birthData.latitude,
                  longitude: double.tryParse(lonCtrl.text) ?? _birthData.longitude,
                  timezone: double.tryParse(tzCtrl.text) ?? _birthData.timezone,
                );
              });
              Navigator.pop(ctx);
              _computeResults();
            },
            child: const Text('கணக்கிடு (Calculate)', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController ctrl, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: ctrl,
        keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 12),
          filled: true,
          fillColor: AppColors.backgroundLight,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryGold),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMid.withValues(alpha: 0.95),
        elevation: 2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KP METHOD 2',
              style: GoogleFonts.cinzel(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.lightGold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'கே.பி முறை 2 - துல்லிய பிளாசிடஸ் & அட்வான்டேஜ்',
              style: GoogleFonts.notoSansTamil(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'சுயவிவரம் திருத்து (Edit Profile)',
            icon: const Icon(Icons.edit_calendar_rounded, color: AppColors.primaryGold),
            onPressed: _showEditProfileDialog,
          ),
          IconButton(
            tooltip: 'மறுகணக்கீடு (Recalculate)',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.lightGold),
            onPressed: _computeResults,
          ),
        ],
      ),
      body: CosmicBackground(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGold),
              )
            : _result == null
                ? const Center(
                    child: Text(
                      'கணித பிழை ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  )
                : SafeArea(
                    child: Column(
                      children: [
                        // Tab Selector Row
                        _buildTabSelector(),

                        // Content View
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: _buildSelectedContent(),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        itemBuilder: (context, idx) {
          final isSelected = _selectedTabIndex == idx;
          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = idx),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGold
                    : AppColors.backgroundLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGold
                      : AppColors.primaryGold.withValues(alpha: 0.25),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryGold.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  _tabs[idx],
                  style: GoogleFonts.notoSansTamil(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.textDark : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedContent() {
    final res = _result!;

    switch (_selectedTabIndex) {
      case 0: // Overview
        return Column(
          children: [
            KP2SummaryWidget(
              result: res,
              onEditProfile: _showEditProfileDialog,
            ),
            const SizedBox(height: 16),
            KP2RulingPlanetsWidget(rulingPlanets: res.rulingPlanets),
          ],
        );
      case 1: // 9 Planets
        return Column(
          children: [
            KP2PlanetsWidget(planetPositions: res.planetPositions),
          ],
        );
      case 2: // 12 Cusps
        return Column(
          children: [
            KP2CuspsWidget(cusps: res.cusps),
          ],
        );
      case 3: // Ruling Planets
        return Column(
          children: [
            KP2RulingPlanetsWidget(rulingPlanets: res.rulingPlanets),
          ],
        );
      case 4: // Significators & Advantage
        return Column(
          children: [
            KP2SignificatorsWidget(
              planetSignificators: res.planetSignificators,
              houseSignificators: res.houseSignificators,
            ),
          ],
        );
      case 5: // Dasha Bhukti
        return Column(
          children: [
            KP2DashaWidget(
              dashaBalance: res.dashaBalance,
              dashaTimeline: res.dashaTimeline,
            ),
          ],
        );
      case 6: // All in One
      default:
        return Column(
          children: [
            KP2SummaryWidget(
              result: res,
              onEditProfile: _showEditProfileDialog,
            ),
            const SizedBox(height: 16),
            KP2PlanetsWidget(planetPositions: res.planetPositions),
            const SizedBox(height: 16),
            KP2CuspsWidget(cusps: res.cusps),
            const SizedBox(height: 16),
            KP2RulingPlanetsWidget(rulingPlanets: res.rulingPlanets),
            const SizedBox(height: 16),
            KP2SignificatorsWidget(
              planetSignificators: res.planetSignificators,
              houseSignificators: res.houseSignificators,
            ),
            const SizedBox(height: 16),
            KP2DashaWidget(
              dashaBalance: res.dashaBalance,
              dashaTimeline: res.dashaTimeline,
            ),
          ],
        );
    }
  }
}
