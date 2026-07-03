import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/stepper_widget.dart';
import '../domain/loan_application_notifier.dart';

/// Step 10 — E-Sign (Aadhaar OTP e-sign via Leegality/Signdesk)
class Step10EsignScreen extends ConsumerStatefulWidget {
  const Step10EsignScreen({super.key});

  @override
  ConsumerState<Step10EsignScreen> createState() => _Step10EsignScreenState();
}

class _Step10EsignScreenState extends ConsumerState<Step10EsignScreen> {
  bool _isLoading = false;
  bool _agreementLoaded = true; // simulated
  bool _isSigning = false;
  bool _isSigned = false;
  bool _consentGiven = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(title: const Text('e-Sign Agreement')),
      body: Column(
        children: [
          const LoanStepperWidget(currentStep: 10),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loan Agreement',
                    style: GoogleFonts.poppins(
                      fontSize: 20, fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Review and sign your loan agreement using Aadhaar e-Sign',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Agreement preview
                  Container(
                    height: 300,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isDark ? null : AppColors.cardShadow,
                      border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                    ),
                    child: _agreementLoaded
                        ? SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LOAN AGREEMENT',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16, fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'MacroFinance Capital Ltd.',
                                  style: GoogleFonts.inter(
                                    fontSize: 13, fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _agreementSection('1. PARTIES', 'This agreement is entered between the Lender (MacroFinance Capital Ltd.) and the Borrower as identified through KYC verification.', isDark),
                                _agreementSection('2. LOAN TERMS', 'The loan amount, tenure, interest rate, and fees are as specified in the Key Fact Statement provided to the Borrower.', isDark),
                                _agreementSection('3. REPAYMENT', 'The Borrower agrees to repay the loan amount along with interest and fees on or before the due date via the registered e-NACH mandate.', isDark),
                                _agreementSection('4. DEFAULT', 'In case of default (non-payment beyond 90 days of due date), the Lender reserves the right to report the default to credit bureaus and initiate recovery proceedings.', isDark),
                                _agreementSection('5. GOVERNING LAW', 'This agreement shall be governed by the laws of India and subject to the jurisdiction of courts in New Delhi.', isDark),
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 12),
                                Text('Loading agreement...', style: GoogleFonts.inter(fontSize: 14)),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Consent
                  CheckboxListTile(
                    value: _consentGiven,
                    onChanged: (v) => setState(() => _consentGiven = v ?? false),
                    title: Text(
                      'I have read and agree to the loan agreement terms. I consent to Aadhaar-based electronic signing.',
                      style: GoogleFonts.inter(fontSize: 13),
                    ),
                    activeColor: AppColors.accent,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),

                  if (_isSigned) ...[
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
                          Expanded(
                            child: Text(
                              'Agreement signed via Aadhaar e-Sign ✓',
                              style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  if (!_isSigned)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: (_consentGiven && !_isSigning) ? _signAgreement : null,
                        icon: _isSigning
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.draw_outlined),
                        label: Text(_isSigning ? 'Signing...' : 'Sign with Aadhaar OTP'),
                      ),
                    ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSigned ? _onContinue : null,
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

  Widget _agreementSection(String title, String body, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          )),
          const SizedBox(height: 4),
          Text(body, style: GoogleFonts.inter(
            fontSize: 12, height: 1.5,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          )),
        ],
      ),
    );
  }

  Future<void> _signAgreement() async {
    setState(() => _isSigning = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isSigning = false;
      _isSigned = true;
    });
  }

  void _onContinue() {
    ref.read(loanApplicationProvider.notifier).completeStep(10, {
      'esign_completed': true,
      'esign_method': 'aadhaar_otp',
    });
  }
}
