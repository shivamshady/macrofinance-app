import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency_formatter.dart';

/// Animated currency amount display with count-up effect
class AmountDisplay extends StatelessWidget {
  final double amount;
  final bool compact;
  final bool showDecimals;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;
  final bool animate;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.compact = false,
    this.showDecimals = false,
    this.style,
    this.prefix,
    this.suffix,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    if (animate) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: amount),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return _buildText(value);
        },
      );
    }

    return _buildText(amount);
  }

  Widget _buildText(double value) {
    String formatted;
    if (compact) {
      formatted = CurrencyFormatter.formatCompact(value);
    } else if (showDecimals) {
      formatted = CurrencyFormatter.formatWithDecimals(value);
    } else {
      formatted = CurrencyFormatter.format(value);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (prefix != null)
          Text(
            '$prefix ',
            style: AppTextStyles.bodySmall,
          ),
        Text(
          formatted,
          style: style ?? AppTextStyles.amountLarge,
        ),
        if (suffix != null)
          Text(
            ' $suffix',
            style: AppTextStyles.bodySmall,
          ),
      ],
    );
  }
}
