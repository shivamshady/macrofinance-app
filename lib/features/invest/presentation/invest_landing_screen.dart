import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../domain/providers/lender_profile_provider.dart';

class InvestLandingScreen extends ConsumerWidget {
  const InvestLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lenderProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // Gate: Check if user is registered and disclosure signed
    final profile = state.profile;
    if (profile != null) {
      if (profile.riskDisclosureSigned) {
        // Already signed, go to dashboard
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/invest/dashboard');
        });
        return Scaffold(
          backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
          body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      } else {
        // Profile exists but not signed, go to disclosure screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/invest/risk-disclosure');
        });
        return Scaffold(
          backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
          body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      }
    }

    // Default: Show "Become a Lender" intro UI
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Hero Graphic (Piggy Bank / Growth Illustration)
              Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient.withOpacity(0.15),
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      size: 88,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Title
              Text(
                'Put your money to work',
                style: AppTextStyles.displaySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Grow your wealth by providing co-lending capital to pre-verified borrowers. Earn fixed annual returns paid monthly.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 3 Features List
              _buildFeatureRow(
                context,
                icon: Icons.shield_outlined,
                iconColor: AppColors.accent,
                title: 'Secured Co-Lending Model',
                desc: 'Funds are deployed across highly vetted borrower pools matching strict RBI co-lending mandates.',
              ),
              const SizedBox(height: 24),
              _buildFeatureRow(
                context,
                icon: Icons.percent_rounded,
                iconColor: AppColors.warning,
                title: 'Earn up to 15% Annual Returns',
                desc: 'Choose from multiple tenure options starting from 3 months to maximize yield.',
              ),
              const SizedBox(height: 24),
              _buildFeatureRow(
                context,
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.info,
                title: 'Monthly Interest Payouts',
                desc: 'Returns are credited monthly directly to your wallet. Reinvest or withdraw anytime.',
              ),
              const SizedBox(height: 48),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: GradientButton(
                  text: 'Become an Investor',
                  onPressed: () => context.go('/invest/risk-disclosure'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
