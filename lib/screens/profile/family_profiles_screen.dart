import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../services/profile_service.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/profile/family_profiles_sheet.dart';

/// Full screen interface for Priority 4:
/// 15. Offline Saved Profiles
/// 16. Maximum 5 Family Profiles
/// 17. Profile Switching
/// 18. Persistent Local Storage
/// 19. 4-Slot Quick Consultation View Shortcut
class FamilyProfilesScreen extends StatefulWidget {
  const FamilyProfilesScreen({super.key});

  @override
  State<FamilyProfilesScreen> createState() => _FamilyProfilesScreenState();
}

class _FamilyProfilesScreenState extends State<FamilyProfilesScreen> {
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

  IconData _getRelationshipIcon(String rel) {
    switch (rel.toLowerCase()) {
      case 'father':
      case 'தந்தை':
        return Icons.elderly_rounded;
      case 'mother':
      case 'தாய்':
        return Icons.elderly_woman_rounded;
      case 'spouse':
      case 'மனைவி':
      case 'கணவர்':
        return Icons.favorite_rounded;
      case 'child':
      case 'மகன்':
      case 'மகள்':
        return Icons.child_care_rounded;
      case 'brother':
      case 'சகோதரன்':
      case 'sister':
      case 'சகோதரி':
        return Icons.people_outline_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profiles = _profileService.profiles;
    final activeId = _profileService.activeProfileId;
    final count = _profileService.count;
    final isFull = _profileService.isFull;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMid,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.lightGold, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'குடும்ப ஜாதகங்கள்',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.lightGold,
              ),
            ),
            Text(
              'Family Profiles & Switching (Max 5 Offline)',
              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isFull ? Colors.red.withOpacity(0.2) : AppColors.primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isFull ? Colors.redAccent : AppColors.primaryGold,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_alt_rounded,
                  size: 14,
                  color: isFull ? Colors.redAccent : AppColors.lightGold,
                ),
                const SizedBox(width: 4),
                Text(
                  '$count / 5',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isFull ? Colors.redAccent : AppColors.lightGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // Offline Storage & Limit Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGold.withOpacity(0.15),
                      AppColors.backgroundMid,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderGold.withOpacity(0.6)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.offline_pin_rounded, color: AppColors.lightGold, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '100% ஆஃப்லைன் உள்ளூர் சேமிப்பு (Persistent Storage)',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'அதிகபட்சம் 5 குடும்ப உறுப்பினர்களின் ஜாதகங்களைச் சேமித்து இணையம் இன்றியே விரைவாக மாற்றிக்கொள்ளலாம்.',
                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4-Slot Quick Consultation Banner
              InkWell(
                onTap: () => Navigator.of(context).pushNamed('/quick_consultation'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryGold, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.dashboard_customize_rounded, color: AppColors.lightGold, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '4-ஸ்லாட் விரைவு ஆலோசனை பார்வை',
                              style: GoogleFonts.cinzel(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightGold,
                              ),
                            ),
                            Text(
                              'Slot 1: தகவல் • Slot 2: ராசி • Slot 3: KP நாதர்கள் • Slot 4: தசா புத்தி',
                              style: GoogleFonts.outfit(fontSize: 10.5, color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.lightGold),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Profiles List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'சேமிக்கப்பட்ட சுயவிவரங்கள் (SAVED PROFILES)',
                    style: GoogleFonts.cinzel(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppColors.lightGold,
                    ),
                  ),
                  Text(
                    '$count / 5',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isFull ? Colors.redAccent : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Profiles List
              ...profiles.map((profile) {
                final isActive = profile.id == activeId;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primaryGold.withOpacity(0.12) : AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? AppColors.primaryGold : AppColors.borderGold.withOpacity(0.4),
                      width: isActive ? 1.8 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive ? AppColors.primaryGold : AppColors.backgroundMid,
                              border: Border.all(color: AppColors.primaryGold),
                            ),
                            child: Icon(
                              _getRelationshipIcon(profile.relationship),
                              size: 20,
                              color: isActive ? AppColors.backgroundDeep : AppColors.lightGold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        profile.name,
                                        style: GoogleFonts.cinzel(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isActive ? AppColors.lightGold : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGold,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'ACTIVE / நடைமுறையில்',
                                          style: GoogleFonts.outfit(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.backgroundDeep,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'உறவு: ${profile.relationship.isNotEmpty ? profile.relationship : "Self (சுயவிவரம்)"}',
                                  style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: Colors.white10, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.cake_rounded, size: 12, color: AppColors.lightGold),
                                    const SizedBox(width: 4),
                                    Text(
                                      'பிறப்பு: ${profile.dob} • ${profile.tob}',
                                      style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 12, color: AppColors.lightGold),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'இடம்: ${profile.placeOfBirth} (${profile.latitude.toStringAsFixed(2)}°, ${profile.longitude.toStringAsFixed(2)}°)',
                                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!isActive)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGold,
                                foregroundColor: AppColors.backgroundDeep,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () async {
                                await _profileService.setActiveProfile(profile.id);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${profile.name} ஜாதகம் செயல்படுத்தப்பட்டது!'),
                                      backgroundColor: AppColors.backgroundMid,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.check_circle_rounded, size: 16),
                              label: Text(
                                'மாற்று (Switch)',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.lightGold,
                              side: const BorderSide(color: AppColors.borderGold),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => FamilyProfilesSheet.show(context),
                            icon: const Icon(Icons.edit_rounded, size: 14),
                            label: Text('திருத்து (Edit)', style: GoogleFonts.outfit(fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 14),

              // Add Profile Button (with hard 5 profile max limit)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFull ? Colors.grey.shade800 : AppColors.primaryGold,
                  foregroundColor: isFull ? Colors.white54 : AppColors.backgroundDeep,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  if (isFull) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ProfileService.limitReachedMessageTa,
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.redAccent.shade700,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  } else {
                    FamilyProfilesSheet.show(context);
                  }
                },
                icon: Icon(isFull ? Icons.block_rounded : Icons.person_add_alt_1_rounded, size: 20),
                label: Text(
                  isFull
                      ? 'அதிகபட்சம் 5 ஜாதகங்கள் நிறைவடைந்தது (5/5 Limit Reached)'
                      : '+ புதிய குடும்ப ஜாதகம் சேர்க்க (Add Member)',
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
