import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/constants/regulatory_constants.dart';

/// Loan application screen with amount slider and tenure selector
class LoanApplyScreen extends StatefulWidget {
  const LoanApplyScreen({super.key});

  @override
  State<LoanApplyScreen> createState() => _LoanApplyScreenState();
}

class _LoanApplyScreenState extends State<LoanApplyScreen> {
  double _loanAmount = 100000;
  int _tenureMonths = 12;
  final double _interestRate = 14.5;
  String _purpose = 'Personal';

  final List<String> _purposes = [
    'Personal',
    'Medical Emergency',
    'Education',
    'Home Renovation',
    'Business',
    'Travel',
    'Wedding',
    'Debt Consolidation',
    'Other',
  ];

  double get _emi {
    double r = _interestRate / 12 / 100;
    double n = _tenureMonths.toDouble();
    return _loanAmount * r * pow(1 + r, n) / (pow(1 + r, n) - 1);
  }

  double get _totalPayable => _emi * _tenureMonths;
  double get _totalInterest => _totalPayable - _loanAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('Apply for Loan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Amount Selector
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loan Amount', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 12),
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        CurrencyFormatter.format(_loanAmount),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.surfaceBorder,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.1),
                      trackHeight: 4,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      min: 5000,
                      max: 500000,
                      divisions: 99,
                      value: _loanAmount,
                      onChanged: (v) =>
                          setState(() => _loanAmount = (v / 5000).round() * 5000),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹5,000', style: AppTextStyles.caption),
                      Text('₹5,00,000', style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tenure Selector
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loan Tenure', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [3, 6, 9, 12, 18, 24, 36].map((months) {
                      final isSelected = _tenureMonths == months;
                      return GestureDetector(
                        onTap: () => setState(() => _tenureMonths = months),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primarySurface
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceBorder,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            CurrencyFormatter.formatTenure(months),
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Purpose
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loan Purpose', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _purpose,
                    dropdownColor: AppColors.surfaceLight,
                    items: _purposes
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setState(() => _purpose = v!),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // EMI Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.primary.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Text('Monthly EMI', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: Text(
                      CurrencyFormatter.format(_emi),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.surfaceBorder),
                  const SizedBox(height: 12),
                  _SummaryRow('Interest Rate',
                      CurrencyFormatter.formatInterestRate(_interestRate)),
                  const SizedBox(height: 8),
                  _SummaryRow('Total Interest',
                      CurrencyFormatter.format(_totalInterest)),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    'Total Payable',
                    CurrencyFormatter.format(_totalPayable),
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // NBFC Disclosure
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.info),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Loan will be disbursed by ${RegulatoryConstants.nbfcName} (${RegulatoryConstants.nbfcRegistrationNumber}), '
                      'directly to your verified bank account.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.info,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            GradientButton(
              text: 'Continue to Offers',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {},
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(
          value,
          style: isBold
              ? AppTextStyles.titleSmall
              : AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
        ),
      ],
    );
  }
}
