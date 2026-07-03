import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models/lender_profile.dart';
import '../domain/models/investment_plan.dart';
import '../domain/models/lender_investment.dart';
import '../domain/models/investment_return.dart';
import '../domain/models/wallet_transaction.dart';
import '../domain/models/platform_health.dart';

/// Additive Local Mock Database for Investment Feature
class InvestRemoteDataSource {
  Box? _box;

  Future<Box> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox('lender_storage');
    }
    return _box!;
  }

  // ── Onboarding & Profile ──

  Future<LenderProfile?> getLenderProfile(String userId) async {
    final box = await _getBox();
    final data = box.get('profile_$userId');
    if (data == null) return null;
    return LenderProfile.fromJson(Map<String, dynamic>.from(data));
  }

  Future<LenderProfile> onboardLender(String userId, String riskProfile) async {
    final box = await _getBox();
    final profile = LenderProfile(
      id: 'lnd_${Random().nextInt(900000) + 100000}',
      userId: userId,
      riskProfile: riskProfile,
      riskDisclosureSigned: true,
      riskDisclosureSignedAt: DateTime.now(),
      lenderAgreementUrl: 'agreements/signed_lender_agreement_${userId}.pdf',
      walletBalance: 12500.0, // Pre-seeded wallet balance as per spec UI
      totalInvested: 50000.0, // Pre-seeded total invested
      totalReturnsEarned: 4200.0, // Pre-seeded total returns
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await box.put('profile_$userId', profile.toJson());

    // Pre-seed some mock data for the pre-seeded stats
    await _preSeedMockData(profile.id, userId);

    return profile;
  }

  // ── Investment Plans ──

  Future<List<InvestmentPlan>> getInvestmentPlans() async {
    final box = await _getBox();
    final list = box.get('investment_plans');
    if (list != null) {
      return List<Map<String, dynamic>>.from(list)
          .map((e) => InvestmentPlan.fromJson(e))
          .toList();
    }
    
    final defaultPlans = [
      InvestmentPlan(
        id: 1,
        planCode: 'STARTER',
        planName: 'Starter Plan',
        tenureMonths: 3,
        annualReturnRate: 10.0,
        monthlyReturnRate: 10.0 / 12,
        minInvestment: 5000.0,
        maxInvestment: 50000.0,
        earlyExitAllowed: true,
        earlyExitPenaltyPct: 2.0,
        description: 'Begin your lending journey with a short 3-month commitment.',
        highlights: const ['Monthly interest payouts', 'Exit after 30 days', '₹5,000 minimum'],
        displayOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      InvestmentPlan(
        id: 2,
        planCode: 'GROWTH',
        planName: 'Growth Plan',
        tenureMonths: 6,
        annualReturnRate: 12.0,
        monthlyReturnRate: 12.0 / 12,
        minInvestment: 10000.0,
        maxInvestment: 200000.0,
        earlyExitAllowed: true,
        earlyExitPenaltyPct: 2.0,
        description: 'Grow your money steadily over 6 months with higher returns.',
        highlights: const ['Monthly interest payouts', '12% annual returns', 'Ideal for salaried investors'],
        displayOrder: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      InvestmentPlan(
        id: 3,
        planCode: 'PREMIUM',
        planName: 'Premium Plan',
        tenureMonths: 12,
        annualReturnRate: 15.0,
        monthlyReturnRate: 15.0 / 12,
        minInvestment: 25000.0,
        maxInvestment: 1000000.0,
        earlyExitAllowed: false,
        earlyExitPenaltyPct: 0.0,
        description: 'Maximum returns for committed long-term investors.',
        highlights: const ['15% annual returns', 'Highest yield available', 'Locked for full tenure'],
        displayOrder: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    await box.put('investment_plans', defaultPlans.map((e) => e.toJson()).toList());
    return defaultPlans;
  }

  // ── Investments & Returns ──

  Future<List<LenderInvestment>> getPortfolio(String lenderId) async {
    final box = await _getBox();
    final list = box.get('investments_$lenderId', defaultValue: []);
    return List<Map<String, dynamic>>.from(list)
        .map((e) => LenderInvestment.fromJson(e))
        .toList();
  }

  Future<LenderInvestment> createInvestment({
    required String lenderId,
    required int planId,
    required double amount,
    required bool isAutoRenew,
  }) async {
    final box = await _getBox();
    final plans = await getInvestmentPlans();
    final plan = plans.firstWhere((p) => p.id == planId);

    // Load profile
    final profileData = box.get('profile_usr_mock'); // Default mockup userId
    if (profileData == null) throw Exception('Lender profile not found');
    var profile = LenderProfile.fromJson(Map<String, dynamic>.from(profileData));

    if (profile.walletBalance < amount) {
      throw Exception('Insufficient wallet balance');
    }

    final invId = 'inv_${Random().nextInt(900000) + 100000}';
    final invNum = 'INV-2026-${Random().nextInt(9000) + 1000}';
    final monthlyReturn = (amount * (plan.annualReturnRate / 100)) / 12;

    final investment = LenderInvestment(
      id: invId,
      lenderId: lenderId,
      planId: planId,
      investmentNumber: invNum,
      principalAmount: amount,
      annualReturnRate: plan.annualReturnRate,
      monthlyReturnAmount: monthlyReturn,
      tenureMonths: plan.tenureMonths,
      status: 'active',
      investedAt: DateTime.now(),
      maturesAt: DateTime.now().add(Duration(days: plan.tenureMonths * 30)),
      nextReturnDate: DateTime.now().add(const Duration(days: 30)),
      isAutoRenew: isAutoRenew,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save investment
    final list = box.get('investments_$lenderId', defaultValue: []);
    final updatedList = List<Map<String, dynamic>>.from(list)..add(investment.toJson());
    await box.put('investments_$lenderId', updatedList);

    // Generate returns schedule
    final returnsList = box.get('returns_$lenderId', defaultValue: []);
    final newReturns = <Map<String, dynamic>>[];
    for (int i = 1; i <= plan.tenureMonths; i++) {
      final retPeriodStart = DateTime.now().add(Duration(days: (i - 1) * 30));
      final retPeriodEnd = DateTime.now().add(Duration(days: i * 30));
      
      // Calculate TDS if applicable (annual interest > 5000)
      final annualEstInterest = profile.annualInterestEarned + (monthlyReturn * plan.tenureMonths);
      final isTds = annualEstInterest > 5000.0;
      final tds = isTds ? (monthlyReturn * 0.1) : 0.0;
      
      final ret = InvestmentReturn(
        id: 'ret_${Random().nextInt(900000) + 100000}',
        investmentId: invId,
        lenderId: lenderId,
        returnMonth: i,
        returnPeriodStart: retPeriodStart,
        returnPeriodEnd: retPeriodEnd,
        grossReturn: monthlyReturn,
        tdsDeducted: tds,
        netReturn: monthlyReturn - tds,
        status: 'scheduled',
        createdAt: DateTime.now(),
      );
      newReturns.add(ret.toJson());
    }
    final updatedReturns = List<Map<String, dynamic>>.from(returnsList)..addAll(newReturns);
    await box.put('returns_$lenderId', updatedReturns);

    // Deduct from wallet and update profile stats
    profile = profile.copyWith(
      walletBalance: profile.walletBalance - amount,
      totalInvested: profile.totalInvested + amount,
    );
    await box.put('profile_usr_mock', profile.toJson());

    // Record wallet transaction
    final txId = 'tx_${Random().nextInt(900000) + 100000}';
    final txn = WalletTransaction(
      id: txId,
      lenderId: lenderId,
      transactionType: 'investment_debit',
      amount: amount,
      balanceAfter: profile.walletBalance,
      referenceId: invId,
      referenceType: 'investment',
      description: 'Investment in ${plan.planName}',
      createdAt: DateTime.now(),
    );
    await _addWalletTransaction(lenderId, txn);

    return investment;
  }

  Future<LenderInvestment> requestEarlyExit(String lenderId, String investmentId) async {
    final box = await _getBox();
    final list = box.get('investments_$lenderId', defaultValue: []);
    final items = List<Map<String, dynamic>>.from(list);
    
    final idx = items.indexWhere((e) => e['id'] == investmentId);
    if (idx == -1) throw Exception('Investment not found');

    var inv = LenderInvestment.fromJson(items[idx]);
    if (inv.status != 'active') throw Exception('Investment is not active');

    final plans = await getInvestmentPlans();
    final plan = plans.firstWhere((p) => p.id == inv.planId);
    if (!plan.earlyExitAllowed) throw Exception('Early exit not allowed for this plan');

    // Calculate penalty
    final penalty = inv.principalAmount * (plan.earlyExitPenaltyPct / 100);
    final netReturnAmount = inv.principalAmount - penalty;

    inv = inv.copyWith(
      status: 'early_exit',
      earlyExitRequestedAt: DateTime.now(),
      earlyExitPenalty: penalty,
      netAmountOnExit: netReturnAmount,
    );

    items[idx] = inv.toJson();
    await box.put('investments_$lenderId', items);

    // Update wallet
    final profileData = box.get('profile_usr_mock');
    var profile = LenderProfile.fromJson(Map<String, dynamic>.from(profileData!));
    profile = profile.copyWith(
      walletBalance: profile.walletBalance + netReturnAmount,
      totalInvested: max(0.0, profile.totalInvested - inv.principalAmount),
    );
    await box.put('profile_usr_mock', profile.toJson());

    // Record transactions
    final txId = 'tx_${Random().nextInt(900000) + 100000}';
    final txn = WalletTransaction(
      id: txId,
      lenderId: lenderId,
      transactionType: 'principal_return',
      amount: inv.principalAmount,
      balanceAfter: profile.walletBalance - penalty,
      referenceId: investmentId,
      referenceType: 'investment',
      description: 'Principal return for early exit',
      createdAt: DateTime.now(),
    );
    await _addWalletTransaction(lenderId, txn);

    final penaltyTxId = 'tx_${Random().nextInt(900000) + 100000}';
    final penaltyTxn = WalletTransaction(
      id: penaltyTxId,
      lenderId: lenderId,
      transactionType: 'penalty_debit',
      amount: penalty,
      balanceAfter: profile.walletBalance,
      referenceId: investmentId,
      referenceType: 'investment',
      description: 'Early exit penalty (${plan.earlyExitPenaltyPct}%)',
      createdAt: DateTime.now(),
    );
    await _addWalletTransaction(lenderId, penaltyTxn);

    // Cancel all scheduled returns for this investment
    final returnsList = box.get('returns_$lenderId', defaultValue: []);
    final returns = List<Map<String, dynamic>>.from(returnsList);
    for (var r in returns) {
      if (r['investment_id'] == investmentId && r['status'] == 'scheduled') {
        r['status'] = 'failed'; // Mark cancelled
      }
    }
    await box.put('returns_$lenderId', returns);

    return inv;
  }

  // ── Wallet Deposits & Withdrawals ──

  Future<List<WalletTransaction>> getWalletTransactions(String lenderId) async {
    final box = await _getBox();
    final list = box.get('transactions_$lenderId', defaultValue: []);
    return List<Map<String, dynamic>>.from(list)
        .map((e) => WalletTransaction.fromJson(e))
        .toList().reversed.toList(); // Newest first
  }

  Future<double> depositFunds(String lenderId, double amount) async {
    final box = await _getBox();
    final profileData = box.get('profile_usr_mock');
    var profile = LenderProfile.fromJson(Map<String, dynamic>.from(profileData!));

    profile = profile.copyWith(walletBalance: profile.walletBalance + amount);
    await box.put('profile_usr_mock', profile.toJson());

    final txId = 'tx_${Random().nextInt(900000) + 100000}';
    final txn = WalletTransaction(
      id: txId,
      lenderId: lenderId,
      transactionType: 'deposit',
      amount: amount,
      balanceAfter: profile.walletBalance,
      gatewayRef: 'pay_${Random().nextInt(9000000) + 1000000}',
      description: 'Loaded funds via UPI',
      createdAt: DateTime.now(),
    );
    await _addWalletTransaction(lenderId, txn);

    return profile.walletBalance;
  }

  Future<double> withdrawFunds(String lenderId, double amount, String bankAccountId) async {
    final box = await _getBox();
    final profileData = box.get('profile_usr_mock');
    var profile = LenderProfile.fromJson(Map<String, dynamic>.from(profileData!));

    if (profile.walletBalance < amount) {
      throw Exception('Insufficient balance to withdraw');
    }

    profile = profile.copyWith(walletBalance: profile.walletBalance - amount);
    await box.put('profile_usr_mock', profile.toJson());

    final txId = 'tx_${Random().nextInt(900000) + 100000}';
    final txn = WalletTransaction(
      id: txId,
      lenderId: lenderId,
      transactionType: 'withdrawal',
      amount: amount,
      balanceAfter: profile.walletBalance,
      status: 'pending',
      description: 'Withdrawal requested to linked bank account',
      createdAt: DateTime.now(),
    );
    await _addWalletTransaction(lenderId, txn);

    return profile.walletBalance;
  }

  // ── Platform & Returns ──

  Future<List<InvestmentReturn>> getReturns(String lenderId) async {
    final box = await _getBox();
    final list = box.get('returns_$lenderId', defaultValue: []);
    return List<Map<String, dynamic>>.from(list)
        .map((e) => InvestmentReturn.fromJson(e))
        .toList();
  }

  Future<PlatformHealth> getPlatformHealth() async {
    final box = await _getBox();
    final data = box.get('platform_health');
    if (data != null) {
      return PlatformHealth.fromJson(Map<String, dynamic>.from(data));
    }
    final defaultHealth = PlatformHealth(
      id: 1,
      snapshotDate: DateTime.now(),
      totalActiveLoans: 2408,
      totalLoansDisbursed: 15480,
      totalAmountDisbursed: 48500000.0,
      npaPercentage: 1.8,
      avgBorrowerCreditScore: 680,
      onTimeRepaymentRate: 94.2,
      totalLendersActive: 412,
      totalFundsDeployed: 31200000.0,
      createdAt: DateTime.now(),
    );
    await box.put('platform_health', defaultHealth.toJson());
    return defaultHealth;
  }

  // ── Private Helpers ──

  Future<void> _addWalletTransaction(String lenderId, WalletTransaction txn) async {
    final box = await _getBox();
    final list = box.get('transactions_$lenderId', defaultValue: []);
    final updatedList = List<Map<String, dynamic>>.from(list)..add(txn.toJson());
    await box.put('transactions_$lenderId', updatedList);
  }

  Future<void> _preSeedMockData(String lenderId, String userId) async {
    final box = await _getBox();
    
    // Check if we already pre-seeded
    if (box.containsKey('preseeded_$lenderId')) return;

    // 1. Seed active investments
    final activeInvs = [
      LenderInvestment(
        id: 'inv_mock_1',
        lenderId: lenderId,
        planId: 2, // Growth Plan
        investmentNumber: 'INV-2026-9041',
        principalAmount: 25000.0,
        annualReturnRate: 12.0,
        monthlyReturnAmount: 250.0,
        tenureMonths: 6,
        status: 'active',
        investedAt: DateTime.now().subtract(const Duration(days: 120)),
        maturesAt: DateTime.now().add(const Duration(days: 60)),
        nextReturnDate: DateTime.now().add(const Duration(days: 15)),
        totalReturnsPaid: 1000.0,
        returnsPaidCount: 4,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        updatedAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      LenderInvestment(
        id: 'inv_mock_2',
        lenderId: lenderId,
        planId: 3, // Premium Plan
        investmentNumber: 'INV-2026-1048',
        principalAmount: 25000.0,
        annualReturnRate: 15.0,
        monthlyReturnAmount: 312.5,
        tenureMonths: 12,
        status: 'active',
        investedAt: DateTime.now().subtract(const Duration(days: 60)),
        maturesAt: DateTime.now().add(const Duration(days: 300)),
        nextReturnDate: DateTime.now().add(const Duration(days: 20)),
        totalReturnsPaid: 625.0,
        returnsPaidCount: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 60)),
      )
    ];

    await box.put('investments_$lenderId', activeInvs.map((e) => e.toJson()).toList());

    // 2. Seed returns schedule
    final returns = <InvestmentReturn>[];
    
    // Growth returns
    for (int i = 1; i <= 6; i++) {
      final isPaid = i <= 4;
      returns.add(InvestmentReturn(
        id: 'ret_growth_$i',
        investmentId: 'inv_mock_1',
        lenderId: lenderId,
        returnMonth: i,
        returnPeriodStart: DateTime.now().subtract(Duration(days: (5 - i) * 30)),
        returnPeriodEnd: DateTime.now().subtract(Duration(days: (4 - i) * 30)),
        grossReturn: 250.0,
        netReturn: 250.0,
        status: isPaid ? 'paid' : 'scheduled',
        paidAt: isPaid ? DateTime.now().subtract(Duration(days: (5 - i) * 30)) : null,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ));
    }

    // Premium returns
    for (int i = 1; i <= 12; i++) {
      final isPaid = i <= 2;
      returns.add(InvestmentReturn(
        id: 'ret_premium_$i',
        investmentId: 'inv_mock_2',
        lenderId: lenderId,
        returnMonth: i,
        returnPeriodStart: DateTime.now().subtract(Duration(days: (3 - i) * 30)),
        returnPeriodEnd: DateTime.now().subtract(Duration(days: (2 - i) * 30)),
        grossReturn: 312.5,
        netReturn: 312.5,
        status: isPaid ? 'paid' : 'scheduled',
        paidAt: isPaid ? DateTime.now().subtract(Duration(days: (3 - i) * 30)) : null,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ));
    }

    await box.put('returns_$lenderId', returns.map((e) => e.toJson()).toList());

    // 3. Seed historical transactions
    final txs = [
      WalletTransaction(
        id: 'tx_init_dep',
        lenderId: lenderId,
        transactionType: 'deposit',
        amount: 60000.0,
        balanceAfter: 60000.0,
        gatewayRef: 'pay_init_1',
        description: 'Initial Deposit via Razorpay',
        createdAt: DateTime.now().subtract(const Duration(days: 125)),
      ),
      WalletTransaction(
        id: 'tx_inv_1',
        lenderId: lenderId,
        transactionType: 'investment_debit',
        amount: 25000.0,
        balanceAfter: 35000.0,
        referenceId: 'inv_mock_1',
        referenceType: 'investment',
        description: 'Investment in Growth Plan',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      WalletTransaction(
        id: 'tx_inv_2',
        lenderId: lenderId,
        transactionType: 'investment_debit',
        amount: 25000.0,
        balanceAfter: 10000.0,
        referenceId: 'inv_mock_2',
        referenceType: 'investment',
        description: 'Investment in Premium Plan',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      WalletTransaction(
        id: 'tx_ret_1',
        lenderId: lenderId,
        transactionType: 'return_credit',
        amount: 250.0,
        balanceAfter: 10250.0,
        referenceId: 'ret_growth_1',
        referenceType: 'return',
        description: 'Monthly Interest Payout - Growth Plan',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      WalletTransaction(
        id: 'tx_ret_2',
        lenderId: lenderId,
        transactionType: 'return_credit',
        amount: 250.0,
        balanceAfter: 10500.0,
        referenceId: 'ret_growth_2',
        referenceType: 'return',
        description: 'Monthly Interest Payout - Growth Plan',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      WalletTransaction(
        id: 'tx_ret_3',
        lenderId: lenderId,
        transactionType: 'return_credit',
        amount: 562.5, // 250 + 312.5
        balanceAfter: 11062.5,
        description: 'Monthly Payout (Growth + Premium)',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      WalletTransaction(
        id: 'tx_ret_4',
        lenderId: lenderId,
        transactionType: 'return_credit',
        amount: 562.5, // 250 + 312.5
        balanceAfter: 12500.0,
        description: 'Monthly Payout (Growth + Premium)',
        createdAt: DateTime.now().subtract(const Duration(seconds: 10)),
      ),
    ];

    await box.put('transactions_$lenderId', txs.map((e) => e.toJson()).toList());
    await box.put('preseeded_$lenderId', true);
  }

  // ── Admin Operations ──

  Future<void> updateInvestmentPlan(InvestmentPlan plan) async {
    final box = await _getBox();
    final plans = await getInvestmentPlans();
    final idx = plans.indexWhere((p) => p.id == plan.id);
    if (idx != -1) {
      plans[idx] = plan;
      await box.put('investment_plans', plans.map((e) => e.toJson()).toList());
    }
  }

  Future<void> updatePlatformHealth(PlatformHealth metrics) async {
    final box = await _getBox();
    await box.put('platform_health', metrics.toJson());
  }

  Future<List<WalletTransaction>> getAllPendingWithdrawals() async {
    final box = await _getBox();
    final lenderId = box.get('profile_usr_mock')?['id'] ?? 'lnd_mock';
    final list = box.get('transactions_$lenderId', defaultValue: []);
    return List<Map<String, dynamic>>.from(list)
        .map((e) => WalletTransaction.fromJson(e))
        .where((tx) => tx.transactionType == 'withdrawal' && tx.status == 'pending')
        .toList();
  }

  Future<void> updateWithdrawalStatus(String txId, String status, String? utr) async {
    final box = await _getBox();
    final lenderId = box.get('profile_usr_mock')?['id'] ?? 'lnd_mock';
    final list = box.get('transactions_$lenderId', defaultValue: []);
    final items = List<Map<String, dynamic>>.from(list);

    final idx = items.indexWhere((e) => e['id'] == txId);
    if (idx != -1) {
      final oldTx = WalletTransaction.fromJson(items[idx]);
      final newTx = WalletTransaction(
        id: oldTx.id,
        lenderId: oldTx.lenderId,
        transactionType: oldTx.transactionType,
        amount: oldTx.amount,
        balanceAfter: oldTx.balanceAfter,
        status: status,
        referenceId: oldTx.referenceId,
        referenceType: oldTx.referenceType,
        gatewayRef: utr,
        description: status == 'success'
            ? 'Withdrawal completed. UTR: $utr'
            : 'Withdrawal rejected.',
        createdAt: oldTx.createdAt,
      );
      items[idx] = newTx.toJson();
      await box.put('transactions_$lenderId', items);
    }
  }
}
