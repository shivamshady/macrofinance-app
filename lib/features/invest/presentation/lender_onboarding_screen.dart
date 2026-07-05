import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/user_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/document_upload_widget.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../features/invest/domain/providers/lender_profile_provider.dart';
import '../../../features/invest/domain/models/lender_profile.dart';

class LenderOnboardingScreen extends ConsumerStatefulWidget {
  const LenderOnboardingScreen({super.key});

  @override
  ConsumerState<LenderOnboardingScreen> createState() => _LenderOnboardingScreenState();
}

class _LenderOnboardingScreenState extends ConsumerState<LenderOnboardingScreen> {
  int _currentStep = 1; // 1 to 6
  bool _showOverlay = false;
  String? _overlayMessage;

  // STEP 1 CONTROLLERS
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _pinCodeController = TextEditingController();
  String _selectedState = 'Delhi';
  String _residenceType = 'Owned';
  String _gender = 'Male';
  DateTime? _selectedDob;

  // STEP 2 CONTROLLERS
  String _incomeType = 'Salaried Employee';
  final _orgNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _workingSinceController = TextEditingController();
  DateTime? _workingSinceDate;

  final _businessNameController = TextEditingController();
  String _businessIndustry = 'Retail';
  final _annualTurnoverController = TextEditingController();
  double _yearsInBusiness = 2.0;

  String _annualIncomeRange = 'Below ₹2.5 Lakhs';
  String _sourceOfFunds = 'Savings';
  bool _isPep = false;

  // STEP 3 CONTROLLERS
  final _panController = TextEditingController();
  bool _panVerified = false;
  String? _panMatchedName;
  String? _panError;

  // STEP 4 CONTROLLERS
  String? _panPhotoPath;
  String? _aadhaarFrontPath;
  String? _aadhaarBackPath;
  String? _selfiePath;
  final _aadhaarNumController = TextEditingController();
  bool _isAadhaarNumValid = false;

  // STEP 5 CONTROLLERS
  final _bankHolderController = TextEditingController();
  final _bankAccController = TextEditingController();
  final _bankConfirmAccController = TextEditingController();
  final _ifscController = TextEditingController();
  bool _obscureAccNum = true;
  String? _ifscResultMsg;
  Color _ifscResultColor = AppColors.error;
  bool _bankVerified = false;

  // STEP 6 CONTROLLERS
  final ScrollController _scrollController = ScrollController();
  bool _reachedBottom = false;
  bool _riskDisclosureAgreed = false;
  String _investmentObjective = 'Regular Income';
  String _riskAppetite = 'Moderate';
  String _investmentHorizon = 'Medium-term (6–12 months)';

  // Static state/UT list
  final List<String> _indianStatesAndUTs = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh', 'Goa',
    'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala',
    'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland',
    'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
    'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Andaman and Nicobar Islands', 'Chandigarh', 'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi', 'Jammu and Kashmir', 'Ladakh', 'Lakshadweep', 'Puducherry'
  ];

  @override
  void initState() {
    super.initState();
    _loadOnboardingProgress();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent - 20) {
        if (!_reachedBottom) {
          setState(() {
            _reachedBottom = true;
          });
        }
      }
    }
  }

  void _loadOnboardingProgress() {
    // Attempt pre-filling from mock registration
    final currentUser = ref.read(userProvider).valueOrNull;
    if (currentUser != null) {
      _nameController.text = currentUser.fullName ?? '';
      _emailController.text = currentUser.email ?? '';
      _gender = currentUser.gender ?? 'Male';
      _selectedDob = currentUser.dateOfBirth;
      if (_selectedDob != null) {
        _dobController.text =
            '${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}';
      }
      _bankHolderController.text = currentUser.fullName ?? '';
    }

    // Bank prefill
    _bankHolderController.text = currentUser?.fullName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _altPhoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    
    _orgNameController.dispose();
    _jobTitleController.dispose();
    _monthlyIncomeController.dispose();
    _workingSinceController.dispose();
    _businessNameController.dispose();
    _annualTurnoverController.dispose();

    _panController.dispose();
    _aadhaarNumController.dispose();

    _bankHolderController.dispose();
    _bankAccController.dispose();
    _bankConfirmAccController.dispose();
    _ifscController.dispose();
    
    _scrollController.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    int m = today.month - birthDate.month;
    if (m < 0 || (m == 0 && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDob(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final age = _calculateAge(picked);
      if (age < 18) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be 18 years or older to invest.')),
        );
        return;
      }
      setState(() {
        _selectedDob = picked;
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        _saveStep1();
      });
    }
  }

  Future<void> _selectWorkingSince(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _workingSinceDate = picked;
        _workingSinceController.text = '${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        _saveStep2();
      });
    }
  }

  // ── SAVE STATE (Removed MockLenderDataStore) ──
  void _saveStep1() {}
  void _saveStep2() {}
  void _saveStep3() {}
  void _saveStep4() {}
  void _saveStep5() {}

  // ── SUBMIT ENDPOINTS (SIMULATED) ──
  Future<bool> _postStep(int step) async {
    setState(() {
      _showOverlay = true;
      _overlayMessage = 'Saving progress...';
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _showOverlay = false);
    return true;
  }

  // Verhoeff checksum validation
  bool _validateAadhaarChecksum(String num) {
    if (num.length != 12) return false;
    final List<List<int>> d = [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
      [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
      [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
      [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
      [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
      [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
      [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
      [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
      [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
    ];
    final List<List<int>> p = [
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
      [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
      [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
      [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
      [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
      [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
      [7, 0, 4, 6, 9, 1, 3, 2, 5, 8]
    ];
    int c = 0;
    try {
      List<int> digits = num.split('').map(int.parse).toList();
      digits = digits.reversed.toList();
      for (int i = 0; i < digits.length; i++) {
        c = d[c][p[i % 8][digits[i]]];
      }
      return c == 0;
    } catch (_) {
      return false;
    }
  }

  // PAN Verify action
  Future<void> _verifyPan() async {
    final pan = _panController.text.toUpperCase().trim();
    setState(() {
      _showOverlay = true;
      _overlayMessage = 'Verifying PAN with NSDL...';
      _panError = null;
    });

    // Fake verification for now
    final res = await MockPanService.verify(pan, []);
    setState(() => _showOverlay = false);

    if (res['valid'] == true) {
      setState(() {
        _panVerified = true;
        _panMatchedName = res['name'] ?? _nameController.text.toUpperCase();
        _saveStep3();
      });
    } else {
      setState(() {
        _panVerified = false;
        _panError = res['error'] ?? 'PAN already linked to another account';
        _saveStep3();
      });
    }
  }

  // IFSC Lookup action
  Future<void> _lookupIfsc() async {
    final ifsc = _ifscController.text.toUpperCase().trim();
    if (ifsc.length != 11) return;

    // Mock IFSC lookup
    final details = {'bank': 'State Bank of India', 'branch': 'Delhi'};
    setState(() {
      if (details.containsKey('bank') && details['bank'] != 'Bank of India') {
        _ifscResultMsg = '${details['bank']} — ${details['branch']}';
        _ifscResultColor = AppColors.accent;
      } else {
        _ifscResultMsg = 'Bank details will be verified manually';
        _ifscResultColor = AppColors.warning;
      }
      _saveStep5();
    });
  }

  // Penny Drop Simulation
  Future<void> _verifyBankAccount() async {
    if (_bankAccController.text.trim() != _bankConfirmAccController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account numbers do not match!')),
      );
      return;
    }

    setState(() {
      _showOverlay = true;
    });

    final List<String> stages = [
      'Initiating verification transfer...',
      'Sending ₹1 to your account...',
      'Confirming receipt...'
    ];

    for (var msg in stages) {
      setState(() {
        _overlayMessage = msg;
      });
      await Future.delayed(const Duration(milliseconds: 800));
    }

    setState(() => _showOverlay = false);

    // 10% failure simulation
    final success = DateTime.now().millisecond % 10 != 0;

    setState(() {
      if (success) {
        _bankVerified = true;
        _saveStep5();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Account Verified — ₹1 credited successfully')),
        );
      } else {
        _bankVerified = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Verification failed. Check your account details and retry.')),
        );
      }
    });
  }

  // ── FINAL ACCOUNT ACTIVATION ──
  Future<void> _activateAccount() async {
    setState(() {
      _showOverlay = true;
      _overlayMessage = 'Activating your Investor account...';
    });

    await Future.delayed(const Duration(seconds: 2));

    // Create the Lender Profile
    final newProfile = LenderProfile(
      id: 'lnd_${DateTime.now().millisecondsSinceEpoch % 1000000}',
      userId: 'usr_mock',
      riskProfile: _riskAppetite.toLowerCase(),
      riskDisclosureSigned: true,
      riskDisclosureSignedAt: DateTime.now(),
      lenderAgreementUrl: 'agreements/signed_lender_agreement_usr_mock.pdf',
      walletBalance: 12500.0, // Pre-seeded
      totalInvested: 50000.0, // Pre-seeded
      totalReturnsEarned: 4200.0, // Pre-seeded
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      onboardingComplete: true,
      kycStatus: 'pending_review', // Step 4 sets to pending_review
    );

    // Profile creation simulated
    await ref.read(lenderProfileProvider.notifier).refreshProfile();

    setState(() => _showOverlay = false);

    if (!mounted) return;
    
    // Navigate with success banner
    context.go('/invest/dashboard');
    
    // Suggested plan based on appetite
    String suggested = 'Growth Plan';
    if (_riskAppetite == 'Conservative') suggested = 'Starter Plan';
    if (_riskAppetite == 'Aggressive') suggested = 'Premium Plan';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Account activated! Start investing today. Recommended: $suggested'),
        duration: const Duration(seconds: 4),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  // ── MAIN BUTTON HANDLER ──
  Future<void> _handleNext() async {
    if (_currentStep == 1) {
      if (_nameController.text.trim().isEmpty ||
          _dobController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty ||
          _streetController.text.trim().isEmpty ||
          _cityController.text.trim().isEmpty ||
          _pinCodeController.text.trim().length != 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill out all required fields correctly.')),
        );
        return;
      }
      _saveStep1();
      final ok = await _postStep(1);
      if (ok) setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_incomeType == 'Salaried Employee' || _incomeType == 'Self-Employed Professional') {
        if (_orgNameController.text.trim().isEmpty ||
            _jobTitleController.text.trim().isEmpty ||
            _monthlyIncomeController.text.trim().isEmpty ||
            _workingSinceController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill in organisation details.')),
          );
          return;
        }
      } else if (_incomeType == 'Business Owner') {
        if (_businessNameController.text.trim().isEmpty ||
            _annualTurnoverController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please fill in business details.')),
          );
          return;
        }
      }
      _saveStep2();
      final ok = await _postStep(2);
      if (ok) setState(() => _currentStep = 3);
    } else if (_currentStep == 3) {
      if (!_panVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify your PAN to proceed.')),
        );
        return;
      }
      _saveStep3();
      final ok = await _postStep(3);
      if (ok) setState(() => _currentStep = 4);
    } else if (_currentStep == 4) {
      if (_panPhotoPath == null ||
          _aadhaarFrontPath == null ||
          _aadhaarBackPath == null ||
          _selfiePath == null ||
          !_isAadhaarNumValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All uploads and a valid Aadhaar number are required.')),
        );
        return;
      }
      _saveStep4();
      final ok = await _postStep(4);
      if (ok) setState(() => _currentStep = 5);
    } else if (_currentStep == 5) {
      if (!_bankVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify your bank account to proceed.')),
        );
        return;
      }
      _saveStep5();
      final ok = await _postStep(5);
      if (ok) setState(() => _currentStep = 6);
    } else if (_currentStep == 6) {
      if (!_riskDisclosureAgreed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please agree to the risk disclosures.')),
        );
        return;
      }
      await _activateAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressVal = _currentStep / 6.0;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              onPressed: () {
                if (_currentStep > 1) {
                  setState(() => _currentStep--);
                } else {
                  context.go('/invest');
                }
              },
            ),
            title: Text(
              'Investor Onboarding',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
          body: Column(
            children: [
              // Stepper/Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Step $_currentStep of 6',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                        Text(
                          '${(progressVal * 100).toInt()}% Complete',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressVal,
                        minHeight: 6,
                        color: AppColors.accent,
                        backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                  ],
                ),
              ),

              // Content in SingleChildScrollView
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: _buildStepContent(isDark),
                ),
              ),

              // Bottom Button container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.accent : AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _currentStep == 6 ? 'Activate My Account' : 'Continue',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_showOverlay) LoadingOverlay(message: _overlayMessage),
      ],
    );
  }

  Widget _buildStepContent(bool isDark) {
    switch (_currentStep) {
      case 1:
        return _buildStep1(isDark);
      case 2:
        return _buildStep2(isDark);
      case 3:
        return _buildStep3(isDark);
      case 4:
        return _buildStep4(isDark);
      case 5:
        return _buildStep5(isDark);
      case 6:
        return _buildStep6(isDark);
      default:
        return const SizedBox();
    }
  }

  // ── STEP 1: PERSONAL DETAILS ──
  Widget _buildStep1(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tell us about yourself', style: AppTextStyles.headlineMedium),
        Text('We need this to set up your investor account', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 24),

        // Full Name
        Text('Full Name', style: AppTextStyles.titleSmall),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Enter full name as per PAN'),
          onChanged: (val) {
            _saveStep1();
          },
        ),
        const SizedBox(height: 16),

        // DOB
        Text('Date of Birth', style: AppTextStyles.titleSmall),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _selectDob(context),
          child: IgnorePointer(
            child: TextFormField(
              controller: _dobController,
              decoration: const InputDecoration(
                hintText: 'DD / MM / YYYY',
                suffixIcon: Icon(Icons.calendar_today_rounded),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Gender segmented
        Text('Gender', style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: ['Male', 'Female', 'Other'].map((g) {
            final sel = _gender == g;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: sel
                        ? (isDark ? AppColors.accent.withOpacity(0.15) : AppColors.primary.withOpacity(0.08))
                        : Colors.transparent,
                    side: BorderSide(
                      color: sel ? (isDark ? AppColors.accent : AppColors.primary) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: sel ? 2 : 1,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() {
                      _gender = g;
                      _saveStep1();
                    });
                  },
                  child: Text(g),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Email
        Text('Email Address', style: AppTextStyles.titleSmall),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'name@example.com'),
          onChanged: (val) => _saveStep1(),
        ),
        const SizedBox(height: 16),

        // Alternate phone
        Text('Alternate Phone (optional)', style: AppTextStyles.titleSmall),
        const SizedBox(height: 6),
        TextFormField(
          controller: _altPhoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: const InputDecoration(hintText: '10 digit mobile number'),
          onChanged: (val) => _saveStep1(),
        ),
        const SizedBox(height: 16),

        // Current Address
        Text('Street / Flat / House No.', style: AppTextStyles.titleSmall),
        const SizedBox(height: 6),
        TextFormField(
          controller: _streetController,
          decoration: const InputDecoration(hintText: 'Door no, Building, Street name'),
          onChanged: (val) => _saveStep1(),
        ),
        const SizedBox(height: 16),

        Text('City', style: AppTextStyles.titleSmall),
        const SizedBox(height: 6),
        TextFormField(
          controller: _cityController,
          decoration: const InputDecoration(hintText: 'City'),
          onChanged: (val) => _saveStep1(),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('State', style: AppTextStyles.titleSmall),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedState,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                    items: _indianStatesAndUTs.map((state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(state, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedState = val;
                          _saveStep1();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PIN Code', style: AppTextStyles.titleSmall),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _pinCodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(hintText: '6 digits'),
                    onChanged: (val) => _saveStep1(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Residence type
        Text('Residence Type', style: AppTextStyles.titleSmall),
        const SizedBox(height: 4),
        Row(
          children: ['Owned', 'Rented', 'Parental'].map((res) {
            return Row(
              children: [
                Radio<String>(
                  value: res,
                  groupValue: _residenceType,
                  activeColor: AppColors.accent,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _residenceType = val;
                        _saveStep1();
                      });
                    }
                  },
                ),
                Text(res, style: GoogleFonts.inter(fontSize: 14)),
                const SizedBox(width: 12),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── STEP 2: FINANCIAL PROFILE ──
  Widget _buildStep2(bool isDark) {
    final showSalaried = _incomeType == 'Salaried Employee' || _incomeType == 'Self-Employed Professional';
    final showBusiness = _incomeType == 'Business Owner';

    // Min income check warning
    double monthlyVal = double.tryParse(_monthlyIncomeController.text.trim()) ?? 0.0;
    bool showWarning = monthlyVal > 0 && monthlyVal < 10000 && _annualIncomeRange == 'Below ₹2.5 Lakhs';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your financial background', style: AppTextStyles.headlineMedium),
        Text('This helps us understand your investment capacity', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 24),

        // Income type
        Text('Employment / Income Type', style: AppTextStyles.titleSmall),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _incomeType,
          items: [
            'Salaried Employee',
            'Business Owner',
            'Self-Employed Professional',
            'Retired',
            'Housewife/Homemaker',
            'Student',
            'Other'
          ].map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _incomeType = val;
                _saveStep2();
              });
            }
          },
        ),
        const SizedBox(height: 16),

        if (showSalaried) ...[
          Text('Organisation Name', style: AppTextStyles.titleSmall),
          const SizedBox(height: 6),
          TextFormField(
            controller: _orgNameController,
            decoration: const InputDecoration(hintText: 'Enter company or firm name'),
            onChanged: (val) => _saveStep2(),
          ),
          const SizedBox(height: 16),

          Text('Job Title', style: AppTextStyles.titleSmall),
          const SizedBox(height: 6),
          TextFormField(
            controller: _jobTitleController,
            decoration: const InputDecoration(hintText: 'e.g. Software Engineer, Manager'),
            onChanged: (val) => _saveStep2(),
          ),
          const SizedBox(height: 16),

          Text('Monthly Net Income', style: AppTextStyles.titleSmall),
          const SizedBox(height: 6),
          TextFormField(
            controller: _monthlyIncomeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.currency_rupee_rounded),
              hintText: 'Net amount credited to bank',
            ),
            onChanged: (val) {
              setState(() {
                _saveStep2();
              });
            },
          ),
          const SizedBox(height: 16),

          Text('Working Since', style: AppTextStyles.titleSmall),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _selectWorkingSince(context),
            child: IgnorePointer(
              child: TextFormField(
                controller: _workingSinceController,
                decoration: const InputDecoration(
                  hintText: 'MM / YYYY',
                  suffixIcon: Icon(Icons.calendar_today_rounded),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (showBusiness) ...[
          Text('Business Name', style: AppTextStyles.titleSmall),
          const SizedBox(height: 6),
          TextFormField(
            controller: _businessNameController,
            decoration: const InputDecoration(hintText: 'Legal business name'),
            onChanged: (val) => _saveStep2(),
          ),
          const SizedBox(height: 16),

          Text('Business Type / Industry', style: AppTextStyles.titleSmall),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _businessIndustry,
            items: ['Retail', 'Manufacturing', 'Services', 'Consulting', 'Tech/E-commerce', 'Wholesale', 'Other'].map((ind) {
              return DropdownMenuItem<String>(
                value: ind,
                child: Text(ind),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _businessIndustry = val;
                  _saveStep2();
                });
              }
            },
          ),
          const SizedBox(height: 16),

          Text('Annual Turnover', style: AppTextStyles.titleSmall),
          const SizedBox(height: 6),
          TextFormField(
            controller: _annualTurnoverController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.currency_rupee_rounded),
              hintText: 'Turnover in rupees',
            ),
            onChanged: (val) => _saveStep2(),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Years in Business', style: AppTextStyles.titleSmall),
              Text('${_yearsInBusiness.toInt()} years', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.accent)),
            ],
          ),
          Slider(
            value: _yearsInBusiness,
            min: 0,
            max: 40,
            divisions: 40,
            activeColor: AppColors.accent,
            onChanged: (val) {
              setState(() {
                _yearsInBusiness = val;
                _saveStep2();
              });
            },
          ),
          const SizedBox(height: 16),
        ],

        // Annual income range
        Text('Annual Income Range', style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        Column(
          children: ['Below ₹2.5 Lakhs', '₹2.5L – ₹5L', '₹5L – ₹10L', '₹10L – ₹25L', 'Above ₹25L'].map((range) {
            return Row(
              children: [
                Radio<String>(
                  value: range,
                  groupValue: _annualIncomeRange,
                  activeColor: AppColors.accent,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _annualIncomeRange = val;
                        _saveStep2();
                      });
                    }
                  },
                ),
                Text(range, style: GoogleFonts.inter(fontSize: 14)),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Source of funds
        Text('Source of Investment Funds', style: AppTextStyles.titleSmall),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _sourceOfFunds,
          items: ['Savings', 'Salary Income', 'Business Income', 'Inheritance / Gift', 'Sale of Assets', 'Other'].map((src) {
            return DropdownMenuItem<String>(
              value: src,
              child: Text(src),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _sourceOfFunds = val;
                _saveStep2();
              });
            }
          },
        ),
        const SizedBox(height: 16),

        // PEP Switch
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Politically Exposed Person (PEP)', style: AppTextStyles.titleSmall),
                Text('Hold political position or close associate', style: AppTextStyles.caption),
              ],
            ),
            Switch(
              value: _isPep,
              activeColor: AppColors.accent,
              onChanged: (val) {
                setState(() {
                  _isPep = val;
                  _saveStep2();
                });
              },
            ),
          ],
        ),
        if (_isPep) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your application will require additional manual review',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Warning banner
        if (showWarning) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Minimum income for investing is ₹10,000/month. You can still proceed but investment limits may apply.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.warningDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── STEP 3: PAN VERIFICATION ──
  Widget _buildStep3(bool isDark) {
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
    final canVerify = panRegex.hasMatch(_panController.text.toUpperCase().trim());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verify your PAN', style: AppTextStyles.headlineMedium),
        Text('Required for tax (TDS) purposes on your returns', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 28),

        // PAN field
        Text('PAN Number', style: AppTextStyles.titleSmall),
        const SizedBox(height: 6),
        TextFormField(
          controller: _panController,
          textCapitalization: TextCapitalization.characters,
          maxLength: 10,
          enabled: !_panVerified,
          decoration: InputDecoration(
            hintText: 'ABCDE1234F',
            prefixIcon: const Icon(Icons.badge_outlined),
            suffixIcon: _panVerified ? const Icon(Icons.check_circle_rounded, color: AppColors.accent) : null,
          ),
          onChanged: (val) {
            setState(() {
              _panError = null;
              _saveStep3();
            });
          },
        ),

        // Real-time validation feedback
        if (!_panVerified) ...[
          const SizedBox(height: 4),
          Text(
            _panController.text.isEmpty
                ? 'Enter 10-character PAN number'
                : (canVerify ? 'Format is valid ✓' : 'Format should be: 5 letters, 4 numbers, 1 letter'),
            style: GoogleFonts.inter(
              fontSize: 11,
              color: canVerify ? AppColors.accent : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
            ),
          ),
        ],

        if (_panError != null) ...[
          const SizedBox(height: 12),
          Text(_panError!, style: GoogleFonts.inter(color: AppColors.error, fontSize: 13)),
        ],

        if (_panVerified && _panMatchedName != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
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
                        'PAN Verified successfully ✓',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accent),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Name: $_panMatchedName',
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 28),

        if (!_panVerified)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: canVerify ? _verifyPan : null,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Verify PAN'),
            ),
          ),
      ],
    );
  }

  // ── STEP 4: KYC DOCUMENTS ──
  Widget _buildStep4(bool isDark) {
    int uploadedCount = 0;
    if (_panPhotoPath != null) uploadedCount++;
    if (_aadhaarFrontPath != null) uploadedCount++;
    if (_aadhaarBackPath != null) uploadedCount++;
    if (_selfiePath != null) uploadedCount++;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload your documents', style: AppTextStyles.headlineMedium),
        Text('We need to verify your identity before activating your account', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 16),

        // Summary Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: uploadedCount == 4 ? AppColors.accentSurface : AppColors.primarySurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$uploadedCount of 4 documents uploaded',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: uploadedCount == 4 ? AppColors.accent : AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Four uploaders
        DocumentUploadWidget(
          label: 'PAN Card Photo',
          initialValue: _panPhotoPath,
          onFileSelected: (path) {
            setState(() {
              _panPhotoPath = path;
              _saveStep4();
            });
          },
        ),
        const SizedBox(height: 12),

        DocumentUploadWidget(
          label: 'Aadhaar Front Photo',
          initialValue: _aadhaarFrontPath,
          onFileSelected: (path) {
            setState(() {
              _aadhaarFrontPath = path;
              _saveStep4();
            });
          },
        ),
        const SizedBox(height: 12),

        DocumentUploadWidget(
          label: 'Aadhaar Back Photo',
          initialValue: _aadhaarBackPath,
          onFileSelected: (path) {
            setState(() {
              _aadhaarBackPath = path;
              _saveStep4();
            });
          },
        ),
        const SizedBox(height: 12),

        DocumentUploadWidget(
          label: 'Live Selfie',
          isSelfie: true,
          initialValue: _selfiePath,
          onFileSelected: (path) {
            setState(() {
              _selfiePath = path;
              _saveStep4();
            });
          },
        ),
        const SizedBox(height: 20),

        // Aadhaar number input
        Text('Aadhaar Number', style: AppTextStyles.titleSmall),
        const SizedBox(height: 6),
        TextFormField(
          controller: _aadhaarNumController,
          keyboardType: TextInputType.number,
          maxLength: 14, // 12 digits + 2 spaces (XXXX XXXX XXXX)
          decoration: const InputDecoration(hintText: 'XXXX XXXX XXXX'),
          onChanged: (val) {
            final clean = val.replaceAll(' ', '');
            // Format as XXXX XXXX XXXX
            if (clean.length <= 12) {
              String formatted = '';
              for (int i = 0; i < clean.length; i++) {
                if (i > 0 && i % 4 == 0) formatted += ' ';
                formatted += clean[i];
              }
              if (formatted != val) {
                _aadhaarNumController.text = formatted;
                _aadhaarNumController.selection = TextSelection.fromPosition(
                  TextPosition(offset: formatted.length),
                );
              }
            }

            final finalClean = clean;
            setState(() {
              _isAadhaarNumValid = _validateAadhaarChecksum(finalClean);
              _saveStep4();
            });
          },
        ),
        if (_aadhaarNumController.text.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            _isAadhaarNumValid ? 'Aadhaar Checksum Valid ✓' : 'Invalid Aadhaar checksum',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: _isAadhaarNumValid ? AppColors.accent : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],

        // Info Banner (Non-blocking review info)
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, color: AppColors.warning, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Verification Review',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Documents submitted. Admin will verify within 2-4 hours. You can continue setting up meanwhile.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── STEP 5: BANK ACCOUNT ──
  Widget _buildStep5(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Link your bank account', style: AppTextStyles.headlineMedium),
        Text('Returns will be credited to this account monthly', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 24),

        // Account holder
        Text('Account Holder Name', style: AppTextStyles.titleSmall),
        const SizedBox(height: 6),
        TextFormField(
          controller: _bankHolderController,
          decoration: const InputDecoration(hintText: 'As per bank records'),
          onChanged: (val) => _saveStep5(),
        ),
        const SizedBox(height: 16),

        // Account number
        Text('Account Number', style: AppTextStyles.titleSmall),
        const SizedBox(height: 6),
        TextFormField(
          controller: _bankAccController,
          obscureText: _obscureAccNum,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter account number',
            suffixIcon: IconButton(
              icon: Icon(_obscureAccNum ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() => _obscureAccNum = !_obscureAccNum);
              },
            ),
          ),
          onChanged: (val) => _saveStep5(),
        ),
        const SizedBox(height: 16),

        // Confirm Account number
        Text('Confirm Account Number', style: AppTextStyles.titleSmall),
        const SizedBox(height: 6),
        TextFormField(
          controller: _bankConfirmAccController,
          obscureText: _obscureAccNum,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Re-enter account number'),
          onChanged: (val) => _saveStep5(),
        ),
        const SizedBox(height: 16),

        // IFSC Code
        Text('IFSC Code', style: AppTextStyles.titleSmall),
        const SizedBox(height: 6),
        TextFormField(
          controller: _ifscController,
          textCapitalization: TextCapitalization.characters,
          maxLength: 11,
          decoration: const InputDecoration(hintText: '11 digit alphanumeric code'),
          onChanged: (val) {
            _saveStep5();
            if (val.trim().length == 11) {
              _lookupIfsc();
            } else {
              setState(() {
                _ifscResultMsg = null;
              });
            }
          },
        ),
        if (_ifscResultMsg != null) ...[
          const SizedBox(height: 6),
          Text(
            _ifscResultMsg!,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _ifscResultColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],

        // Account Type Radio
        const SizedBox(height: 16),
        Text('Account Type', style: AppTextStyles.titleSmall),
        Row(
          children: ['Savings', 'Current'].map((type) {
            return Row(
              children: [
                Radio<String>(
                  value: type,
                  groupValue: _residenceType == 'Current' ? 'Current' : 'Savings',
                  activeColor: AppColors.accent,
                  onChanged: (val) {
                    setState(() {
                      // Hacky storage
                      _residenceType = val == 'Current' ? 'Current' : 'Savings';
                      _saveStep5();
                    });
                  },
                ),
                Text(type, style: GoogleFonts.inter(fontSize: 14)),
                const SizedBox(width: 16),
              ],
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Verification Status / Button
        if (_bankVerified) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle, color: AppColors.accent, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '✅ Account Verified — ₹1 credited successfully',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: (_bankAccController.text.trim().isNotEmpty && _ifscController.text.trim().length == 11)
                  ? _verifyBankAccount
                  : null,
              icon: const Icon(Icons.account_balance_outlined),
              label: const Text('Verify Bank Account'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── STEP 6: RISK DISCLOSURE & PROFILE ──
  Widget _buildStep6(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Before you invest', style: AppTextStyles.headlineMedium),
        Text('Please read and acknowledge the following', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 24),

        // PART A: RISK DISCLOSURE (Non-skippable)
        Text('PART A — Risk Disclosure', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),

        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                borderRadius: BorderRadius.circular(12),
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'IMPORTANT RISK DISCLOSURE FOR INVESTORS',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '1. NATURE OF INVESTMENT: MacroFinance operates as a co-lending platform. Your funds are lent to individual verified borrowers. This is NOT a bank deposit. Your principal is NOT guaranteed.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '2. RISK OF LOSS: Borrowers may default on repayments. While MacroFinance employs rigorous credit checks, there is inherent risk of partial or full loss of invested capital.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '3. LIQUIDITY RISK: Investments are locked for the chosen tenure. Early exit may attract penalties. Funds cannot be withdrawn before maturity except as per plan terms.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '4. RETURNS: Quoted returns (10%–15% p.a.) are indicative based on historical performance. Actual returns may vary.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '5. REGULATORY STATUS: MacroFinance NBFC operates under RBI guidelines. Investments are subject to applicable laws and regulations.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '6. TAX: Interest income is taxable under the Income Tax Act, 1961. TDS will be deducted at 10% if annual interest exceeds ₹5,000.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '7. GRIEVANCES: For disputes, contact grievance@macrofinance.in or the RBI Ombudsman.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Floating scroll warning indicator
            if (!_reachedBottom)
              Positioned(
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_downward_rounded, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Scroll to read full disclosure ↓', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        if (_reachedBottom) ...[
          Row(
            children: [
              Checkbox(
                value: _riskDisclosureAgreed,
                activeColor: AppColors.accent,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _riskDisclosureAgreed = val;
                    });
                  }
                },
              ),
              Expanded(
                child: Text(
                  'I have read and understood all the above risks. I am investing with my own funds and am aware of the risks involved.',
                  style: GoogleFonts.inter(fontSize: 12, height: 1.3),
                ),
              ),
            ],
          ),
        ],

        // PART B: INVESTMENT PROFILE
        if (_riskDisclosureAgreed) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          Text('PART B — Investment Profile', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),

          // Objective
          Text('Investment Objective', style: AppTextStyles.titleSmall),
          Column(
            children: ['Regular Income (monthly payouts)', 'Wealth Creation (long-term growth)', 'Both'].map((obj) {
              return Row(
                children: [
                  Radio<String>(
                    value: obj,
                    groupValue: _investmentObjective,
                    activeColor: AppColors.accent,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _investmentObjective = val;
                        });
                      }
                    },
                  ),
                  Text(obj, style: GoogleFonts.inter(fontSize: 14)),
                ],
              );
            }).toList(),
          ),

          // Risk Appetite segmented
          const SizedBox(height: 16),
          Text('Risk Appetite', style: AppTextStyles.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: ['Conservative', 'Moderate', 'Aggressive'].map((app) {
              final sel = _riskAppetite == app;
              String autoSuggest = 'STARTER';
              if (app == 'Moderate') autoSuggest = 'GROWTH';
              if (app == 'Aggressive') autoSuggest = 'PREMIUM';

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 54,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: sel
                          ? (isDark ? AppColors.accent.withOpacity(0.15) : AppColors.primary.withOpacity(0.08))
                          : Colors.transparent,
                      side: BorderSide(
                        color: sel ? (isDark ? AppColors.accent : AppColors.primary) : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        width: sel ? 2 : 1,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      setState(() {
                        _riskAppetite = app;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(app, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('Suggest: $autoSuggest', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Horizon
          const SizedBox(height: 20),
          Text('Investment Horizon', style: AppTextStyles.titleSmall),
          Column(
            children: ['Short-term (< 6 months)', 'Medium-term (6–12 months)', 'Long-term (> 12 months)'].map((hor) {
              return Row(
                children: [
                  Radio<String>(
                    value: hor,
                    groupValue: _investmentHorizon,
                    activeColor: AppColors.accent,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _investmentHorizon = val;
                        });
                      }
                    },
                  ),
                  Text(hor, style: GoogleFonts.inter(fontSize: 14)),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
