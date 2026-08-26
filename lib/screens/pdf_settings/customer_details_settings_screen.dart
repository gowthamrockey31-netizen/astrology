import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/customer_pdf_settings_model.dart';
import '../../models/pdf_fixed_content_config.dart';
import '../../services/pdf_settings_service.dart';
import '../../widgets/cosmic_background.dart';

/// PDF Settings Screen: Customer & Company Details Configuration
/// Only customer/company editable fields are shown.
/// Software Footer and Slokam are permanently locked.
class CustomerDetailsSettingsScreen extends StatefulWidget {
  const CustomerDetailsSettingsScreen({super.key});

  @override
  State<CustomerDetailsSettingsScreen> createState() => _CustomerDetailsSettingsScreenState();
}

class _CustomerDetailsSettingsScreenState extends State<CustomerDetailsSettingsScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _companyCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _gstCtrl;
  late TextEditingController _invocationCtrl;

  @override
  void initState() {
    super.initState();
    final s = PdfSettingsService.currentSettings;
    _nameCtrl = TextEditingController(text: s.astrologerName);
    _companyCtrl = TextEditingController(text: s.companyName);
    _titleCtrl = TextEditingController(text: s.titleSubtitle);
    _addressCtrl = TextEditingController(text: s.address);
    _phoneCtrl = TextEditingController(text: s.phone);
    _emailCtrl = TextEditingController(text: s.email);
    _websiteCtrl = TextEditingController(text: s.website);
    _gstCtrl = TextEditingController(text: s.gstNumber);
    _invocationCtrl = TextEditingController(text: s.invocationText);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _titleCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _websiteCtrl.dispose();
    _gstCtrl.dispose();
    _invocationCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    final updated = CustomerPdfSettings(
      astrologerName: _nameCtrl.text.trim(),
      companyName: _companyCtrl.text.trim(),
      titleSubtitle: _titleCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      website: _websiteCtrl.text.trim(),
      gstNumber: _gstCtrl.text.trim(),
      invocationText: _invocationCtrl.text.trim(),
    );

    await PdfSettingsService.saveSettings(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.black),
              const SizedBox(width: 10),
              Text(
                'PDF அமைப்புகள் வெற்றிகரமாக சேமிக்கப்பட்டன!',
                style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryGold,
        ),
      );
    }
  }

  void _resetDefaults() async {
    await PdfSettingsService.resetToDefault();
    final s = PdfSettingsService.currentSettings;
    setState(() {
      _nameCtrl.text = s.astrologerName;
      _companyCtrl.text = s.companyName;
      _titleCtrl.text = s.titleSubtitle;
      _addressCtrl.text = s.address;
      _phoneCtrl.text = s.phone;
      _emailCtrl.text = s.email;
      _websiteCtrl.text = s.website;
      _gstCtrl.text = s.gstNumber;
      _invocationCtrl.text = s.invocationText;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'இயல்புநிலை அமைப்புகள் மீட்கப்பட்டன (Reset to Defaults).',
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: AppColors.backgroundMid,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold),
                    ),
                    Expanded(
                      child: Text(
                        'PDF Settings',
                        style: GoogleFonts.cinzel(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                      tooltip: 'Reset Defaults',
                      onPressed: _resetDefaults,
                    ),
                  ],
                ).animate().fade(duration: 400.ms),

                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    'ஜாதக PDF அச்சிடுவதற்கான வாடிக்கையாளர் / ஜோதிட நிலைய விவரங்கள்',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 18),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'நிறுவன & ஜோதிடர் விவரங்கள்',
                        style: GoogleFonts.cinzel(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                      const Divider(color: AppColors.borderGold, height: 20),
                      const SizedBox(height: 6),

                      _buildField(_companyCtrl, 'ஜோதிட நிலைய பெயர் (Company / Center Name)', Icons.account_balance_rounded),
                      const SizedBox(height: 12),

                      _buildField(_nameCtrl, 'ஜோதிடர் பெயர் (Astrologer Name & Title)', Icons.person_rounded),
                      const SizedBox(height: 12),

                      _buildField(_titleCtrl, 'சிறப்பு தலைப்பு (Subtitle / Services)', Icons.star_rounded),
                      const SizedBox(height: 12),

                      _buildField(_addressCtrl, 'முழு முகவரி (Full Address)', Icons.location_on_rounded, maxLines: 2),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(child: _buildField(_phoneCtrl, 'தொலைபேசி எண் (Phone)', Icons.phone_rounded)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildField(_emailCtrl, 'மின்னஞ்சல் (Email)', Icons.email_rounded)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(child: _buildField(_websiteCtrl, 'இணையதளம் (Website)', Icons.language_rounded)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildField(_gstCtrl, 'பதிவு / GST எண் (Optional)', Icons.receipt_long_rounded)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'PDF முகப்பு வாசகம் (Header Invocation)',
                        style: GoogleFonts.cinzel(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightGold,
                        ),
                      ),
                      const Divider(color: AppColors.borderGold, height: 20),
                      const SizedBox(height: 6),

                      _buildField(_invocationCtrl, 'மேல் முகப்பு வாசகம் (Invocation Line)', Icons.auto_awesome_rounded),
                      const SizedBox(height: 20),

                      // Fixed Permanent Content Section (Read-Only)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundDeep.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderGold.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.lock_outline_rounded, color: AppColors.lightGold, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'நிலையான வாசகங்கள் (Fixed Application Content)',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.lightGold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ஸ்லோகம்: ${PdfFixedContentConfig.slokaFooter}',
                              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'அடிக்குறிப்பு: ${PdfFixedContentConfig.softwareFooter}',
                              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _saveSettings,
                          icon: const Icon(Icons.save_rounded, color: Colors.black),
                          label: Text(
                            'அமைப்புகளை சேமிக்கவும் (Save PDF Settings)',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
        prefixIcon: Icon(icon, color: AppColors.lightGold, size: 18),
        filled: true,
        fillColor: AppColors.backgroundMid,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderGold, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderGold.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
