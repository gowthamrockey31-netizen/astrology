import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/terms_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/golden_button.dart';
import '../../widgets/golden_text_field.dart';

class AdminTermsCmsScreen extends StatefulWidget {
  const AdminTermsCmsScreen({super.key});

  @override
  State<AdminTermsCmsScreen> createState() => _AdminTermsCmsScreenState();
}

class _AdminTermsCmsScreenState extends State<AdminTermsCmsScreen> {
  List<TermItemModel> _terms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    final list = await FirestoreService.fetchTermsAndConditions();
    if (mounted) {
      setState(() {
        _terms = list;
        _isLoading = false;
      });
    }
  }

  void _showAddEditModal({TermItemModel? term}) {
    final titleCtrl = TextEditingController(text: term?.title ?? '');
    final descCtrl = TextEditingController(text: term?.description ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              term == null ? 'Add New Guideline / Term' : 'Edit Term',
              style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightGold),
            ),
            const SizedBox(height: 16),
            GoldenTextField(label: 'Title', hint: 'Title', controller: titleCtrl),
            const SizedBox(height: 12),
            GoldenTextField(label: 'Description', hint: 'Description', controller: descCtrl, maxLines: 4),
            const SizedBox(height: 20),
            GoldenButton(
              text: term == null ? 'Save to Firestore' : 'Update Term',
              onPressed: () async {
                final t = titleCtrl.text.trim();
                final d = descCtrl.text.trim();
                if (t.isEmpty || d.isEmpty) return;

                Navigator.of(context).pop();
                setState(() => _isLoading = true);

                if (term == null) {
                  await FirestoreService.addTerm(t, d);
                } else {
                  await FirestoreService.editTerm(term.id, t, d);
                }

                _loadTerms();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTerm(String id) async {
    setState(() => _isLoading = true);
    await FirestoreService.deleteTerm(id);
    _loadTerms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMid,
        title: Text('Firestore Terms CMS', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGold,
        icon: const Icon(Icons.add, color: AppColors.backgroundDeep),
        label: Text('Add Term', style: GoogleFonts.outfit(color: AppColors.backgroundDeep, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddEditModal(),
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _terms.length,
                  itemBuilder: (context, index) {
                    final item = _terms[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded, color: AppColors.lightGold, size: 20),
                                    onPressed: () => _showAddEditModal(term: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20),
                                    onPressed: () => _deleteTerm(item.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(item.description, style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textPrimary)),
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
