import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../domain/providers/lender_profile_provider.dart';
import '../domain/providers/wallet_provider.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isWithdrawing = false;

  void _onWithdraw(double amount) async {
    setState(() => _isWithdrawing = true);
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      await ref.read(walletProvider.notifier).withdrawFunds(amount, 'bank_mock_1');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Withdrawal request for ₹${CurrencyFormatter.format(amount)} submitted.'),
            backgroundColor: AppColors.accent,
          ),
        );
        context.go('/invest/wallet');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isWithdrawing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Withdrawal failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => context.go('/invest/wallet'),
        ),
        title: Text(
          'Withdraw Funds',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Available Balance label
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

                // Amount Input card
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
                      Text('Enter Withdrawal Amount', style: AppTextStyles.titleSmall),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        decoration: InputDecoration(
                          prefixText: '₹ ',
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                          hintText: '5,000',
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.lightTextTertiary.withOpacity(0.4),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter amount';
                          }
                          final amt = double.tryParse(val);
                          if (amt == null || amt <= 0) {
                            return 'Please enter a valid amount';
                          }
                          if (amt > walletBalance) {
                            return 'Insufficient wallet balance';
                          }
                          if (amt < 500) {
                            return 'Minimum withdrawal amount is ₹500';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Linked bank card
                Text('Withdraw to Bank Account', style: AppTextStyles.labelMedium),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('HDFC Bank Limited', style: AppTextStyles.titleSmall),
                            Text('Account ending in •••• 4892', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      const Icon(Icons.verified_rounded, color: AppColors.accent, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Processing speed notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.lightTextSecondary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Settlements are processed daily. Funds usually credit to your verified bank account in 1–3 business days.',
                          style: AppTextStyles.caption.copyWith(height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Withdraw button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: _isWithdrawing
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final amt = double.parse(_amountController.text.trim());
                              _onWithdraw(amt);
                            }
                          },
                          child: const Text('Withdraw Funds'),
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
