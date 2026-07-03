import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/providers/admin_provider.dart';
import '../../domain/models/wallet_transaction.dart';

class AdminWithdrawalsScreen extends ConsumerStatefulWidget {
  const AdminWithdrawalsScreen({super.key});

  @override
  ConsumerState<AdminWithdrawalsScreen> createState() => _AdminWithdrawalsScreenState();
}

class _AdminWithdrawalsScreenState extends ConsumerState<AdminWithdrawalsScreen> {
  String? _processingTxId;

  void _onApprove(WalletTransaction tx) async {
    setState(() => _processingTxId = tx.id);
    
    // Simulate gateway handshakes
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      await ref.read(adminProvider.notifier).approveWithdrawal(tx.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Withdrawal of ₹${CurrencyFormatter.format(tx.amount)} approved successfully.'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processingTxId = null);
      }
    }
  }

  void _onReject(WalletTransaction tx) async {
    setState(() => _processingTxId = tx.id);
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      await ref.read(adminProvider.notifier).rejectWithdrawal(tx.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Withdrawal of ₹${CurrencyFormatter.format(tx.amount)} rejected.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processingTxId = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
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
          'Withdrawal Approvals',
          style: AppTextStyles.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: adminState.isLoading && _processingTxId == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : adminState.pendingWithdrawals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.accent),
                        const SizedBox(height: 14),
                        Text('All clear!', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Text('No pending withdrawal requests.', style: AppTextStyles.caption),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: adminState.pendingWithdrawals.length,
                    itemBuilder: (context, index) {
                      final tx = adminState.pendingWithdrawals[index];
                      final isProcessing = _processingTxId == tx.id;
                      final dateStr = '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: isDark ? Border.all(color: AppColors.darkBorder) : null,
                          boxShadow: isDark ? null : AppColors.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Lender ID: ${tx.lenderId}', style: AppTextStyles.titleSmall),
                                    const SizedBox(height: 2),
                                    Text('Requested: $dateStr', style: AppTextStyles.caption),
                                  ],
                                ),
                                Text(
                                  '₹${CurrencyFormatter.format(tx.amount)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Text(
                              'Linked Account: HDFC Bank ending in •••• 4892',
                              style: AppTextStyles.caption.copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 16),
                            
                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isProcessing)
                                  const SizedBox(
                                    height: 36,
                                    width: 36,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                  )
                                else ...[
                                  TextButton(
                                    onPressed: () => _onReject(tx),
                                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                    child: const Text('Reject'),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: () => _onApprove(tx),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accent,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                    child: const Text('Approve Payout'),
                                  ),
                                ],
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
