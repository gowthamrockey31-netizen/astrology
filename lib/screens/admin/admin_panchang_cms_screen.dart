import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/panchang_model.dart';
import '../../services/api_service.dart';
import '../../widgets/cosmic_background.dart';

class AdminPanchangCmsScreen extends StatefulWidget {
  const AdminPanchangCmsScreen({super.key});

  @override
  State<AdminPanchangCmsScreen> createState() => _AdminPanchangCmsScreenState();
}

class _AdminPanchangCmsScreenState extends State<AdminPanchangCmsScreen> {
  List<PanchangModel> _panchangList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPanchangData();
  }

  Future<void> _loadPanchangData() async {
    setState(() => _isLoading = true);
    final data = await ApiService.fetchPanchangEntries();
    if (mounted) {
      setState(() {
        _panchangList = data.isNotEmpty ? data : [PanchangModel.today()];
        _isLoading = false;
      });
    }
  }

  void _showFormDialog({PanchangModel? itemToEdit}) async {
    final isEditing = itemToEdit != null;

    final dateCtrl = TextEditingController(text: isEditing ? itemToEdit.date : 'Today');
    final tithiCtrl = TextEditingController(text: isEditing ? itemToEdit.tithi : 'Shukla Paksha Ekadashi (until 04:15 PM)');
    final nakshatraCtrl = TextEditingController(text: isEditing ? itemToEdit.nakshatra : 'Rohini (until 08:30 PM)');
    final yogaCtrl = TextEditingController(text: isEditing ? itemToEdit.yoga : 'Shubha (until 06:10 PM)');
    final karanaCtrl = TextEditingController(text: isEditing ? itemToEdit.karana : 'Bava (until 04:15 PM)');
    final sunriseCtrl = TextEditingController(text: isEditing ? itemToEdit.sunrise : '06:05 AM');
    final sunsetCtrl = TextEditingController(text: isEditing ? itemToEdit.sunset : '06:42 PM');
    final rahuCtrl = TextEditingController(text: isEditing ? itemToEdit.rahuKalam : '01:30 PM - 03:00 PM');
    final yamaCtrl = TextEditingController(text: isEditing ? itemToEdit.yamagandam : '06:00 AM - 07:30 AM');
    final kuliCtrl = TextEditingController(text: isEditing ? itemToEdit.kuligai : '09:00 AM - 10:30 AM');
    final auspiCtrl = TextEditingController(text: isEditing ? itemToEdit.auspiciousTime : '11:45 AM - 12:35 PM (Abhijit)');
    final pakshaCtrl = TextEditingController(text: isEditing ? itemToEdit.paksha : 'Shukla Paksha');

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundMid,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderGold, width: 1.5),
          ),
          title: Row(
            children: [
              Icon(isEditing ? Icons.edit_calendar_rounded : Icons.add_alarm_rounded, color: AppColors.lightGold),
              const SizedBox(width: 10),
              Text(
                isEditing ? "Edit Live Panchangam" : "Add Live Panchangam",
                style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInput(dateCtrl, "Date / Day", "e.g. Today, 15 Aug 2026"),
                  _buildInput(tithiCtrl, "Tithi Details", "e.g. Shukla Paksha Ekadashi"),
                  _buildInput(nakshatraCtrl, "Nakshatra Details", "e.g. Rohini"),
                  _buildInput(yogaCtrl, "Yoga", "e.g. Shubha"),
                  _buildInput(karanaCtrl, "Karana", "e.g. Bava"),
                  Row(
                    children: [
                      Expanded(child: _buildInput(sunriseCtrl, "Sunrise", "06:05 AM")),
                      const SizedBox(width: 8),
                      Expanded(child: _buildInput(sunsetCtrl, "Sunset", "06:42 PM")),
                    ],
                  ),
                  _buildInput(rahuCtrl, "Rahu Kalam", "01:30 PM - 03:00 PM"),
                  Row(
                    children: [
                      Expanded(child: _buildInput(yamaCtrl, "Yamagandam", "06:00 AM - 07:30 AM")),
                      const SizedBox(width: 8),
                      Expanded(child: _buildInput(kuliCtrl, "Kuligai", "09:00 AM - 10:30 AM")),
                    ],
                  ),
                  _buildInput(auspiCtrl, "Auspicious Time (Abhijit)", "11:45 AM - 12:35 PM"),
                  _buildInput(pakshaCtrl, "Paksha", "Shukla Paksha"),
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
                isEditing ? "Save Changes" : "Add Panchang",
                style: GoogleFonts.poppins(color: AppColors.textDark, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      final updatedItem = PanchangModel(
        id: isEditing ? itemToEdit.id : 'panchang_${DateTime.now().millisecondsSinceEpoch}',
        date: dateCtrl.text.trim(),
        tithi: tithiCtrl.text.trim(),
        nakshatra: nakshatraCtrl.text.trim(),
        yoga: yogaCtrl.text.trim(),
        karana: karanaCtrl.text.trim(),
        sunrise: sunriseCtrl.text.trim(),
        sunset: sunsetCtrl.text.trim(),
        moonrise: '03:12 PM',
        moonset: '04:08 AM',
        rahuKalam: rahuCtrl.text.trim(),
        yamagandam: yamaCtrl.text.trim(),
        kuligai: kuliCtrl.text.trim(),
        auspiciousTime: auspiCtrl.text.trim(),
        paksha: pakshaCtrl.text.trim(),
      );

      if (isEditing) {
        await ApiService.editPanchangEntry(updatedItem);
      } else {
        await ApiService.addPanchangEntry(updatedItem);
      }

      await _loadPanchangData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? "Panchangam entry updated in MongoDB!" : "New Panchangam entry saved to MongoDB!",
              style: GoogleFonts.poppins(color: AppColors.lightGold),
            ),
            backgroundColor: AppColors.backgroundMid,
          ),
        );
      }
    }
  }

  void _confirmDelete(PanchangModel item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        title: Text("Delete Panchangam Entry", style: GoogleFonts.cinzel(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete Panchangam entry for '${item.date}'?", style: GoogleFonts.poppins(color: AppColors.textPrimary)),
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
      await ApiService.deletePanchangEntry(item.id);
      await _loadPanchangData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Panchangam entry deleted.", style: GoogleFonts.poppins(color: AppColors.lightGold)),
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
        title: Text('Live Panchangam CMS', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.lightGold),
            onPressed: _loadPanchangData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGold,
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add_rounded, color: AppColors.textDark),
        label: Text("Add Panchang", style: GoogleFonts.outfit(color: AppColors.textDark, fontWeight: FontWeight.bold)),
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
              : _panchangList.isEmpty
                  ? Center(
                      child: Text(
                        "No Panchangam Entries in MongoDB.\nClick '+ Add Panchang' below.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _panchangList.length,
                      itemBuilder: (context, index) {
                        final item = _panchangList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderGold.withOpacity(0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item.date, style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.lightGold, size: 20),
                                        onPressed: () => _showFormDialog(itemToEdit: item),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                        onPressed: () => _confirmDelete(item),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white12),
                              const SizedBox(height: 6),
                              _buildRowInfo("Tithi", item.tithi, Icons.brightness_6_rounded),
                              _buildRowInfo("Nakshatra", item.nakshatra, Icons.auto_awesome),
                              _buildRowInfo("Yoga", item.yoga, Icons.self_improvement_rounded),
                              _buildRowInfo("Karana", item.karana, Icons.hourglass_full_rounded),
                              _buildRowInfo("Rahu Kalam", item.rahuKalam, Icons.warning_amber_rounded, isWarning: true),
                              _buildRowInfo("Auspicious Time", item.auspiciousTime, Icons.check_circle_rounded, isGood: true),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildRowInfo(String label, String value, IconData icon, {bool isWarning = false, bool isGood = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isWarning ? Colors.redAccent : (isGood ? Colors.greenAccent : AppColors.lightGold)),
          const SizedBox(width: 8),
          Text("$label: ", style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.outfit(fontSize: 12, color: isWarning ? Colors.redAccent : (isGood ? Colors.greenAccent : Colors.white)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
