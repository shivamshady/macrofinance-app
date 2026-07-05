import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/network/mock_auth_service.dart';
import '../../../../core/storage/mock_data_store.dart';

/// OTP verification screen — v2, no BLoC dependency
class OtpScreen extends StatefulWidget {
  final String phone;
  final String sessionId;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.sessionId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final _otpController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  Timer? _resendTimer;
  int _resendSeconds = AppConstants.otpExpirySeconds;
  bool _canResend = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendSeconds = AppConstants.otpExpirySeconds;
    _canResend = false;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendSeconds > 0) {
            _resendSeconds--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _animController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyOtp(String otp) async {
    setState(() => _isLoading = true);
    
    final response = await MockAuthService.verifyOtp(widget.phone, otp);
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.success) {
      if (widget.phone == '6200854150' || response.role == 'admin') {
        context.go('/admin/dashboard');
        return;
      }
      
      if (response.isNewUser == true) {
        context.go('/register/details', extra: widget.phone);
      } else {
        final storage = const FlutterSecureStorage();
        final savedRole = await storage.read(key: 'user_role');
        final role = savedRole ?? 'borrower';
        
        if (role == 'lender') {
          context.go('/home/lender');
        } else {
          context.go('/home');
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.error ?? 'Invalid OTP code'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String get _formattedTimer {
    final minutes = _resendSeconds ~/ 60;
    final seconds = _resendSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Title
                Text('Verify OTP', style: AppTextStyles.displaySmall.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                )),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'Enter the 6-digit code sent to '),
                      TextSpan(
                        text: '+91 ${widget.phone}',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // OTP Input
                PinCodeTextField(
                  appContext: context,
                  controller: _otpController,
                  length: AppConstants.otpLength,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  animationDuration: const Duration(milliseconds: 200),
                  cursorColor: AppColors.primary,
                  textStyle: AppTextStyles.headlineLarge.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(14),
                    fieldHeight: 60,
                    fieldWidth: 48,
                    activeFillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    inactiveFillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    selectedFillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    activeColor: AppColors.primary,
                    inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    selectedColor: AppColors.primary,
                    borderWidth: 1.5,
                  ),
                  enableActiveFill: true,
                  onCompleted: _verifyOtp,
                  onChanged: (_) {},
                ),

                const SizedBox(height: 32),

                // Timer + Resend
                Center(
                  child: _canResend
                      ? TextButton(
                          onPressed: () {
                            _startResendTimer();
                          },
                          child: Text(
                            'Resend OTP',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Resend code in ',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formattedTimer,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),

                const Spacer(),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_otpController.text.length == AppConstants.otpLength) {
                              _verifyOtp(_otpController.text);
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Verify & Continue'),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
