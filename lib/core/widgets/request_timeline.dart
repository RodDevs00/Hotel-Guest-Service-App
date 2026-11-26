import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../../models/models.dart';

class RequestTimeline extends StatelessWidget {
  const RequestTimeline({
    super.key,
    required this.status,
    required this.events,
  });

  final RequestStatus status;
  final List<RequestEvent> events;

  DateTime? _timeFor(RequestStatus target) {
    for (final event in events) {
      if (event.toStatus == target.dbValue) {
        return event.createdAt;
      }
      if (target == RequestStatus.pending && event.eventType == 'created') {
        return event.createdAt;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final steps = RequestStatus.values;
    final timeFormat = DateFormat.jm();

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _TimelineStep(
            label: steps[i].label,
            time: _timeFor(steps[i]),
            timeFormat: timeFormat,
            isDone: status.index >= steps[i].index,
            isCurrent: status == steps[i],
            color: switch (steps[i]) {
              RequestStatus.pending => AppColors.pending,
              RequestStatus.inProgress => AppColors.inProgress,
              RequestStatus.completed => AppColors.completed,
            },
            isLast: i == steps.length - 1,
          ),
        ],
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.time,
    required this.timeFormat,
    required this.isDone,
    required this.isCurrent,
    required this.color,
    required this.isLast,
  });

  final String label;
  final DateTime? time;
  final DateFormat timeFormat;
  final bool isDone;
  final bool isCurrent;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? color : Colors.grey.shade300,
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isDone ? color : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isDone ? color : Colors.grey.shade600,
                  ),
                ),
                if (time != null)
                  Text(
                    timeFormat.format(time!.toLocal()),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
