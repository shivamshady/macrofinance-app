import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/stepper_widget.dart';
import '../domain/loan_application_notifier.dart';

/// Step 9 — e-NACH / Auto-Debit Setup (Razorpay NACH)
class Step9NachScreen extends ConsumerStatefulWidget {
  const Step9NachScreen({super.key});

  @override
  ConsumerState<Step9NachScreen> createState() => _Step9NachScreenState();
}

class _Step9NachScreenState extends ConsumerState<Step9NachScreen> {
  bool _isProcessing = false;
  bool _nachRegistered = false;
  bool _consentGiven = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loanState = ref.watch(loanApplicationProvider);
    final step7 = loanState.stepData[7];
    final amount = step7?['total_repayable']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(title: const Text('e-NACH Setup')),
      body: Column(
        children: [
          const LoanStepperWidget(currentStep: 9),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto-Debit Authorization',
                    style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Set up e-NACH mandate for automatic repayment',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isDark ? null : AppColors.cardShadow,
                      border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                    ),
                    child: Column(
                      children: [
                        _infoRow(Icons.account_balance_outlined, 'Bank',
                            loanState.stepData[8]?['bank_name'] ?? 'N/A', isDark),
                        const SizedBox(height: 12),
                        _infoRow(Icons.currency_rupee, 'Max Debit Amount',
                            '₹$amount', isDark),
                        const SizedBox(height: 12),
                        _infoRow(Icons.repeat, 'Frequency', 'One-time', isDark),
                        const SizedBox(height: 12),
                        _infoRow(Icons.calendar_today_outlined, 'Valid Until',
                            'Loan due date', isDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // What is e-NACH
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.infoSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppColors.info),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'e-NACH (National Automated Clearing House) allows automatic debit from your bank account on the due date. This is processed securely via Razorpay.',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.info, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Consent
                  CheckboxListTile(
                    value: _consentGiven,
                    onChanged: (v) => setState(() => _consentGiven = v ?? false),
                    title: Text(
                      'I authorize MacroFinance to set up an e-NACH mandate on my bank account for loan repayment',
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                    activeColor: AppColors.accent,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),

                  if (_nachRegistered) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.accentSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.accent),
                          const SizedBox(width: 10),
                          Text(
                            'e-NACH mandate registered successfully ✓',
                            style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  if (!_nachRegistered)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: (_consentGiven && !_isProcessing) ? _registerNach : null,
                        icon: _isProcessing
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.account_balance_wallet_outlined),
                        label: Text(_isProcessing ? 'Processing...' : 'Register e-NACH'),
                      ),
                    ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _nachRegistered ? _onContinue : null,
                      child: const Text('Continue'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.inter(
          fontSize: 13, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        )),
        const Spacer(),
        Text(value, style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        )),
      ],
    );
  }

  Future<void> _registerNach() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isProcessing = false;
      _nachRegistered = true;
    });
  }

  void _onContinue() {
    ref.read(loanApplicationProvider.notifier).completeStep(9, {
      'nach_registered': true,
      'nach_status': 'registered',
    });
  }
}
