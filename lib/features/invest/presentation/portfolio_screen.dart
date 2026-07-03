import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../domain/providers/portfolio_provider.dart';
import '../domain/models/lender_investment.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioState = ref.watch(portfolioProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (portfolioState.isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final activeInvs = portfolioState.investments.where((inv) => inv.status == 'active').toList();
    final maturedInvs = portfolioState.investments.where((inv) => inv.status == 'matured').toList();
    final exitedInvs = portfolioState.investments.where((inv) => inv.status == 'early_exit').toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
            'My Portfolio',
            style: AppTextStyles.headlineSmall.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: isDark ? AppColors.darkTextTertiary : AppColors.lightTextSecondary,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Matured'),
              Tab(text: 'Early Exited'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInvestmentsList(context, activeInvs, 'No active investments'),
            _buildInvestmentsList(context, maturedInvs, 'No matured investments'),
            _buildInvestmentsList(context, exitedInvs, 'No early exited investments'),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentsList(BuildContext context, List<LenderInvestment> investments, String emptyText) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (investments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.folder_open_rounded, size: 48, color: AppColors.lightTextTertiary),
              const SizedBox(height: 12),
              Text(
                emptyText,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: investments.length,
      itemBuilder: (context, idx) {
        final inv = investments[idx];
        final planName = inv.planId == 1
            ? 'Starter Plan'
            : inv.planId == 2
                ? 'Growth Plan'
                : 'Premium Plan';

        final progress = inv.returnsPaidCount / inv.tenureMonths;

        return GestureDetector(
          onTap: () => context.go('/invest/portfolio/${inv.id}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
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
                // Top row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      planName,
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '₹${CurrencyFormatter.format(inv.principalAmount)}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(inv.investmentNumber, style: AppTextStyles.caption),
                    Text('${(inv.annualReturnRate).toInt()}% p.a.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.accent, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress Bar
                if (inv.status != 'early_exit') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress', style: AppTextStyles.caption),
                      Text('${inv.returnsPaidCount}/${inv.tenureMonths} Months completed', style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      color: AppColors.accent,
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Early Exit Date:', style: AppTextStyles.caption),
                      Text(
                        inv.earlyExitRequestedAt != null
                            ? '${inv.earlyExitRequestedAt!.day}/${inv.earlyExitRequestedAt!.month}/${inv.earlyExitRequestedAt!.year}'
                            : '-',
                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Penalty deducted:', style: AppTextStyles.caption),
                      Text(
                        '₹${CurrencyFormatter.format(inv.earlyExitPenalty)}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                ],

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Bottom row returns
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total returns paid:', style: AppTextStyles.caption),
                    Text(
                      '₹${CurrencyFormatter.format(inv.totalReturnsPaid)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
