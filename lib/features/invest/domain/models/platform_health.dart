/// Platform Health Metrics Model
class PlatformHealth {
  final int id;
  final DateTime snapshotDate;
  final int totalActiveLoans;
  final int totalLoansDisbursed;
  final double totalAmountDisbursed;
  final double npaPercentage;
  final int avgBorrowerCreditScore;
  final double onTimeRepaymentRate;
  final int totalLendersActive;
  final double totalFundsDeployed;
  final DateTime createdAt;

  const PlatformHealth({
    required this.id,
    required this.snapshotDate,
    this.totalActiveLoans = 0,
    this.totalLoansDisbursed = 0,
    this.totalAmountDisbursed = 0.0,
    this.npaPercentage = 0.0,
    this.avgBorrowerCreditScore = 0,
    this.onTimeRepaymentRate = 0.0,
    this.totalLendersActive = 0,
    this.totalFundsDeployed = 0.0,
    required this.createdAt,
  });

  factory PlatformHealth.fromJson(Map<String, dynamic> json) {
    return PlatformHealth(
      id: json['id'] as int,
      snapshotDate: DateTime.parse(json['snapshot_date']),
      totalActiveLoans: json['total_active_loans'] as int? ?? 0,
      totalLoansDisbursed: json['total_loans_disbursed'] as int? ?? 0,
      totalAmountDisbursed: (json['total_amount_disbursed'] as num? ?? 0.0).toDouble(),
      npaPercentage: (json['npa_percentage'] as num? ?? 0.0).toDouble(),
      avgBorrowerCreditScore: json['avg_borrower_credit_score'] as int? ?? 0,
      onTimeRepaymentRate: (json['on_time_repayment_rate'] as num? ?? 0.0).toDouble(),
      totalLendersActive: json['total_lenders_active'] as int? ?? 0,
      totalFundsDeployed: (json['total_funds_deployed'] as num? ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'snapshot_date': snapshotDate.toIso8601String(),
      'total_active_loans': totalActiveLoans,
      'total_loans_disbursed': totalLoansDisbursed,
      'total_amount_disbursed': totalAmountDisbursed,
      'npa_percentage': npaPercentage,
      'avg_borrower_credit_score': avgBorrowerCreditScore,
      'on_time_repayment_rate': onTimeRepaymentRate,
      'total_lenders_active': totalLendersActive,
      'total_funds_deployed': totalFundsDeployed,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
