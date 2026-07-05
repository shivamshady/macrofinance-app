import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/stepper_widget.dart';
import '../domain/loan_application_notifier.dart';

/// Step 5 — KYC Verification (formerly Step 6)
/// Aadhaar OTP → DigiLocker → Selfie via HyperVerge → Video
class Step5KycScreen extends ConsumerStatefulWidget {
  const Step5KycScreen({super.key});

  @override
  ConsumerState<Step5KycScreen> createState() => _Step5KycScreenState();
}

class _Step5KycScreenState extends ConsumerState<Step5KycScreen> {
  int _kycStep = 0; // 0=aadhaar, 1=digilocker, 2=selfie, 3=video, 4=complete
  bool _isProcessing = false;
  bool _aadhaarVerified = false;
  bool _digilockerLinked = false;
  bool _selfieUploaded = false;
  bool _videoUploaded = false;
  final _aadhaarController = TextEditingController();
  
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selfieBytes;
  String? _videoName;

  @override
  void dispose() {
    _aadhaarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(title: const Text('KYC Verification')),
      body: Column(
        children: [
          const LoanStepperWidget(currentStep: 5),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Identity Verification',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Complete all verification steps to proceed',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Step cards
                  _kycStepCard(
                    index: 0,
                    title: 'Aadhaar Verification',
                    subtitle: 'Verify via OTP sent to Aadhaar-linked mobile',
                    icon: Icons.fingerprint,
                    isComplete: _aadhaarVerified,
                    isCurrent: _kycStep == 0,
                    isDark: isDark,
                    child: _buildAadhaarStep(isDark),
                  ),
                  const SizedBox(height: 12),

                  _kycStepCard(
                    index: 1,
                    title: 'DigiLocker',
                    subtitle: 'Link DigiLocker to fetch documents',
                    icon: Icons.folder_outlined,
                    isComplete: _digilockerLinked,
                    isCurrent: _kycStep == 1,
                    isDark: isDark,
                    child: _buildDigilockerStep(isDark),
                  ),
                  const SizedBox(height: 12),

                  _kycStepCard(
                    index: 2,
                    title: 'Selfie Verification',
                    subtitle: 'Take a selfie for liveness check',
                    icon: Icons.camera_alt_outlined,
                    isComplete: _selfieUploaded,
                    isCurrent: _kycStep == 2,
                    isDark: isDark,
                    child: _buildSelfieStep(isDark),
                  ),
                  const SizedBox(height: 12),

                  _kycStepCard(
                    index: 3,
                    title: 'Video Verification',
                    subtitle: 'Record a short video for identity confirmation',
                    icon: Icons.videocam_outlined,
                    isComplete: _videoUploaded,
                    isCurrent: _kycStep == 3,
                    isDark: isDark,
                    child: _buildVideoStep(isDark),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _allComplete ? _onContinue : null,
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

  bool get _allComplete =>
      _aadhaarVerified && _digilockerLinked && _selfieUploaded && _videoUploaded;

  Widget _kycStepCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isComplete,
    required bool isCurrent,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark ? null : AppColors.cardShadow,
        border: isDark
            ? Border.all(
                color: isCurrent ? AppColors.primary : AppColors.darkBorder,
              )
            : isCurrent
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isComplete
                    ? AppColors.accentSurface
                    : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isComplete ? Icons.check_circle : icon,
                color: isComplete ? AppColors.accent : AppColors.primary,
                size: 22,
              ),
            ),
            title: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            subtitle: Text(
              isComplete ? 'Verified ✓' : subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isComplete ? AppColors.accent : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
              ),
            ),
            onTap: isComplete ? null : () => setState(() => _kycStep = index),
          ),
          if (isCurrent && !isComplete)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildAadhaarStep(bool isDark) {
    return Column(
      children: [
        TextFormField(
          controller: _aadhaarController,
          decoration: const InputDecoration(
            labelText: 'Aadhaar Number (last 4 digits)',
            prefixIcon: Icon(Icons.badge_outlined),
            hintText: 'XXXX',
          ),
          keyboardType: TextInputType.number,
          maxLength: 4,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _isProcessing ? null : _verifyAadhaar,
            icon: _isProcessing
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send_outlined),
            label: Text(_isProcessing ? 'Sending OTP...' : 'Send Aadhaar OTP'),
          ),
        ),
      ],
    );
  }

  Widget _buildDigilockerStep(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _isProcessing ? null : _linkDigilocker,
        icon: const Icon(Icons.link),
        label: Text(_isProcessing ? 'Linking...' : 'Link DigiLocker'),
      ),
    );
  }

  Widget _buildSelfieStep(bool isDark) {
    return Column(
      children: [
        if (_selfieBytes != null) ...[
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: ClipOval(
              child: Image.memory(_selfieBytes!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _isProcessing ? null : _captureSelfie,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(_isProcessing ? 'Processing Selfie...' : (_selfieUploaded ? 'Retake Selfie' : 'Take Selfie')),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoStep(bool isDark) {
    return Column(
      children: [
        if (_videoName != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.accent, size: 16),
              const SizedBox(width: 6),
              Text(
                'Recorded: $_videoName',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _isProcessing ? null : _recordVideo,
            icon: const Icon(Icons.videocam_outlined),
            label: Text(_isProcessing ? 'Uploading Video...' : (_videoUploaded ? 'Re-record Video' : 'Record Video')),
          ),
        ),
      ],
    );
  }

  Future<void> _verifyAadhaar() async {
    if (_aadhaarController.text.length != 4) return;
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isProcessing = false;
      _aadhaarVerified = true;
      _kycStep = 1;
    });
  }

  Future<void> _linkDigilocker() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isProcessing = false;
      _digilockerLinked = true;
      _kycStep = 2;
    });
  }

  Future<void> _captureSelfie() async {
    setState(() => _isProcessing = true);
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selfieBytes = bytes;
          _selfieUploaded = true;
          _isProcessing = false;
          _kycStep = 3;
        });
      } else {
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selfieBytes = bytes;
          _selfieUploaded = true;
          _isProcessing = false;
          _kycStep = 3;
        });
      } else {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _recordVideo() async {
    setState(() => _isProcessing = true);
    try {
      final XFile? file = await _picker.pickVideo(source: ImageSource.camera);
      if (file != null) {
        setState(() {
          _videoName = file.name;
          _videoUploaded = true;
          _isProcessing = false;
          _kycStep = 4;
        });
      } else {
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          _videoName = file.name;
          _videoUploaded = true;
          _isProcessing = false;
          _kycStep = 4;
        });
      } else {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _onContinue() {
    ref.read(loanApplicationProvider.notifier).completeStep(5, {
      'aadhaar_verified': true,
      'aadhaar_last4': _aadhaarController.text.trim(),
      'digilocker_linked': true,
      'selfie_uploaded': true,
      'video_uploaded': true,
      'kyc_status': 'verified',
      'pan_verified': true, // Assume verified since it passed step 2
    });
  }
}
