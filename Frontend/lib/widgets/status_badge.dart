import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final dynamic status; // ExpenseStatus or UserApprovalStatus

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bgColor;
    String text;
    IconData icon;

    if (status == ExpenseStatus.approved || status == UserApprovalStatus.approved) {
      color = AppTheme.approved;
      bgColor = AppTheme.approved.withOpacity(0.15);
      text = 'Approved';
      icon = Icons.check_circle_outline;
    } else if (status == ExpenseStatus.rejected || status == UserApprovalStatus.rejected) {
      color = AppTheme.rejected;
      bgColor = AppTheme.rejected.withOpacity(0.15);
      text = 'Rejected';
      icon = Icons.highlight_off;
    } else {
      color = AppTheme.pending;
      bgColor = AppTheme.pending.withOpacity(0.15);
      text = 'Pending';
      icon = Icons.access_time;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
