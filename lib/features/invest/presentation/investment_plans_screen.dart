import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../domain/providers/investment_plans_provider.dart';
import '../domain/models/investment_plan.dart';

class InvestmentPlansScreen extends ConsumerWidget {
  const InvestmentPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(investmentPlansProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          onPressed: () => context.go('/invest/dashboard'),
        ),
        title: Text(
          'Investment Plans',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: plansAsync.when(
        data: (plans) => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return _buildPlanCard(context, plan);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error loading plans: $e')),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, InvestmentPlan plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPopular = plan.planCode == 'GROWTH';

    return GestureDetector(
      onTap: () => context.go('/invest/plan/${plan.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPopular
                ? AppColors.accent
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isPopular ? 1.5 : 1.0,
          ),
          boxShadow: isDark ? null : AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Header with badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isPopular
                    ? AppColors.accent.withOpacity(0.08)
                    : (isDark ? AppColors.darkSurfaceVariant : Colors.grey.withOpacity(0.05)),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        plan.planCode == 'STARTER'
                            ? Icons.rocket_launch_outlined
                            : plan.planCode == 'GROWTH'
                                ? Icons.trending_up_outlined
                                : Icons.workspace_premium_outlined,
                        color: isPopular ? AppColors.accent : AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        plan.planName.toUpperCase(),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: isPopular ? AppColors.accent : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                    ],
                  ),
                  if (isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'MOST POPULAR',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Plan details body
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${plan.annualReturnRate.toInt()}% p.a.',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                          Text('Fixed Annual Return', style: AppTextStyles.caption),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${plan.tenureMonths} Months',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text('Tenure lock-in', style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Min & Max Investment Limits
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Minimum: ₹${CurrencyFormatter.formatCompact(plan.minInvestment)}',
                          style: AppTextStyles.bodyMedium),
                      Text('Maximum: ₹${CurrencyFormatter.formatCompact(plan.maxInvestment)}',
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Highlights / Checklist
                  ...plan.highlights.map((highlight) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 16),
                            const SizedBox(width: 8),
                            Text(highlight, style: AppTextStyles.bodySmall),
                          ],
                        ),
                      )),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go('/invest/plan/${plan.id}'),
                          child: const Text('View details'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => context.go('/invest/now/${plan.id}'),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Invest'),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
