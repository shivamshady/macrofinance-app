import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../domain/providers/lender_profile_provider.dart';
import '../domain/providers/wallet_provider.dart';
import '../domain/models/wallet_transaction.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<WalletTransaction> _filterTransactions(List<WalletTransaction> list) {
    final idx = _tabController.index;
    switch (idx) {
      case 1: // Deposits
        return list.where((tx) => tx.transactionType == 'deposit').toList();
      case 2: // Returns
        return list.where((tx) => tx.transactionType == 'return_credit' || tx.transactionType == 'principal_return').toList();
      case 3: // Investments
        return list.where((tx) => tx.transactionType == 'investment_debit').toList();
      case 4: // Withdrawals
        return list.where((tx) => tx.transactionType == 'withdrawal').toList();
      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(lenderProfileProvider);
    final walletState = ref.watch(walletProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (profileState.isLoading || profileState.profile == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final profile = profileState.profile!;
    final filteredTxs = _filterTransactions(walletState.transactions);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          onPressed: () => context.go('/invest/dashboard'),
        ),
        title: Text(
          'Lender Wallet',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Balance Hero Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              child: Column(
                children: [
                  Text('Total Wallet Balance', style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Text(
                    '₹${CurrencyFormatter.format(profile.walletBalance)}',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => context.go('/invest/wallet/add'),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Add Funds'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.lightBorder),
                            ),
                            onPressed: () => context.go('/invest/wallet/withdraw'),
                            icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                            label: const Text('Withdraw'),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Horizontal Tab Filter List
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? AppColors.darkTextTertiary : AppColors.lightTextSecondary,
              labelStyle: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
              unselectedLabelStyle: AppTextStyles.titleSmall,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Deposits'),
                Tab(text: 'Returns'),
                Tab(text: 'Investments'),
                Tab(text: 'Withdrawals'),
              ],
            ),

            // Ledger Entries List
            Expanded(
              child: walletState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : filteredTxs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.lightTextTertiary),
                              const SizedBox(height: 10),
                              Text('No transactions found', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          itemCount: filteredTxs.length,
                          itemBuilder: (context, index) {
                            final tx = filteredTxs[index];
                            return _buildTransactionItem(context, tx);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, WalletTransaction tx) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Type visual mapping
    IconData icon = Icons.payment;
    Color color = AppColors.primary;
    String prefix = '';
    String label = '';

    if (tx.transactionType == 'deposit' || tx.transactionType == 'return_credit' || tx.transactionType == 'principal_return' || tx.transactionType == 'referral_bonus' || tx.transactionType == 'refund') {
      icon = tx.transactionType == 'deposit'
          ? Icons.arrow_downward_rounded
          : (tx.transactionType == 'referral_bonus' ? Icons.card_giftcard_outlined : Icons.add_circle_outline);
      color = AppColors.accent;
      prefix = '+';
    } else {
      icon = tx.transactionType == 'withdrawal'
          ? Icons.arrow_upward_rounded
          : Icons.remove_circle_outline;
      color = AppColors.error;
      prefix = '-';
    }

    switch (tx.transactionType) {
      case 'deposit':
        label = 'Deposit';
        break;
      case 'withdrawal':
        label = 'Withdrawal';
        break;
      case 'investment_debit':
        label = 'Investment locked';
        break;
      case 'return_credit':
        label = 'Interest payout';
        break;
      case 'principal_return':
        label = 'Principal refund';
        break;
      case 'tds_deduction':
        label = 'TDS Deduction';
        break;
      case 'referral_bonus':
        label = 'Referral Bonus';
        break;
      case 'penalty_debit':
        label = 'Exit Penalty';
        break;
      default:
        label = 'Transaction';
    }

    final dateStr = '${tx.createdAt.day} ${_getMonthName(tx.createdAt.month)} ${tx.createdAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.titleSmall),
                const SizedBox(height: 2),
                Text(tx.description ?? '', style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$prefix₹${CurrencyFormatter.format(tx.amount)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(dateStr, style: AppTextStyles.caption.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
