import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/invest_repository.dart';
import '../models/wallet_transaction.dart';
import 'lender_profile_provider.dart';

class WalletState {
  final bool isLoading;
  final List<WalletTransaction> transactions;
  final String? errorMessage;

  const WalletState({
    this.isLoading = false,
    this.transactions = const [],
    this.errorMessage,
  });

  WalletState copyWith({
    bool? isLoading,
    List<WalletTransaction>? transactions,
    String? errorMessage,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final InvestRepository _repository;
  final Ref _ref;

  WalletNotifier(this._repository, this._ref) : super(const WalletState()) {
    loadWalletData();
  }

  String? _getLenderId() {
    return _ref.read(lenderProfileProvider).profile?.id;
  }

  Future<void> loadWalletData() async {
    final lenderId = _getLenderId();
    if (lenderId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final txs = await _repository.getWalletTransactions(lenderId);
      state = state.copyWith(transactions: txs, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> addFunds(double amount) async {
    final lenderId = _getLenderId();
    if (lenderId == null) throw Exception('Lender profile not onboarded');

    state = state.copyWith(isLoading: true);
    try {
      await _repository.depositFunds(lenderId, amount);
      await loadWalletData();
      await _ref.read(lenderProfileProvider.notifier).refreshProfile();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<void> withdrawFunds(double amount, String bankAccountId) async {
    final lenderId = _getLenderId();
    if (lenderId == null) throw Exception('Lender profile not onboarded');

    state = state.copyWith(isLoading: true);
    try {
      await _repository.withdrawFunds(lenderId, amount, bankAccountId);
      await loadWalletData();
      await _ref.read(lenderProfileProvider.notifier).refreshProfile();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      rethrow;
    }
  }
}

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  final repository = ref.watch(investRepositoryProvider);
  return WalletNotifier(repository, ref);
});
