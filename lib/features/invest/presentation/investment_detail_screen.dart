import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../domain/providers/portfolio_provider.dart';
import '../domain/providers/investment_plans_provider.dart';
import '../domain/models/lender_investment.dart';

class InvestmentDetailScreen extends ConsumerWidget {
  final String investmentId;
  const InvestmentDetailScreen({super.key, required this.investmentId});

  void _onEarlyExit(BuildContext context, WidgetRef ref, LenderInvestment inv, double penalty, double netAmount) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          title: Text('Exit Investment?', style: AppTextStyles.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to exit early? Your funds will be returned to your wallet immediately.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildExitRow('Principal Amount:', '₹${CurrencyFormatter.format(inv.principalAmount)}', isDark),
              _buildExitRow('Early Exit Penalty (2%):', '- ₹${CurrencyFormatter.format(penalty)}', isDark, isError: true),
              const Divider(),
              _buildExitRow('Net Refund to Wallet:', '₹${CurrencyFormatter.format(netAmount)}', isDark, isAccent: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.lightTextSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                try {
                  await ref.read(portfolioProvider.notifier).requestEarlyExit(inv.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Early exit completed. Funds refunded to wallet.')),
                    );
                    context.go('/invest/portfolio');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Early exit failed: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              child: const Text('Confirm Exit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExitRow(String label, String value, bool isDark, {bool isError = false, bool isAccent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isError ? AppColors.error : (isAccent ? AppColors.accent : null),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioState = ref.watch(portfolioProvider);
    final plansAsync = ref.watch(investmentPlansProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inv = portfolioState.investments.firstWhere(
      (e) => e.id == investmentId,
      orElse: () => portfolioState.investments.first,
    );

    final planName = inv.planId == 1
        ? 'Starter Plan'
        : inv.planId == 2
            ? 'Growth Plan'
            : 'Premium Plan';

    final returnsList = portfolioState.returns.where((e) => e.investmentId == inv.id).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          onPressed: () => context.go('/invest/portfolio'),
        ),
        title: Text(
          planName,
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: plansAsync.when(
        data: (plans) {
          final plan = plans.firstWhere((p) => p.id == inv.planId, orElse: () => plans.first);
          
          final penalty = inv.principalAmount * (plan.earlyExitPenaltyPct / 100);
          final netRefund = inv.principalAmount - penalty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                    boxShadow: isDark ? null : AppColors.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Principal Invested', style: AppTextStyles.caption),
                              const SizedBox(height: 2),
                              Text(
                                '₹${CurrencyFormatter.format(inv.principalAmount)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          _buildStatusBadge(inv.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailCol('Interest Rate', '${inv.annualReturnRate}% p.a.'),
                          _buildDetailCol('Monthly Payout', '₹${CurrencyFormatter.format(inv.monthlyReturnAmount)}'),
                          _buildDetailCol('Tenure', '${inv.tenureMonths} Months'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Timeline Section
                Text('Returns Timeline', style: AppTextStyles.titleMedium),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                  ),
                  child: returnsList.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('No payouts scheduled', style: AppTextStyles.bodySmall),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: returnsList.length,
                          itemBuilder: (context, index) {
                            final ret = returnsList[index];
                            final dateStr = '${ret.returnPeriodEnd.day}/${ret.returnPeriodEnd.month}/${ret.returnPeriodEnd.year}';
                            final isPaid = ret.status == 'paid';

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
                                    color: isPaid ? AppColors.accent : AppColors.lightTextTertiary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Month ${ret.returnMonth}', style: AppTextStyles.titleSmall),
                                        Text('Payout due by: $dateStr', style: AppTextStyles.caption),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${CurrencyFormatter.format(ret.netReturn)}',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: isPaid ? AppColors.accent : null,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),

                // Documents / Actions
                _buildActionTile(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Download Investment Certificate',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Downloading Certificate PDF...')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildActionTile(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'Download Return Statement',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Downloading Statement PDF...')),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Early Exit Option
                if (inv.status == 'active' && plan.earlyExitAllowed) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.errorSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Early Exit Option',
                          style: AppTextStyles.titleSmall.copyWith(color: AppColors.error, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'You can liquidate this investment early. A penalty of ${plan.earlyExitPenaltyPct}% will be deducted from your principal amount.',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _onEarlyExit(context, ref, inv, penalty, netRefund),
                            child: const Text('Exit Investment'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error loading plan: $e')),
      ),
    );
  }

  Widget _buildDetailCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.lightTextTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = AppColors.statusPending.withOpacity(0.12);
    Color fg = AppColors.statusPending;
    String label = status.toUpperCase();

    if (status == 'active') {
      bg = AppColors.statusActive.withOpacity(0.12);
      fg = AppColors.statusActive;
      label = 'ACTIVE';
    } else if (status == 'matured') {
      bg = AppColors.statusApproved.withOpacity(0.12);
      fg = AppColors.statusApproved;
      label = 'MATURED';
    } else if (status == 'early_exit') {
      bg = AppColors.statusRejected.withOpacity(0.12);
      fg = AppColors.statusRejected;
      label = 'EXITED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
