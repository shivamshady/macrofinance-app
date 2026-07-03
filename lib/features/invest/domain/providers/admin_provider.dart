import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/investment_plan.dart';
import '../../domain/models/platform_health.dart';
import '../../domain/models/wallet_transaction.dart';
import 'lender_profile_provider.dart';
import 'investment_plans_provider.dart';
import 'wallet_provider.dart';
import 'platform_health_provider.dart';

class AdminState {
  final List<WalletTransaction> pendingWithdrawals;
  final bool isLoading;
  final String? error;

  AdminState({
    required this.pendingWithdrawals,
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    List<WalletTransaction>? pendingWithdrawals,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      pendingWithdrawals: pendingWithdrawals ?? this.pendingWithdrawals,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final Ref _ref;

  AdminNotifier(this._ref) : super(AdminState(pendingWithdrawals: [])) {
    loadPendingWithdrawals();
  }

  Future<void> loadPendingWithdrawals() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = _ref.read(investRepositoryProvider);
      final withdrawals = await repository.getAllPendingWithdrawals();
      state = state.copyWith(pendingWithdrawals: withdrawals, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> approveWithdrawal(String txId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = _ref.read(investRepositoryProvider);
      final utr = 'UTR${Random().nextInt(90000000) + 10000000}';
      await repository.updateWithdrawalStatus(txId, 'success', utr);
      await loadPendingWithdrawals();
      
      // Invalidate profile & wallet states so UI updates lender balances instantly
      _ref.invalidate(walletProvider);
      _ref.invalidate(lenderProfileProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> rejectWithdrawal(String txId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = _ref.read(investRepositoryProvider);
      await repository.updateWithdrawalStatus(txId, 'failed', null);
      await loadPendingWithdrawals();
      
      // Invalidate profile & wallet states so UI updates lender balances instantly
      _ref.invalidate(walletProvider);
      _ref.invalidate(lenderProfileProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updatePlan(InvestmentPlan plan) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = _ref.read(investRepositoryProvider);
      await repository.updateInvestmentPlan(plan);
      _ref.invalidate(investmentPlansProvider);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateHealth(PlatformHealth health) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = _ref.read(investRepositoryProvider);
      await repository.updatePlatformHealth(health);
      _ref.invalidate(platformHealthProvider);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref);
});
