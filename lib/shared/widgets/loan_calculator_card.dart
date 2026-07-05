import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class LoanCalculatorCard extends StatelessWidget {
  final double loanAmount;
  final int tenureDays;
  final double interestRateMonthly;
  final double processingFeePct;
  final double insurancePct;
  final double gstPct;

  const LoanCalculatorCard({
    super.key,
    required this.loanAmount,
    required this.tenureDays,
    required this.interestRateMonthly,
    required this.processingFeePct,
    required this.insurancePct,
    required this.gstPct,
  });

  @override
  Widget build(BuildContext context) {
    final processingFee = loanAmount * (processingFeePct / 100);
    final gstOnFee = processingFee * (gstPct / 100);
    final insurance = loanAmount * (insurancePct / 100);
    final totalFees = processingFee + gstOnFee + insurance;
    final youReceive = loanAmount - totalFees;
    
    final interestAmount = loanAmount * (interestRateMonthly / 100) * (tenureDays / 30);
    final totalRepayable = loanAmount + interestAmount;
    final dailyInterest = interestAmount / tenureDays;
    final dueDate = DateTime.now().add(Duration(days: tenureDays));

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRow('Loan Amount', loanAmount, isBold: true),
            const SizedBox(height: 8),
            _buildRow('Processing Fee (${processingFeePct}%)', processingFee),
            const SizedBox(height: 8),
            _buildRow('GST on Fee (${gstPct}%)', gstOnFee),
            const SizedBox(height: 8),
            _buildRow('Insurance (${insurancePct}%)', insurance),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(color: AppColors.border, thickness: 1),
            ),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildRow('YOU RECEIVE', youReceive, 
                  isBold: true, color: AppColors.success),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(color: AppColors.border, thickness: 1),
            ),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildRow('Total Repayable', totalRepayable, 
                  isBold: true, color: AppColors.primary),
            ),
            
            const SizedBox(height: 12),
            _buildRow('Interest (${interestRateMonthly}%/mo)', interestAmount),
            const SizedBox(height: 8),
            _buildRow('Daily Interest', dailyInterest),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Due Date',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(dueDate),
                  style: const TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w600, 
                    color: AppColors.textPrimary
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, double amount, {bool isBold = false, Color? color}) {
    final formatter = NumberFormat('#,##,###.00', 'en_IN');
    final style = TextStyle(
      fontSize: isBold ? 15 : 14,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
      color: color ?? (isBold ? AppColors.textPrimary : AppColors.textSecondary),
    );
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Row(
        key: ValueKey<String>('$label$amount'),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('₹${formatter.format(amount)}', style: style),
        ],
      ),
    );
  }
}
