import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/panchang_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/cosmic_background.dart';

class PanchangScreen extends StatefulWidget {
  const PanchangScreen({super.key});

  @override
  State<PanchangScreen> createState() => _PanchangScreenState();
}

class _PanchangScreenState extends State<PanchangScreen> {
  PanchangModel _panchang = PanchangModel.today();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLivePanchang();
  }

  Future<void> _fetchLivePanchang() async {
    final list = await ApiService.fetchPanchangEntries();
    if (mounted) {
      setState(() {
        if (list.isNotEmpty) {
          _panchang = list.first;
        }
        _isLoading = false;
      });
    }
  }

  void _showFormDialog(PanchangModel itemToEdit) async {
    final dateCtrl = TextEditingController(text: itemToEdit.date);
    final tithiCtrl = TextEditingController(text: itemToEdit.tithi);
    final nakshatraCtrl = TextEditingController(text: itemToEdit.nakshatra);
    final yogaCtrl = TextEditingController(text: itemToEdit.yoga);
    final karanaCtrl = TextEditingController(text: itemToEdit.karana);
    final sunriseCtrl = TextEditingController(text: itemToEdit.sunrise);
    final sunsetCtrl = TextEditingController(text: itemToEdit.sunset);
    final rahuCtrl = TextEditingController(text: itemToEdit.rahuKalam);
    final yamaCtrl = TextEditingController(text: itemToEdit.yamagandam);
    final kuliCtrl = TextEditingController(text: itemToEdit.kuligai);
    final auspiCtrl = TextEditingController(text: itemToEdit.auspiciousTime);
    final pakshaCtrl = TextEditingController(text: itemToEdit.paksha);

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
              const Icon(Icons.edit_calendar_rounded, color: AppColors.lightGold),
              const SizedBox(width: 10),
              Text(
                "Edit Live Panchangam",
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
              onPressed: () => Navigator.pop(ctx, false),
              child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.backgroundDeep,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text("Save Changes", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      final updatedItem = PanchangModel(
        id: itemToEdit.id,
        date: dateCtrl.text.trim(),
        tithi: tithiCtrl.text.trim(),
        nakshatra: nakshatraCtrl.text.trim(),
        yoga: yogaCtrl.text.trim(),
        karana: karanaCtrl.text.trim(),
        sunrise: sunriseCtrl.text.trim(),
        sunset: sunsetCtrl.text.trim(),
        moonrise: itemToEdit.moonrise,
        moonset: itemToEdit.moonset,
        rahuKalam: rahuCtrl.text.trim(),
        yamagandam: yamaCtrl.text.trim(),
        kuligai: kuliCtrl.text.trim(),
        auspiciousTime: auspiCtrl.text.trim(),
        paksha: pakshaCtrl.text.trim(),
      );

      await ApiService.editPanchangEntry(updatedItem);
      await _fetchLivePanchang();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Panchangam details updated in MongoDB!",
              style: GoogleFonts.poppins(color: AppColors.lightGold),
            ),
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
        title: Text('Auspicious Panchangam', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit_calendar_rounded, color: AppColors.lightGold),
              tooltip: 'Edit Live Panchangam (Astrologer CMS)',
              onPressed: () => _showFormDialog(_panchang),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.lightGold),
            onPressed: _fetchLivePanchang,
          ),
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryGold,
              icon: const Icon(Icons.edit_note_rounded, color: AppColors.backgroundDeep),
              label: Text(
                'Edit Panchang',
                style: GoogleFonts.outfit(color: AppColors.backgroundDeep, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showFormDialog(_panchang),
            )
          : null,
      body: CosmicBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (canEdit)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primaryGold),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.edit_note_rounded, color: AppColors.lightGold, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ASTROLOGER CMS MODE', style: GoogleFonts.cinzel(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
                                    Text('Tap to edit live Tithi, Nakshatra, Rahu Kalam & timings.', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textPrimary)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGold,
                                  foregroundColor: AppColors.backgroundDeep,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                ),
                                onPressed: () => _showFormDialog(_panchang),
                                child: Text('Edit', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_panchang.date, style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryGold, width: 0.8),
                            ),
                            child: Text(
                              _panchang.paksha,
                              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.lightGold, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      _buildPanchangCard('Tithi', _panchang.tithi, Icons.brightness_6_rounded),
                      _buildPanchangCard('Nakshatra', _panchang.nakshatra, Icons.auto_awesome),
                      _buildPanchangCard('Yoga', _panchang.yoga, Icons.self_improvement_rounded),
                      _buildPanchangCard('Karana', _panchang.karana, Icons.hourglass_full_rounded),
                      _buildPanchangCard('Sunrise / Sunset', '${_panchang.sunrise} • ${_panchang.sunset}', Icons.wb_sunny_rounded),
                      _buildPanchangCard('Rahu Kalam (Inauspicious)', _panchang.rahuKalam, Icons.warning_amber_rounded, isWarning: true),
                      _buildPanchangCard('Yamagandam', _panchang.yamagandam, Icons.alarm_rounded),
                      _buildPanchangCard('Kuligai', _panchang.kuligai, Icons.star_rounded),
                      _buildPanchangCard('Abhijit Muhurat (Auspicious)', _panchang.auspiciousTime, Icons.check_circle_rounded, isGood: true),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPanchangCard(String title, String val, IconData icon, {bool isWarning = false, bool isGood = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWarning ? Colors.redAccent : (isGood ? Colors.greenAccent : Colors.white12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isWarning ? Colors.redAccent : (isGood ? Colors.greenAccent : AppColors.lightGold)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(val, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
