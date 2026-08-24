import 'dart:async';
import '../models/wallet_transaction_model.dart';
import '../services/mock_data_service.dart';
import '../services/auth_service.dart';

class PaymentResult {
  final bool isSuccess;
  final String message;
  final String transactionId;
  final double newBalance;

  PaymentResult({
    required this.isSuccess,
    required this.message,
    required this.transactionId,
    required this.newBalance,
  });
}

class PaymentService {
  /// Process wallet payment or recharge via Razorpay/UPI/Card/NetBanking
  static Future<PaymentResult> processPayment({
    required double amount,
    required String paymentMethod, // Wallet, Razorpay, UPI, Credit/Debit Card, Net Banking
    required String title,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final user = AuthService.currentUser;
    final currentBal = user?.walletBalance ?? 500.0;
    final txnId = 'RZP_${DateTime.now().millisecondsSinceEpoch}';

    double newBal = currentBal;

    if (paymentMethod == 'Wallet') {
      if (currentBal < amount) {
        return PaymentResult(
          isSuccess: false,
          message: 'Insufficient wallet balance. Please recharge your wallet to continue.',
          transactionId: '',
          newBalance: currentBal,
        );
      }
      newBal = currentBal - amount;
    } else {
      // Recharge or direct gateway payment adds or settles
      newBal = currentBal + (title.toLowerCase().contains('recharge') ? amount : 0);
    }

    if (user != null) {
      AuthService.updateUserProfile(user.copyWith(walletBalance: newBal));
    }

    final newTxn = WalletTransactionModel(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      userId: user?.id ?? 'usr_1',
      title: title,
      type: title.toLowerCase().contains('recharge') ? 'credit' : 'debit',
      amount: amount,
      paymentMethod: paymentMethod,
      status: 'success',
      timestamp: DateTime.now(),
      referenceId: txnId,
    );

    MockDataService.walletTransactions.insert(0, newTxn);

    return PaymentResult(
      isSuccess: true,
      message: 'Thank you for choosing AstroDashaCare! Payment processed successfully.',
      transactionId: txnId,
      newBalance: newBal,
    );
  }
}
