import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gradient_button.dart';

/// Onboarding screen — 3 swipeable pages
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.bolt_rounded,
      iconColor: Color(0xFF00E5A0),
      title: 'Instant Cash Loans',
      subtitle:
          'Get approved in minutes. Loans from ₹5,000 to ₹5,00,000 directly to your bank account.',
      gradient: AppColors.primaryGradient,
    ),
    _OnboardingPage(
      icon: Icons.trending_up_rounded,
      iconColor: Color(0xFFFFD700),
      title: 'Grow Your Wealth',
      subtitle:
          'Earn attractive returns by funding verified borrowers. Track your investments in real-time.',
      gradient: AppColors.goldGradient,
    ),
    _OnboardingPage(
      icon: Icons.verified_user_rounded,
      iconColor: Color(0xFF4DA6FF),
      title: '100% RBI Compliant',
      subtitle:
          'Your data is safe. We follow all RBI Digital Lending guidelines and KYC norms.',
      gradient: LinearGradient(
        colors: [Color(0xFF4DA6FF), Color(0xFF2979FF)],
      ),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: widget.onComplete,
                child: Text(
                  'Skip',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with glow
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: page.gradient,
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: page.iconColor.withValues(alpha: 0.4),
                                blurRadius: 40,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            page.icon,
                            size: 56,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Title
                        Text(
                          page.title,
                          style: AppTextStyles.displaySmall,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          page.subtitle,
                          style: AppTextStyles.bodyMedium.copyWith(
                            height: 1.7,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicator + Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      dotWidth: 8,
                      dotHeight: 8,
                      expansionFactor: 4,
                      spacing: 6,
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.surfaceBorder,
                    ),
                  ),

                  const SizedBox(height: 40),

                  GradientButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    icon: _currentPage == _pages.length - 1
                        ? Icons.rocket_launch_rounded
                        : Icons.arrow_forward_rounded,
                    onPressed: _onNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final LinearGradient gradient;

  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
