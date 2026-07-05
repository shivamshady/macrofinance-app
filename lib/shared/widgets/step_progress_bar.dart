import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StepProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final List<String> labels;
  final ValueChanged<int>? onStepTapped;

  const StepProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.labels,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalSteps,
        itemBuilder: (context, index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;
          
          return GestureDetector(
            onTap: () {
              if (isCompleted && onStepTapped != null) {
                onStepTapped!(index);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStepCircle(index, isCompleted, isCurrent),
                if (index < totalSteps - 1)
                  Container(
                    width: 30,
                    height: 2,
                    color: isCompleted ? AppColors.success : AppColors.border,
                    margin: const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 20),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepCircle(int index, bool isCompleted, bool isCurrent) {
    final label = index < labels.length ? labels[index] : 'Step ${index + 1}';
    
    return SizedBox(
      width: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppColors.success
                  : isCurrent
                      ? AppColors.primary
                      : AppColors.surface,
              border: Border.all(
                color: isCompleted
                    ? AppColors.success
                    : isCurrent
                        ? AppColors.primary
                        : AppColors.border,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCurrent ? Colors.white : AppColors.textHint,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: isCurrent ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
