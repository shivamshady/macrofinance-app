/// Lender Investment Model
class LenderInvestment {
  final String id;
  final String lenderId;
  final int planId;
  final String investmentNumber; // e.g. INV-2024-000001
  final double principalAmount;
  final double annualReturnRate;
  final double monthlyReturnAmount;
  final int tenureMonths;
  final String status; // active, matured, early_exit, cancelled, pending_activation
  final DateTime? investedAt;
  final DateTime? maturesAt;
  final DateTime? nextReturnDate;
  final double totalReturnsPaid;
  final int returnsPaidCount;
  final bool isAutoRenew;
  final DateTime? earlyExitRequestedAt;
  final double earlyExitPenalty;
  final double? netAmountOnExit;
  final String? bankAccountId;
  final String? investmentCertificateUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LenderInvestment({
    required this.id,
    required this.lenderId,
    required this.planId,
    required this.investmentNumber,
    required this.principalAmount,
    required this.annualReturnRate,
    required this.monthlyReturnAmount,
    required this.tenureMonths,
    this.status = 'pending_activation',
    this.investedAt,
    this.maturesAt,
    this.nextReturnDate,
    this.totalReturnsPaid = 0.0,
    this.returnsPaidCount = 0,
    this.isAutoRenew = false,
    this.earlyExitRequestedAt,
    this.earlyExitPenalty = 0.0,
    this.netAmountOnExit,
    this.bankAccountId,
    this.investmentCertificateUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LenderInvestment.fromJson(Map<String, dynamic> json) {
    return LenderInvestment(
      id: json['id'] as String,
      lenderId: json['lender_id'] as String,
      planId: json['plan_id'] as int,
      investmentNumber: json['investment_number'] as String,
      principalAmount: (json['principal_amount'] as num).toDouble(),
      annualReturnRate: (json['annual_return_rate'] as num).toDouble(),
      monthlyReturnAmount: (json['monthly_return_amount'] as num).toDouble(),
      tenureMonths: json['tenure_months'] as int,
      status: json['status'] as String? ?? 'pending_activation',
      investedAt: json['invested_at'] != null ? DateTime.parse(json['invested_at']) : null,
      maturesAt: json['matures_at'] != null ? DateTime.parse(json['matures_at']) : null,
      nextReturnDate: json['next_return_date'] != null ? DateTime.parse(json['next_return_date']) : null,
      totalReturnsPaid: (json['total_returns_paid'] as num? ?? 0.0).toDouble(),
      returnsPaidCount: json['returns_paid_count'] as int? ?? 0,
      isAutoRenew: json['is_auto_renew'] as bool? ?? false,
      earlyExitRequestedAt: json['early_exit_requested_at'] != null ? DateTime.parse(json['early_exit_requested_at']) : null,
      earlyExitPenalty: (json['early_exit_penalty'] as num? ?? 0.0).toDouble(),
      netAmountOnExit: json['net_amount_on_exit'] != null ? (json['net_amount_on_exit'] as num).toDouble() : null,
      bankAccountId: json['bank_account_id'] as String?,
      investmentCertificateUrl: json['investment_certificate_url'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lender_id': lenderId,
      'plan_id': planId,
      'investment_number': investmentNumber,
      'principal_amount': principalAmount,
      'annual_return_rate': annualReturnRate,
      'monthly_return_amount': monthlyReturnAmount,
      'tenure_months': tenureMonths,
      'status': status,
      'invested_at': investedAt?.toIso8601String(),
      'matures_at': maturesAt?.toIso8601String(),
      'next_return_date': nextReturnDate?.toIso8601String(),
      'total_returns_paid': totalReturnsPaid,
      'returns_paid_count': returnsPaidCount,
      'is_auto_renew': isAutoRenew,
      'early_exit_requested_at': earlyExitRequestedAt?.toIso8601String(),
      'early_exit_penalty': earlyExitPenalty,
      'net_amount_on_exit': netAmountOnExit,
      'bank_account_id': bankAccountId,
      'investment_certificate_url': investmentCertificateUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  LenderInvestment copyWith({
    String? status,
    DateTime? investedAt,
    DateTime? maturesAt,
    DateTime? nextReturnDate,
    double? totalReturnsPaid,
    int? returnsPaidCount,
    bool? isAutoRenew,
    DateTime? earlyExitRequestedAt,
    double? earlyExitPenalty,
    double? netAmountOnExit,
    String? investmentCertificateUrl,
  }) {
    return LenderInvestment(
      id: id,
      lenderId: lenderId,
      planId: planId,
      investmentNumber: investmentNumber,
      principalAmount: principalAmount,
      annualReturnRate: annualReturnRate,
      monthlyReturnAmount: monthlyReturnAmount,
      tenureMonths: tenureMonths,
      status: status ?? this.status,
      investedAt: investedAt ?? this.investedAt,
      maturesAt: maturesAt ?? this.maturesAt,
      nextReturnDate: nextReturnDate ?? this.nextReturnDate,
      totalReturnsPaid: totalReturnsPaid ?? this.totalReturnsPaid,
      returnsPaidCount: returnsPaidCount ?? this.returnsPaidCount,
      isAutoRenew: isAutoRenew ?? this.isAutoRenew,
      earlyExitRequestedAt: earlyExitRequestedAt ?? this.earlyExitRequestedAt,
      earlyExitPenalty: earlyExitPenalty ?? this.earlyExitPenalty,
      netAmountOnExit: netAmountOnExit ?? this.netAmountOnExit,
      bankAccountId: bankAccountId,
      investmentCertificateUrl: investmentCertificateUrl ?? this.investmentCertificateUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
