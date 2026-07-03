import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/secure_text_field.dart';

/// KYC home screen — step-by-step verification flow
class KycHomeScreen extends StatefulWidget {
  const KycHomeScreen({super.key});

  @override
  State<KycHomeScreen> createState() => _KycHomeScreenState();
}

class _KycHomeScreenState extends State<KycHomeScreen> {
  int _currentStep = 0;
  final _panController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _bankNameController = TextEditingController();

  final List<_KycStep> _steps = const [
    _KycStep(
      title: 'PAN Verification',
      subtitle: 'Verify your PAN card',
      icon: Icons.credit_card_outlined,
    ),
    _KycStep(
      title: 'Aadhaar Verification',
      subtitle: 'Verify your identity',
      icon: Icons.fingerprint_rounded,
    ),
    _KycStep(
      title: 'Selfie Verification',
      subtitle: 'Take a live selfie',
      icon: Icons.camera_front_outlined,
    ),
    _KycStep(
      title: 'Bank Account',
      subtitle: 'Link your bank account',
      icon: Icons.account_balance_outlined,
    ),
    _KycStep(
      title: 'Review & Submit',
      subtitle: 'Review your details',
      icon: Icons.fact_check_outlined,
    ),
  ];

  @override
  void dispose() {
    _panController.dispose();
    _aadhaarController.dispose();
    _bankAccountController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: const Text('KYC Verification')),
      body: Column(
        children: [
          // Step indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: List.generate(_steps.length, (index) {
                final isCompleted = index < _currentStep;
                final isCurrent = index == _currentStep;

                return Expanded(
                  child: Row(
                    children: [
                      // Step circle
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.primary
                              : isCurrent
                                  ? AppColors.primarySurface
                                  : AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted || isCurrent
                                ? AppColors.primary
                                : AppColors.surfaceBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check_rounded,
                                  size: 16, color: AppColors.textOnPrimary)
                              : Text(
                                  '${index + 1}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isCurrent
                                        ? AppColors.primary
                                        : AppColors.textTertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      // Connector line
                      if (index < _steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            color: isCompleted
                                ? AppColors.primary
                                : AppColors.surfaceBorder,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Step title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _steps[_currentStep].icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _steps[_currentStep].title,
                      style: AppTextStyles.titleMedium,
                    ),
                    Text(
                      _steps[_currentStep].subtitle,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Step content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStepContent(),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.surfaceBorder),
              ),
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    text: _currentStep == _steps.length - 1
                        ? 'Submit KYC'
                        : 'Continue',
                    onPressed: () {
                      if (_currentStep < _steps.length - 1) {
                        setState(() => _currentStep++);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPanStep();
      case 1:
        return _buildAadhaarStep();
      case 2:
        return _buildSelfieStep();
      case 3:
        return _buildBankStep();
      case 4:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPanStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SecureTextField(
          controller: _panController,
          labelText: 'PAN Number',
          hintText: 'ABCDE1234F',
          prefixIcon: Icons.credit_card_outlined,
          validator: Validators.pan,
          maxLength: 10,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          ],
        ),
        const SizedBox(height: 16),
        _InfoBox(
          text:
              'Your PAN details will be verified with the Income Tax database. '
              'Ensure the name matches your PAN card exactly.',
        ),
      ],
    );
  }

  Widget _buildAadhaarStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SecureTextField(
          controller: _aadhaarController,
          labelText: 'Aadhaar Number',
          hintText: 'XXXX XXXX XXXX',
          prefixIcon: Icons.fingerprint_rounded,
          validator: Validators.aadhaar,
          maxLength: 12,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warningSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined,
                  size: 16, color: AppColors.warning),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'As per RBI guidelines, your Aadhaar number will be masked '
                  '(only last 4 digits stored). An OTP will be sent to your '
                  'Aadhaar-linked mobile for verification.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelfieStep() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text('Take a Selfie', style: AppTextStyles.titleMedium),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Please ensure good lighting and look directly at the camera',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _InfoBox(
          text: 'A liveness check will verify that you are a real person. '
              'Camera access is required only for this step and will not access '
              'your photo gallery.',
        ),
      ],
    );
  }

  Widget _buildBankStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SecureTextField(
          controller: _bankAccountController,
          labelText: 'Bank Account Number',
          hintText: 'Enter account number',
          prefixIcon: Icons.account_balance_outlined,
          validator: Validators.bankAccount,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        SecureTextField(
          controller: _ifscController,
          labelText: 'IFSC Code',
          hintText: 'SBIN0001234',
          prefixIcon: Icons.pin_outlined,
          validator: Validators.ifsc,
          maxLength: 11,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),
        SecureTextField(
          controller: _bankNameController,
          labelText: 'Bank Name',
          hintText: 'Auto-detected from IFSC',
          prefixIcon: Icons.business_outlined,
          enabled: false,
        ),
        const SizedBox(height: 16),
        _InfoBox(
          text:
              'A penny-drop verification (₹1) will be made to confirm your account. '
              'All loan disbursements will be credited directly to this account as per RBI guidelines.',
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      children: [
        _ReviewItem(
          icon: Icons.credit_card_outlined,
          label: 'PAN',
          value: _panController.text.isNotEmpty
              ? Validators.maskPan(_panController.text)
              : 'ABCDE1234F',
          verified: true,
        ),
        const SizedBox(height: 12),
        _ReviewItem(
          icon: Icons.fingerprint_rounded,
          label: 'Aadhaar',
          value: _aadhaarController.text.isNotEmpty
              ? Validators.maskAadhaar(_aadhaarController.text)
              : 'XXXX XXXX 3456',
          verified: true,
        ),
        const SizedBox(height: 12),
        _ReviewItem(
          icon: Icons.camera_front_outlined,
          label: 'Selfie',
          value: 'Liveness verified',
          verified: true,
        ),
        const SizedBox(height: 12),
        _ReviewItem(
          icon: Icons.account_balance_outlined,
          label: 'Bank Account',
          value: _bankAccountController.text.isNotEmpty
              ? '****${_bankAccountController.text.substring(_bankAccountController.text.length > 4 ? _bankAccountController.text.length - 4 : 0)}'
              : '****5678',
          verified: true,
        ),
        const SizedBox(height: 20),
        _InfoBox(
          text: 'Your KYC documents will be securely submitted for verification. '
              'This usually takes 2-4 hours. You will be notified once verified.',
        ),
      ],
    );
  }
}

class _KycStep {
  final String title;
  final String subtitle;
  final IconData icon;

  const _KycStep({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _ReviewItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool verified;

  const _ReviewItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                )),
              ],
            ),
          ),
          if (verified)
            const Icon(Icons.check_circle_rounded,
                size: 20, color: AppColors.success),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;

  const _InfoBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 16, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.info,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
