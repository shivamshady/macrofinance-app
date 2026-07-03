import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../domain/providers/portfolio_provider.dart';
import '../domain/models/investment_return.dart';

class ReturnsHistoryScreen extends ConsumerWidget {
  const ReturnsHistoryScreen({super.key});

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

    final returns = portfolioState.returns;
    final paidReturns = returns.where((r) => r.status == 'paid').toList()
      ..sort((a, b) => b.returnPeriodEnd.compareTo(a.returnPeriodEnd)); // Newest first

    final totalInterestPaid = paidReturns.fold<double>(0.0, (acc, r) => acc + r.netReturn);

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
          'Returns History',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interest Earned Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                ),
                child: Column(
                  children: [
                    Text('Total Interest Income Earned', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text(
                      '₹${CurrencyFormatter.format(totalInterestPaid)}',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Transaction Ledger', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),

              // Ledger List
              Expanded(
                child: paidReturns.isEmpty
                    ? Center(
                        child: Text(
                          'No returns paid yet.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: paidReturns.length,
                        itemBuilder: (context, index) {
                          final ret = paidReturns[index];
                          final dateStr = '${ret.returnPeriodEnd.day}/${ret.returnPeriodEnd.month}/${ret.returnPeriodEnd.year}';
                          
                          // Find corresponding plan code or name
                          final inv = portfolioState.investments.firstWhere(
                            (e) => e.id == ret.investmentId,
                            orElse: () => portfolioState.investments.first,
                          );
                          final planName = inv.planId == 1
                              ? 'Starter Plan'
                              : inv.planId == 2
                                  ? 'Growth Plan'
                                  : 'Premium Plan';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$planName — Month ${ret.returnMonth}', style: AppTextStyles.titleSmall),
                                    const SizedBox(height: 2),
                                    Text('Paid on: $dateStr', style: AppTextStyles.caption),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '+₹${CurrencyFormatter.format(ret.netReturn)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                    if (ret.tdsDeducted > 0)
                                      Text(
                                        'TDS: ₹${CurrencyFormatter.format(ret.tdsDeducted)}',
                                        style: AppTextStyles.caption.copyWith(fontSize: 9, color: AppColors.error),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
