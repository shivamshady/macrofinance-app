/// Lender Wallet Transaction Model
class WalletTransaction {
  final String id;
  final String lenderId;
  final String transactionType; // deposit, withdrawal, investment_debit, return_credit, principal_return, tds_deduction, referral_bonus, penalty_debit, refund
  final double amount;
  final double balanceAfter;
  final String? referenceId;
  final String? referenceType; // investment, withdrawal, return
  final String status; // pending, success, failed, reversed
  final String? gatewayRef;
  final String? description;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.lenderId,
    required this.transactionType,
    required this.amount,
    required this.balanceAfter,
    this.referenceId,
    this.referenceType,
    this.status = 'success',
    this.gatewayRef,
    this.description,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      lenderId: json['lender_id'] as String,
      transactionType: json['transaction_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      balanceAfter: (json['balance_after'] as num).toDouble(),
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      status: json['status'] as String? ?? 'success',
      gatewayRef: json['gateway_ref'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lender_id': lenderId,
      'transaction_type': transactionType,
      'amount': amount,
      'balance_after': balanceAfter,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'status': status,
      'gateway_ref': gatewayRef,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
