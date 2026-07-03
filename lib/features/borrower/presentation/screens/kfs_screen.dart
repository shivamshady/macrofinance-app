import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/constants/regulatory_constants.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/consent_checkbox.dart';

/// Key Fact Statement (KFS) screen — RBI mandatory disclosure
/// Must be shown to borrower before loan acceptance
class KfsScreen extends StatefulWidget {
  const KfsScreen({super.key});

  @override
  State<KfsScreen> createState() => _KfsScreenState();
}

class _KfsScreenState extends State<KfsScreen> {
  bool _hasRead = false;
  bool _consentGiven = false;

  // Mock loan data
  final double _principal = 150000;
  final double _apr = 14.5;
  final int _tenure = 12;
  final double _emi = 13568;
  final double _processingFee = 1500;
  final double _totalInterest = 12816;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Key Fact Statement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {},
            tooltip: 'Download KFS',
          ),
        ],
      ),
      body: Column(
        children: [
          // RBI header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppColors.primarySurface,
            child: Row(
              children: [
                const Icon(Icons.verified_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'As per RBI Digital Lending Directions, 2025',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollEndNotification &&
                    scrollNotification.metrics.pixels >=
                        scrollNotification.metrics.maxScrollExtent * 0.9) {
                  if (!_hasRead) setState(() => _hasRead = true);
                }
                return false;
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lender Info
                    _KfsSection(
                      label: RegulatoryConstants.kfsLabelLender,
                      value: RegulatoryConstants.nbfcName,
                      icon: Icons.account_balance_outlined,
                    ),
                    _KfsDivider(),

                    // Loan Details
                    Text('LOAN DETAILS', style: AppTextStyles.overline),
                    const SizedBox(height: 16),

                    _KfsRow(
                      RegulatoryConstants.kfsLabelPrincipal,
                      CurrencyFormatter.format(_principal),
                    ),
                    _KfsRow(
                      RegulatoryConstants.kfsLabelApr,
                      CurrencyFormatter.formatInterestRate(_apr),
                      highlight: true,
                    ),
                    _KfsRow(
                      RegulatoryConstants.kfsLabelTenure,
                      CurrencyFormatter.formatTenure(_tenure),
                    ),
                    _KfsRow(
                      RegulatoryConstants.kfsLabelEmi,
                      CurrencyFormatter.format(_emi),
                      highlight: true,
                    ),
                    _KfsDivider(),

                    // Cost Breakdown
                    Text('COST BREAKDOWN', style: AppTextStyles.overline),
                    const SizedBox(height: 16),

                    _KfsRow(
                      RegulatoryConstants.kfsLabelTotalInterest,
                      CurrencyFormatter.format(_totalInterest),
                    ),
                    _KfsRow(
                      RegulatoryConstants.kfsLabelProcessingFee,
                      CurrencyFormatter.format(_processingFee),
                    ),
                    _KfsRow(
                      RegulatoryConstants.kfsLabelInsurance,
                      'Not applicable',
                    ),
                    _KfsRow(
                      RegulatoryConstants.kfsLabelTotalRepayment,
                      CurrencyFormatter.format(
                          _principal + _totalInterest + _processingFee),
                      highlight: true,
                    ),
                    _KfsDivider(),

                    // Penalties
                    Text('CHARGES & PENALTIES', style: AppTextStyles.overline),
                    const SizedBox(height: 16),

                    _KfsRow(
                      RegulatoryConstants.kfsLabelPenalty,
                      '2% per month on overdue amount',
                    ),
                    _KfsRow(
                      RegulatoryConstants.kfsLabelForeclosure,
                      'Nil after 3 months',
                    ),
                    _KfsRow(
                      RegulatoryConstants.kfsLabelCoolingOff,
                      '3 days from disbursement',
                    ),
                    _KfsDivider(),

                    // Grievance
                    Text('GRIEVANCE REDRESSAL',
                        style: AppTextStyles.overline),
                    const SizedBox(height: 16),

                    _KfsSection(
                      label: RegulatoryConstants.kfsLabelGrievance,
                      value:
                          '${RegulatoryConstants.nodalOfficerName}\n${RegulatoryConstants.nodalOfficerEmail}\n${RegulatoryConstants.nodalOfficerPhone}',
                      icon: Icons.support_agent_outlined,
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.warningSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 16, color: AppColors.warning),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'If your complaint is not resolved within ${RegulatoryConstants.grievanceResolutionDays} days, '
                              'you can escalate to the RBI CMS portal.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.warning,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Cooling off reminder
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
                              RegulatoryConstants.coolingOffPeriod,
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
                  ],
                ),
              ),
            ),
          ),

          // Bottom consent + accept
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.surfaceBorder),
              ),
            ),
            child: Column(
              children: [
                ConsentCheckbox(
                  value: _consentGiven,
                  onChanged: (v) =>
                      setState(() => _consentGiven = v ?? false),
                  text:
                      'I have read and understood the Key Fact Statement and agree to the loan terms.',
                ),
                const SizedBox(height: 16),
                GradientButton(
                  text: 'Accept & Proceed',
                  onPressed:
                      (_hasRead && _consentGiven) ? () {} : null,
                ),
                if (!_hasRead)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Please scroll through the entire document to proceed',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KfsRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _KfsRow(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(label, style: AppTextStyles.bodySmall),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: highlight
                  ? AppTextStyles.titleSmall.copyWith(color: AppColors.primary)
                  : AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _KfsSection extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _KfsSection({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KfsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: AppColors.surfaceBorder),
    );
  }
}
