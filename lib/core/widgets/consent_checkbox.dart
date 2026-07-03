import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// RBI-compliant consent checkbox with linked terms
class ConsentCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String text;
  final String? linkText;
  final VoidCallback? onLinkTap;
  final bool isRequired;

  const ConsentCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.text,
    this.linkText,
    this.onLinkTap,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: value ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? AppColors.primary : AppColors.textTertiary,
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: AppColors.textOnPrimary,
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            // Text + Link
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  children: [
                    if (isRequired)
                      const TextSpan(
                        text: '* ',
                        style: TextStyle(color: AppColors.error),
                      ),
                    TextSpan(text: text),
                    if (linkText != null) ...[
                      const TextSpan(text: ' '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: onLinkTap,
                          child: Text(
                            linkText!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
