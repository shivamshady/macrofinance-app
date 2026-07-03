import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/tier_constants.dart';
import '../../../shared/widgets/stepper_widget.dart';
import '../domain/loan_application_notifier.dart';

/// Step 5 — Credit Bureau Check
/// Animated score display, tier eligibility preview
class Step5CreditCheckScreen extends ConsumerStatefulWidget {
  const Step5CreditCheckScreen({super.key});

  @override
  ConsumerState<Step5CreditCheckScreen> createState() => _Step5CreditCheckScreenState();
}

class _Step5CreditCheckScreenState extends ConsumerState<Step5CreditCheckScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  int? _creditScore;
  String? _scoreBand;
  LoanTierConfig? _eligibleTier;
  bool _isRejected = false;
  late AnimationController _animController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fetchCreditScore();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchCreditScore() async {
    // Simulate bureau API call
    await Future.delayed(const Duration(seconds: 3));

    // Simulated score (in production: CRIF/Experian REST API)
    const simulatedScore = 680;
    final band = _getScoreBand(simulatedScore);

    if (simulatedScore < 500) {
      setState(() {
        _isLoading = false;
        _isRejected = true;
        _creditScore = simulatedScore;
        _scoreBand = band;
      });
      return;
    }

    final loanState = ref.read(loanApplicationProvider);
    final eligible = TierConstants.getEligibleTier(
      loansRepaidOnTime: loanState.stepData[1] != null ? 0 : 0, // first-time borrower
      creditScore: simulatedScore,
    );

    setState(() {
      _isLoading = false;
      _creditScore = simulatedScore;
      _scoreBand = band;
      _eligibleTier = eligible;
    });

    _animController.forward();
  }

  String _getScoreBand(int score) {
    if (score >= 750) return 'Excellent';
    if (score >= 700) return 'Good';
    if (score >= 650) return 'Fair';
    if (score >= 500) return 'Poor';
    return 'Very Poor';
  }

  Color _getScoreColor(String band) {
    switch (band) {
      case 'Excellent': return AppColors.accent;
      case 'Good': return AppColors.accent;
      case 'Fair': return AppColors.warning;
      case 'Poor': return AppColors.error;
      default: return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(title: const Text('Credit Check')),
      body: Column(
        children: [
          const LoanStepperWidget(currentStep: 5),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? _buildLoadingView(isDark)
                : _isRejected
                    ? _buildRejectionView(isDark)
                    : _buildResultView(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Checking your credit score...',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This usually takes a few seconds',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionView(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cancel_outlined, size: 72, color: AppColors.error),
          const SizedBox(height: 20),
          Text(
            'Application Not Eligible',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your credit score of $_creditScore is below the minimum requirement. Please try again after improving your credit history.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'You can re-apply after 90 days',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(bool isDark) {
    final scoreColor = _getScoreColor(_scoreBand!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Score display
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark ? null : AppColors.cardShadow,
              border: isDark ? Border.all(color: AppColors.darkBorder) : null,
            ),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    return Column(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(
                                  value: (_creditScore! / 900) * _scoreAnimation.value,
                                  strokeWidth: 8,
                                  backgroundColor: isDark
                                      ? AppColors.darkSurfaceVariant
                                      : AppColors.lightSurfaceVariant,
                                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Text(
                                '${(_creditScore! * _scoreAnimation.value).toInt()}',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: scoreColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: scoreColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _scoreBand!,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: scoreColor,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Score bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _creditScore! / 900,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('300', style: GoogleFonts.inter(fontSize: 10, color: AppColors.lightTextTertiary)),
                    Text('900', style: GoogleFonts.inter(fontSize: 10, color: AppColors.lightTextTertiary)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tier eligibility
          if (_eligibleTier != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(_eligibleTier!.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    'Based on your score, you qualify for:',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Up to ₹${_eligibleTier!.maxAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} (${_eligibleTier!.name} Tier)',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),

          // No credit history message
          if (_creditScore != null && _creditScore! == 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'No credit history found',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No worries! As a first-time borrower, you qualify for Tier 1 (Starter) — up to ₹5,000',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.info),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _onContinue,
              child: const Text('Continue'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _onContinue() {
    if (_eligibleTier != null) {
      ref.read(loanApplicationProvider.notifier).updateTier(_eligibleTier!.level);
    }
    ref.read(loanApplicationProvider.notifier).completeStep(5, {
      'credit_score': _creditScore,
      'score_band': _scoreBand,
      'eligible_tier': _eligibleTier?.level ?? 1,
    });
  }
}
