import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/stepper_widget.dart';
import '../domain/loan_application_notifier.dart';

/// Step 4 — References (3 refs, 2 must be family)
class Step4ReferencesScreen extends ConsumerStatefulWidget {
  const Step4ReferencesScreen({super.key});

  @override
  ConsumerState<Step4ReferencesScreen> createState() => _Step4ReferencesScreenState();
}

class _Step4ReferencesScreenState extends ConsumerState<Step4ReferencesScreen> {
  final _formKey = GlobalKey<FormState>();

  // 3 references
  final List<_RefData> _refs = List.generate(3, (_) => _RefData());

  final _relationships = ['Father', 'Mother', 'Spouse', 'Brother', 'Sister',
    'Son', 'Daughter', 'Friend', 'Colleague', 'Relative'];

  final _familyRelationships = {'Father', 'Mother', 'Spouse', 'Brother', 'Sister', 'Son', 'Daughter', 'Relative'};

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _loadSavedData() {
    final data = ref.read(loanApplicationProvider).stepData[4];
    if (data != null) {
      for (int i = 0; i < 3; i++) {
        final refData = data['ref_${i + 1}'];
        if (refData is Map) {
          _refs[i].nameController.text = refData['name'] ?? '';
          _refs[i].phoneController.text = refData['phone'] ?? '';
          _refs[i].relationship = refData['relationship'] ?? _relationships.first;
        }
      }
    }
  }

  @override
  void dispose() {
    for (final r in _refs) {
      r.nameController.dispose();
      r.phoneController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(title: const Text('References')),
      body: Column(
        children: [
          const LoanStepperWidget(currentStep: 4),
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
                      'Add 3 References',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.infoSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: AppColors.info),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'At least 2 references must be family members',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.info),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    for (int i = 0; i < 3; i++) ...[
                      _buildRefCard(i, isDark),
                      if (i < 2) const SizedBox(height: 16),
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

  Widget _buildRefCard(int index, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark ? null : AppColors.cardShadow,
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reference ${index + 1}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _refs[index].nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _refs[index].relationship,
            dropdownColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
            items: _relationships
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setState(() => _refs[index].relationship = v!),
            decoration: const InputDecoration(
              labelText: 'Relationship',
              prefixIcon: Icon(Icons.people_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _refs[index].phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_outlined),
              prefixText: '+91 ',
            ),
            keyboardType: TextInputType.phone,
            maxLength: AppConstants.phoneLength,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Phone is required';
              if (v.length != AppConstants.phoneLength) return 'Enter valid phone';
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;

    // Check: at least 2 must be family
    int familyCount = 0;
    for (final r in _refs) {
      if (_familyRelationships.contains(r.relationship)) {
        familyCount++;
      }
    }
    if (familyCount < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'At least 2 references must be family members',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final Map<String, dynamic> data = {};
    for (int i = 0; i < 3; i++) {
      data['ref_${i + 1}'] = {
        'name': _refs[i].nameController.text.trim(),
        'relationship': _refs[i].relationship,
        'phone': _refs[i].phoneController.text.trim(),
      };
    }

    ref.read(loanApplicationProvider.notifier).completeStep(4, data);
  }
}

class _RefData {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String relationship = 'Father';
}
