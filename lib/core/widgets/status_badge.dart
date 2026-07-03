import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Loan/transaction status badge with color-coded indicator
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: _color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color get _color {
    switch (type) {
      case StatusType.approved:
        return AppColors.statusApproved;
      case StatusType.pending:
        return AppColors.statusPending;
      case StatusType.rejected:
        return AppColors.statusRejected;
      case StatusType.active:
        return AppColors.statusActive;
      case StatusType.closed:
        return AppColors.statusClosed;
      case StatusType.overdue:
        return AppColors.statusOverdue;
    }
  }

  Color get _backgroundColor {
    switch (type) {
      case StatusType.approved:
        return AppColors.successSurface;
      case StatusType.pending:
        return AppColors.warningSurface;
      case StatusType.rejected:
        return AppColors.errorSurface;
      case StatusType.active:
        return AppColors.infoSurface;
      case StatusType.closed:
        return AppColors.surfaceLight;
      case StatusType.overdue:
        return AppColors.errorSurface;
    }
  }
}

enum StatusType {
  approved,
  pending,
  rejected,
  active,
  closed,
  overdue,
}
