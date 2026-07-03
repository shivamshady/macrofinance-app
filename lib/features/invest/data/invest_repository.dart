import '../domain/models/lender_profile.dart';
import '../domain/models/investment_plan.dart';
import '../domain/models/lender_investment.dart';
import '../domain/models/investment_return.dart';
import '../domain/models/wallet_transaction.dart';
import '../domain/models/platform_health.dart';
import 'invest_remote_datasource.dart';

class InvestRepository {
  final InvestRemoteDataSource _dataSource;

  InvestRepository({InvestRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? InvestRemoteDataSource();

  Future<LenderProfile?> getLenderProfile(String userId) {
    return _dataSource.getLenderProfile(userId);
  }

  Future<LenderProfile> onboardLender(String userId, String riskProfile) {
    return _dataSource.onboardLender(userId, riskProfile);
  }

  Future<List<InvestmentPlan>> getInvestmentPlans() {
    return _dataSource.getInvestmentPlans();
  }

  Future<List<LenderInvestment>> getPortfolio(String lenderId) {
    return _dataSource.getPortfolio(lenderId);
  }

  Future<LenderInvestment> createInvestment({
    required String lenderId,
    required int planId,
    required double amount,
    required bool isAutoRenew,
  }) {
    return _dataSource.createInvestment(
      lenderId: lenderId,
      planId: planId,
      amount: amount,
      isAutoRenew: isAutoRenew,
    );
  }

  Future<LenderInvestment> requestEarlyExit(String lenderId, String investmentId) {
    return _dataSource.requestEarlyExit(lenderId, investmentId);
  }

  Future<List<WalletTransaction>> getWalletTransactions(String lenderId) {
    return _dataSource.getWalletTransactions(lenderId);
  }

  Future<double> depositFunds(String lenderId, double amount) {
    return _dataSource.depositFunds(lenderId, amount);
  }

  Future<double> withdrawFunds(String lenderId, double amount, String bankAccountId) {
    return _dataSource.withdrawFunds(lenderId, amount, bankAccountId);
  }

  Future<List<InvestmentReturn>> getReturns(String lenderId) {
    return _dataSource.getReturns(lenderId);
  }

  Future<PlatformHealth> getPlatformHealth() {
    return _dataSource.getPlatformHealth();
  }

  Future<void> updateInvestmentPlan(InvestmentPlan plan) {
    return _dataSource.updateInvestmentPlan(plan);
  }

  Future<void> updatePlatformHealth(PlatformHealth metrics) {
    return _dataSource.updatePlatformHealth(metrics);
  }

  Future<List<WalletTransaction>> getAllPendingWithdrawals() {
    return _dataSource.getAllPendingWithdrawals();
  }

  Future<void> updateWithdrawalStatus(String txId, String status, String? utr) {
    return _dataSource.updateWithdrawalStatus(txId, status, utr);
  }
}
