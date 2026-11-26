import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../../models/models.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final RequestStatus status;

  Color get _color => switch (status) {
        RequestStatus.pending => AppColors.pending,
        RequestStatus.inProgress => AppColors.inProgress,
        RequestStatus.completed => AppColors.completed,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
