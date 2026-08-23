import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/panchang_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosmic_background.dart';

class PlanetPositionsScreen extends StatefulWidget {
  const PlanetPositionsScreen({super.key});

  @override
  State<PlanetPositionsScreen> createState() => _PlanetPositionsScreenState();
}

class _PlanetPositionsScreenState extends State<PlanetPositionsScreen> {
  List<PlanetPositionModel> _positions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLivePositions();
  }

  Future<void> _fetchLivePositions() async {
    final list = await ApiService.fetchPlanetPositions();
    if (mounted) {
      setState(() {
        _positions = list.isNotEmpty
            ? list
            : [
                PlanetPositionModel(id: '1', planet: 'Sun (Surya)', rasi: 'Cancer (Karka)', degrees: '12° 45\'', isRetrograde: false, nakshatra: 'Pushya'),
                PlanetPositionModel(id: '2', planet: 'Moon (Chandra)', rasi: 'Taurus (Vrishabha)', degrees: '24° 10\'', isRetrograde: false, nakshatra: 'Rohini'),
                PlanetPositionModel(id: '3', planet: 'Mars (Mangal)', rasi: 'Leo (Simha)', degrees: '08° 30\'', isRetrograde: false, nakshatra: 'Magha'),
                PlanetPositionModel(id: '4', planet: 'Mercury (Budha)', rasi: 'Gemini (Mithuna)', degrees: '18° 55\'', isRetrograde: true, nakshatra: 'Ardra'),
                PlanetPositionModel(id: '5', planet: 'Jupiter (Guru)', rasi: 'Taurus (Vrishabha)', degrees: '15° 20\'', isRetrograde: false, nakshatra: 'Rohini'),
                PlanetPositionModel(id: '6', planet: 'Venus (Shukra)', rasi: 'Cancer (Karka)', degrees: '05° 40\'', isRetrograde: false, nakshatra: 'Punarvasu'),
                PlanetPositionModel(id: '7', planet: 'Saturn (Shani)', rasi: 'Aquarius (Kumbha)', degrees: '21° 15\'', isRetrograde: true, nakshatra: 'Purva Bhadrapada'),
                PlanetPositionModel(id: '8', planet: 'Rahu (North Node)', rasi: 'Pisces (Meena)', degrees: '11° 02\'', isRetrograde: true, nakshatra: 'Uttara Bhadrapada'),
                PlanetPositionModel(id: '9', planet: 'Ketu (South Node)', rasi: 'Virgo (Kanya)', degrees: '11° 02\'', isRetrograde: true, nakshatra: 'Hasta'),
              ];
        _isLoading = false;
      });
    }
  }

  void _showFormDialog({PlanetPositionModel? itemToEdit}) async {
    final isEditing = itemToEdit != null;

    final planetCtrl = TextEditingController(text: isEditing ? itemToEdit.planet : 'Sun (Surya)');
    final rasiCtrl = TextEditingController(text: isEditing ? itemToEdit.rasi : 'Cancer (Karka)');
    final degreesCtrl = TextEditingController(text: isEditing ? itemToEdit.degrees : '12° 45\'');
    final nakshatraCtrl = TextEditingController(text: isEditing ? itemToEdit.nakshatra : 'Pushya');
    bool isRetro = isEditing ? itemToEdit.isRetrograde : false;

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundMid,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.borderGold, width: 1.5),
              ),
              title: Row(
                children: [
                  Icon(isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded, color: AppColors.lightGold),
                  const SizedBox(width: 10),
                  Text(
                    isEditing ? "Edit Planet Position" : "Add Planet Position",
                    style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInput(planetCtrl, "Planet Name", "e.g. Sun (Surya)"),
                  _buildInput(rasiCtrl, "Zodiac Rasi", "e.g. Cancer (Karka)"),
                  _buildInput(degreesCtrl, "Degrees", "e.g. 12° 45'"),
                  _buildInput(nakshatraCtrl, "Nakshatra", "e.g. Pushya"),
                  SwitchListTile(
                    activeColor: AppColors.primaryGold,
                    title: Text("Is Retrograde (Vakra)?", style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)),
                    value: isRetro,
                    onChanged: (val) => setDialogState(() => isRetro = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.backgroundDeep,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(isEditing ? "Save Position" : "Add Position", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      final updatedItem = PlanetPositionModel(
        id: isEditing ? itemToEdit.id : 'plt_${DateTime.now().millisecondsSinceEpoch}',
        planet: planetCtrl.text.trim(),
        rasi: rasiCtrl.text.trim(),
        degrees: degreesCtrl.text.trim(),
        isRetrograde: isRetro,
        nakshatra: nakshatraCtrl.text.trim(),
      );

      if (isEditing) {
        await ApiService.editPlanetPosition(updatedItem);
      } else {
        await ApiService.addPlanetPosition(updatedItem);
      }

      await _fetchLivePositions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Planet position updated in MongoDB!", style: GoogleFonts.poppins(color: AppColors.lightGold)),
            backgroundColor: AppColors.backgroundMid,
          ),
        );
      }
    }
  }

  Widget _buildInput(TextEditingController ctrl, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 12),
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.white30, fontSize: 12),
          filled: true,
          fillColor: AppColors.cardSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white24)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryGold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = AuthService.currentUser?.role == 'Astrologer' || AuthService.currentUser?.role == 'Admin';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMid,
        title: Text('Daily Planet Positions', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.lightGold),
              tooltip: 'Add Planet Position (Astrologer CMS)',
              onPressed: () => _showFormDialog(),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.lightGold),
            onPressed: _fetchLivePositions,
          ),
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryGold,
              icon: const Icon(Icons.edit_note_rounded, color: AppColors.backgroundDeep),
              label: Text(
                'Edit Planets',
                style: GoogleFonts.outfit(color: AppColors.backgroundDeep, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showFormDialog(),
            )
          : null,
      body: CosmicBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _positions.length,
                  itemBuilder: (context, index) {
                    final pos = _positions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderGold.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.public_rounded, color: AppColors.lightGold, size: 26),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pos.planet, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 2),
                                Text('${pos.rasi} • ${pos.nakshatra}', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(pos.degrees, style: GoogleFonts.cinzel(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
                              if (pos.isRetrograde)
                                Text('(Retrograde R)', style: GoogleFonts.outfit(fontSize: 10, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          if (canEdit) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit_note_rounded, color: AppColors.lightGold, size: 22),
                              tooltip: 'Edit Position',
                              onPressed: () => _showFormDialog(itemToEdit: pos),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
