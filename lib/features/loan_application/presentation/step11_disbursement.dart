import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/tier_constants.dart';
import '../../../shared/widgets/stepper_widget.dart';
import '../domain/loan_application_notifier.dart';

/// Step 11 — Disbursement Confirmation
class Step11DisbursementScreen extends ConsumerStatefulWidget {
  const Step11DisbursementScreen({super.key});

  @override
  ConsumerState<Step11DisbursementScreen> createState() => _Step11DisbursementScreenState();
}

class _Step11DisbursementScreenState extends ConsumerState<Step11DisbursementScreen>
    with SingleTickerProviderStateMixin {
  bool _isDisbursing = true;
  bool _isDisbursed = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _processDisbursement();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _processDisbursement() async {
    await Future.delayed(const Duration(seconds: 4));
    _animController.stop();
    setState(() {
      _isDisbursing = false;
      _isDisbursed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loanState = ref.watch(loanApplicationProvider);
    final step7 = loanState.stepData[7] ?? {};
    final tier = TierConstants.getTier(step7['tier_level'] ?? 1);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Disbursement'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const LoanStepperWidget(currentStep: 11),
          const SizedBox(height: 8),
          Expanded(
            child: _isDisbursing
                ? _buildProcessingView(isDark)
                : _buildSuccessView(isDark, step7, tier),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _animController,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent,
                  width: 3,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: const Icon(Icons.sync, size: 36, color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Processing Disbursement...',
            style: GoogleFonts.poppins(
              fontSize: 20, fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transferring funds to your bank account',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isDark, Map<String, dynamic> step7, LoanTierConfig tier) {
    final netDisbursement = step7['net_disbursement'] ?? 0.0;
    final totalRepayable = step7['total_repayable'] ?? 0.0;
    final tenureDays = step7['tenure_days'] ?? 30;
    final nextTier = TierConstants.getNextTier(tier.level);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Success icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, size: 60, color: AppColors.accent),
          ),
          const SizedBox(height: 24),

          Text(
            'Loan Disbursed! 🎉',
            style: GoogleFonts.poppins(
              fontSize: 26, fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Funds have been transferred to your bank account',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),

          const SizedBox(height: 32),

          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark ? null : AppColors.cardShadow,
              border: isDark ? Border.all(color: AppColors.darkBorder) : null,
            ),
            child: Column(
              children: [
                _summaryRow('Amount Received', '₹${_format(netDisbursement)}', isDark,
                    valueColor: AppColors.accent, isBold: true),
                const Divider(height: 24),
                _summaryRow('Total Repayable', '₹${_format(totalRepayable)}', isDark),
                const SizedBox(height: 8),
                _summaryRow('Tenure', '$tenureDays days', isDark),
                const SizedBox(height: 8),
                _summaryRow('Due Date',
                    _formatDate(DateTime.now().add(Duration(days: tenureDays as int))),
                    isDark, valueColor: AppColors.warning),
                const SizedBox(height: 8),
                _summaryRow('Tier', '${tier.emoji} ${tier.name}', isDark),
              ],
            ),
          ),

          // Upgrade teaser
          if (nextTier != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accentSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, size: 18, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Repay on time to unlock ${nextTier.name} tier (up to ₹${_format(nextTier.maxAmount)})',
                      style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                ref.read(loanApplicationProvider.notifier).resetApplication();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Go to Dashboard'),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Share receipt
              },
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share Receipt'),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isDark,
      {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(
          fontSize: 13,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        )),
        Text(value, style: GoogleFonts.inter(
          fontSize: isBold ? 18 : 13,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          color: valueColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
        )),
      ],
    );
  }

  String _format(dynamic amount) {
    final d = (amount is double) ? amount : double.tryParse(amount.toString()) ?? 0;
    return d.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
