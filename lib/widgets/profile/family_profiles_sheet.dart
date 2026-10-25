import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/astrology_calculator.dart' as service;
import '../../services/auth_service.dart';
import '../../services/geocoding_service.dart';
import '../../services/profile_service.dart';

/// Modal bottom sheet allowing users to view, switch, add (max 5),
/// and manage family birth profiles offline.
class FamilyProfilesSheet extends StatefulWidget {
  final VoidCallback? onProfileChanged;

  const FamilyProfilesSheet({super.key, this.onProfileChanged});

  static Future<void> show(BuildContext context, {VoidCallback? onProfileChanged}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FamilyProfilesSheet(onProfileChanged: onProfileChanged),
    );
  }

  @override
  State<FamilyProfilesSheet> createState() => _FamilyProfilesSheetState();
}

class _FamilyProfilesSheetState extends State<FamilyProfilesSheet> {
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

  void _showAddOrEditDialog({UserModel? existingProfile}) {
    final isEditing = existingProfile != null;
    final isFull = _profileService.isFull;

    if (!isEditing && isFull) {
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
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => _ProfileEditDialog(
        existingProfile: existingProfile,
        onSave: (savedUser) async {
          if (isEditing) {
            final res = await _profileService.updateProfile(savedUser);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(res.message), backgroundColor: AppColors.backgroundMid),
              );
            }
          } else {
            final res = await _profileService.addProfile(savedUser);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(res.message),
                  backgroundColor: res.isSuccess ? AppColors.backgroundMid : Colors.redAccent,
                ),
              );
            }
          }
          widget.onProfileChanged?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profiles = _profileService.profiles;
    final activeId = _profileService.activeProfileId;
    final isFull = _profileService.isFull;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'குடும்ப ஜாதகங்கள்',
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightGold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Family Profiles (${profiles.length}/${ProfileService.maxProfiles})',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Limit warning banner if at max 5
          if (isFull)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primaryGold, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'அதிகபட்ச வரம்பு: 5 குடும்ப ஜாதகங்கள் எட்டப்பட்டது.',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.lightGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(color: Colors.white12, height: 1),

          // Profiles List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final p = profiles[index];
                final isActive = p.id == activeId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryGold.withOpacity(0.12)
                        : AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? AppColors.primaryGold : Colors.white12,
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await _profileService.selectProfile(p.id);
                      widget.onProfileChanged?.call();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${p.name} ஜாதகம் தேர்வு செய்யப்பட்டது.',
                              style: GoogleFonts.outfit(color: AppColors.lightGold),
                            ),
                            backgroundColor: AppColors.backgroundMid,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: isActive
                                ? AppColors.primaryGold
                                : AppColors.backgroundMid,
                            child: Icon(
                              _getRelationshipIcon(p.relationship),
                              color: isActive ? AppColors.backgroundDeep : AppColors.lightGold,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Profile Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        p.name,
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isActive ? AppColors.lightGold : Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGold.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        p.relationship.isNotEmpty ? p.relationship : 'Family',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.lightGold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${p.dob} | ${p.timeOfBirth} | ${p.city.isNotEmpty ? p.city : p.placeOfBirth}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'ராசி: ${p.zodiac} | லக்னம்: ${p.lagna}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: AppColors.textSecondary.withOpacity(0.8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Action Buttons
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryGold,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, size: 14, color: AppColors.backgroundDeep),
                                )
                              else
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () async {
                                    await _profileService.selectProfile(p.id);
                                    widget.onProfileChanged?.call();
                                  },
                                  child: Text(
                                    'தேர்ந்தெடு',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: AppColors.primaryGold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.white70),
                                    tooltip: 'தொகுக்க',
                                    onPressed: () => _showAddOrEditDialog(existingProfile: p),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  if (profiles.length > 1) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                      tooltip: 'நீக்குக',
                                      onPressed: () => _confirmDelete(p),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Add Profile Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFull ? Colors.grey.shade800 : AppColors.primaryGold,
                  foregroundColor: isFull ? Colors.white38 : AppColors.backgroundDeep,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(
                  isFull ? Icons.lock_outline_rounded : Icons.person_add_alt_1_rounded,
                  size: 20,
                ),
                label: Text(
                  isFull
                      ? 'அதிகபட்சம் 5 ஜாதகங்கள் நிறைவடைந்தது'
                      : 'புதிய குடும்ப ஜாதகம் சேர்க்க (${profiles.length}/5)',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _showAddOrEditDialog(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(UserModel p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        title: Text(
          'ஜாதகத்தை நீக்கவா?',
          style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${p.name} (${p.relationship}) ஜாதகத்தை நிச்சயம் நீக்க விரும்புகிறீர்களா?',
          style: GoogleFonts.outfit(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ரத்து', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await _profileService.deleteProfile(p.id);
              widget.onProfileChanged?.call();
            },
            child: const Text('நீக்கு', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

/// Dialog to Add or Edit a Family Member Birth Profile
class _ProfileEditDialog extends StatefulWidget {
  final UserModel? existingProfile;
  final ValueChanged<UserModel> onSave;

  const _ProfileEditDialog({
    this.existingProfile,
    required this.onSave,
  });

  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _placeController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _latController;
  late TextEditingController _lonController;
  late TextEditingController _tzController;

  late String _relationship;
  late String _gender;
  late DateTime _dob;
  late TimeOfDay _tob;

  String _zodiac = 'Mesha';
  String _nakshatra = 'Ashwini';
  String _lagna = 'Mesha';

  final List<String> _relationshipOptions = [
    'Self',
    'Father',
    'Mother',
    'Spouse',
    'Child',
    'Brother',
    'Sister',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.existingProfile;

    _nameController = TextEditingController(text: p?.name ?? '');
    _placeController = TextEditingController(text: p?.placeOfBirth ?? 'Chennai, Tamil Nadu');
    _cityController = TextEditingController(text: p?.city ?? 'Chennai');
    _stateController = TextEditingController(text: p?.state ?? 'Tamil Nadu');
    _latController = TextEditingController(text: '${p?.latitude ?? 13.0827}');
    _lonController = TextEditingController(text: '${p?.longitude ?? 80.2707}');
    _tzController = TextEditingController(text: '${p?.timezone ?? 5.5}');

    _relationship = p?.relationship ?? 'Child';
    if (!_relationshipOptions.contains(_relationship)) {
      _relationship = 'Other';
    }

    _gender = p?.gender ?? 'Male';
    _dob = p?.birthDateTime ?? DateTime(2000, 1, 1);
    _tob = TimeOfDay(hour: _dob.hour, minute: _dob.minute);

    _zodiac = p?.zodiac ?? 'Mesha';
    _nakshatra = p?.nakshatra ?? 'Ashwini';
    _lagna = p?.lagna ?? 'Mesha';

    _recalculateAstrology();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _tzController.dispose();
    super.dispose();
  }

  void _recalculateAstrology() {
    final dt = DateTime(_dob.year, _dob.month, _dob.day, _tob.hour, _tob.minute);
    final lat = double.tryParse(_latController.text) ?? 13.0827;
    final lon = double.tryParse(_lonController.text) ?? 80.2707;
    final tz = double.tryParse(_tzController.text) ?? 5.5;

    try {
      final res = service.AstrologyCalculator.calculateHoroscope(
        dateOfBirth: dt,
        latitude: lat,
        longitude: lon,
        utcOffsetHours: tz,
      );

      setState(() {
        _zodiac = '${res.moon.rasiNameTa} (${res.moon.rasiNameEn})';
        _nakshatra = '${res.moon.nakshatraNameTa} (${res.moon.nakshatraNameEn})';
        _lagna = '${res.lagna.rasiNameTa} (${res.lagna.rasiNameEn})';
      });
    } catch (_) {}
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGold,
              onPrimary: AppColors.backgroundDeep,
              surface: AppColors.backgroundMid,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dob = picked);
      _recalculateAstrology();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _tob,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGold,
              onPrimary: AppColors.backgroundDeep,
              surface: AppColors.backgroundMid,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _tob = picked);
      _recalculateAstrology();
    }
  }

  void _onPlaceChanged(String val) {
    final loc = GeocodingService.resolvePlace(val);
    if (loc != null) {
      setState(() {
        _cityController.text = loc.cityName;
        _stateController.text = loc.state;
        _latController.text = '${loc.latitude}';
        _lonController.text = '${loc.longitude}';
      });
      _recalculateAstrology();
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final hour = _tob.hour;
    final minute = _tob.minute;
    final isPm = hour >= 12;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final tobStr = '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${isPm ? 'PM' : 'AM'}';
    final dobStr = DateFormat('yyyy-MM-dd').format(_dob);

    final user = UserModel(
      id: widget.existingProfile?.id ?? '',
      name: _nameController.text.trim(),
      mobile: widget.existingProfile?.mobile ?? AuthService.currentUser?.mobile ?? '',
      gender: _gender,
      dob: dobStr,
      timeOfBirth: tobStr,
      placeOfBirth: _placeController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: 'India',
      zodiac: _zodiac,
      nakshatra: _nakshatra,
      lagna: _lagna,
      walletBalance: widget.existingProfile?.walletBalance ?? 500.0,
      role: 'User',
      profilePhoto: widget.existingProfile?.profilePhoto ?? '',
      latitude: double.tryParse(_latController.text) ?? 13.0827,
      longitude: double.tryParse(_lonController.text) ?? 80.2707,
      timezone: double.tryParse(_tzController.text) ?? 5.5,
      relationship: _relationship,
    );

    widget.onSave(user);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingProfile != null;

    return Dialog(
      backgroundColor: AppColors.backgroundDeep,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 620),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'ஜாதக விபரம் தொகுக்க' : 'புதிய ஜாதகம் சேர்க்க',
                    style: GoogleFonts.cinzel(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.white12),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text('பெயர் (Name)', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('எ.கா. முரளிதரன்'),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'பெயர் தேவை' : null,
                      ),
                      const SizedBox(height: 12),

                      // Relationship & Gender Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('உறவு (Relation)', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: _relationship,
                                  dropdownColor: AppColors.backgroundMid,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration(''),
                                  items: _relationshipOptions.map((r) {
                                    return DropdownMenuItem(value: r, child: Text(r));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _relationship = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('பாலினம் (Gender)', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: _gender,
                                  dropdownColor: AppColors.backgroundMid,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration(''),
                                  items: const [
                                    DropdownMenuItem(value: 'Male', child: Text('ஆண் (Male)')),
                                    DropdownMenuItem(value: 'Female', child: Text('பெண் (Female)')),
                                    DropdownMenuItem(value: 'Other', child: Text('மற்றவை')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _gender = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Date of Birth & Time of Birth
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('பிறந்த தேதி (DOB)', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: _pickDate,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardSurface,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('dd-MM-yyyy').format(_dob),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.lightGold),
                                      ],
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
                                Text('பிறந்த நேரம் (TOB)', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: _pickTime,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardSurface,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _tob.format(context),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        const Icon(Icons.access_time_rounded, size: 16, color: AppColors.lightGold),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Birth Place
                      Text('பிறந்த இடம் (Place of Birth)', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _placeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('எ.கா. Chennai / Madurai / Coimbatore'),
                        onChanged: _onPlaceChanged,
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'இடம் தேவை' : null,
                      ),
                      const SizedBox(height: 12),

                      // Live Astrology Info Preview
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundMid,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'கணிக்கப்பட்ட விபரம் (Calculated):',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lightGold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('ராசி: $_zodiac', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('நட்சத்திரம்: $_nakshatra', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('லக்னம்: $_lagna', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.backgroundDeep,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submit,
                  child: Text(
                    isEditing ? 'புதுப்பிக்க (Update)' : 'சேமிக்க (Save Profile)',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
      filled: true,
      fillColor: AppColors.cardSurface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryGold),
      ),
    );
  }
}
