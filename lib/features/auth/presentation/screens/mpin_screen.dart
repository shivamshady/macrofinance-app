import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// MPIN Setup / Verification Screen
/// 4-digit PIN with session timeout re-auth
class MpinScreen extends StatefulWidget {
  final bool isSetup; // true = first time setup, false = verification

  const MpinScreen({super.key, this.isSetup = false});

  @override
  State<MpinScreen> createState() => _MpinScreenState();
}

class _MpinScreenState extends State<MpinScreen> {
  final _pinController = TextEditingController();
  String _currentPin = '';
  String _confirmPin = '';
  bool _isConfirmStep = false;
  bool _isVerifying = false;
  String? _errorMessage;
  int _attempts = 0;
  static const _maxAttempts = 5;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'M',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                widget.isSetup
                    ? (_isConfirmStep ? 'Confirm your MPIN' : 'Set your MPIN')
                    : 'Enter your MPIN',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isSetup
                    ? 'Create a 4-digit MPIN for quick access'
                    : 'Enter your 4-digit MPIN to continue',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 36),

              // PIN Input
              SizedBox(
                width: 220,
                child: PinCodeTextField(
                  appContext: context,
                  length: AppConstants.mpinLength,
                  controller: _pinController,
                  obscureText: true,
                  animationType: AnimationType.scale,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 52,
                    fieldWidth: 46,
                    activeFillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    inactiveFillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    selectedFillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    activeColor: AppColors.primary,
                    inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    selectedColor: AppColors.accent,
                  ),
                  enableActiveFill: true,
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    setState(() {
                      _errorMessage = null;
                      if (_isConfirmStep) {
                        _confirmPin = v;
                      } else {
                        _currentPin = v;
                      }
                    });
                  },
                  onCompleted: (v) {
                    if (widget.isSetup) {
                      _handleSetup(v);
                    } else {
                      _handleVerification(v);
                    }
                  },
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.errorSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(_errorMessage!, style: GoogleFonts.inter(fontSize: 13, color: AppColors.error)),
                    ],
                  ),
                ),
              ],

              if (!widget.isSetup) ...[
                const SizedBox(height: 20),
                Text(
                  '${_maxAttempts - _attempts} attempts remaining',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _attempts >= 3 ? AppColors.error : AppColors.lightTextTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot MPIN?',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],

              if (widget.isSetup && !_isConfirmStep) ...[
                const SizedBox(height: 16),
                Text(
                  'Choose a PIN that\'s easy to remember but hard to guess',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextTertiary),
                  textAlign: TextAlign.center,
                ),
              ],

              // Biometric option
              if (!widget.isSetup) ...[
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: [
                      Icon(Icons.fingerprint, size: 44, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text('Use Fingerprint', style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primary,
                      )),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleSetup(String pin) async {
    if (!_isConfirmStep) {
      setState(() {
        _currentPin = pin;
        _isConfirmStep = true;
      });
      Future.microtask(() => _pinController.clear());
    } else {
      if (pin == _currentPin) {
        setState(() => _errorMessage = null);
        try {
          const storage = FlutterSecureStorage();
          final userId = await storage.read(key: AppConstants.keyUserId);
          if (userId != null) {
            await ApiService.setMpin(userId, pin);
          }
          if (mounted) Navigator.of(context).pop(true);
        } catch (e) {
          setState(() {
            _errorMessage = 'Failed to save MPIN. Try again.';
            _isConfirmStep = false;
            _currentPin = '';
          });
          Future.microtask(() => _pinController.clear());
        }
      } else {
        setState(() {
          _errorMessage = 'PINs don\'t match. Try again.';
          _isConfirmStep = false;
          _currentPin = '';
        });
        Future.microtask(() => _pinController.clear());
      }
    }
  }

  Future<void> _handleVerification(String pin) async {
    setState(() => _isVerifying = true);
    
    try {
      const storage = FlutterSecureStorage();
      final phone = await storage.read(key: AppConstants.keyUserPhone);
      
      if (phone != null) {
        final response = await ApiService.loginMpin(phone, pin);
        
        if (response['success'] == true) {
          await storage.write(key: AppConstants.keyAuthToken, value: response['accessToken']);
          await storage.write(key: AppConstants.keyRefreshToken, value: response['refreshToken']);
          if (mounted) Navigator.of(context).pop(true);
          return;
        }
      }
      
      if (!mounted) return;
      setState(() {
        _attempts++;
        _isVerifying = false;
        _pinController.clear();
        if (_attempts >= _maxAttempts) {
          _errorMessage = 'Too many attempts. Please try again later.';
        } else {
          _errorMessage = 'Incorrect MPIN';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _pinController.clear();
        _errorMessage = 'Incorrect MPIN or server error';
      });
    }
  }
}
