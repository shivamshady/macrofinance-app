import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// MacroFinance v2 — Progressive Loan Tier Configuration
/// 4-tier system: Starter → Bronze → Silver → Gold
/// Max loan capped at ₹50,000
class TierConstants {
  TierConstants._();

  static const List<LoanTierConfig> tiers = [
    LoanTierConfig(
      level: 1,
      name: 'Starter',
      emoji: '🌱',
      minAmount: 2000,
      maxAmount: 5000,
      minCreditScore: 0,        // no credit history needed
      loansRepaidRequired: 0,
      interestRateMonthly: 2.5,
      processingFeePct: 5.0,
      insuranceFeePct: 0.5,
      lateFeeDailyPct: 0.5,
      gstPct: 18.0,
      maxTenureDays: 30,
      color: AppColors.tierStarter,
    ),
    LoanTierConfig(
      level: 2,
      name: 'Bronze',
      emoji: '🥉',
      minAmount: 5001,
      maxAmount: 15000,
      minCreditScore: 600,
      loansRepaidRequired: 1,
      interestRateMonthly: 2.5,
      processingFeePct: 5.0,
      insuranceFeePct: 0.5,
      lateFeeDailyPct: 0.5,
      gstPct: 18.0,
      maxTenureDays: 45,
      color: AppColors.tierBronze,
    ),
    LoanTierConfig(
      level: 3,
      name: 'Silver',
      emoji: '🥈',
      minAmount: 15001,
      maxAmount: 30000,
      minCreditScore: 650,
      loansRepaidRequired: 2,
      interestRateMonthly: 2.5,
      processingFeePct: 5.0,
      insuranceFeePct: 0.5,
      lateFeeDailyPct: 0.5,
      gstPct: 18.0,
      maxTenureDays: 60,
      color: AppColors.tierSilver,
    ),
    LoanTierConfig(
      level: 4,
      name: 'Gold',
      emoji: '🥇',
      minAmount: 30001,
      maxAmount: 50000,
      minCreditScore: 700,
      loansRepaidRequired: 3,
      interestRateMonthly: 2.5,
      processingFeePct: 5.0,
      insuranceFeePct: 0.5,
      lateFeeDailyPct: 0.5,
      gstPct: 18.0,
      maxTenureDays: 90,
      color: AppColors.tierGold,
    ),
  ];

  /// Get tier config by level (1-indexed)
  static LoanTierConfig getTier(int level) {
    return tiers.firstWhere(
      (t) => t.level == level,
      orElse: () => tiers.first,
    );
  }

  /// Get next tier config (null if already at Gold)
  static LoanTierConfig? getNextTier(int currentLevel) {
    if (currentLevel >= 4) return null;
    return getTier(currentLevel + 1);
  }

  /// Determine eligible tier based on credit score and repayment history
  static LoanTierConfig getEligibleTier({
    required int loansRepaidOnTime,
    required int? creditScore,
  }) {
    LoanTierConfig eligible = tiers.first;
    for (final tier in tiers) {
      final score = creditScore ?? 0;
      if (loansRepaidOnTime >= tier.loansRepaidRequired &&
          score >= tier.minCreditScore) {
        eligible = tier;
      }
    }
    return eligible;
  }

  // ── Downgrade Rules ──
  static const int warningThreshold = 1;       // 1 late → warning only
  static const int downgradeThreshold = 2;     // 2 consecutive late → drop 1 tier
  static const int defaultOverdueDays = 90;    // >90 days → lock to Tier 1 + bureau report

  /// Compute tier after downgrade evaluation
  static int evaluateDowngrade({
    required int currentTierLevel,
    required int consecutiveLatePayments,
    required bool hasDefaulted,
  }) {
    if (hasDefaulted) return 1; // locked to Tier 1
    if (consecutiveLatePayments >= downgradeThreshold) {
      return (currentTierLevel - 1).clamp(1, 4);
    }
    return currentTierLevel; // no change
  }
}

/// Immutable tier configuration model
class LoanTierConfig {
  final int level;
  final String name;
  final String emoji;
  final double minAmount;
  final double maxAmount;
  final int minCreditScore;
  final int loansRepaidRequired;
  final double interestRateMonthly;
  final double processingFeePct;
  final double insuranceFeePct;
  final double lateFeeDailyPct;
  final double gstPct;
  final int maxTenureDays;
  final Color color;

  const LoanTierConfig({
    required this.level,
    required this.name,
    required this.emoji,
    required this.minAmount,
    required this.maxAmount,
    required this.minCreditScore,
    required this.loansRepaidRequired,
    required this.interestRateMonthly,
    required this.processingFeePct,
    required this.insuranceFeePct,
    required this.lateFeeDailyPct,
    required this.gstPct,
    required this.maxTenureDays,
    required this.color,
  });

  /// Calculate fee breakdown for a given amount and tenure
  LoanFeeBreakdown calculateFees(double amount, int tenureDays) {
    final processingFee = amount * processingFeePct / 100;
    final gstOnFee = processingFee * gstPct / 100;
    final insuranceFee = amount * insuranceFeePct / 100;
    final totalDeductions = processingFee + gstOnFee + insuranceFee;
    final netDisbursement = amount - totalDeductions;
    final dailyInterest = amount * interestRateMonthly / 100 / 30;
    final totalInterest = dailyInterest * tenureDays;
    final totalRepayable = amount + totalInterest;

    return LoanFeeBreakdown(
      loanAmount: amount,
      processingFee: processingFee,
      gstOnFee: gstOnFee,
      insuranceFee: insuranceFee,
      totalDeductions: totalDeductions,
      netDisbursement: netDisbursement,
      dailyInterest: dailyInterest,
      totalInterest: totalInterest,
      totalRepayable: totalRepayable,
      tenureDays: tenureDays,
    );
  }
}

/// Calculated fee breakdown for a loan
class LoanFeeBreakdown {
  final double loanAmount;
  final double processingFee;
  final double gstOnFee;
  final double insuranceFee;
  final double totalDeductions;
  final double netDisbursement;
  final double dailyInterest;
  final double totalInterest;
  final double totalRepayable;
  final int tenureDays;

  const LoanFeeBreakdown({
    required this.loanAmount,
    required this.processingFee,
    required this.gstOnFee,
    required this.insuranceFee,
    required this.totalDeductions,
    required this.netDisbursement,
    required this.dailyInterest,
    required this.totalInterest,
    required this.totalRepayable,
    required this.tenureDays,
  });
}
