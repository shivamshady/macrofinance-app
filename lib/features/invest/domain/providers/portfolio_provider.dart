import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/invest_repository.dart';
import '../models/lender_investment.dart';
import '../models/investment_return.dart';
import 'lender_profile_provider.dart';
import 'wallet_provider.dart';

class PortfolioState {
  final bool isLoading;
  final List<LenderInvestment> investments;
  final List<InvestmentReturn> returns;
  final String? errorMessage;

  const PortfolioState({
    this.isLoading = false,
    this.investments = const [],
    this.returns = const [],
    this.errorMessage,
  });

  PortfolioState copyWith({
    bool? isLoading,
    List<LenderInvestment>? investments,
    List<InvestmentReturn>? returns,
    String? errorMessage,
  }) {
    return PortfolioState(
      isLoading: isLoading ?? this.isLoading,
      investments: investments ?? this.investments,
      returns: returns ?? this.returns,
      errorMessage: errorMessage,
    );
  }
}

class PortfolioNotifier extends StateNotifier<PortfolioState> {
  final InvestRepository _repository;
  final Ref _ref;

  PortfolioNotifier(this._repository, this._ref) : super(const PortfolioState()) {
    loadPortfolio();
  }

  String? _getLenderId() {
    return _ref.read(lenderProfileProvider).profile?.id;
  }

  Future<void> loadPortfolio() async {
    final lenderId = _getLenderId();
    if (lenderId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final investments = await _repository.getPortfolio(lenderId);
      final returns = await _repository.getReturns(lenderId);
      state = state.copyWith(
        investments: investments,
        returns: returns,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<LenderInvestment> createInvestment({
    required int planId,
    required double amount,
    required bool isAutoRenew,
  }) async {
    final lenderId = _getLenderId();
    if (lenderId == null) throw Exception('Lender profile not onboarded');

    state = state.copyWith(isLoading: true);
    try {
      final investment = await _repository.createInvestment(
        lenderId: lenderId,
        planId: planId,
        amount: amount,
        isAutoRenew: isAutoRenew,
      );
      
      // Reload portfolio, profile, and wallet balance
      await loadPortfolio();
      await _ref.read(lenderProfileProvider.notifier).refreshProfile();
      await _ref.read(walletProvider.notifier).loadWalletData();
      
      return investment;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> requestEarlyExit(String investmentId) async {
    final lenderId = _getLenderId();
    if (lenderId == null) throw Exception('Lender profile not onboarded');

    state = state.copyWith(isLoading: true);
    try {
      await _repository.requestEarlyExit(lenderId, investmentId);
      
      // Reload portfolio, profile, and wallet balance
      await loadPortfolio();
      await _ref.read(lenderProfileProvider.notifier).refreshProfile();
      await _ref.read(walletProvider.notifier).loadWalletData();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      rethrow;
    }
  }
}

final portfolioProvider = StateNotifierProvider<PortfolioNotifier, PortfolioState>((ref) {
  final repository = ref.watch(investRepositoryProvider);
  return PortfolioNotifier(repository, ref);
});
