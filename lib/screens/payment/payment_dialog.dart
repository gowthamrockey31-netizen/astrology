import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/astrologer_model.dart';
import '../../services/auth_service.dart';
import '../../services/payment_service.dart';

class PaymentDialog extends StatefulWidget {
  final AstrologerModel astrologer;
  final String consultationType; // Chat, Voice, Video
  final Function(PaymentResult result) onPaymentComplete;

  const PaymentDialog({
    super.key,
    required this.astrologer,
    required this.consultationType,
    required this.onPaymentComplete,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  String _selectedOption = 'Wallet';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'Wallet', 'name': 'AstroDashaCare Wallet', 'icon': Icons.account_balance_wallet_rounded, 'subtitle': 'Instant Checkout'},
    {'id': 'Razorpay', 'name': 'Razorpay Payment Gateway', 'icon': Icons.flash_on_rounded, 'subtitle': 'All Payment Methods'},
    {'id': 'UPI', 'name': 'UPI (GPay / PhonePe / Paytm)', 'icon': Icons.qr_code_2_rounded, 'subtitle': 'Instant UPI Transfer'},
    {'id': 'Card', 'name': 'Credit / Debit Card', 'icon': Icons.credit_card_rounded, 'subtitle': 'Visa, Mastercard, RuPay'},
    {'id': 'NetBanking', 'name': 'Net Banking', 'icon': Icons.account_balance_rounded, 'subtitle': 'Major Indian Banks'},
  ];

  void _handlePay() async {
    setState(() {
      _isProcessing = true;
    });

    final amount = widget.astrologer.consultationFee * 10; // 10 minutes initial base session

    final result = await PaymentService.processPayment(
      amount: amount,
      paymentMethod: _selectedOption,
      title: '${widget.consultationType} Consultation with ${widget.astrologer.name}',
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    if (result.isSuccess) {
      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.backgroundMid,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
          ),
          title: Column(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.lightGold, size: 54),
              const SizedBox(height: 10),
              Text(
                'Thank you for choosing AstroDashaCare.',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            'Payment of ₹${amount.toStringAsFixed(0)} completed successfully.\nUpdated Wallet Balance: ₹${result.newBalance.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onPaymentComplete(result);
                },
                child: Text('Start Consultation', style: GoogleFonts.outfit(color: AppColors.textDark, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = widget.astrologer.consultationFee * 10;
    final walletBal = AuthService.currentUser?.walletBalance ?? 500.0;

    return Dialog(
      backgroundColor: AppColors.backgroundDeep,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.borderGold, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.security_rounded, color: AppColors.lightGold, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Consultation Payment',
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Message Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
              ),
              child: Text(
                'Please complete the consultation payment to continue with ${widget.astrologer.name}.',
                style: GoogleFonts.outfit(fontSize: 13, color: AppColors.lightGold, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 14),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.consultationType} Call (10 Min Base)',
                        style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      Text(
                        '₹${widget.astrologer.consultationFee.toStringAsFixed(0)} / min',
                        style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  Text(
                    '₹${amount.toStringAsFixed(0)}',
                    style: GoogleFonts.cinzel(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightGold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            Text(
              'Select Payment Option',
              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),

            // Options List
            ..._paymentMethods.map((method) {
              final isSelected = _selectedOption == method['id'];
              return GestureDetector(
                onTap: () => setState(() => _selectedOption = method['id']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGold.withOpacity(0.15) : AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.lightGold : Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Icon(method['icon'] as IconData, color: isSelected ? AppColors.lightGold : AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method['name'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.lightGold : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              method['id'] == 'Wallet'
                                  ? 'Current Balance: ₹${walletBal.toStringAsFixed(2)}'
                                  : method['subtitle'] as String,
                              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Radio<String>(
                        value: method['id'] as String,
                        groupValue: _selectedOption,
                        activeColor: AppColors.primaryGold,
                        onChanged: (val) => setState(() => _selectedOption = val!),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            // Submit Pay Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isProcessing ? null : _handlePay,
                child: _isProcessing
                    ? const CircularProgressIndicator(color: AppColors.backgroundDeep)
                    : Text(
                        'Pay ₹${amount.toStringAsFixed(0)} & Connect',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.backgroundDeep,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
