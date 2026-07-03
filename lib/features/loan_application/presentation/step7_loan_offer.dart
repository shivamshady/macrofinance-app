import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/tier_constants.dart';
import '../../../shared/widgets/stepper_widget.dart';
import '../../../shared/widgets/tier_badge.dart';
import '../../../shared/widgets/loan_summary_card.dart';
import '../domain/loan_application_notifier.dart';

/// Step 7 — Loan Offer
/// Tier badge, amount slider constrained to tier min–max,
/// tenure selector, real-time fee breakdown, upgrade teaser
class Step7LoanOfferScreen extends ConsumerStatefulWidget {
  const Step7LoanOfferScreen({super.key});

  @override
  ConsumerState<Step7LoanOfferScreen> createState() => _Step7LoanOfferScreenState();
}

class _Step7LoanOfferScreenState extends ConsumerState<Step7LoanOfferScreen> {
  late double _loanAmount;
  late int _tenureDays;
  late LoanTierConfig _tier;

  @override
  void initState() {
    super.initState();
    final state = ref.read(loanApplicationProvider);
    _tier = state.tierConfig;
    _loanAmount = state.selectedAmount ?? _tier.minAmount;
    _tenureDays = state.selectedTenureDays ?? _tier.maxTenureDays;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nextTier = TierConstants.getNextTier(_tier.level);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(title: const Text('Loan Offer')),
      body: Column(
        children: [
          const LoanStepperWidget(currentStep: 7),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tier Badge
                  Center(child: TierBadge(tierLevel: _tier.level)),
                  const SizedBox(height: 24),

                  // Amount selector
                  _buildAmountSection(isDark),
                  const SizedBox(height: 20),

                  // Tenure selector
                  _buildTenureSection(isDark),
                  const SizedBox(height: 24),

                  // Fee breakdown
                  LoanSummaryCard(
                    loanAmount: _loanAmount,
                    tenureDays: _tenureDays,
                    tierLevel: _tier.level,
                    dueDate: DateTime.now().add(Duration(days: _tenureDays)),
                  ),
                  const SizedBox(height: 16),

                  // Tier upgrade teaser
                  if (nextTier != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.accentSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_up_rounded,
                              size: 18, color: AppColors.accent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Repay on time to unlock up to ₹${_formatAmount(nextTier.maxAmount)} (${nextTier.name} tier)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onContinue,
                      child: const Text('Accept Offer & Continue'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(bool isDark) {
    return Container(
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
          Text('Loan Amount', style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          )),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '₹${_formatAmount(_loanAmount)}',
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accent.withValues(alpha: 0.1),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              min: _tier.minAmount,
              max: _tier.maxAmount,
              divisions: ((_tier.maxAmount - _tier.minAmount) / 500).round().clamp(1, 100),
              value: _loanAmount.clamp(_tier.minAmount, _tier.maxAmount),
              onChanged: (v) => setState(() => _loanAmount = (v / 500).round() * 500),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${_formatAmount(_tier.minAmount)}',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.lightTextTertiary)),
              Text('₹${_formatAmount(_tier.maxAmount)}',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.lightTextTertiary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTenureSection(bool isDark) {
    // Generate tenure options based on tier max
    final options = <int>[];
    if (_tier.maxTenureDays >= 7) options.add(7);
    if (_tier.maxTenureDays >= 14) options.add(14);
    if (_tier.maxTenureDays >= 30) options.add(30);
    if (_tier.maxTenureDays >= 45) options.add(45);
    if (_tier.maxTenureDays >= 60) options.add(60);
    if (_tier.maxTenureDays >= 90) options.add(90);

    return Container(
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
          Text('Loan Tenure', style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          )),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((days) {
              final isSelected = _tenureDays == days;
              return GestureDetector(
                onTap: () => setState(() => _tenureDays = days),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primarySurface : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    '$days days',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  void _onContinue() {
    ref.read(loanApplicationProvider.notifier).setLoanAmount(_loanAmount);
    ref.read(loanApplicationProvider.notifier).setTenureDays(_tenureDays);

    final fees = _tier.calculateFees(_loanAmount, _tenureDays);
    ref.read(loanApplicationProvider.notifier).completeStep(7, {
      'loan_amount': _loanAmount,
      'tenure_days': _tenureDays,
      'tier_level': _tier.level,
      'processing_fee': fees.processingFee,
      'gst_amount': fees.gstOnFee,
      'insurance_fee': fees.insuranceFee,
      'net_disbursement': fees.netDisbursement,
      'total_repayable': fees.totalRepayable,
      'daily_interest': fees.dailyInterest,
    });
  }
}
