import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/providers/admin_provider.dart';
import '../../domain/providers/platform_health_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(platformHealthProvider);
    final adminState = ref.watch(adminProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          onPressed: () => context.go('/profile'),
        ),
        title: Text(
          'Admin Portal',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Text('Welcome back, Admin', style: AppTextStyles.titleMedium),
              const SizedBox(height: 4),
              Text('Manage investor plans, withdrawals, and system status.', style: AppTextStyles.caption),
              const SizedBox(height: 24),

              // Summary Stats Cards Row
              healthState.when(
                data: (metrics) => Column(
                  children: [
                    Row(
                      children: [
                        _buildSummaryCard(
                          context,
                          'Total Funds Deployed',
                          '₹${CurrencyFormatter.formatCompact(metrics.totalFundsDeployed)}',
                          Icons.account_balance_wallet_outlined,
                        ),
                        const SizedBox(width: 12),
                        _buildSummaryCard(
                          context,
                          'Active Lenders',
                          '${metrics.totalLendersActive}',
                          Icons.people_outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSummaryCard(
                          context,
                          'Pending Payouts',
                          '${adminState.pendingWithdrawals.length} requests',
                          Icons.pending_actions_rounded,
                          isWarning: adminState.pendingWithdrawals.isNotEmpty,
                        ),
                        const SizedBox(width: 12),
                        _buildSummaryCard(
                          context,
                          'Platform NPA',
                          '${metrics.npaPercentage}%',
                          Icons.warning_amber_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading summary stats: $e')),
              ),
              const SizedBox(height: 28),

              Text('Management Sections', style: AppTextStyles.titleMedium),
              const SizedBox(height: 14),

              // Navigation Options List
              _buildAdminOptionTile(
                context,
                title: 'Withdrawal Approvals',
                desc: 'Review and approve pending lender fund withdrawals.',
                icon: Icons.account_balance_rounded,
                badgeCount: adminState.pendingWithdrawals.length,
                onTap: () => context.go('/admin/withdrawals'),
              ),
              const SizedBox(height: 12),
              _buildAdminOptionTile(
                context,
                title: 'Manage Investment Plans',
                desc: 'Edit Starter, Growth, and Premium rates, tenures and locks.',
                icon: Icons.edit_calendar_rounded,
                onTap: () => context.go('/admin/plans'),
              ),
              const SizedBox(height: 12),
              _buildAdminOptionTile(
                context,
                title: 'Configure Health Telemetry',
                desc: 'Tweak default metrics (NPAs, credit scores) in real time.',
                icon: Icons.analytics_outlined,
                onTap: () => context.go('/admin/health'),
              ),

              const SizedBox(height: 48),

              // Return options
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/home/lender'),
                  icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
                  label: const Text('Return to Lender Portal', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isWarning = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isWarning
                ? AppColors.error.withOpacity(0.5)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isWarning ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 18, color: isWarning ? AppColors.error : AppColors.primary),
              ],
            ),
            const SizedBox(height: 12),
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isWarning ? AppColors.error : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOptionTile(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 2),
                  Text(desc, style: AppTextStyles.caption.copyWith(fontSize: 11)),
                ],
              ),
            ),
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.lightTextTertiary),
          ],
        ),
      ),
    );
  }
}
