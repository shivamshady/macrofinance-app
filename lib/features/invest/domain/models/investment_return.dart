/// Investment Return Model
class InvestmentReturn {
  final String id;
  final String investmentId;
  final String lenderId;
  final int returnMonth;
  final DateTime returnPeriodStart;
  final DateTime returnPeriodEnd;
  final double grossReturn;
  final double tdsDeducted;
  final double netReturn;
  final String status; // scheduled, processing, paid, failed
  final DateTime? paidAt;
  final String? walletTxnId;
  final DateTime createdAt;

  const InvestmentReturn({
    required this.id,
    required this.investmentId,
    required this.lenderId,
    required this.returnMonth,
    required this.returnPeriodStart,
    required this.returnPeriodEnd,
    required this.grossReturn,
    this.tdsDeducted = 0.0,
    required this.netReturn,
    this.status = 'scheduled',
    this.paidAt,
    this.walletTxnId,
    required this.createdAt,
  });

  factory InvestmentReturn.fromJson(Map<String, dynamic> json) {
    return InvestmentReturn(
      id: json['id'] as String,
      investmentId: json['investment_id'] as String,
      lenderId: json['lender_id'] as String,
      returnMonth: json['return_month'] as int,
      returnPeriodStart: DateTime.parse(json['return_period_start']),
      returnPeriodEnd: DateTime.parse(json['return_period_end']),
      grossReturn: (json['gross_return'] as num).toDouble(),
      tdsDeducted: (json['tds_deducted'] as num? ?? 0.0).toDouble(),
      netReturn: (json['net_return'] as num).toDouble(),
      status: json['status'] as String? ?? 'scheduled',
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      walletTxnId: json['wallet_txn_id'] as String?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'investment_id': investmentId,
      'lender_id': lenderId,
      'return_month': returnMonth,
      'return_period_start': returnPeriodStart.toIso8601String(),
      'return_period_end': returnPeriodEnd.toIso8601String(),
      'gross_return': grossReturn,
      'tds_deducted': tdsDeducted,
      'net_return': netReturn,
      'status': status,
      'paid_at': paidAt?.toIso8601String(),
      'wallet_txn_id': walletTxnId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
