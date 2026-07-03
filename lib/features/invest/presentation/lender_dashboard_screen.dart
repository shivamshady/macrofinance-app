import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../domain/providers/lender_profile_provider.dart';
import '../domain/providers/portfolio_provider.dart';
import '../domain/providers/wallet_provider.dart';
import '../domain/providers/platform_health_provider.dart';
import '../domain/models/lender_investment.dart';
import '../domain/models/platform_health.dart';


class LenderDashboardScreen extends ConsumerWidget {
  const LenderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(lenderProfileProvider);
    final portfolioState = ref.watch(portfolioProvider);
    final healthState = ref.watch(platformHealthProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (profileState.isLoading || profileState.profile == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final profile = profileState.profile!;
    final activeInvs = portfolioState.investments.where((inv) => inv.status == 'active').toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'M',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lender Portal', style: AppTextStyles.bodySmall),
                Text('Rahul Sharma', style: AppTextStyles.titleSmall),
              ],
            ),
          ],
        ),
        actions: [
          // Switch to Borrower Role Button
          IconButton(
            tooltip: 'Switch to Borrower',
            icon: Icon(Icons.swap_horiz_rounded,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(lenderProfileProvider.notifier).loadProfile();
          await ref.read(portfolioProvider.notifier).loadPortfolio();
          await ref.read(walletProvider.notifier).loadWalletData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Summary Card
              _buildWalletCard(context, profile.walletBalance),
              const SizedBox(height: 20),

              // Portfolio Summary Row (3 stat chips)
              _buildPortfolioStatsRow(
                context,
                totalInvested: profile.totalInvested,
                returnsEarned: profile.totalReturnsEarned,
                activeCount: activeInvs.length,
              ),
              const SizedBox(height: 24),

              // Active Investments Carousel/Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Active Investments', style: AppTextStyles.titleMedium),
                  if (portfolioState.investments.isNotEmpty)
                    TextButton(
                      onPressed: () => context.go('/invest/portfolio'),
                      child: Text('View All',
                          style: AppTextStyles.labelMedium.copyWith(color: AppColors.accent)),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              _buildActiveInvestmentsSection(context, activeInvs),
              const SizedBox(height: 24),

              // Quick Actions
              Text('Quick Actions', style: AppTextStyles.titleMedium),
              const SizedBox(height: 14),
              _buildQuickActionsGrid(context),
              const SizedBox(height: 28),

              // Platform Health Teaser
              healthState.when(
                data: (metrics) => _buildPlatformHealthCard(context, metrics),
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => const SizedBox(),
              ),
              const SizedBox(height: 28),

              // Payouts line chart
              Text('Returns History', style: AppTextStyles.titleMedium),
              const SizedBox(height: 14),
              _buildReturnsChartCard(context),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, double balance) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
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
              Text('💰 Available Balance', style: AppTextStyles.labelMedium),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.lightTextSecondary),
                onPressed: () => context.go('/invest/wallet'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${CurrencyFormatter.format(balance)}',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => context.go('/invest/wallet/add'),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Funds'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.lightBorder),
                    ),
                    onPressed: () => context.go('/invest/wallet/withdraw'),
                    icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                    label: const Text('Withdraw'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioStatsRow(
    BuildContext context, {
    required double totalInvested,
    required double returnsEarned,
    required int activeCount,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final decoration = BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(12),
      border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      boxShadow: isDark ? null : AppColors.cardShadow,
    );

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: decoration,
            child: Column(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 20),
                const SizedBox(height: 6),
                Text('Invested', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  '₹${CurrencyFormatter.formatCompact(totalInvested)}',
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: decoration,
            child: Column(
              children: [
                const Icon(Icons.trending_up_rounded, color: AppColors.accent, size: 20),
                const SizedBox(height: 6),
                Text('Returns', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  '₹${CurrencyFormatter.formatCompact(returnsEarned)}',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: decoration,
            child: Column(
              children: [
                const Icon(Icons.auto_awesome_motion_outlined, color: AppColors.info, size: 20),
                const SizedBox(height: 6),
                Text('Active Plans', style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  activeCount.toString(),
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveInvestmentsSection(BuildContext context, List<LenderInvestment> investments) {
    if (investments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Theme.of(context).brightness == Brightness.dark
              ? Border.all(color: AppColors.darkBorder)
              : null,
        ),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined, size: 36, color: AppColors.lightTextTertiary),
            const SizedBox(height: 10),
            Text(
              'No active investments',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Park funds in our Starter, Growth, or Premium plans to begin earning returns.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => context.go('/invest/plans'),
              child: const Text('Browse Plans →', style: TextStyle(color: AppColors.accent)),
            )
          ],
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: investments.length,
        itemBuilder: (context, idx) {
          final inv = investments[idx];
          return _buildActiveInvestmentCard(context, inv);
        },
      ),
    );
  }

  Widget _buildActiveInvestmentCard(BuildContext context, LenderInvestment inv) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthsCompleted = inv.returnsPaidCount;
    final progress = monthsCompleted / inv.tenureMonths;
    final planName = inv.planId == 1
        ? 'Starter Plan'
        : inv.planId == 2
            ? 'Growth Plan'
            : 'Premium Plan';

    return GestureDetector(
      onTap: () => context.go('/invest/portfolio/${inv.id}'),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
          boxShadow: isDark ? null : AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(planName, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  '₹${CurrencyFormatter.formatCompact(inv.principalAmount)}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Next payout: ${inv.nextReturnDate != null ? "${inv.nextReturnDate!.day}/${inv.nextReturnDate!.month}" : "Pending"}',
                    style: AppTextStyles.caption),
                Text('$monthsCompleted/${inv.tenureMonths} Mo', style: AppTextStyles.caption),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return Row(
      children: [
        _buildActionItem(context, icon: Icons.trending_up_rounded, label: 'Invest\nNow', path: '/invest/plans', color: AppColors.primary),
        const SizedBox(width: 8),
        _buildActionItem(context, icon: Icons.file_present_outlined, label: 'Tax\nDocs', path: '/invest/tax', color: AppColors.accent),
        const SizedBox(width: 8),
        _buildActionItem(context, icon: Icons.health_and_safety_outlined, label: 'Loan\nBook', path: '/invest/health', color: AppColors.info),
        const SizedBox(width: 8),
        _buildActionItem(context, icon: Icons.share_outlined, label: 'Referral\nCode', path: '/invest/referral', color: AppColors.warning),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String path,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.go(path),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: isDark ? Border.all(color: AppColors.darkBorder) : null,
            boxShadow: isDark ? null : AppColors.cardShadow,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformHealthCard(BuildContext context, PlatformHealth metrics) {
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
              Text('📊 Platform Trust metrics', style: AppTextStyles.titleMedium),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.accent),
                onPressed: () => context.go('/invest/health'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHealthItem('On-time Repayment', '${metrics.onTimeRepaymentRate}%', AppColors.accent),
              ),
              Expanded(
                child: _buildHealthItem('Avg Credit Score', '${metrics.avgBorrowerCreditScore}', AppColors.primary),
              ),
              Expanded(
                child: _buildHealthItem('NPA percentage', '${metrics.npaPercentage}%', AppColors.error),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHealthItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReturnsChartCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: isDark ? null : AppColors.cardShadow,
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: _bottomTitlesWidget,
                reservedSize: 22,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 250),
                FlSpot(1, 250),
                FlSpot(2, 562),
                FlSpot(3, 562),
              ],
              isCurved: true,
              gradient: AppColors.accentGradient,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.accent.withOpacity(0.2),
                    AppColors.accent.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomTitlesWidget(double value, TitleMeta meta) {
    String text = '';
    switch (value.toInt()) {
      case 0:
        text = 'Mar';
        break;
      case 1:
        text = 'Apr';
        break;
      case 2:
        text = 'May';
        break;
      case 3:
        text = 'Jun';
        break;
    }
    return SideTitleWidget(
      meta: meta,
      child: Text(text, style: AppTextStyles.caption.copyWith(fontSize: 10)),
    );
  }
}
