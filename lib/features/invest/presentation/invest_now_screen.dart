import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../domain/providers/investment_plans_provider.dart';
import '../domain/providers/lender_profile_provider.dart';
import '../domain/models/investment_plan.dart';

class InvestNowScreen extends ConsumerStatefulWidget {
  final String planId;
  const InvestNowScreen({super.key, required this.planId});

  @override
  ConsumerState<InvestNowScreen> createState() => _InvestNowScreenState();
}

class _InvestNowScreenState extends ConsumerState<InvestNowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isAutoRenew = false;
  double _enteredAmount = 0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final text = _amountController.text.trim();
    if (text.isEmpty) {
      setState(() => _enteredAmount = 0);
      return;
    }
    final amount = double.tryParse(text);
    if (amount != null) {
      setState(() => _enteredAmount = amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(investmentPlansProvider);
    final profileState = ref.watch(lenderProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (profileState.isLoading || profileState.profile == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final profile = profileState.profile!;
    final walletBalance = profile.walletBalance;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          onPressed: () => context.go('/invest/plan/${widget.planId}'),
        ),
        title: Text(
          'Invest Now',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: plansAsync.when(
        data: (plans) {
          final plan = plans.firstWhere(
            (p) => p.id.toString() == widget.planId,
            orElse: () => plans.first,
          );

          final isWalletInsufficient = _enteredAmount > walletBalance;
          final diffAmount = _enteredAmount - walletBalance;

          // Calculations
          final monthlyReturn = (_enteredAmount * (plan.annualReturnRate / 100)) / 12;
          final totalReturns = monthlyReturn * plan.tenureMonths;
          final maturityAmount = _enteredAmount + totalReturns;

          // TDS threshold (annual interest > 5000)
          final isTdsApplicable = (profile.annualInterestEarned + totalReturns) > 5000.0;
          final tdsDeduction = isTdsApplicable ? (totalReturns * 0.1) : 0.0;
          final netMaturity = maturityAmount - tdsDeduction;

          return SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Insufficient wallet banner
                          if (_enteredAmount > 0 && isWalletInsufficient)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.errorSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.error.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Insufficient wallet balance. You need ₹${CurrencyFormatter.format(diffAmount)} more.',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.go('/invest/wallet/add'),
                                    child: const Text('Add Funds', style: TextStyle(color: AppColors.primary)),
                                  ),
                                ],
                              ),
                            ),

                          // Wallet Balance Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Available Wallet Balance:', style: AppTextStyles.bodyMedium),
                              Text(
                                '₹${CurrencyFormatter.format(walletBalance)}',
                                style: AppTextStyles.titleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Investment Input Card
                          Container(
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
                                Text('Enter Investment Amount', style: AppTextStyles.titleSmall),
                                const SizedBox(height: 4),
                                Text(
                                  'Limits for ${plan.planName}: ₹${CurrencyFormatter.formatCompact(plan.minInvestment)} - ₹${CurrencyFormatter.formatCompact(plan.maxInvestment)}',
                                  style: AppTextStyles.caption,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                  decoration: InputDecoration(
                                    prefixText: '₹ ',
                                    prefixStyle: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                    hintText: '${plan.minInvestment.toInt()}',
                                    hintStyle: GoogleFonts.poppins(
                                      color: AppColors.lightTextTertiary.withOpacity(0.4),
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Please enter amount';
                                    }
                                    final amt = double.tryParse(val);
                                    if (amt == null) {
                                      return 'Please enter a valid number';
                                    }
                                    if (amt < plan.minInvestment) {
                                      return 'Minimum investment is ₹${CurrencyFormatter.format(plan.minInvestment)}';
                                    }
                                    if (amt > plan.maxInvestment) {
                                      return 'Maximum investment is ₹${CurrencyFormatter.format(plan.maxInvestment)}';
                                    }
                                    if (amt > walletBalance) {
                                      return 'Insufficient wallet balance';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Auto-Renew Toggle
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                                    Text('Auto-renew plan', style: AppTextStyles.titleSmall),
                                    const SizedBox(height: 2),
                                    Text('Automatically reinvest principal on maturity', style: AppTextStyles.caption),
                                  ],
                                ),
                                Switch(
                                  value: _isAutoRenew,
                                  onChanged: (v) => setState(() => _isAutoRenew = v),
                                  activeColor: AppColors.accent,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Real-time Calculations Card
                          if (_enteredAmount >= plan.minInvestment && _enteredAmount <= plan.maxInvestment)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                borderRadius: BorderRadius.circular(16),
                                border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Payout Forecast', style: AppTextStyles.titleSmall),
                                  const SizedBox(height: 12),
                                  _buildCalcRow('Plan Tenure', '${plan.tenureMonths} Months'),
                                  const SizedBox(height: 8),
                                  _buildCalcRow('Interest Rate', '${plan.annualReturnRate}% p.a.'),
                                  const SizedBox(height: 8),
                                  _buildCalcRow('Monthly interest payout', '₹${CurrencyFormatter.format(monthlyReturn)}', isAccent: true),
                                  const SizedBox(height: 8),
                                  _buildCalcRow('Total interest returns', '₹${CurrencyFormatter.format(totalReturns)}'),
                                  const SizedBox(height: 8),
                                  _buildCalcRow('TDS (10% on interest)', '₹${CurrencyFormatter.format(tdsDeduction)}', isNegative: tdsDeduction > 0),
                                  const Divider(height: 24),
                                  _buildCalcRow('Net Maturity value', '₹${CurrencyFormatter.format(netMaturity)}', isBold: true),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Continue button sticky at bottom
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      border: isDark ? const Border(top: BorderSide(color: AppColors.darkBorder)) : null,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Navigate to Confirm Screen, pass details
                            context.push('/invest/confirm', extra: {
                              'planId': plan.id,
                              'amount': _enteredAmount,
                              'isAutoRenew': _isAutoRenew,
                            });
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Continue to Review'),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error loading plan: $e')),
      ),
    );
  }

  Widget _buildCalcRow(String label, String value, {bool isAccent = false, bool isBold = false, bool isNegative = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 15 : 13,
            fontWeight: (isBold || isAccent) ? FontWeight.w700 : FontWeight.w500,
            color: isNegative
                ? AppColors.error
                : (isAccent ? AppColors.accent : (isBold ? AppColors.primary : null)),
          ),
        ),
      ],
    );
  }
}
