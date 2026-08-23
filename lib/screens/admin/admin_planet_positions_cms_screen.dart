import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/panchang_model.dart';
import '../../services/api_service.dart';
import '../../widgets/cosmic_background.dart';

class AdminPlanetPositionsCmsScreen extends StatefulWidget {
  const AdminPlanetPositionsCmsScreen({super.key});

  @override
  State<AdminPlanetPositionsCmsScreen> createState() => _AdminPlanetPositionsCmsScreenState();
}

class _AdminPlanetPositionsCmsScreenState extends State<AdminPlanetPositionsCmsScreen> {
  List<PlanetPositionModel> _planets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlanetPositions();
  }

  Future<void> _loadPlanetPositions() async {
    setState(() => _isLoading = true);
    final data = await ApiService.fetchPlanetPositions();
    if (mounted) {
      setState(() {
        _planets = data;
        _isLoading = false;
      });
    }
  }

  void _showFormDialog({PlanetPositionModel? itemToEdit}) async {
    final isEditing = itemToEdit != null;

    final planetCtrl = TextEditingController(text: isEditing ? itemToEdit.planet : 'Sun (Surya)');
    final rasiCtrl = TextEditingController(text: isEditing ? itemToEdit.rasi : 'Leo (Simha)');
    final degreesCtrl = TextEditingController(text: isEditing ? itemToEdit.degrees : '12° 45\'');
    final nakshatraCtrl = TextEditingController(text: isEditing ? itemToEdit.nakshatra : 'Pushya');
    bool isRetro = isEditing ? itemToEdit.isRetrograde : false;

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundMid,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.borderGold, width: 1.5),
              ),
              title: Row(
                children: [
                  Icon(isEditing ? Icons.edit_location_alt_rounded : Icons.public_rounded, color: AppColors.lightGold),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEditing ? "Edit Planet Position" : "Add Planet Position",
                      style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 16),
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
                    children: [
                      _buildInput(planetCtrl, "Planet Name", "e.g. Sun (Surya) / Jupiter (Guru)"),
                      _buildInput(rasiCtrl, "Zodiac Rasi", "e.g. Cancer (Karka)"),
                      _buildInput(degreesCtrl, "Degrees & Minutes", "e.g. 15° 20'"),
                      _buildInput(nakshatraCtrl, "Nakshatra", "e.g. Rohini"),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderGold.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Retrograde Motion (R)?",
                              style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Switch(
                              value: isRetro,
                              activeColor: AppColors.primaryGold,
                              onChanged: (val) {
                                setModalState(() => isRetro = val);
                              },
                            ),
                          ],
                        ),
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
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(
                    isEditing ? "Save Position" : "Add Planet",
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

      await _loadPlanetPositions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? "Planet position updated in MongoDB!" : "New planet position saved to MongoDB!",
              style: GoogleFonts.poppins(color: AppColors.lightGold),
            ),
            backgroundColor: AppColors.backgroundMid,
          ),
        );
      }
    }
  }

  void _confirmDelete(PlanetPositionModel item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        title: Text("Delete Planet Position", style: GoogleFonts.cinzel(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete '${item.planet}' position?", style: GoogleFonts.poppins(color: AppColors.textPrimary)),
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
      await ApiService.deletePlanetPosition(item.id);
      await _loadPlanetPositions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Planet position deleted from MongoDB.", style: GoogleFonts.poppins(color: AppColors.lightGold)),
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
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: AppColors.lightGold),
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMid,
        title: Text('Daily Planet Chart CMS', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.lightGold),
            onPressed: _loadPlanetPositions,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGold,
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add_rounded, color: AppColors.textDark),
        label: Text("Add Planet", style: GoogleFonts.outfit(color: AppColors.textDark, fontWeight: FontWeight.bold)),
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
              : _planets.isEmpty
                  ? Center(
                      child: Text(
                        "No Planet Positions in MongoDB.\nClick '+ Add Planet' below.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _planets.length,
                      itemBuilder: (context, index) {
                        final pos = _planets[index];
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
                                  Text(pos.degrees, style: GoogleFonts.cinzel(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
                                  if (pos.isRetrograde)
                                    Text('(Retrograde R)', style: GoogleFonts.outfit(fontSize: 10, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.lightGold, size: 18),
                                onPressed: () => _showFormDialog(itemToEdit: pos),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                onPressed: () => _confirmDelete(pos),
                              ),
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
