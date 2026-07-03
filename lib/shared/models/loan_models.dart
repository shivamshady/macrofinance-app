/// MacroFinance v2 — Loan Application Model
/// Matches PostgreSQL loan_applications table schema
class LoanApplicationModel {
  final String id;
  final String userId;
  final int tierLevel;
  final String applicationNumber;
  final double requestedAmount;
  final double? approvedAmount;
  final int tenureDays;
  final double? interestRate;
  final double? processingFee;
  final double? insuranceFee;
  final double? gstAmount;
  final double? netDisbursement;
  final double? totalRepayable;
  final int? creditScoreAtTime;
  final LoanStatus status;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? disbursedAt;
  final DateTime? dueDate;
  final String? bankAccountId;
  final String? loanAgreementUrl;
  final String? esignRefId;
  final DateTime? esignCompletedAt;
  final String? nachRefId;
  final String? nachStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LoanApplicationModel({
    required this.id,
    required this.userId,
    required this.tierLevel,
    required this.applicationNumber,
    required this.requestedAmount,
    this.approvedAmount,
    required this.tenureDays,
    this.interestRate,
    this.processingFee,
    this.insuranceFee,
    this.gstAmount,
    this.netDisbursement,
    this.totalRepayable,
    this.creditScoreAtTime,
    this.status = LoanStatus.draft,
    this.rejectionReason,
    this.submittedAt,
    this.approvedAt,
    this.disbursedAt,
    this.dueDate,
    this.bankAccountId,
    this.loanAgreementUrl,
    this.esignRefId,
    this.esignCompletedAt,
    this.nachRefId,
    this.nachStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == LoanStatus.disbursed;
  bool get isPending => status == LoanStatus.underReview || status == LoanStatus.submitted;
  bool get isOverdue {
    if (dueDate == null || status != LoanStatus.disbursed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  int get daysUntilDue {
    if (dueDate == null) return 0;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  factory LoanApplicationModel.fromJson(Map<String, dynamic> json) {
    return LoanApplicationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tierLevel: json['tier_level'] as int,
      applicationNumber: json['application_number'] as String,
      requestedAmount: (json['requested_amount'] as num).toDouble(),
      approvedAmount: (json['approved_amount'] as num?)?.toDouble(),
      tenureDays: json['tenure_days'] as int,
      interestRate: (json['interest_rate'] as num?)?.toDouble(),
      processingFee: (json['processing_fee'] as num?)?.toDouble(),
      insuranceFee: (json['insurance_fee'] as num?)?.toDouble(),
      gstAmount: (json['gst_amount'] as num?)?.toDouble(),
      netDisbursement: (json['net_disbursement'] as num?)?.toDouble(),
      totalRepayable: (json['total_repayable'] as num?)?.toDouble(),
      creditScoreAtTime: json['credit_score_at_time'] as int?,
      status: LoanStatus.fromString(json['status'] ?? 'draft'),
      rejectionReason: json['rejection_reason'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      disbursedAt: json['disbursed_at'] != null
          ? DateTime.parse(json['disbursed_at'])
          : null,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      bankAccountId: json['bank_account_id'] as String?,
      loanAgreementUrl: json['loan_agreement_url'] as String?,
      esignRefId: json['esign_ref_id'] as String?,
      esignCompletedAt: json['esign_completed_at'] != null
          ? DateTime.parse(json['esign_completed_at'])
          : null,
      nachRefId: json['nach_ref_id'] as String?,
      nachStatus: json['nach_status'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tier_level': tierLevel,
      'application_number': applicationNumber,
      'requested_amount': requestedAmount,
      'approved_amount': approvedAmount,
      'tenure_days': tenureDays,
      'interest_rate': interestRate,
      'processing_fee': processingFee,
      'insurance_fee': insuranceFee,
      'gst_amount': gstAmount,
      'net_disbursement': netDisbursement,
      'total_repayable': totalRepayable,
      'credit_score_at_time': creditScoreAtTime,
      'status': status.value,
      'rejection_reason': rejectionReason,
      'submitted_at': submittedAt?.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'disbursed_at': disbursedAt?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'bank_account_id': bankAccountId,
      'loan_agreement_url': loanAgreementUrl,
      'esign_ref_id': esignRefId,
      'nach_ref_id': nachRefId,
      'nach_status': nachStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Transaction model matching PostgreSQL transactions table
class TransactionModel {
  final String id;
  final String userId;
  final String? loanId;
  final TransactionType type;
  final double amount;
  final String currency;
  final TransactionStatus status;
  final String? paymentMethod;
  final String? gateway;
  final String? gatewayOrderId;
  final String? gatewayPaymentId;
  final DateTime initiatedAt;
  final DateTime? completedAt;
  final String? notes;

  const TransactionModel({
    required this.id,
    required this.userId,
    this.loanId,
    required this.type,
    required this.amount,
    this.currency = 'INR',
    this.status = TransactionStatus.initiated,
    this.paymentMethod,
    this.gateway,
    this.gatewayOrderId,
    this.gatewayPaymentId,
    required this.initiatedAt,
    this.completedAt,
    this.notes,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      loanId: json['loan_id'] as String?,
      type: TransactionType.fromString(json['transaction_type']),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      status: TransactionStatus.fromString(json['status'] ?? 'initiated'),
      paymentMethod: json['payment_method'] as String?,
      gateway: json['gateway'] as String?,
      gatewayOrderId: json['gateway_order_id'] as String?,
      gatewayPaymentId: json['gateway_payment_id'] as String?,
      initiatedAt: DateTime.parse(json['initiated_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      notes: json['notes'] as String?,
    );
  }
}

/// Loan status enum matching PostgreSQL CHECK constraint
enum LoanStatus {
  draft('draft'),
  submitted('submitted'),
  underReview('under_review'),
  approved('approved'),
  rejected('rejected'),
  disbursed('disbursed'),
  cancelled('cancelled'),
  expired('expired');

  final String value;
  const LoanStatus(this.value);

  static LoanStatus fromString(String s) {
    return LoanStatus.values.firstWhere(
      (e) => e.value == s,
      orElse: () => LoanStatus.draft,
    );
  }
}

/// Transaction type enum
enum TransactionType {
  disbursement('disbursement'),
  repayment('repayment'),
  lateFee('late_fee'),
  processingFee('processing_fee'),
  refund('refund'),
  referralPayout('referral_payout');

  final String value;
  const TransactionType(this.value);

  static TransactionType fromString(String s) {
    return TransactionType.values.firstWhere(
      (e) => e.value == s,
      orElse: () => TransactionType.repayment,
    );
  }
}

/// Transaction status enum
enum TransactionStatus {
  initiated('initiated'),
  pending('pending'),
  success('success'),
  failed('failed'),
  refunded('refunded');

  final String value;
  const TransactionStatus(this.value);

  static TransactionStatus fromString(String s) {
    return TransactionStatus.values.firstWhere(
      (e) => e.value == s,
      orElse: () => TransactionStatus.initiated,
    );
  }
}
