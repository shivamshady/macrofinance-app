import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../domain/providers/platform_health_provider.dart';
import '../domain/models/platform_health.dart';

class LoanBookHealthScreen extends ConsumerWidget {
  const LoanBookHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(platformHealthProvider);
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
          'Loan Book Health',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: healthState.when(
          data: (metrics) => _buildBody(context, metrics),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('Error loading health metrics: $e')),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PlatformHealth metrics) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Repayment rate large card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'ON-TIME REPAYMENT RATE',
                  style: AppTextStyles.caption.copyWith(color: Colors.white70, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  '${metrics.onTimeRepaymentRate}%',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Out of ${metrics.totalActiveLoans} active borrower accounts',
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Platform Statistics', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),

          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(context, 'Total Disbursements', '₹${CurrencyFormatter.formatCompact(metrics.totalAmountDisbursed)}'),
              _buildStatCard(
                context,
                'NPA Rate (90+ DPD)',
                '${metrics.npaPercentage}%',
                tooltip: 'Non-Performing Assets: percentage of total loans overdue by more than 90 days.',
              ),
              _buildStatCard(context, 'Avg Borrower Credit', '${metrics.avgBorrowerCreditScore}'),
              _buildStatCard(context, 'Active Investors', '${metrics.totalLendersActive}'),
            ],
          ),
          const SizedBox(height: 28),

          // Protection static cards
          Text('How Your Money is Protected', style: AppTextStyles.titleMedium),
          const SizedBox(height: 14),
          _buildProtectionRow(
            context,
            icon: Icons.gavel_rounded,
            title: 'RBI Regulated Framework',
            desc: 'Lending is routed strictly via RBI-regulated co-lending partner NBFCs, ensuring compliance with Fair Practices codes.',
          ),
          const SizedBox(height: 16),
          _buildProtectionRow(
            context,
            icon: Icons.shield_rounded,
            title: 'Automatic Diversification',
            desc: 'Your funds are never deployed to a single borrower. Auto-allocation scatters capital across a basket of pre-screened borrower categories to spread default risk.',
          ),
          const SizedBox(height: 16),
          _buildProtectionRow(
            context,
            icon: Icons.edit_note_rounded,
            title: 'Legally Bound Mandates',
            desc: 'Borrower bank accounts are bound via e-NACH auto-debit triggers and legally enforceable e-signed loan agreements.',
          ),
          const SizedBox(height: 36),

          // Fair Practice code download link
          Center(
            child: TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading Fair Practices Code PDF...')),
                );
              },
              icon: const Icon(Icons.download_rounded, color: AppColors.primary),
              label: const Text('Download Fair Practices Code (PDF)', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, {String? tooltip}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (tooltip != null)
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        title: Text(label, style: AppTextStyles.titleMedium),
                        content: Text(tooltip, style: AppTextStyles.bodyMedium),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got it'),
                          )
                        ],
                      ),
                    );
                  },
                  child: const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.lightTextTertiary),
                ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtectionRow(BuildContext context, {required IconData icon, required String title, required String desc}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleSmall),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppTextStyles.bodySmall.copyWith(height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
