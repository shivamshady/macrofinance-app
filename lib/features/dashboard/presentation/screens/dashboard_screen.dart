import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';

import '../../../../shared/widgets/tier_progress_card.dart';
import '../../../../shared/widgets/tier_badge.dart';

import '../../../../core/storage/mock_data_store.dart';

/// Dashboard v2 — Tier-aware Borrower & Lender views
class DashboardScreen extends StatefulWidget {
  final bool isLender;

  const DashboardScreen({super.key, this.isLender = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = MockDataStore().currentUser;
    final userName = user?.fullName ?? 'Shivam';
    final userInitials = userName.isNotEmpty ? userName[0].toUpperCase() : 'S';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Center(
                    child: Text(
                      userInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good Evening', style: AppTextStyles.bodySmall),
                    Text(userName, style: AppTextStyles.titleSmall),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Stack(
                  children: [
                    Icon(Icons.notifications_outlined, size: 24,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                widget.isLender ? _buildLenderView(isDark) : _buildBorrowerView(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Borrower Dashboard (v2: Tier-aware) ──
  List<Widget> _buildBorrowerView(bool isDark) {
    return [
      const SizedBox(height: 8),

      // Tier Progress Card (replaces old credit score card)
      const TierProgressCard(
        currentTierLevel: 2,
        loansRepaidOnTime: 1,
        creditScore: 680,
      ),

      const SizedBox(height: 20),

      // Active Loan Card (v2 spec)
      _ActiveLoanCard(isDark: isDark),

      const SizedBox(height: 20),

      // Quick Actions
      Text('Quick Actions', style: AppTextStyles.titleMedium),
      const SizedBox(height: 14),
      Row(
        children: [
          _QuickAction(
            icon: Icons.add_circle_outline_rounded,
            label: 'Apply\nLoan',
            gradient: AppColors.primaryGradient,
            onTap: () {},
          ),
          const SizedBox(width: 12),
          _QuickAction(
            icon: Icons.payment_outlined,
            label: 'Repay\nLoan',
            gradient: AppColors.accentGradient,
            onTap: () {},
          ),
          const SizedBox(width: 12),
          _QuickAction(
            icon: Icons.share_outlined,
            label: 'Refer &\nEarn',
            gradient: AppColors.goldGradient,
            onTap: () {},
          ),
          const SizedBox(width: 12),
          _QuickAction(
            icon: Icons.support_agent_outlined,
            label: 'Help\nCenter',
            gradient: const LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
            ),
            onTap: () {},
          ),
        ],
      ),

      const SizedBox(height: 28),

      // Loan History
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Loan History', style: AppTextStyles.titleMedium),
          TextButton(
            onPressed: () {},
            child: Text('View All',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.accent)),
          ),
        ],
      ),
      const SizedBox(height: 8),
      _LoanHistoryCard(
        amount: 5000,
        status: 'Repaid',
        date: 'May 2026',
        tier: 1,
        isDark: isDark,
      ),
      const SizedBox(height: 12),
      _LoanHistoryCard(
        amount: 10000,
        status: 'Active',
        date: 'Jun 2026',
        tier: 2,
        isDark: isDark,
      ),

      const SizedBox(height: 100),
    ];
  }

  // ── Lender Dashboard ──
  List<Widget> _buildLenderView(bool isDark) {
    return [
      const SizedBox(height: 8),

      // Portfolio Value Card
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF022C22)], // Dark navy to dark green
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? null : AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Value',
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹8,47,500',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E), // explicit dark background chip
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_upward_rounded, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '+12.5% IRR',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'This quarter',
                      style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
                Text(
                  'Total Returns: ₹97,500',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Mini chart
            SizedBox(
              height: 100,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3), FlSpot(1, 3.5), FlSpot(2, 3.2),
                        FlSpot(3, 4.5), FlSpot(4, 4.2), FlSpot(5, 5), FlSpot(6, 5.8),
                      ],
                      isCurved: true,
                      gradient: AppColors.primaryGradient,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.2),
                            AppColors.primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 20),

      // Stats Row
      Row(
        children: [
          Expanded(child: _StatCard(label: 'Total Invested', amount: '₹7.5L', icon: Icons.account_balance_wallet_outlined, color: AppColors.primary, isDark: isDark)),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(label: 'Total Returns', amount: '₹97,500', icon: Icons.trending_up_rounded, color: AppColors.accent, isDark: isDark)),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(child: _StatCard(label: 'Active Loans', amount: '12', icon: Icons.receipt_long_outlined, color: AppColors.info, isDark: isDark)),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(label: 'Default Rate', amount: '0.8%', icon: Icons.shield_outlined, color: AppColors.accent, isDark: isDark)),
        ],
      ),

      const SizedBox(height: 100),
    ];
  }
}

// ── Active Loan Card (v2 spec) ──
class _ActiveLoanCard extends StatelessWidget {
  final bool isDark;
  const _ActiveLoanCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Active Loan', style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  )),
                ],
              ),
              const TierBadge(tierLevel: 2, compact: true),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹10,000',
            style: GoogleFonts.poppins(
              fontSize: 28, fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('Outstanding: ', style: GoogleFonts.inter(
                fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              )),
              Text('₹10,750', style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              )),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Text('Due in: 12 days (15 Jan 2025)', style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.warning,
              )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Pay Now'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('View Details'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Action Widget ──
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isDark ? null : AppColors.cardShadow,
            border: isDark ? Border.all(color: AppColors.darkBorder) : null,
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w500,
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
}

// ── Loan History Card ──
class _LoanHistoryCard extends StatelessWidget {
  final double amount;
  final String status;
  final String date;
  final int tier;
  final bool isDark;

  const _LoanHistoryCard({
    required this.amount,
    required this.status,
    required this.date,
    required this.tier,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isRepaid = status == 'Repaid';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark ? null : AppColors.cardShadow,
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isRepaid ? AppColors.accentSurface : AppColors.infoSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isRepaid ? Icons.check_circle_outline : Icons.access_time,
              color: isRepaid ? AppColors.accent : AppColors.info,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${CurrencyFormatter.formatCompact(amount)}',
                  style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(date, style: GoogleFonts.inter(
                  fontSize: 12, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isRepaid ? AppColors.accentSurface : AppColors.infoSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status, style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: isRepaid ? AppColors.accent : AppColors.info,
                )),
              ),
              const SizedBox(height: 4),
              TierBadge(tierLevel: tier, compact: true),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stat Card Widget ──
class _StatCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final valueColor = label == 'Default Rate'
        ? AppColors.success
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(14),
          bottomRight: Radius.circular(14),
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: isDark ? null : AppColors.cardShadow,
        border: Border(
          left: BorderSide(color: color, width: 3),
          top: isDark ? const BorderSide(color: AppColors.darkBorder) : BorderSide.none,
          right: isDark ? const BorderSide(color: AppColors.darkBorder) : BorderSide.none,
          bottom: isDark ? const BorderSide(color: AppColors.darkBorder) : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
