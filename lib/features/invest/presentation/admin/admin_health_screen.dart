import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/providers/admin_provider.dart';
import '../../domain/providers/platform_health_provider.dart';
import '../../domain/models/platform_health.dart';

class AdminHealthScreen extends ConsumerStatefulWidget {
  const AdminHealthScreen({super.key});

  @override
  ConsumerState<AdminHealthScreen> createState() => _AdminHealthScreenState();
}

class _AdminHealthScreenState extends ConsumerState<AdminHealthScreen> {
  bool _initialized = false;
  bool _isSaving = false;
  double _repaymentRate = 94.2;
  double _npaRate = 1.8;
  double _avgCredit = 680.0;
  int _activeLenders = 412;
  double _fundsDeployed = 31200000.0;
  PlatformHealth? _originalHealth;

  void _initFields(PlatformHealth health) {
    if (_initialized) return;
    _originalHealth = health;
    _repaymentRate = health.onTimeRepaymentRate;
    _npaRate = health.npaPercentage;
    _avgCredit = health.avgBorrowerCreditScore.toDouble();
    _activeLenders = health.totalLendersActive;
    _fundsDeployed = health.totalFundsDeployed;
    _initialized = true;
  }

  void _onSave() async {
    if (_originalHealth == null) return;
    setState(() => _isSaving = true);

    final updatedHealth = PlatformHealth(
      id: _originalHealth!.id,
      snapshotDate: DateTime.now(),
      totalActiveLoans: _originalHealth!.totalActiveLoans,
      totalLoansDisbursed: _originalHealth!.totalLoansDisbursed,
      totalAmountDisbursed: _originalHealth!.totalAmountDisbursed,
      npaPercentage: double.parse(_npaRate.toStringAsFixed(1)),
      avgBorrowerCreditScore: _avgCredit.round(),
      onTimeRepaymentRate: double.parse(_repaymentRate.toStringAsFixed(1)),
      totalLendersActive: _activeLenders,
      totalFundsDeployed: _fundsDeployed,
      createdAt: _originalHealth!.createdAt,
    );

    try {
      await ref.read(adminProvider.notifier).updateHealth(updatedHealth);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Platform health telemetry updated successfully.'), backgroundColor: AppColors.accent),
        );
        context.go('/admin/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(platformHealthProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          onPressed: () => context.go('/admin/dashboard'),
        ),
        title: Text(
          'Health Telemetry',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: healthState.when(
          data: (health) {
            _initFields(health);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        // Repayment Rate Slider
                        _buildSliderHeader('On-time Repayment Rate', '${_repaymentRate.toStringAsFixed(1)}%'),
                        Slider(
                          value: _repaymentRate,
                          min: 80.0,
                          max: 100.0,
                          activeColor: AppColors.accent,
                          inactiveColor: isDark ? Colors.grey[800] : Colors.grey[300],
                          onChanged: (val) => setState(() => _repaymentRate = val),
                        ),
                        const SizedBox(height: 16),

                        // NPA percentage Slider
                        _buildSliderHeader('NPA Rate (90+ DPD)', '${_npaRate.toStringAsFixed(1)}%'),
                        Slider(
                          value: _npaRate,
                          min: 0.0,
                          max: 10.0,
                          activeColor: AppColors.error,
                          inactiveColor: isDark ? Colors.grey[800] : Colors.grey[300],
                          onChanged: (val) => setState(() => _npaRate = val),
                        ),
                        const SizedBox(height: 16),

                        // Average Credit score Slider
                        _buildSliderHeader('Average Borrower Credit Score', '${_avgCredit.round()}'),
                        Slider(
                          value: _avgCredit,
                          min: 500.0,
                          max: 850.0,
                          activeColor: AppColors.primary,
                          inactiveColor: isDark ? Colors.grey[800] : Colors.grey[300],
                          onChanged: (val) => setState(() => _avgCredit = val),
                        ),
                        const SizedBox(height: 16),

                        // Input fields for static platform sizes
                        Text('Total Deployed Portfolio (₹)', style: AppTextStyles.labelMedium),
                        const SizedBox(height: 6),
                        TextFormField(
                          initialValue: _fundsDeployed.toInt().toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'e.g. 31200000'),
                          onChanged: (v) {
                            final val = double.tryParse(v);
                            if (val != null) _fundsDeployed = val;
                          },
                        ),
                        const SizedBox(height: 16),

                        Text('Active Investors Count', style: AppTextStyles.labelMedium),
                        const SizedBox(height: 6),
                        TextFormField(
                          initialValue: _activeLenders.toString(),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'e.g. 412'),
                          onChanged: (v) {
                            final val = int.tryParse(v);
                            if (val != null) _activeLenders = val;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

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
                            child: const Text('Save Telemetry Settings'),
                          ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Center(child: Text('Error loading telemetry: $e')),
        ),
      ),
    );
  }

  Widget _buildSliderHeader(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
