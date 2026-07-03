import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

/// Referral Screen — Share code, view earnings, leaderboard
class ReferScreen extends StatelessWidget {
  const ReferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(title: const Text('Refer & Earn')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Referral card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.card_giftcard, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  Text('Invite Friends, Earn Rewards!', style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
                  )),
                  const SizedBox(height: 6),
                  Text('Earn 10% of processing fee for every successful referral',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('MACRO2026', style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 2,
                        )),
                        const SizedBox(width: 12),
                        const Icon(Icons.copy, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Share button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share),
                label: const Text('Share Referral Code'),
              ),
            ),
            const SizedBox(height: 24),

            // Earnings summary
            Row(
              children: [
                Expanded(child: _EarningCard(label: 'Total Earned', amount: '₹250', isDark: isDark)),
                const SizedBox(width: 12),
                Expanded(child: _EarningCard(label: 'Referrals', amount: '3', isDark: isDark)),
                const SizedBox(width: 12),
                Expanded(child: _EarningCard(label: 'Pending', amount: '₹50', isDark: isDark)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningCard extends StatelessWidget {
  final String label, amount;
  final bool isDark;
  const _EarningCard({required this.label, required this.amount, required this.isDark});

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
      child: Column(
        children: [
          Text(amount, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.accent)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.lightTextTertiary)),
        ],
      ),
    );
  }
}
