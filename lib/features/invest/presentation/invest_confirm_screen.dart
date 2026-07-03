import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../domain/providers/investment_plans_provider.dart';
import '../domain/providers/portfolio_provider.dart';

class InvestConfirmScreen extends ConsumerStatefulWidget {
  const InvestConfirmScreen({super.key});

  @override
  ConsumerState<InvestConfirmScreen> createState() => _InvestConfirmScreenState();
}

class _InvestConfirmScreenState extends ConsumerState<InvestConfirmScreen> {
  bool _agreementAccepted = false;
  bool _isSubmitting = false;

  void _onConfirm(int planId, double amount, bool isAutoRenew) async {
    if (!_agreementAccepted || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(portfolioProvider.notifier).createInvestment(
            planId: planId,
            amount: amount,
            isAutoRenew: isAutoRenew,
          );
      if (mounted) {
        context.go('/invest/success');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete investment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Unpack arguments
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>? ?? {};
    final planId = extra['planId'] as int? ?? 1;
    final amount = extra['amount'] as double? ?? 10000.0;
    final isAutoRenew = extra['isAutoRenew'] as bool? ?? false;

    final plansAsync = ref.watch(investmentPlansProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Confirm Investment',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: plansAsync.when(
        data: (plans) {
          final plan = plans.firstWhere(
            (p) => p.id == planId,
            orElse: () => plans.first,
          );

          final monthlyReturn = (amount * (plan.annualReturnRate / 100)) / 12;
          final totalReturns = monthlyReturn * plan.tenureMonths;
          final maturityAmount = amount + totalReturns;

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Investment Card Overview
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'INVESTMENT PRINCIPAL',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₹${CurrencyFormatter.format(amount)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Divider(color: Colors.white24),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildWhiteMetric('Plan tenure', '${plan.tenureMonths} Months'),
                                  _buildWhiteMetric('Annual Return', '${plan.annualReturnRate}% p.a.'),
                                  _buildWhiteMetric('Payout Frequency', 'Monthly'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Wallet & Payout bank summaries
                        Text('Transaction Details', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 12),
                        _buildDetailCard(
                          context,
                          children: [
                            _buildDetailRow('Debit Source', 'Lender Wallet (₹${CurrencyFormatter.format(amount)} debited)'),
                            _buildDetailRow('Payout Destination', 'HDFC Bank •••• 4892'),
                            _buildDetailRow('Auto-Renew Plan', isAutoRenew ? 'Enabled' : 'Disabled'),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Return break down summary
                        Text('Earnings Summary', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 12),
                        _buildDetailCard(
                          context,
                          children: [
                            _buildDetailRow('Monthly Interest Return', '₹${CurrencyFormatter.format(monthlyReturn)}'),
                            _buildDetailRow('Total Return on Tenure', '₹${CurrencyFormatter.format(totalReturns)}'),
                            _buildDetailRow('Estimated Maturity Payout', '₹${CurrencyFormatter.format(maturityAmount)}'),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Important warning bullet
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warningSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  plan.earlyExitAllowed
                                      ? 'Note: Early exit is allowed after 30 days. However, a penalty of ${plan.earlyExitPenaltyPct}% is applicable on the principal amount.'
                                      : 'Note: This investment is locked for the entire tenure of 12 months. No early exits are permitted.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.warningDark,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Sticky Checkbox and Confirm Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    border: isDark ? const Border(top: BorderSide(color: AppColors.darkBorder)) : null,
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _agreementAccepted,
                            onChanged: (v) => setState(() => _agreementAccepted = v ?? false),
                            activeColor: AppColors.accent,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _agreementAccepted = !_agreementAccepted),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'I authorize MacroFinance to lock my wallet balance and deploy it to verified borrower pools. I agree to the Investor Agreement.',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: _isSubmitting
                            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _agreementAccepted
                                    ? () => _onConfirm(planId, amount, isAutoRenew)
                                    : null,
                                child: const Text('Confirm & Invest'),
                              ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildWhiteMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: Colors.white70)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
