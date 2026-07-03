import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Gradient button with ripple effect and loading state
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;
  final LinearGradient? gradient;
  final double height;
  final double borderRadius;
  final IconData? icon;
  final Widget? prefix;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.gradient,
    this.height = 56,
    this.borderRadius = 14,
    this.icon,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    final buttonGradient = gradient ?? AppColors.primaryGradient;
    final isEnabled = onPressed != null && !isLoading;

    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: height,
      decoration: BoxDecoration(
        gradient: isEnabled ? buttonGradient : null,
        color: isEnabled ? null : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withValues(alpha: 0.15),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textOnPrimary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize:
                        isExpanded ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (prefix != null) ...[
                        prefix!,
                        const SizedBox(width: 8),
                      ],
                      if (icon != null) ...[
                        Icon(
                          icon,
                          color: isEnabled
                              ? AppColors.textOnPrimary
                              : AppColors.textTertiary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: AppTextStyles.buttonText.copyWith(
                          color: isEnabled
                              ? AppColors.textOnPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
