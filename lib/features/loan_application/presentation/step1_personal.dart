import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/stepper_widget.dart';
import '../domain/loan_application_notifier.dart';

/// Step 1 — Personal Details
/// Name, DOB (18+ validation), gender, marital status, education, email+OTP, address
class Step1PersonalScreen extends ConsumerStatefulWidget {
  const Step1PersonalScreen({super.key});

  @override
  ConsumerState<Step1PersonalScreen> createState() => _Step1PersonalScreenState();
}

class _Step1PersonalScreenState extends ConsumerState<Step1PersonalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _altPhoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();

  String _gender = 'Male';
  String _maritalStatus = 'Single';
  String _educationLevel = 'Graduate';
  String _residenceType = 'Owned';
  DateTime? _selectedDob;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _loadSavedData() {
    final state = ref.read(loanApplicationProvider);
    final data = state.stepData[1];
    if (data != null) {
      _nameController.text = data['full_name'] ?? '';
      _emailController.text = data['email'] ?? '';
      _altPhoneController.text = data['alternate_phone'] ?? '';
      _streetController.text = data['street'] ?? '';
      _cityController.text = data['city'] ?? '';
      _stateController.text = data['state'] ?? '';
      _pinCodeController.text = data['pin_code'] ?? '';
      _gender = data['gender'] ?? 'Male';
      _maritalStatus = data['marital_status'] ?? 'Single';
      _educationLevel = data['education_level'] ?? 'Graduate';
      _residenceType = data['residence_type'] ?? 'Owned';
      if (data['date_of_birth'] != null) {
        _selectedDob = DateTime.tryParse(data['date_of_birth']);
        if (_selectedDob != null) {
          _dobController.text =
              '${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}';
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _altPhoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        title: const Text('Apply for Loan'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const LoanStepperWidget(currentStep: 1),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Personal Information', isDark),
                    const SizedBox(height: 12),

                    // Full Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name (as per PAN)',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Name is required';
                        if (v.trim().length < 3) return 'Enter full name';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Date of Birth
                    TextFormField(
                      controller: _dobController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        hintText: 'DD/MM/YYYY',
                      ),
                      onTap: _selectDob,
                      validator: (v) {
                        if (_selectedDob == null) return 'Date of birth is required';
                        final age = DateTime.now().difference(_selectedDob!).inDays ~/ 365;
                        if (age < 18) return 'You must be at least 18 years old';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Gender
                    _buildDropdown(
                      'Gender',
                      Icons.wc_outlined,
                      _gender,
                      ['Male', 'Female', 'Other'],
                      (v) => setState(() => _gender = v!),
                      isDark,
                    ),
                    const SizedBox(height: 14),

                    // Marital Status
                    _buildDropdown(
                      'Marital Status',
                      Icons.favorite_outline,
                      _maritalStatus,
                      ['Single', 'Married', 'Divorced', 'Widowed'],
                      (v) => setState(() => _maritalStatus = v!),
                      isDark,
                    ),
                    const SizedBox(height: 14),

                    // Education Level
                    _buildDropdown(
                      'Education Level',
                      Icons.school_outlined,
                      _educationLevel,
                      ['Below 10th', '10th Pass', '12th Pass', 'Graduate', 'Post Graduate', 'Professional', 'Doctorate'],
                      (v) => setState(() => _educationLevel = v!),
                      isDark,
                    ),
                    const SizedBox(height: 14),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v != null && v.isNotEmpty) {
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(v)) return 'Invalid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Alternate Phone
                    TextFormField(
                      controller: _altPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Alternate Phone (optional)',
                        prefixIcon: Icon(Icons.phone_outlined),
                        prefixText: '+91 ',
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: AppConstants.phoneLength,
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle('Current Address', isDark),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _streetController,
                      decoration: const InputDecoration(
                        labelText: 'Street / Locality',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      maxLines: 2,
                      validator: (v) => (v == null || v.isEmpty) ? 'Address is required' : null,
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(labelText: 'City'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _stateController,
                            decoration: const InputDecoration(labelText: 'State'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _pinCodeController,
                            decoration: const InputDecoration(labelText: 'PIN Code'),
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (v.length != 6) return 'Invalid PIN';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            'Residence',
                            Icons.home_outlined,
                            _residenceType,
                            ['Owned', 'Rented', 'Parental', 'Company Provided'],
                            (v) => setState(() => _residenceType = v!),
                            isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Continue button
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    IconData icon,
    String value,
    List<String> items,
    void Function(String?) onChanged,
    bool isDark,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Future<void> _selectDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      ref.read(loanApplicationProvider.notifier).completeStep(1, {
        'full_name': _nameController.text.trim(),
        'date_of_birth': _selectedDob?.toIso8601String(),
        'gender': _gender,
        'marital_status': _maritalStatus,
        'education_level': _educationLevel,
        'email': _emailController.text.trim(),
        'alternate_phone': _altPhoneController.text.trim(),
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'pin_code': _pinCodeController.text.trim(),
        'residence_type': _residenceType,
      });
    }
  }
}
