import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/horoscope_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/cosmic_background.dart';

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  String _selectedSign = AppConstants.zodiacSigns[0];
  int _selectedTab = 0; // 0: Daily, 1: Weekly, 2: Monthly, 3: Yearly

  HoroscopePredictionModel? _getCurrentPrediction() {
    if (MockDataService.deletedPredictions.contains(_selectedSign)) {
      return null;
    }
    if (MockDataService.customPredictions.containsKey(_selectedSign)) {
      return MockDataService.customPredictions[_selectedSign]!;
    }
    return HoroscopePredictionModel.forSign(_selectedSign);
  }

  void _showEditPredictionDialog({bool isNew = false}) async {
    final current = _getCurrentPrediction() ?? HoroscopePredictionModel.forSign(_selectedSign);
    final signCtrl = TextEditingController(text: isNew ? 'Aries (Mesha)' : current.zodiacSign);
    final dailyCtrl = TextEditingController(text: isNew ? '' : current.daily);
    final weeklyCtrl = TextEditingController(text: isNew ? '' : current.weekly);
    final monthlyCtrl = TextEditingController(text: isNew ? '' : current.monthly);
    final yearlyCtrl = TextEditingController(text: isNew ? '' : current.yearly);
    final luckyNoCtrl = TextEditingController(text: isNew ? '7' : '${current.luckyNumber}');
    final luckyColorCtrl = TextEditingController(text: isNew ? 'Golden Yellow' : current.luckyColor);
    final luckyGemCtrl = TextEditingController(text: isNew ? 'Yellow Sapphire' : current.luckyGem);

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
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
                isNew ? Icons.add_circle_outline_rounded : Icons.edit_note_rounded,
                color: AppColors.lightGold,
                size: 26,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isNew ? "Add Custom Horoscope" : "Edit ${_selectedSign.split(' ')[0]} Prediction",
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
                  TextField(
                    controller: signCtrl,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(labelText: "Zodiac Sign Name", labelStyle: TextStyle(color: AppColors.lightGold)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dailyCtrl,
                    maxLines: 2,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(labelText: "Daily Prediction", labelStyle: TextStyle(color: AppColors.lightGold)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: weeklyCtrl,
                    maxLines: 2,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(labelText: "Weekly Prediction", labelStyle: TextStyle(color: AppColors.lightGold)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: monthlyCtrl,
                    maxLines: 2,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(labelText: "Monthly Prediction", labelStyle: TextStyle(color: AppColors.lightGold)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: yearlyCtrl,
                    maxLines: 2,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(labelText: "Yearly Prediction", labelStyle: TextStyle(color: AppColors.lightGold)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: luckyNoCtrl,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(labelText: "Lucky No.", labelStyle: TextStyle(color: AppColors.lightGold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: luckyColorCtrl,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(labelText: "Lucky Color", labelStyle: TextStyle(color: AppColors.lightGold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: luckyGemCtrl,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(labelText: "Lucky Gemstone", labelStyle: TextStyle(color: AppColors.lightGold)),
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
                if (signCtrl.text.trim().isEmpty) return;
                Navigator.of(ctx).pop(true);
              },
              child: Text(
                isNew ? "Add Prediction" : "Save Changes",
                style: GoogleFonts.poppins(color: AppColors.textDark, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (saved == true) {
      final updated = HoroscopePredictionModel(
        zodiacSign: signCtrl.text.trim(),
        daily: dailyCtrl.text.trim().isNotEmpty ? dailyCtrl.text.trim() : current.daily,
        weekly: weeklyCtrl.text.trim().isNotEmpty ? weeklyCtrl.text.trim() : current.weekly,
        monthly: monthlyCtrl.text.trim().isNotEmpty ? monthlyCtrl.text.trim() : current.monthly,
        yearly: yearlyCtrl.text.trim().isNotEmpty ? yearlyCtrl.text.trim() : current.yearly,
        luckyNumber: int.tryParse(luckyNoCtrl.text.trim()) ?? current.luckyNumber,
        luckyColor: luckyColorCtrl.text.trim().isNotEmpty ? luckyColorCtrl.text.trim() : current.luckyColor,
        luckyGem: luckyGemCtrl.text.trim().isNotEmpty ? luckyGemCtrl.text.trim() : current.luckyGem,
        compatibilityScore: current.compatibilityScore,
      );

      await FirestoreService.saveHoroscopePrediction(updated);
      setState(() {
        _selectedSign = updated.zodiacSign;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Horoscope prediction saved successfully!", style: GoogleFonts.poppins(color: AppColors.lightGold)),
            backgroundColor: AppColors.backgroundMid,
          ),
        );
      }
    }
  }

  void _confirmDeletePrediction() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        title: Text("Delete Prediction", style: GoogleFonts.cinzel(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete prediction for '$_selectedSign'?", style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13)),
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
      await FirestoreService.deleteHoroscopePrediction(_selectedSign);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Prediction for '$_selectedSign' deleted successfully.", style: GoogleFonts.poppins(color: AppColors.lightGold)),
            backgroundColor: AppColors.backgroundMid,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = AuthService.activeRole == 'Admin';
    final prediction = _getCurrentPrediction();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMid,
        title: Text('Horoscope Predictions', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
        actions: [
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.lightGold, size: 24),
              tooltip: "Add Prediction",
              onPressed: () => _showEditPredictionDialog(isNew: true),
            ),
          ],
        ],
      ),
      floatingActionButton: isAdmin && prediction != null
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryGold,
              onPressed: () => _showEditPredictionDialog(isNew: false),
              icon: const Icon(Icons.edit_outlined, color: AppColors.textDark),
              label: Text("Edit Prediction", style: GoogleFonts.outfit(color: AppColors.textDark, fontWeight: FontWeight.bold)),
            )
          : null,
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Zodiac Sign Selector Grid/Horizontal list
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: AppConstants.zodiacSigns.map((sign) {
                    final isSel = _selectedSign == sign;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSign = sign),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primaryGold.withOpacity(0.2) : AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSel ? AppColors.lightGold : Colors.white12),
                        ),
                        child: Text(
                          sign.split(' ')[0],
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSel ? AppColors.lightGold : Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Timeframe Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['Daily', 'Weekly', 'Monthly', 'Yearly'].asMap().entries.map((entry) {
                  final idx = entry.key;
                  final label = entry.value;
                  final isSel = _selectedTab == idx;
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSel,
                    selectedColor: AppColors.primaryGold,
                    labelStyle: GoogleFonts.outfit(
                      color: isSel ? AppColors.backgroundDeep : AppColors.lightGold,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (val) => setState(() => _selectedTab = idx),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Prediction Details Container
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: prediction == null
                      ? _buildEmptyPredictionView(isAdmin)
                      : Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderGold),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.auto_awesome, color: AppColors.lightGold, size: 24),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _selectedSign,
                                            style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isAdmin) ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: AppColors.lightGold, size: 20),
                                      tooltip: "Edit Prediction",
                                      onPressed: () => _showEditPredictionDialog(isNew: false),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                      tooltip: "Delete Prediction",
                                      onPressed: _confirmDeletePrediction,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedTab == 0
                                    ? prediction.daily
                                    : (_selectedTab == 1
                                        ? prediction.weekly
                                        : (_selectedTab == 2 ? prediction.monthly : prediction.yearly)),
                                style: GoogleFonts.outfit(fontSize: 14, color: Colors.white, height: 1.5),
                              ),
                              const SizedBox(height: 24),
                              const Divider(color: Colors.white12),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _buildLuckyItem('Lucky No.', '${prediction.luckyNumber}')),
                                  Expanded(child: _buildLuckyItem('Lucky Color', prediction.luckyColor)),
                                  Expanded(child: _buildLuckyItem('Gemstone', prediction.luckyGem)),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPredictionView(bool isAdmin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGold.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 48),
          const SizedBox(height: 12),
          Text(
            "Prediction Deleted",
            style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            "The horoscope prediction for '$_selectedSign' has been deleted by Admin.",
            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (isAdmin) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
              onPressed: () => _showEditPredictionDialog(isNew: true),
              icon: const Icon(Icons.add_rounded, color: AppColors.textDark),
              label: Text("Add Prediction for ${_selectedSign.split(' ')[0]}", style: GoogleFonts.outfit(color: AppColors.textDark, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLuckyItem(String title, String val) {
    return Column(
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            val,
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightGold),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
