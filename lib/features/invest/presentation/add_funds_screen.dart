import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../domain/providers/wallet_provider.dart';

class AddFundsScreen extends ConsumerStatefulWidget {
  const AddFundsScreen({super.key});

  @override
  ConsumerState<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends ConsumerState<AddFundsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isPaying = false;

  void _selectPreset(double val) {
    _amountController.text = val.toInt().toString();
  }

  void _onPay(double amount) async {
    setState(() => _isPaying = true);

    // Simulate Razorpay sheet opening
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Razorpay Checkout', style: AppTextStyles.titleMedium),
                  Text(
                    '₹${CurrencyFormatter.format(amount)}',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const LinearProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Simulating UPI / Netbanking gateway verification...',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context); // Close bottom sheet
    }

    try {
      await ref.read(walletProvider.notifier).addFunds(amount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('₹${CurrencyFormatter.format(amount)} added successfully to wallet.'),
            backgroundColor: AppColors.accent,
          ),
        );
        context.go('/invest/wallet');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'Add Funds',
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
                      Text('Enter Top-up Amount', style: AppTextStyles.titleSmall),
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
                          if (amt < 100) {
                            return 'Minimum top-up is ₹100';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Preset Chips Row
                Text('Quick Amounts', style: AppTextStyles.labelMedium),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildPresetChip(5000),
                    const SizedBox(width: 8),
                    _buildPresetChip(10000),
                    const SizedBox(width: 8),
                    _buildPresetChip(25000),
                    const SizedBox(width: 8),
                    _buildPresetChip(50000),
                  ],
                ),

                const Spacer(),

                // Proceed Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: _isPaying
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final amt = double.parse(_amountController.text.trim());
                              _onPay(amt);
                            }
                          },
                          child: const Text('Proceed to Pay'),
                        ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.lightTextTertiary.withOpacity(0.7)),
                      const SizedBox(width: 6),
                      Text('Secure 256-bit SSL encrypted payments', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(double val) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: ActionChip(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        label: Text(
          '₹${CurrencyFormatter.formatCompact(val)}',
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        onPressed: () => _selectPreset(val),
      ),
    );
  }
}
