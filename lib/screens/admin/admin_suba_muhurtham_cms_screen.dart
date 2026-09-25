import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/suba_muhurtham_model.dart';
import '../../services/suba_muhurtham_service.dart';
import '../../widgets/cosmic_background.dart';

class AdminSubaMuhurthamCmsScreen extends StatefulWidget {
  const AdminSubaMuhurthamCmsScreen({super.key});

  @override
  State<AdminSubaMuhurthamCmsScreen> createState() => _AdminSubaMuhurthamCmsScreenState();
}

class _AdminSubaMuhurthamCmsScreenState extends State<AdminSubaMuhurthamCmsScreen> {
  List<SubaMuhurthamModel> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await SubaMuhurthamService.fetchList(includeInactive: true);
    if (mounted) {
      setState(() {
        _items = data;
        _isLoading = false;
      });
    }
  }

  void _showFormDialog({SubaMuhurthamModel? itemToEdit}) async {
    final isEditing = itemToEdit != null;

    final tamilDateCtrl = TextEditingController(text: isEditing ? itemToEdit.tamilDate : '');
    final englishDateCtrl = TextEditingController(text: isEditing ? itemToEdit.englishDate : '');
    final dayOfWeekCtrl = TextEditingController(text: isEditing ? itemToEdit.dayOfWeek : '');
    final tithiCtrl = TextEditingController(text: isEditing ? itemToEdit.tithi : '');
    final nakshatraCtrl = TextEditingController(text: isEditing ? itemToEdit.nakshatra : '');
    final yogaCtrl = TextEditingController(text: isEditing ? itemToEdit.yoga : '');
    final muhurthamTimeCtrl = TextEditingController(text: isEditing ? itemToEdit.muhurthamTime : '');
    final lagnaCtrl = TextEditingController(text: isEditing ? itemToEdit.lagna : '');
    final descCtrl = TextEditingController(text: isEditing ? itemToEdit.description : '');
    bool isActive = isEditing ? itemToEdit.isActive : true;

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundMid,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: AppColors.borderGold, width: 1.5),
              ),
              title: Row(
                children: [
                  Icon(isEditing ? Icons.edit_calendar_rounded : Icons.add_alarm_rounded, color: AppColors.lightGold),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEditing ? "சுப முகூர்த்தம் திருத்து (Edit)" : "சுப முகூர்த்தம் சேர்க்க (Add)",
                      style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 16),
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
                      Row(
                        children: [
                          Expanded(child: _buildInput(tamilDateCtrl, "தமிழ் தேதி *", "எ.கா. வைகாசி 02")),
                          const SizedBox(width: 8),
                          Expanded(child: _buildInput(englishDateCtrl, "ஆங்கில தேதி *", "எ.கா. மே 16")),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildInput(dayOfWeekCtrl, "கிழமை / வாரம் *", "எ.கா. வெள்ளி")),
                          const SizedBox(width: 8),
                          Expanded(child: _buildInput(lagnaCtrl, "லக்னம்", "எ.கா. மிதுனம்")),
                        ],
                      ),
                      _buildInput(muhurthamTimeCtrl, "முகூர்த்த நேரம் / தாலி கட்டும் நேரம் *", "எ.கா. காலை 9:10 - 9:22"),
                      Row(
                        children: [
                          Expanded(child: _buildInput(tithiCtrl, "திதி", "எ.கா. சதுர்த்தி")),
                          const SizedBox(width: 8),
                          Expanded(child: _buildInput(nakshatraCtrl, "நட்சத்திரம்", "எ.கா. மூலம்")),
                        ],
                      ),
                      _buildInput(yogaCtrl, "யோகம்", "எ.கா. அமிர்த யோகம்"),
                      _buildInput(descCtrl, "சுப காரியங்கள் / விவரம்", "எ.கா. திருமணம், சீமந்தம், கிரக ஆரம்பம்", maxLines: 2),
                      const SizedBox(height: 6),
                      SwitchListTile(
                        title: Text('இயக்கத்தில் உள்ளதா (Is Active)', style: GoogleFonts.outfit(color: Colors.white, fontSize: 13)),
                        value: isActive,
                        activeThumbColor: AppColors.primaryGold,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) {
                          setDialogState(() => isActive = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text("ரத்து (Cancel)", style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.textDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    // Validation
                    if (tamilDateCtrl.text.trim().isEmpty ||
                        englishDateCtrl.text.trim().isEmpty ||
                        muhurthamTimeCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("தமிழ் தேதி, ஆங்கில தேதி மற்றும் முகூர்த்த நேரம் அவசியம் தேவை!"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    Navigator.of(ctx).pop(true);
                  },
                  child: Text(
                    isEditing ? "மாற்றங்களைச் சேமி (Save)" : "சேர்க்க (Add)",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      final item = SubaMuhurthamModel(
        id: isEditing ? itemToEdit.id : 'sm_${DateTime.now().millisecondsSinceEpoch}',
        tamilDate: tamilDateCtrl.text.trim(),
        englishDate: englishDateCtrl.text.trim(),
        dayOfWeek: dayOfWeekCtrl.text.trim(),
        tithi: tithiCtrl.text.trim(),
        nakshatra: nakshatraCtrl.text.trim(),
        yoga: yogaCtrl.text.trim(),
        muhurthamTime: muhurthamTimeCtrl.text.trim(),
        lagna: lagnaCtrl.text.trim(),
        description: descCtrl.text.trim(),
        displayOrder: isEditing ? itemToEdit.displayOrder : _items.length + 1,
        isActive: isActive,
      );

      if (isEditing) {
        await SubaMuhurthamService.edit(item);
      } else {
        await SubaMuhurthamService.add(item);
      }

      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? "சுப முகூர்த்த விவரங்கள் புதுப்பிக்கப்பட்டன!" : "புதிய சுப முகூர்த்தம் சேர்க்கப்பட்டது!",
              style: GoogleFonts.poppins(color: AppColors.lightGold),
            ),
            backgroundColor: AppColors.backgroundMid,
          ),
        );
      }
    }
  }

  void _confirmDelete(SubaMuhurthamModel item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        title: Text("முகூர்த்தத்தை நீக்கவா?", style: GoogleFonts.cinzel(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text(
          "'${item.tamilDate} (${item.englishDate}) - ${item.muhurthamTime}' விவரத்தை நீக்க விரும்புகிறீர்களா?",
          style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text("ரத்து (Cancel)", style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text("நீக்கு (Delete)", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SubaMuhurthamService.delete(item.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("சுப முகூர்த்த பதிவு நீக்கப்பட்டது.", style: GoogleFonts.poppins(color: AppColors.lightGold)),
            backgroundColor: AppColors.backgroundMid,
          ),
        );
      }
    }
  }

  Widget _buildInput(TextEditingController ctrl, String label, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(color: AppColors.lightGold, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 12),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.white24, fontSize: 11),
              fillColor: AppColors.inputBackground,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderGold)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryGold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDeep,
        title: Text(
          'சுப முகூர்த்த நேரம் CMS',
          style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightGold, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.lightGold),
            tooltip: "மீண்டும் ஏற்று (Refresh)",
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.lightGold),
            onSelected: (val) async {
              if (val == 'reset') {
                await SubaMuhurthamService.resetToDefaults();
                await _loadData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("இயல்புநிலை பஞ்சாங்க பதிவுகள் மீட்டமைக்கப்பட்டன!")),
                  );
                }
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'reset',
                child: Text('இயல்புநிலைக்கு மீட்டமை (Reset Defaults)'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGold,
        icon: const Icon(Icons.add_rounded, color: AppColors.textDark),
        label: Text("புதிய முகூர்த்தம் சேர்க்க", style: GoogleFonts.outfit(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        onPressed: () => _showFormDialog(),
      ),
      body: CosmicBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
            : _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_busy, color: AppColors.lightGold, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          "பதிவுகள் எதுவும் இல்லை.\n'+ புதிய முகூர்த்தம் சேர்க்க' அழுத்தவும்.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.only(left: 14, right: 14, top: 12, bottom: 80),
                    itemCount: _items.length,
                    onReorder: (oldIndex, newIndex) async {
                      await SubaMuhurthamService.reorder(oldIndex, newIndex);
                      await _loadData();
                    },
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Container(
                        key: ValueKey(item.id),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: item.isActive
                                ? AppColors.borderGold.withValues(alpha: 0.6)
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          leading: CircleAvatar(
                            backgroundColor: item.isActive
                                ? AppColors.primaryGold.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.2),
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: item.isActive ? AppColors.lightGold : Colors.grey,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                '${item.tamilDate} (${item.englishDate})',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: item.isActive ? AppColors.lightGold : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.dayOfWeek,
                                  style: GoogleFonts.outfit(fontSize: 10, color: AppColors.lightGold),
                                ),
                              ),
                              if (!item.isActive) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'மறைக்கப்பட்டது',
                                    style: GoogleFonts.outfit(fontSize: 9, color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '⏰ முகூர்த்த நேரம்: ${item.muhurthamTime}  •  லக்னம்: ${item.lagna}',
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'திதி: ${item.tithi}  •  நட்சத்திரம்: ${item.nakshatra}  •  யோகம்: ${item.yoga}',
                                style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10.5),
                              ),
                              if (item.description.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  '✨ ${item.description}',
                                  style: GoogleFonts.poppins(color: AppColors.textGold, fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, color: AppColors.lightGold, size: 20),
                                tooltip: "திருத்து (Edit)",
                                onPressed: () => _showFormDialog(itemToEdit: item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                tooltip: "நீக்கு (Delete)",
                                onPressed: () => _confirmDelete(item),
                              ),
                              const Icon(Icons.drag_handle_rounded, color: Colors.white30, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
