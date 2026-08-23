class WalletTransactionModel {
  final String id;
  final String userId;
  final String title;
  final String type; // credit (recharge/refund), debit (consultation)
  final double amount;
  final String paymentMethod; // Wallet, Razorpay, UPI, Card, NetBanking
  final String status; // success, pending, failed
  final DateTime timestamp;
  final String referenceId;

  WalletTransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.timestamp,
    required this.referenceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'type': type,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'referenceId': referenceId,
    };
  }

  factory WalletTransactionModel.fromMap(Map<String, dynamic> map) {
    return WalletTransactionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? 'Wallet Activity',
      type: map['type'] ?? 'credit',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] ?? 'Razorpay',
      status: map['status'] ?? 'success',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      referenceId: map['referenceId'] ?? 'TXN${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
