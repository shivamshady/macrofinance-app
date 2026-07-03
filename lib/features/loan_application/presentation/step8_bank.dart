import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/stepper_widget.dart';
import '../domain/loan_application_notifier.dart';

/// Step 8 — Bank Verification (penny drop)
class Step8BankScreen extends ConsumerStatefulWidget {
  const Step8BankScreen({super.key});

  @override
  ConsumerState<Step8BankScreen> createState() => _Step8BankScreenState();
}

class _Step8BankScreenState extends ConsumerState<Step8BankScreen> {
  final _formKey = GlobalKey<FormState>();
  final _holderNameController = TextEditingController();
  final _accountController = TextEditingController();
  final _confirmAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();
  String _accountType = 'Savings';
  bool _isVerifying = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _loadSavedData() {
    final data = ref.read(loanApplicationProvider).stepData[8];
    if (data != null) {
      _holderNameController.text = data['account_holder_name'] ?? '';
      _accountController.text = data['account_number'] ?? '';
      _confirmAccountController.text = data['account_number'] ?? '';
      _ifscController.text = data['ifsc_code'] ?? '';
      _bankNameController.text = data['bank_name'] ?? '';
      _accountType = data['account_type'] ?? 'Savings';
      _isVerified = data['penny_drop_verified'] == true;
    }
  }

  @override
  void dispose() {
    _holderNameController.dispose();
    _accountController.dispose();
    _confirmAccountController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(title: const Text('Bank Verification')),
      body: Column(
        children: [
          const LoanStepperWidget(currentStep: 8),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bank Account Details',
                      style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'We\'ll verify your bank account via a ₹1 penny drop',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _holderNameController,
                      decoration: const InputDecoration(
                        labelText: 'Account Holder Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _accountController,
                      decoration: const InputDecoration(
                        labelText: 'Account Number',
                        prefixIcon: Icon(Icons.account_balance_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 9 || v.length > 18) return 'Invalid account number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _confirmAccountController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Account Number',
                        prefixIcon: Icon(Icons.account_balance_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v != _accountController.text) return 'Account numbers don\'t match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _ifscController,
                      decoration: const InputDecoration(
                        labelText: 'IFSC Code',
                        prefixIcon: Icon(Icons.code),
                        hintText: 'e.g. SBIN0001234',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      maxLength: AppConstants.ifscLength,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length != AppConstants.ifscLength) return 'Invalid IFSC';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _bankNameController,
                      decoration: const InputDecoration(
                        labelText: 'Bank Name',
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                    const SizedBox(height: 14),

                    DropdownButtonFormField<String>(
                      value: _accountType,
                      items: ['Savings', 'Current']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _accountType = v!),
                      decoration: const InputDecoration(
                        labelText: 'Account Type',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                    ),

                    if (_isVerified) ...[
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
                              'Bank account verified via penny drop ✓',
                              style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    if (!_isVerified)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _isVerifying ? null : _verifyBank,
                          icon: _isVerifying
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.verified_outlined),
                          label: Text(_isVerifying ? 'Verifying...' : 'Verify Account (Penny Drop)'),
                        ),
                      ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isVerified ? _onContinue : null,
                        child: const Text('Continue'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyBank() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isVerifying = false;
      _isVerified = true;
    });
  }

  void _onContinue() {
    ref.read(loanApplicationProvider.notifier).completeStep(8, {
      'account_holder_name': _holderNameController.text.trim(),
      'account_number': _accountController.text.trim(),
      'ifsc_code': _ifscController.text.trim().toUpperCase(),
      'bank_name': _bankNameController.text.trim(),
      'account_type': _accountType.toLowerCase(),
      'penny_drop_verified': true,
    });
  }
}
