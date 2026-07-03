/// Investment Plan Model
class InvestmentPlan {
  final int id;
  final String planCode; // STARTER, GROWTH, PREMIUM
  final String planName;
  final int tenureMonths;
  final double annualReturnRate; // e.g., 12.0 for 12%
  final double monthlyReturnRate; // annualReturnRate / 12
  final double minInvestment;
  final double maxInvestment;
  final bool isActive;
  final bool earlyExitAllowed;
  final double earlyExitPenaltyPct;
  final String description;
  final List<String> highlights;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvestmentPlan({
    required this.id,
    required this.planCode,
    required this.planName,
    required this.tenureMonths,
    required this.annualReturnRate,
    required this.monthlyReturnRate,
    required this.minInvestment,
    required this.maxInvestment,
    this.isActive = true,
    this.earlyExitAllowed = false,
    this.earlyExitPenaltyPct = 0.0,
    required this.description,
    required this.highlights,
    this.displayOrder = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvestmentPlan.fromJson(Map<String, dynamic> json) {
    return InvestmentPlan(
      id: json['id'] as int,
      planCode: json['plan_code'] as String,
      planName: json['plan_name'] as String,
      tenureMonths: json['tenure_months'] as int,
      annualReturnRate: (json['annual_return_rate'] as num).toDouble(),
      monthlyReturnRate: (json['monthly_return_rate'] as num).toDouble(),
      minInvestment: (json['min_investment'] as num).toDouble(),
      maxInvestment: (json['max_investment'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      earlyExitAllowed: json['early_exit_allowed'] as bool? ?? false,
      earlyExitPenaltyPct: (json['early_exit_penalty_pct'] as num? ?? 0.0).toDouble(),
      description: json['description'] as String? ?? '',
      highlights: List<String>.from(json['highlights'] ?? []),
      displayOrder: json['display_order'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_code': planCode,
      'plan_name': planName,
      'tenure_months': tenureMonths,
      'annual_return_rate': annualReturnRate,
      'monthly_return_rate': monthlyReturnRate,
      'min_investment': minInvestment,
      'max_investment': maxInvestment,
      'is_active': isActive,
      'early_exit_allowed': earlyExitAllowed,
      'early_exit_penalty_pct': earlyExitPenaltyPct,
      'description': description,
      'highlights': highlights,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
