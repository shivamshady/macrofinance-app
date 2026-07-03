import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/stepper_widget.dart';
import '../domain/loan_application_notifier.dart';

/// Step 3 — Occupation & Income
/// Employment type branching with sub-fields
class Step3OccupationScreen extends ConsumerStatefulWidget {
  const Step3OccupationScreen({super.key});

  @override
  ConsumerState<Step3OccupationScreen> createState() => _Step3OccupationScreenState();
}

class _Step3OccupationScreenState extends ConsumerState<Step3OccupationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _employmentType = 'salaried';
  final _companyController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _gstController = TextEditingController();
  String _salaryMode = 'Bank Transfer';
  String _jobType = 'Full Time';
  String _loanPurpose = 'Personal';
  bool _hasExistingLoans = false;
  final _existingEmiController = TextEditingController();

  final _employmentTypes = {
    'salaried': 'Salaried',
    'self_employed_business': 'Self Employed (Business)',
    'self_employed_professional': 'Self Employed (Professional)',
    'student': 'Student',
    'housewife': 'Housewife',
    'retired': 'Retired',
    'other': 'Other',
  };

  final _purposes = ['Personal', 'Medical Emergency', 'Education', 'Home Renovation',
    'Business', 'Travel', 'Wedding', 'Debt Consolidation', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _loadSavedData() {
    final data = ref.read(loanApplicationProvider).stepData[3];
    if (data != null) {
      _employmentType = data['employment_type'] ?? 'salaried';
      _companyController.text = data['company_name'] ?? '';
      _jobTitleController.text = data['job_title'] ?? '';
      _monthlyIncomeController.text = data['monthly_income']?.toString() ?? '';
      _businessNameController.text = data['business_name'] ?? '';
      _gstController.text = data['gst_number'] ?? '';
      _salaryMode = data['salary_mode'] ?? 'Bank Transfer';
      _jobType = data['job_type'] ?? 'Full Time';
      _loanPurpose = data['loan_purpose'] ?? 'Personal';
      _hasExistingLoans = data['has_existing_loans'] ?? false;
      _existingEmiController.text = data['existing_emi_monthly']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _jobTitleController.dispose();
    _monthlyIncomeController.dispose();
    _businessNameController.dispose();
    _gstController.dispose();
    _existingEmiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(title: const Text('Occupation & Income')),
      body: Column(
        children: [
          const LoanStepperWidget(currentStep: 3),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employment Type
                    DropdownButtonFormField<String>(
                      value: _employmentType,
                      dropdownColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
                      items: _employmentTypes.entries
                          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) => setState(() => _employmentType = v!),
                      decoration: const InputDecoration(
                        labelText: 'Employment Type',
                        prefixIcon: Icon(Icons.work_outline),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Salaried fields
                    if (_employmentType == 'salaried') ...[
                      TextFormField(
                        controller: _companyController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _jobTitleController,
                        decoration: const InputDecoration(
                          labelText: 'Job Title / Designation',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _jobType,
                        items: ['Full Time', 'Part Time', 'Contract']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _jobType = v!),
                        decoration: const InputDecoration(
                          labelText: 'Job Type',
                          prefixIcon: Icon(Icons.schedule_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _salaryMode,
                        items: ['Bank Transfer', 'Cash', 'Cheque']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _salaryMode = v!),
                        decoration: const InputDecoration(
                          labelText: 'Salary Mode',
                          prefixIcon: Icon(Icons.account_balance_outlined),
                        ),
                      ),
                    ],

                    // Business fields
                    if (_employmentType.startsWith('self_employed')) ...[
                      TextFormField(
                        controller: _businessNameController,
                        decoration: const InputDecoration(
                          labelText: 'Business Name',
                          prefixIcon: Icon(Icons.store_outlined),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _gstController,
                        decoration: const InputDecoration(
                          labelText: 'GST Number (optional)',
                          prefixIcon: Icon(Icons.receipt_outlined),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 15,
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Monthly Income (all types)
                    TextFormField(
                      controller: _monthlyIncomeController,
                      decoration: const InputDecoration(
                        labelText: 'Monthly Income (₹)',
                        prefixIcon: Icon(Icons.currency_rupee_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Income is required';
                        final income = double.tryParse(v);
                        if (income == null || income <= 0) return 'Enter valid income';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Loan Purpose
                    DropdownButtonFormField<String>(
                      value: _loanPurpose,
                      items: _purposes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _loanPurpose = v!),
                      decoration: const InputDecoration(
                        labelText: 'Loan Purpose',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Existing Loans
                    SwitchListTile(
                      title: Text(
                        'Do you have existing loans?',
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      value: _hasExistingLoans,
                      onChanged: (v) => setState(() => _hasExistingLoans = v),
                      activeColor: AppColors.accent,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_hasExistingLoans) ...[
                      TextFormField(
                        controller: _existingEmiController,
                        decoration: const InputDecoration(
                          labelText: 'Total Monthly EMI (₹)',
                          prefixIcon: Icon(Icons.payment_outlined),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    const SizedBox(height: 32),

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

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      ref.read(loanApplicationProvider.notifier).completeStep(3, {
        'employment_type': _employmentType,
        'company_name': _companyController.text.trim(),
        'job_title': _jobTitleController.text.trim(),
        'job_type': _jobType,
        'salary_mode': _salaryMode,
        'monthly_income': double.tryParse(_monthlyIncomeController.text) ?? 0,
        'business_name': _businessNameController.text.trim(),
        'gst_number': _gstController.text.trim(),
        'loan_purpose': _loanPurpose,
        'has_existing_loans': _hasExistingLoans,
        'existing_emi_monthly': double.tryParse(_existingEmiController.text) ?? 0,
      });
    }
  }
}
