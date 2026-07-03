import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/invest_repository.dart';
import '../models/lender_profile.dart';

final investRepositoryProvider = Provider<InvestRepository>((ref) => InvestRepository());

class LenderProfileState {
  final bool isLoading;
  final LenderProfile? profile;
  final String? errorMessage;

  const LenderProfileState({
    this.isLoading = false,
    this.profile,
    this.errorMessage,
  });

  LenderProfileState copyWith({
    bool? isLoading,
    LenderProfile? profile,
    String? errorMessage,
  }) {
    return LenderProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
    );
  }
}

class LenderProfileNotifier extends StateNotifier<LenderProfileState> {
  final InvestRepository _repository;
  final String _mockUserId = 'usr_mock'; // Mock user session identifier

  LenderProfileNotifier(this._repository) : super(const LenderProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _repository.getLenderProfile(_mockUserId);
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> onboardLender(String riskProfile) async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _repository.onboardLender(_mockUserId, riskProfile);
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> refreshProfile() async {
    try {
      final profile = await _repository.getLenderProfile(_mockUserId);
      state = state.copyWith(profile: profile);
    } catch (_) {}
  }
}

final lenderProfileProvider = StateNotifierProvider<LenderProfileNotifier, LenderProfileState>((ref) {
  final repository = ref.watch(investRepositoryProvider);
  return LenderProfileNotifier(repository);
});
