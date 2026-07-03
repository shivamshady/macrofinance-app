import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../domain/providers/investment_plans_provider.dart';
import '../domain/models/investment_plan.dart';

class PlanDetailScreen extends ConsumerStatefulWidget {
  final String planId;
  const PlanDetailScreen({super.key, required this.planId});

  @override
  ConsumerState<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends ConsumerState<PlanDetailScreen> {
  double _investAmount = 10000;

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => context.go('/invest/plans'),
        ),
        title: Text(
          'Plan Details',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: plansAsync.when(
        data: (plans) {
          final plan = plans.firstWhere(
            (p) => p.id.toString() == widget.planId,
            orElse: () => plans.first,
          );

          // Constrain slider value to min and max investment of the plan
          if (_investAmount < plan.minInvestment) {
            _investAmount = plan.minInvestment;
          } else if (_investAmount > plan.maxInvestment) {
            _investAmount = plan.maxInvestment;
          }

          final monthlyReturn = (_investAmount * (plan.annualReturnRate / 100)) / 12;
          final totalReturns = monthlyReturn * plan.tenureMonths;
          final maturityAmount = _investAmount + totalReturns;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plan Info Card
                      _buildHeaderCard(context, plan),
                      const SizedBox(height: 24),

                      // Return Calculator Section
                      Text('Return Calculator', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 14),
                      _buildCalculatorCard(context, plan, monthlyReturn, totalReturns, maturityAmount),
                      const SizedBox(height: 24),

                      // FAQs Section
                      Text('Frequently Asked Questions', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 14),
                      _buildFaqItem(
                        context,
                        q: 'How are interest payouts credited?',
                        a: 'Interest payouts are computed daily and credited directly to your MacroFinance wallet on the 1st of every month. You can withdraw them immediately or reinvest.',
                      ),
                      _buildFaqItem(
                        context,
                        q: 'Can I exit early before maturity?',
                        a: plan.earlyExitAllowed
                            ? 'Yes, early exits are allowed after a lock-in of 30 days. However, a penalty of ${plan.earlyExitPenaltyPct}% will be deducted from your principal amount.'
                            : 'No, this Premium Plan has a strict lock-in. Funds are deployed in 12-month tenure commercial pools and cannot be withdrawn prior to maturity.',
                      ),
                      _buildFaqItem(
                        context,
                        q: 'Are returns subject to TDS?',
                        a: 'Yes, interest earned is subject to 10% TDS under Section 194A if your aggregate interest earnings on the platform exceed ₹5,000 in a financial year.',
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom sticky invest bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    )
                  ],
                  border: isDark
                      ? const Border(top: BorderSide(color: AppColors.darkBorder))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Total Return rate', style: AppTextStyles.caption),
                        Text(
                          '${plan.annualReturnRate}% p.a.',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 180,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => context.go('/invest/now/${plan.id}'),
                        child: const Text('Invest Now'),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error loading details: $e')),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, InvestmentPlan plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : AppColors.cardShadow,
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.planName,
                style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: plan.earlyExitAllowed
                      ? AppColors.accent.withOpacity(0.12)
                      : AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plan.earlyExitAllowed ? 'Early Exit' : 'Locked Plan',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: plan.earlyExitAllowed ? AppColors.accent : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(plan.description, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('Tenure', '${plan.tenureMonths} Months'),
              _buildMetric('Rate of Return', '${plan.annualReturnRate}% p.a.'),
              _buildMetric('Min Amount', '₹${CurrencyFormatter.formatCompact(plan.minInvestment)}'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildCalculatorCard(
    BuildContext context,
    InvestmentPlan plan,
    double monthlyReturn,
    double totalReturns,
    double maturityAmount,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: isDark ? null : AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Investment Amount', style: AppTextStyles.labelMedium),
              Text(
                '₹${CurrencyFormatter.format(_investAmount.toInt().toDouble())}',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accent.withOpacity(0.2),
            ),
            child: Slider(
              value: _investAmount,
              min: plan.minInvestment,
              max: plan.maxInvestment,
              divisions: ((plan.maxInvestment - plan.minInvestment) / 1000).toInt(),
              onChanged: (val) {
                setState(() {
                  _investAmount = (val / 1000).round() * 1000.0;
                });
              },
            ),
          ),

          // Limits label below slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${CurrencyFormatter.formatCompact(plan.minInvestment)}', style: AppTextStyles.caption),
              Text('₹${CurrencyFormatter.formatCompact(plan.maxInvestment)}', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 20),

          // Calculated Results Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkScaffold : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildCalcRow('Monthly interest payout', '₹${CurrencyFormatter.format(monthlyReturn)}', isAccent: true),
                const SizedBox(height: 10),
                _buildCalcRow('Total interest returns', '₹${CurrencyFormatter.format(totalReturns)}'),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                _buildCalcRow('Total maturity value', '₹${CurrencyFormatter.format(maturityAmount)}', isBold: true),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCalcRow(String label, String value, {bool isAccent = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 16 : 14,
            fontWeight: (isBold || isAccent) ? FontWeight.w700 : FontWeight.w500,
            color: isAccent ? AppColors.accent : (isBold ? AppColors.primary : null),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqItem(BuildContext context, {required String q, required String a}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        ),
        child: ExpansionTile(
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.lightTextSecondary,
          title: Text(
            q,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                a,
                style: AppTextStyles.bodySmall.copyWith(
                  height: 1.45,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
