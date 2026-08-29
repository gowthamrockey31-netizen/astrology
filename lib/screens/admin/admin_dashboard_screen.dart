import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/file_picker_helper.dart' as filePicker;
import '../../core/theme/app_colors.dart';
import '../../models/astrologer_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/cosmic_drawer.dart';

class AdminDashboardScreen extends StatefulWidget {
  final Function(String route) onNavigate;

  const AdminDashboardScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<AstrologerModel> _astrologers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await FirestoreService.fetchAstrologers();
    if (mounted) {
      setState(() {
        _astrologers = list;
        _isLoading = false;
      });
    }
  }

  void _confirmDeleteAstrologer(AstrologerModel ast) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        title: Text("Delete Astrologer", style: GoogleFonts.cinzel(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete '${ast.name}' from the system?", style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text("Cancel", style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text("Delete", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirestoreService.deleteAstrologer(ast.id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("'${ast.name}' has been deleted.", style: GoogleFonts.poppins(color: AppColors.lightGold)),
            backgroundColor: AppColors.backgroundMid,
          ),
        );
      }
    }
  }

  void _pickImageFile(Function(String photoDataUrl) onPicked) {
    if (kIsWeb) {
      filePicker.pickImageFile(onPicked);
    }
  }

  void _showAddAstrologerDialog() => _showAstrologerFormDialog();

  void _showAstrologerFormDialog({AstrologerModel? astToEdit}) async {
    final isEditing = astToEdit != null;
    final nameCtrl = TextEditingController(text: isEditing ? astToEdit.name : '');
    final emailCtrl = TextEditingController(text: isEditing ? astToEdit.email : '');
    final passwordCtrl = TextEditingController(text: isEditing ? astToEdit.password : 'password123');
    final specCtrl = TextEditingController(text: isEditing ? astToEdit.specializations.join(', ') : 'Vedic Astrology, Nadi');
    final langCtrl = TextEditingController(text: isEditing ? astToEdit.languages.join(', ') : 'Tamil, English');
    final expCtrl = TextEditingController(text: isEditing ? '${astToEdit.experienceYears}' : '10');
    final feeCtrl = TextEditingController(text: isEditing ? '${astToEdit.consultationFee}' : '30.0');
    final cityCtrl = TextEditingController(text: isEditing ? '${astToEdit.city}, ${astToEdit.state}' : 'Chennai, TN');
    final phoneCtrl = TextEditingController(text: isEditing ? astToEdit.mobile : '+919876543211');

    String selectedPhotoUrl = isEditing ? astToEdit.photoUrl : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80';

    final presetAvatars = [
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=300&q=80',
    ];

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundMid,
              insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.borderGold, width: 1.5),
              ),
              title: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_note_rounded : Icons.person_add_alt_1_rounded,
                    color: AppColors.lightGold,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEditing ? "Edit Astrologer Details" : "Add New Astrologer",
                      style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Upload / Dropzone Widget
                      Text("Astrologer Photo", style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {
                          _pickImageFile((dataUrl) {
                            setModalState(() {
                              selectedPhotoUrl = dataUrl;
                            });
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primaryGold, width: 1.2),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(selectedPhotoUrl),
                                onBackgroundImageError: (_, __) {},
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.cloud_upload_rounded, color: AppColors.lightGold, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Drag & Drop / Upload Photo",
                                          style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "Click to pick photo file from device",
                                      style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 14),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Preset Avatars Quick Selector
                      Text("Or Select Preset Avatar:", style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11)),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: presetAvatars.map((url) {
                            final isSel = selectedPhotoUrl == url;
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedPhotoUrl = url;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSel ? AppColors.lightGold : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(url),
                                  onBackgroundImageError: (_, __) {},
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: nameCtrl,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(labelText: "Astrologer Full Name", labelStyle: TextStyle(color: AppColors.lightGold)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: "Unique Email Address (Required for Login)",
                          labelStyle: TextStyle(color: AppColors.lightGold),
                          hintText: "astrologer@astrodashacare.com",
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordCtrl,
                        obscureText: true,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: "Login Password",
                          labelStyle: TextStyle(color: AppColors.lightGold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: specCtrl,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(labelText: "Specializations (comma separated)", labelStyle: TextStyle(color: AppColors.lightGold)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: langCtrl,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(labelText: "Languages (comma separated)", labelStyle: TextStyle(color: AppColors.lightGold)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: expCtrl,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(labelText: "Exp (Years)", labelStyle: TextStyle(color: AppColors.lightGold)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: feeCtrl,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(labelText: "Fee (₹/min)", labelStyle: TextStyle(color: AppColors.lightGold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: cityCtrl,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(labelText: "City & State", labelStyle: TextStyle(color: AppColors.lightGold)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phoneCtrl,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(labelText: "Mobile Number", labelStyle: TextStyle(color: AppColors.lightGold)),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text("Cancel", style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final emailInput = emailCtrl.text.trim().toLowerCase();
                    if (emailInput.isEmpty || !emailInput.contains('@')) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid unique email address.')),
                      );
                      return;
                    }
                    final isDuplicate = _astrologers.any((a) => a.email.trim().toLowerCase() == emailInput && (!isEditing || a.id != astToEdit.id));
                    if (isDuplicate) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text("Email '$emailInput' is already assigned to another astrologer!")),
                      );
                      return;
                    }
                    Navigator.of(ctx).pop(true);
                  },
                  child: Text(
                    isEditing ? "Save Changes" : "Add Astrologer",
                    style: GoogleFonts.poppins(color: AppColors.textDark, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      final specs = specCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      final langs = langCtrl.text.split(',').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

      final updatedAst = AstrologerModel(
        id: isEditing ? astToEdit.id : 'ast_${DateTime.now().millisecondsSinceEpoch}',
        name: nameCtrl.text.trim(),
        photoUrl: selectedPhotoUrl,
        mobile: phoneCtrl.text.trim(),
        email: emailCtrl.text.trim().toLowerCase(),
        password: passwordCtrl.text.trim().isNotEmpty ? passwordCtrl.text.trim() : 'password123',
        gender: isEditing ? astToEdit.gender : 'Male',
        city: cityCtrl.text.trim(),
        state: 'Tamil Nadu',
        experienceYears: int.tryParse(expCtrl.text.trim()) ?? 10,
        qualification: isEditing ? astToEdit.qualification : 'Certified Vedic Astrologer',
        specializations: specs.isNotEmpty ? specs : ['Vedic Astrology'],
        languages: langs.isNotEmpty ? langs : ['Tamil', 'English'],
        consultationFee: double.tryParse(feeCtrl.text.trim()) ?? 30.0,
        rating: isEditing ? astToEdit.rating : 5.0,
        totalReviews: isEditing ? astToEdit.totalReviews : 1,
        status: isEditing ? astToEdit.status : 'online',
        estimatedWaitMinutes: 0,
        verificationStatus: 'approved',
      );

      if (isEditing) {
        await FirestoreService.editAstrologer(updatedAst);
      } else {
        await FirestoreService.addAstrologer(updatedAst);
      }

      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? "Astrologer '${updatedAst.name}' updated successfully!" : "Astrologer '${updatedAst.name}' added successfully!",
              style: GoogleFonts.poppins(color: AppColors.lightGold),
            ),
            backgroundColor: AppColors.backgroundMid,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _astrologers.where((a) => a.verificationStatus == 'pending').length;

    return Scaffold(
      key: _scaffoldKey,
      drawer: CosmicDrawer(
        onSelectRoute: (route) {
          Navigator.of(context).pop();
          widget.onNavigate(route);
        },
      ),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMid,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.lightGold),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text('Admin Control Panel', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revenue Summary Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.purpleAccent, AppColors.backgroundMid],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderGold),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL PLATFORM REVENUE',
                              style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 0.8),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('₹1,240,500', style: GoogleFonts.cinzel(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'COMMISSION (20%)',
                            style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('₹248,100', style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // CMS & Management Suite (Compact Tiles)
                Text('Admin Management Suite', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 13)),
                const SizedBox(height: 8),

                _buildCmsTile(
                  title: 'Manage Dynamic T&C',
                  subtitle: 'Firestore Terms CRUD',
                  icon: Icons.gavel_rounded,
                  onTap: () => widget.onNavigate('/admin_terms'),
                ),
                _buildCmsTile(
                  title: 'AstroDashaCare Magazine CMS',
                  subtitle: 'Articles, Images & Videos',
                  icon: Icons.menu_book_rounded,
                  onTap: () => widget.onNavigate('/admin_magazine'),
                ),
                _buildCmsTile(
                  title: 'Live Panchangam CMS',
                  subtitle: 'Add, Edit & Delete Daily Tithi, Rahu Kalam',
                  icon: Icons.calendar_month_rounded,
                  onTap: () => widget.onNavigate('/admin_panchang'),
                ),
                _buildCmsTile(
                  title: 'Daily Planet Chart CMS',
                  subtitle: 'Add, Edit & Delete Rasi, Degrees & Retrograde',
                  icon: Icons.public_rounded,
                  onTap: () => widget.onNavigate('/admin_planet_positions'),
                ),
                _buildCmsTile(
                  title: 'Daily Horoscope Predictions',
                  subtitle: 'Daily Transits & Predictions',
                  icon: Icons.brightness_7_rounded,
                  onTap: () => widget.onNavigate('/horoscope'),
                ),
                _buildCmsTile(
                  title: 'உலகியல் ஜோதிடம் (Mundane Astrology)',
                  subtitle: 'Global Transits, Mundane Aspects & National Predictions',
                  icon: Icons.public_rounded,
                  onTap: () => widget.onNavigate('/mundane_astrology'),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Astrologers List (${_astrologers.length})', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.lightGold, fontSize: 16)),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _showAddAstrologerDialog,
                      icon: const Icon(Icons.add_rounded, color: AppColors.textDark, size: 18),
                      label: Text(
                        "Add Astrologer",
                        style: GoogleFonts.outfit(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                    : _astrologers.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderGold.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.psychology_outlined, color: AppColors.lightGold, size: 42),
                                const SizedBox(height: 8),
                                Text("No Astrologers Listed", style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text("Click '+ Add Astrologer' above to create new astrologers.", style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12), textAlign: TextAlign.center),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _astrologers.length,
                            itemBuilder: (context, index) {
                              final ast = _astrologers[index];
                              final isPending = ast.verificationStatus == 'pending';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: isPending ? Colors.orangeAccent : Colors.white12),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(ast.photoUrl),
                                      onBackgroundImageError: (_, __) {},
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(ast.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          Text('${ast.specializations.join(", ")} • ₹${ast.consultationFee}/min', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: AppColors.lightGold, size: 20),
                                      onPressed: () => _showAstrologerFormDialog(astToEdit: ast),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                      onPressed: () => _confirmDeleteAstrologer(ast),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCmsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGold.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.lightGold, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.lightGold, size: 18),
          ],
        ),
      ),
    );
  }
}
