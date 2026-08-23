import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../models/terms_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/golden_button.dart';

class TermsConditionsScreen extends StatefulWidget {
  final VoidCallback onAccepted;

  const TermsConditionsScreen({
    super.key,
    required this.onAccepted,
  });

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  bool _isAccepted = false;
  bool _isLoading = true;
  List<TermItemModel> _terms = [];

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    final termsList = await FirestoreService.fetchTermsAndConditions();
    if (mounted) {
      setState(() {
        _terms = termsList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.gavel_rounded, color: AppColors.lightGold, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Guidelines & Terms',
                      style: GoogleFonts.cinzel(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Please review the client terms and consultation guidelines carefully.',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                // Terms List Container (Firestore Dynamic Content)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
                    ),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.primaryGold),
                          )
                        : ListView.separated(
                            itemCount: _terms.length,
                            separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 24),
                            itemBuilder: (context, index) {
                              final item = _terms[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.lightGold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.description,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: AppColors.textPrimary.withOpacity(0.9),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms);
                            },
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Acceptance Checkbox
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isAccepted ? AppColors.lightGold : Colors.white12,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: _isAccepted,
                    activeColor: AppColors.primaryGold,
                    checkColor: AppColors.backgroundDeep,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      'I have read and accept the above Terms and Conditions.',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _isAccepted = val ?? false;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Next Button (Disabled until checked)
                GoldenButton(
                  text: 'Accept & Proceed',
                  onPressed: _isAccepted ? widget.onAccepted : null,
                  icon: Icons.arrow_forward_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
