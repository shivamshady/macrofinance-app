import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/providers/admin_provider.dart';
import '../../domain/providers/investment_plans_provider.dart';
import '../../domain/models/investment_plan.dart';

class AdminPlanEditScreen extends ConsumerStatefulWidget {
  final String planId;
  const AdminPlanEditScreen({super.key, required this.planId});

  @override
  ConsumerState<AdminPlanEditScreen> createState() => _AdminPlanEditScreenState();
}

class _AdminPlanEditScreenState extends ConsumerState<AdminPlanEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _rateController;
  late TextEditingController _minController;
  late TextEditingController _maxController;
  late TextEditingController _tenureController;
  late TextEditingController _penaltyController;
  bool _earlyExitAllowed = false;
  bool _initialized = false;
  bool _isSaving = false;
  InvestmentPlan? _originalPlan;

  @override
  void dispose() {
    if (_initialized) {
      _nameController.dispose();
      _rateController.dispose();
      _minController.dispose();
      _maxController.dispose();
      _tenureController.dispose();
      _penaltyController.dispose();
    }
    super.dispose();
  }

  void _initFields(InvestmentPlan plan) {
    if (_initialized) return;
    _originalPlan = plan;
    _nameController = TextEditingController(text: plan.planName);
    _rateController = TextEditingController(text: plan.annualReturnRate.toString());
    _minController = TextEditingController(text: plan.minInvestment.toInt().toString());
    _maxController = TextEditingController(text: plan.maxInvestment.toInt().toString());
    _tenureController = TextEditingController(text: plan.tenureMonths.toString());
    _penaltyController = TextEditingController(text: plan.earlyExitPenaltyPct.toString());
    _earlyExitAllowed = plan.earlyExitAllowed;
    _initialized = true;
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate() || _originalPlan == null) return;
    setState(() => _isSaving = true);

    final modifiedPlan = InvestmentPlan(
      id: _originalPlan!.id,
      planCode: _originalPlan!.planCode,
      planName: _nameController.text.trim(),
      tenureMonths: int.parse(_tenureController.text.trim()),
      annualReturnRate: double.parse(_rateController.text.trim()),
      monthlyReturnRate: double.parse(_rateController.text.trim()) / 12,
      minInvestment: double.parse(_minController.text.trim()),
      maxInvestment: double.parse(_maxController.text.trim()),
      earlyExitAllowed: _earlyExitAllowed,
      earlyExitPenaltyPct: _earlyExitAllowed ? double.parse(_penaltyController.text.trim()) : 0.0,
      description: _originalPlan!.description,
      highlights: _originalPlan!.highlights,
      displayOrder: _originalPlan!.displayOrder,
      createdAt: _originalPlan!.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(adminProvider.notifier).updatePlan(modifiedPlan);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan configuration updated successfully.'), backgroundColor: AppColors.accent),
        );
        context.go('/admin/plans');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update plan: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansState = ref.watch(investmentPlansProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          onPressed: () => context.go('/admin/plans'),
        ),
        title: Text(
          'Edit Plan Formulation',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: plansState.when(
          data: (plans) {
            final targetId = int.tryParse(widget.planId);
            final plan = plans.firstWhere((p) => p.id == targetId, orElse: () => plans.first);
            _initFields(plan);

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Plan Name', style: AppTextStyles.labelMedium),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(hintText: 'e.g. Starter Plan'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter plan name' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Annual Yield (% p.a.)', style: AppTextStyles.labelMedium),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _rateController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(hintText: '12.5'),
                                      validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid yield' : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tenure (Months)', style: AppTextStyles.labelMedium),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _tenureController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      decoration: const InputDecoration(hintText: '6'),
                                      validator: (v) => (v == null || int.tryParse(v) == null) ? 'Enter months' : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Min Investment (₹)', style: AppTextStyles.labelMedium),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _minController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      decoration: const InputDecoration(hintText: '5,000'),
                                      validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter amount' : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Max Investment (₹)', style: AppTextStyles.labelMedium),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _maxController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      decoration: const InputDecoration(hintText: '200,000'),
                                      validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter amount' : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Switch toggles
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Allow Early Liquidation (Exit)', style: AppTextStyles.titleSmall),
                            subtitle: Text('Lender can exit before maturity date subject to penalties.', style: AppTextStyles.caption),
                            value: _earlyExitAllowed,
                            activeColor: AppColors.accent,
                            onChanged: (val) {
                              setState(() {
                                _earlyExitAllowed = val;
                              });
                            },
                          ),

                          if (_earlyExitAllowed) ...[
                            const SizedBox(height: 12),
                            Text('Early Exit Penalty Pct (%)', style: AppTextStyles.labelMedium),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _penaltyController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(hintText: '2.0'),
                              validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid percentage' : null,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Action buttons
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: _isSaving
                          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _onSave,
                              child: const Text('Save Plan Settings'),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('Error loading plan config: $e')),
        ),
      ),
    );
  }
}
