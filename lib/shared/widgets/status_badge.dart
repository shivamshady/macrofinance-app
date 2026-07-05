import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  Color _getColor() {
    final s = status.toLowerCase();
    if (['approved', 'active', 'verified', 'success'].contains(s)) return AppColors.success;
    if (['pending', 'under_review', 'in_progress'].contains(s)) return AppColors.warning;
    if (['rejected', 'overdue', 'blocked', 'failed'].contains(s)) return AppColors.error;
    if (['closed', 'matured', 'paid'].contains(s)) return AppColors.tierStarter; // blue grey
    if (['submitted'].contains(s)) return AppColors.primaryLight; // indigo
    return AppColors.textHint;
  }

  IconData _getIcon() {
    final s = status.toLowerCase();
    if (['approved', 'active', 'verified', 'success'].contains(s)) return Icons.check_circle_outline;
    if (['pending', 'under_review', 'in_progress', 'submitted'].contains(s)) return Icons.access_time;
    if (['rejected', 'overdue', 'blocked', 'failed'].contains(s)) return Icons.error_outline;
    if (['closed', 'matured', 'paid'].contains(s)) return Icons.task_alt;
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase().replaceAll('_', ' '),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
