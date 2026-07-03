import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';

class InvestSuccessScreen extends StatelessWidget {
  const InvestSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Pick a mock investment number and dates for success visualization
    final mockInvNumber = 'INV-2026-${1000 + (DateTime.now().millisecond % 9000)}';
    final firstPayoutDate = DateTime.now().add(const Duration(days: 30));
    final firstPayoutStr = '${firstPayoutDate.day} ${_getMonthName(firstPayoutDate.month)} ${firstPayoutDate.year}';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Success Icon Celebration Animation
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.accentSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.accent,
                  size: 72,
                ),
              )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.bounceOut)
                  .then()
                  .shake(duration: 300.ms),

              const SizedBox(height: 28),

              // Title
              Text(
                'Investment Successful!',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 12),
              Text(
                'Your co-lending capital has been deployed. You will start receiving monthly interest returns directly in your wallet.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 40),

              // Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                  boxShadow: isDark ? null : AppColors.cardShadow,
                ),
                child: Column(
                  children: [
                    _buildRow('Investment Reference', mockInvNumber),
                    const Divider(height: 20),
                    _buildRow('First Payout Date', firstPayoutStr),
                    const Divider(height: 20),
                    _buildRow('Interest Credit', 'Direct to Wallet'),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 500.ms)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

              const SizedBox(height: 24),

              // Download certificate button
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading Certificate PDF...')),
                  );
                },
                icon: const Icon(Icons.download_rounded, color: AppColors.primary, size: 18),
                label: const Text('Download Certificate PDF', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              )
                  .animate()
                  .fadeIn(delay: 600.ms),

              const Spacer(),

              // Action Buttons at bottom
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/invest/plans'),
                      child: const Text('Invest More'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      text: 'View Portfolio',
                      onPressed: () => context.go('/invest/portfolio'),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 750.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
