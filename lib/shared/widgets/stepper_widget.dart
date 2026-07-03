import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Loan application stepper widget
/// Colored circles: green = done, blue = current, grey = upcoming
class LoanStepperWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepNames;

  const LoanStepperWidget({
    super.key,
    required this.currentStep,
    this.totalSteps = AppConstants.totalLoanSteps,
    this.stepNames,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final names = stepNames ?? AppConstants.loanStepNames;

    return Column(
      children: [
        // Step circles row
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: totalSteps,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final stepNum = index + 1;
              final isCompleted = stepNum < currentStep;
              final isCurrent = stepNum == currentStep;

              return Row(
                children: [
                  // Circle
                  _StepCircle(
                    stepNumber: stepNum,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    isDark: isDark,
                  ),
                  // Connector line (not after last)
                  if (index < totalSteps - 1)
                    Container(
                      width: 16,
                      height: 2,
                      color: isCompleted
                          ? AppColors.accent
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Current step label
        if (currentStep >= 1 && currentStep <= names.length)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Step $currentStep of $totalSteps',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '— ${names[currentStep - 1]}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int stepNumber;
  final bool isCompleted;
  final bool isCurrent;
  final bool isDark;

  const _StepCircle({
    required this.stepNumber,
    required this.isCompleted,
    required this.isCurrent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;

    if (isCompleted) {
      bgColor = AppColors.accent;
      textColor = Colors.white;
      borderColor = AppColors.accent;
    } else if (isCurrent) {
      bgColor = AppColors.primary;
      textColor = Colors.white;
      borderColor = AppColors.primary;
    } else {
      bgColor = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
      textColor = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
      borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    }

    return Semantics(
      label: 'Step $stepNumber${isCompleted ? ', completed' : isCurrent ? ', current' : ', upcoming'}',
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(
          child: isCompleted
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : Text(
                  '$stepNumber',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}
