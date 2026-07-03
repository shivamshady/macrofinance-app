import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/hive_storage.dart';
import '../../../core/constants/tier_constants.dart';

/// Loan Application State — Riverpod AsyncNotifier
/// Tracks multi-step progress with Hive persistence

// ── State ──
class LoanApplicationState {
  final int currentStep;
  final Map<int, Map<String, dynamic>> stepData;
  final int tierLevel;
  final LoanTierConfig tierConfig;
  final double? selectedAmount;
  final int? selectedTenureDays;
  final bool isSubmitting;
  final String? applicationId;
  final String? errorMessage;

  const LoanApplicationState({
    this.currentStep = 1,
    this.stepData = const {},
    this.tierLevel = 1,
    LoanTierConfig? tierConfig,
    this.selectedAmount,
    this.selectedTenureDays,
    this.isSubmitting = false,
    this.applicationId,
    this.errorMessage,
  }) : tierConfig = tierConfig ?? const LoanTierConfig(
          level: 1,
          name: 'Starter',
          emoji: '🌱',
          minAmount: 2000,
          maxAmount: 5000,
          minCreditScore: 0,
          loansRepaidRequired: 0,
          interestRateMonthly: 2.5,
          processingFeePct: 5.0,
          insuranceFeePct: 0.5,
          lateFeeDailyPct: 0.5,
          gstPct: 18.0,
          maxTenureDays: 30,
          color: Color(0xFF9CA3AF),
        );

  LoanApplicationState copyWith({
    int? currentStep,
    Map<int, Map<String, dynamic>>? stepData,
    int? tierLevel,
    LoanTierConfig? tierConfig,
    double? selectedAmount,
    int? selectedTenureDays,
    bool? isSubmitting,
    String? applicationId,
    String? errorMessage,
  }) {
    return LoanApplicationState(
      currentStep: currentStep ?? this.currentStep,
      stepData: stepData ?? this.stepData,
      tierLevel: tierLevel ?? this.tierLevel,
      tierConfig: tierConfig ?? this.tierConfig,
      selectedAmount: selectedAmount ?? this.selectedAmount,
      selectedTenureDays: selectedTenureDays ?? this.selectedTenureDays,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      applicationId: applicationId ?? this.applicationId,
      errorMessage: errorMessage,
    );
  }
}

// ── Notifier ──
class LoanApplicationNotifier extends StateNotifier<LoanApplicationState> {
  LoanApplicationNotifier() : super(LoanApplicationState()) {
    _loadFromHive();
  }

  /// Load saved progress from Hive
  void _loadFromHive() {
    final savedStep = HiveStorage.getLoanStep();
    final tierLevel = HiveStorage.getCachedTierLevel();
    final tier = TierConstants.getTier(tierLevel);

    // Load all saved step data
    final Map<int, Map<String, dynamic>> savedData = {};
    for (int i = 1; i <= 11; i++) {
      final data = HiveStorage.getStepData(i);
      if (data != null) savedData[i] = data;
    }

    state = state.copyWith(
      currentStep: savedStep > 0 ? savedStep : 1,
      stepData: savedData,
      tierLevel: tierLevel,
      tierConfig: tier,
    );
  }

  /// Save step data and advance to next step
  Future<void> completeStep(int step, Map<String, dynamic> data) async {
    // Save to Hive for persistence
    await HiveStorage.saveStepData(step, data);
    await HiveStorage.saveLoanStep(step + 1);

    final updatedData = Map<int, Map<String, dynamic>>.from(state.stepData);
    updatedData[step] = data;

    state = state.copyWith(
      currentStep: step + 1,
      stepData: updatedData,
    );
  }

  /// Go back to previous step
  void goToStep(int step) {
    if (step >= 1 && step <= 11) {
      state = state.copyWith(currentStep: step);
    }
  }

  /// Update selected loan amount
  void setLoanAmount(double amount) {
    state = state.copyWith(selectedAmount: amount);
  }

  /// Update selected tenure
  void setTenureDays(int days) {
    state = state.copyWith(selectedTenureDays: days);
  }

  /// Update tier (after credit check)
  void updateTier(int tierLevel) {
    final tier = TierConstants.getTier(tierLevel);
    state = state.copyWith(
      tierLevel: tierLevel,
      tierConfig: tier,
    );
  }

  /// Set error
  void setError(String error) {
    state = state.copyWith(errorMessage: error);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset entire application (after disbursement or cancel)
  Future<void> resetApplication() async {
    await HiveStorage.clearLoanProgress();
    state = LoanApplicationState();
  }
}

// ── Provider ──
final loanApplicationProvider =
    StateNotifierProvider<LoanApplicationNotifier, LoanApplicationState>(
  (ref) => LoanApplicationNotifier(),
);
