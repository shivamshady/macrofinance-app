/// Lender Profile Model
/// Extends the user for investor/lender-specific functions
class LenderProfile {
  final bool onboardingComplete;
  final String kycStatus; // none, pending_review, verified, rejected
  final String id;
  final String userId;
  final bool isActive;
  final String riskProfile; // conservative, moderate, aggressive
  final bool riskDisclosureSigned;
  final DateTime? riskDisclosureSignedAt;
  final String? lenderAgreementUrl;
  final double totalInvested;
  final double totalReturnsEarned;
  final double walletBalance;
  final bool isTdsApplicable;
  final String? panForTds;
  final double annualInterestEarned;
  final String financialYear;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LenderProfile({
    required this.id,
    required this.userId,
    this.isActive = true,
    this.riskProfile = 'moderate',
    this.riskDisclosureSigned = false,
    this.riskDisclosureSignedAt,
    this.lenderAgreementUrl,
    this.totalInvested = 0.0,
    this.totalReturnsEarned = 0.0,
    this.walletBalance = 0.0,
    this.isTdsApplicable = false,
    this.panForTds,
    this.annualInterestEarned = 0.0,
    this.financialYear = '2024-25',
    required this.createdAt,
    required this.updatedAt,
    this.onboardingComplete = false,
    this.kycStatus = 'none',
  });

  factory LenderProfile.fromJson(Map<String, dynamic> json) {
    return LenderProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      isActive: json['is_active'] as bool? ?? true,
      riskProfile: json['risk_profile'] as String? ?? 'moderate',
      riskDisclosureSigned: json['risk_disclosure_signed'] as bool? ?? false,
      riskDisclosureSignedAt: json['risk_disclosure_signed_at'] != null
          ? DateTime.parse(json['risk_disclosure_signed_at'])
          : null,
      lenderAgreementUrl: json['lender_agreement_url'] as String?,
      totalInvested: (json['total_invested'] as num? ?? 0.0).toDouble(),
      totalReturnsEarned: (json['total_returns_earned'] as num? ?? 0.0).toDouble(),
      walletBalance: (json['wallet_balance'] as num? ?? 0.0).toDouble(),
      isTdsApplicable: json['is_tds_applicable'] as bool? ?? false,
      panForTds: json['pan_for_tds'] as String?,
      annualInterestEarned: (json['annual_interest_earned'] as num? ?? 0.0).toDouble(),
      financialYear: json['financial_year'] as String? ?? '2024-25',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      onboardingComplete: json['onboarding_complete'] as bool? ?? false,
      kycStatus: json['kyc_status'] as String? ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'is_active': isActive,
      'risk_profile': riskProfile,
      'risk_disclosure_signed': riskDisclosureSigned,
      'risk_disclosure_signed_at': riskDisclosureSignedAt?.toIso8601String(),
      'lender_agreement_url': lenderAgreementUrl,
      'total_invested': totalInvested,
      'total_returns_earned': totalReturnsEarned,
      'wallet_balance': walletBalance,
      'is_tds_applicable': isTdsApplicable,
      'pan_for_tds': panForTds,
      'annual_interest_earned': annualInterestEarned,
      'financial_year': financialYear,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'onboarding_complete': onboardingComplete,
      'kyc_status': kycStatus,
    };
  }

  LenderProfile copyWith({
    bool? isActive,
    String? riskProfile,
    bool? riskDisclosureSigned,
    DateTime? riskDisclosureSignedAt,
    String? lenderAgreementUrl,
    double? totalInvested,
    double? totalReturnsEarned,
    double? walletBalance,
    bool? isTdsApplicable,
    String? panForTds,
    double? annualInterestEarned,
    String? financialYear,
    bool? onboardingComplete,
    String? kycStatus,
  }) {
    return LenderProfile(
      id: id,
      userId: userId,
      isActive: isActive ?? this.isActive,
      riskProfile: riskProfile ?? this.riskProfile,
      riskDisclosureSigned: riskDisclosureSigned ?? this.riskDisclosureSigned,
      riskDisclosureSignedAt: riskDisclosureSignedAt ?? this.riskDisclosureSignedAt,
      lenderAgreementUrl: lenderAgreementUrl ?? this.lenderAgreementUrl,
      totalInvested: totalInvested ?? this.totalInvested,
      totalReturnsEarned: totalReturnsEarned ?? this.totalReturnsEarned,
      walletBalance: walletBalance ?? this.walletBalance,
      isTdsApplicable: isTdsApplicable ?? this.isTdsApplicable,
      panForTds: panForTds ?? this.panForTds,
      annualInterestEarned: annualInterestEarned ?? this.annualInterestEarned,
      financialYear: financialYear ?? this.financialYear,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      kycStatus: kycStatus ?? this.kycStatus,
    );
  }
}
