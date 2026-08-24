import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/wallet_transaction_model.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../services/payment_service.dart';
import '../../widgets/cosmic_background.dart';
import '../../widgets/golden_button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedTab = 0; // 0: All, 1: Recharges, 2: Refunds

  void _showRechargeModal() {
    double rechargeAmount = 500;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundDeep,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recharge AstroDashaCare Wallet',
                  style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                ),
                const SizedBox(height: 6),
                Text('Select recharge amount to add to your divine balance.', style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [100.0, 300.0, 500.0, 1000.0].map((amt) {
                    final isSel = rechargeAmount == amt;
                    return GestureDetector(
                      onTap: () => setModalState(() => rechargeAmount = amt),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primaryGold.withOpacity(0.2) : AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSel ? AppColors.lightGold : Colors.white12),
                        ),
                        child: Text(
                          '₹${amt.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSel ? AppColors.lightGold : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                GoldenButton(
                  text: 'Pay ₹${rechargeAmount.toStringAsFixed(0)} via Razorpay UPI',
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final res = await PaymentService.processPayment(
                      amount: rechargeAmount,
                      paymentMethod: 'Razorpay UPI',
                      title: 'Wallet Recharge via Razorpay UPI',
                    );
                    if (mounted) {
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _downloadInvoice(WalletTransactionModel txn) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading GST Invoice for ${txn.referenceId}... PDF saved!'),
        backgroundColor: AppColors.backgroundMid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final balance = user?.walletBalance ?? 750.0;
    final txns = MockDataService.walletTransactions;

    final filtered = _selectedTab == 0
        ? txns
        : (_selectedTab == 1
            ? txns.where((t) => t.type == 'credit' && !t.title.contains('Refund')).toList()
            : txns.where((t) => t.title.contains('Refund')).toList());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMid,
        title: Text('AstroDashaCare Wallet', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.purpleAccent, AppColors.backgroundMid],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderGold, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.3),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AVAILABLE WALLET BALANCE', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 1)),
                          const SizedBox(height: 6),
                          Text('₹${balance.toStringAsFixed(2)}', style: GoogleFonts.cinzel(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.lightGold)),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.add_rounded, color: AppColors.backgroundDeep),
                        label: Text('Recharge', style: GoogleFonts.outfit(color: AppColors.backgroundDeep, fontWeight: FontWeight.bold)),
                        onPressed: _showRechargeModal,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Filter Tabs
                Row(
                  children: ['All Activity', 'Recharges', 'Refunds'].asMap().entries.map((entry) {
                    final idx = entry.key;
                    final title = entry.value;
                    final isSel = _selectedTab == idx;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTab = idx),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primaryGold.withOpacity(0.2) : AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSel ? AppColors.lightGold : Colors.white12),
                        ),
                        child: Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSel ? AppColors.lightGold : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Transaction History List
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isCredit = item.type == 'credit';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isCredit ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                              child: Icon(
                                isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                color: isCredit ? Colors.greenAccent : Colors.redAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.title, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${DateFormat('dd MMM yyyy, hh:mm a').format(item.timestamp)} • ${item.paymentMethod}',
                                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isCredit ? "+" : "-"}₹${item.amount.toStringAsFixed(0)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isCredit ? Colors.greenAccent : Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _downloadInvoice(item),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.download_rounded, size: 12, color: AppColors.lightGold),
                                      const SizedBox(width: 2),
                                      Text('Invoice', style: GoogleFonts.outfit(fontSize: 10, color: AppColors.lightGold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
