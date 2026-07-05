import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

enum AmountSize { small, medium, large }

class AmountDisplay extends StatelessWidget {
  final double amount;
  final AmountSize size;
  final Color? color;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.size = AmountSize.medium,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##,###.##', 'en_IN');
    final formattedAmount = currencyFormatter.format(amount);

    double mainSize;
    double symbolSize;
    
    switch (size) {
      case AmountSize.small:
        mainSize = 16.0;
        symbolSize = 12.0;
        break;
      case AmountSize.medium:
        mainSize = 22.0;
        symbolSize = 16.0;
        break;
      case AmountSize.large:
        mainSize = 30.0;
        symbolSize = 22.0;
        break;
    }

    final effectiveColor = color ?? AppColors.textPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '₹',
          style: TextStyle(
            fontSize: symbolSize,
            fontWeight: FontWeight.w600,
            color: effectiveColor,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          formattedAmount,
          style: TextStyle(
            fontSize: mainSize,
            fontWeight: FontWeight.w700,
            color: effectiveColor,
          ),
        ),
      ],
    );
  }
}
