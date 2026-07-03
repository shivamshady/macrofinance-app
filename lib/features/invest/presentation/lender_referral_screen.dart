import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../domain/providers/lender_profile_provider.dart';

class LenderReferralScreen extends ConsumerWidget {
  const LenderReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(lenderProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (profileState.isLoading || profileState.profile == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final profile = profileState.profile!;
    final refCode = 'LND-${profile.id.toUpperCase().substring(0, min(5, profile.id.length))}';

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
          'Refer & Earn',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Promo card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.card_giftcard_rounded, size: 44, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      'Earn 0.5% Cash Bonus',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'On your referred friend\'s first investment amount',
                      style: AppTextStyles.caption.copyWith(color: Colors.white70, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Referral Code Display
              Text('Your Referral Code', style: AppTextStyles.labelMedium),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      refCode,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: AppColors.accent),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: refCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Referral code copied to clipboard.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // How it works
              Text('How It Works', style: AppTextStyles.titleMedium),
              const SizedBox(height: 14),
              _buildStepItem('1', 'Share your referral code', 'Send the referral code or link to your friends.'),
              const SizedBox(height: 12),
              _buildStepItem('2', 'Friend completes onboarding', 'Your friend registers as a lender and signs the disclosure.'),
              const SizedBox(height: 12),
              _buildStepItem('3', 'Receive payout instantly', 'Once your friend deploys capital in any plan, you earn a 0.5% one-time bonus credited directly to your wallet.'),
              const SizedBox(height: 28),

              // Stats Row
              Text('Referral Dashboard', style: AppTextStyles.titleMedium),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildStatItem('Total Referred', '4', isDark),
                  const SizedBox(width: 10),
                  _buildStatItem('Active Lenders', '2', isDark),
                  const SizedBox(width: 10),
                  _buildStatItem('Bonus Earned', '₹500', isDark, isAccent: true),
                ],
              ),
              const SizedBox(height: 28),

              // Referee list masked
              Text('Referred Friends', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              _buildFriendItem('Suresh K.', 'Joined · First investment made', '₹250 bonus paid', isPaid: true, isDark: isDark),
              _buildFriendItem('Ramesh L.', 'Joined · First investment made', '₹250 bonus paid', isPaid: true, isDark: isDark),
              _buildFriendItem('Meena S.', 'Joined · Pending investment', 'Pending', isPaid: false, isDark: isDark),
              _buildFriendItem('Vikram A.', 'Registered', 'Pending', isPaid: false, isDark: isDark),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(String number, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.accentSurface,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleSmall),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark, {bool isAccent = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        ),
        child: Column(
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isAccent ? AppColors.accent : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendItem(
    String name,
    String state,
    String status, {
    required bool isPaid,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(10),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.titleSmall),
              const SizedBox(height: 2),
              Text(state, style: AppTextStyles.caption),
            ],
          ),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isPaid ? AppColors.accent : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
