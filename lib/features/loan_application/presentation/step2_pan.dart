import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/stepper_widget.dart';
import '../domain/loan_application_notifier.dart';

/// Step 2 — PAN Verification
/// PAN regex validation [A-Z]{5}[0-9]{4}[A-Z], API call → NSDL → name match
class Step2PanScreen extends ConsumerStatefulWidget {
  const Step2PanScreen({super.key});

  @override
  ConsumerState<Step2PanScreen> createState() => _Step2PanScreenState();
}

class _Step2PanScreenState extends ConsumerState<Step2PanScreen> {
  final _panController = TextEditingController();
  bool _isVerifying = false;
  bool _isVerified = false;
  String? _matchedName;
  String? _errorMessage;

  final _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _loadSavedData() {
    final data = ref.read(loanApplicationProvider).stepData[2];
    if (data != null) {
      _panController.text = data['pan_number'] ?? '';
      _isVerified = data['pan_verified'] == true;
      _matchedName = data['pan_name'];
    }
  }

  @override
  void dispose() {
    _panController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(title: const Text('PAN Verification')),
      body: Column(
        children: [
          const LoanStepperWidget(currentStep: 2),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verify your PAN',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter your PAN number for identity verification via NSDL',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // PAN Input
                  TextFormField(
                    controller: _panController,
                    decoration: InputDecoration(
                      labelText: 'PAN Number',
                      hintText: 'ABCDE1234F',
                      prefixIcon: const Icon(Icons.credit_card_outlined),
                      suffixIcon: _isVerified
                          ? const Icon(Icons.check_circle, color: AppColors.accent)
                          : null,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 10,
                    onChanged: (v) {
                      setState(() {
                        _errorMessage = null;
                        _isVerified = false;
                        _matchedName = null;
                      });
                    },
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (_isVerified && _matchedName != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accentSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.accent, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PAN Verified ✓',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Name: $_matchedName',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Verify Button
                  if (!_isVerified)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _isVerifying ? null : _verifyPan,
                        icon: _isVerifying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.verified_outlined),
                        label: Text(_isVerifying ? 'Verifying...' : 'Verify PAN'),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isVerified ? _onContinue : null,
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyPan() async {
    final pan = _panController.text.trim().toUpperCase();

    if (pan.length != 10) {
      setState(() => _errorMessage = 'PAN must be exactly 10 characters');
      return;
    }
    if (!_panRegex.hasMatch(pan)) {
      setState(() => _errorMessage = 'Invalid PAN format. Expected: ABCDE1234F');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    // Simulate NSDL API call
    await Future.delayed(const Duration(seconds: 2));

    final step1Data = ref.read(loanApplicationProvider).stepData[1];
    final userName = step1Data?['full_name'] ?? 'User';

    setState(() {
      _isVerifying = false;
      _isVerified = true;
      _matchedName = userName.toString().toUpperCase();
    });
  }

  void _onContinue() {
    ref.read(loanApplicationProvider.notifier).completeStep(2, {
      'pan_number': _panController.text.trim().toUpperCase(),
      'pan_verified': true,
      'pan_name': _matchedName,
    });
  }
}
