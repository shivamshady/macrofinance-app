import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/tier_constants.dart';

/// Tier Progress Card — dashboard widget showing upgrade path
/// Shows current tier, progress toward next tier, and unlock teaser
class TierProgressCard extends StatelessWidget {
  final int currentTierLevel;
  final int loansRepaidOnTime;
  final int? creditScore;

  const TierProgressCard({
    super.key,
    required this.currentTierLevel,
    required this.loansRepaidOnTime,
    this.creditScore,
  });

  @override
  Widget build(BuildContext context) {
    final currentTier = TierConstants.getTier(currentTierLevel);
    final nextTier = TierConstants.getNextTier(currentTierLevel);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : AppColors.cardShadow,
        border: isDark
            ? Border.all(color: AppColors.darkBorder)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(currentTier.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${currentTier.name} Tier',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: currentTier.color,
                      ),
                    ),
                    Text(
                      'You\'ve repaid $loansRepaidOnTime loan${loansRepaidOnTime == 1 ? '' : 's'} on time',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Current limit badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₹${_formatAmount(currentTier.maxAmount)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),

          if (nextTier != null) ...[
            const SizedBox(height: 18),

            // Progress bar
            _buildProgressSection(context, nextTier, isDark),

            const SizedBox(height: 14),

            // Unlock teaser
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.accent : AppColors.accent)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 18,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Repay on time to unlock up to ₹${_formatAmount(nextTier.maxAmount)} (${nextTier.name} tier)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),
            // Max tier reached
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.tierGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You\'ve reached the highest tier! Maximum loan: ₹50,000',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tierGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    LoanTierConfig nextTier,
    bool isDark,
  ) {
    final loansNeeded = nextTier.loansRepaidRequired;
    final progress = loansNeeded > 0
        ? (loansRepaidOnTime / loansNeeded).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$loansRepaidOnTime / $loansNeeded loans for ${nextTier.name}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            if (creditScore != null)
              Text(
                'Score: $creditScore${creditScore! >= nextTier.minCreditScore ? ' ✓' : ' (need ${nextTier.minCreditScore})'}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: creditScore! >= nextTier.minCreditScore
                      ? AppColors.accent
                      : AppColors.warning,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(nextTier.color),
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    final intAmount = amount.toInt();
    return intAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
