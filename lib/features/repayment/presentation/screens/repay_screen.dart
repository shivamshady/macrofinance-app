import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Repayment Screen — Pay Now flow with payment method selection
class RepayScreen extends StatelessWidget {
  const RepayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(title: const Text('Repay Loan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Outstanding amount card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('Outstanding Amount', style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.white70,
                  )),
                  const SizedBox(height: 8),
                  Text('₹10,750', style: GoogleFonts.poppins(
                    fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white,
                  )),
                  const SizedBox(height: 4),
                  Text('Due in 12 days', style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white70,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Payment Method', style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            )),
            const SizedBox(height: 14),

            _PaymentOption(icon: Icons.account_balance, label: 'UPI', subtitle: 'Pay via UPI ID or QR', isDark: isDark),
            const SizedBox(height: 10),
            _PaymentOption(icon: Icons.credit_card, label: 'Debit Card', subtitle: 'Visa, Mastercard, RuPay', isDark: isDark),
            const SizedBox(height: 10),
            _PaymentOption(icon: Icons.language, label: 'Net Banking', subtitle: 'All major banks supported', isDark: isDark),
            const SizedBox(height: 10),
            _PaymentOption(icon: Icons.account_balance_wallet, label: 'e-NACH Auto-Debit', subtitle: 'Scheduled for due date', isDark: isDark),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Pay ₹10,750'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isDark;

  const _PaymentOption({required this.icon, required this.label, required this.subtitle, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? null : AppColors.cardShadow,
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
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
                Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextTertiary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.lightTextTertiary),
        ],
      ),
    );
  }
}

/// Payment History Screen
class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(title: const Text('Payment History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isDark ? null : AppColors.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_outline, size: 20, color: AppColors.accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Loan Repayment', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('${15 - index} Jun 2026 • UPI', style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextTertiary)),
                    ],
                  ),
                ),
                Text('₹${(5000 + index * 2000).toString()}', style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.accent,
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
