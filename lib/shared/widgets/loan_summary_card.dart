import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/tier_constants.dart';

/// Loan summary card — real-time fee breakdown
/// Used in Step 7 (Loan Offer) and loan detail screens
class LoanSummaryCard extends StatelessWidget {
  final double loanAmount;
  final int tenureDays;
  final int tierLevel;
  final DateTime? dueDate;

  const LoanSummaryCard({
    super.key,
    required this.loanAmount,
    required this.tenureDays,
    required this.tierLevel,
    this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final tier = TierConstants.getTier(tierLevel);
    final fees = tier.calculateFees(loanAmount, tenureDays);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : AppColors.cardShadow,
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fee Breakdown',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildRow(
            context,
            'Loan Amount',
            _formatCurrency(fees.loanAmount),
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildRow(
            context,
            'Processing Fee (${tier.processingFeePct}%)',
            '- ${_formatCurrency(fees.processingFee)}',
            isDark: isDark,
            valueColor: AppColors.error,
          ),
          _buildRow(
            context,
            'GST on Fee (${tier.gstPct}%)',
            '- ${_formatCurrency(fees.gstOnFee)}',
            isDark: isDark,
            valueColor: AppColors.error,
          ),
          _buildRow(
            context,
            'Insurance (${tier.insuranceFeePct}%)',
            '- ${_formatCurrency(fees.insuranceFee)}',
            isDark: isDark,
            valueColor: AppColors.error,
          ),
          _buildDivider(isDark),
          _buildRow(
            context,
            'You Receive',
            _formatCurrency(fees.netDisbursement),
            isDark: isDark,
            isBold: true,
            valueColor: AppColors.accent,
          ),
          _buildRow(
            context,
            'Total Repayable',
            _formatCurrency(fees.totalRepayable),
            isDark: isDark,
            isBold: true,
          ),
          _buildRow(
            context,
            'Daily Interest',
            _formatCurrency(fees.dailyInterest),
            isDark: isDark,
          ),

          if (dueDate != null) ...[
            _buildDivider(isDark),
            _buildRow(
              context,
              'Due Date',
              '${dueDate!.day.toString().padLeft(2, '0')}/${dueDate!.month.toString().padLeft(2, '0')}/${dueDate!.year}',
              isDark: isDark,
              isBold: true,
              valueColor: AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    String label,
    String value, {
    required bool isDark,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ??
                  (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(2);
    final parts = formatted.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '₹$intPart.${parts[1]}';
  }
}
