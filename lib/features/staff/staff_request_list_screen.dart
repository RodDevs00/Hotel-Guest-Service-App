import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class StaffRequestListScreen extends ConsumerStatefulWidget {
  const StaffRequestListScreen({super.key});

  @override
  ConsumerState<StaffRequestListScreen> createState() =>
      _StaffRequestListScreenState();
}

class _StaffRequestListScreenState extends ConsumerState<StaffRequestListScreen> {
  RequestStatus? _status;
  String? _departmentId;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = StaffRequestFilter(status: _status, departmentId: _departmentId);
    final requestsAsync = ref.watch(staffRequestsProvider(filter));
    final departments = ref.watch(departmentsProvider).value ?? [];
    final timeFormat = DateFormat.MMMd().add_jm();
    final allForCounts = ref.watch(staffRequestsProvider(const StaffRequestFilter())).value ?? [];
    final pendingCount =
        allForCounts.where((r) => r.status == RequestStatus.pending).length;
    final inProgressCount =
        allForCounts.where((r) => r.status == RequestStatus.inProgress).length;
    final padding = pagePadding(context);
    final compact = isCompactLayout(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(padding.left, padding.top, padding.right, 8),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Requests Inbox', style: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: 4),
                      Text(
                        'Newest first · live updates',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _MetricCard(label: 'PENDING', value: '$pendingCount')),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricCard(label: 'IN PROGRESS', value: '$inProgressCount'),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Requests Inbox',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Newest first · live updates',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      _MetricCard(label: 'PENDING', value: '$pendingCount'),
                      const SizedBox(width: 10),
                      _MetricCard(label: 'IN PROGRESS', value: '$inProgressCount'),
                    ],
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(padding.left, 8, padding.right, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final searchWidth = constraints.maxWidth < 520
                    ? constraints.maxWidth
                    : 240.0;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: _status == null,
                      onTap: () => setState(() => _status = null),
                    ),
                    _FilterChip(
                      label: 'Pending',
                      selected: _status == RequestStatus.pending,
                      onTap: () => setState(() => _status = RequestStatus.pending),
                    ),
                    _FilterChip(
                      label: 'In Progress',
                      selected: _status == RequestStatus.inProgress,
                      onTap: () => setState(() => _status = RequestStatus.inProgress),
                    ),
                    _FilterChip(
                      label: 'Completed',
                      selected: _status == RequestStatus.completed,
                      onTap: () => setState(() => _status = RequestStatus.completed),
                    ),
                    SizedBox(
                      width: searchWidth,
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search room or service…',
                          prefixIcon: Icon(Icons.search, size: 18),
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    DropdownButton<String?>(
                      value: _departmentId,
                      hint: const Text('All departments'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All departments')),
                        ...departments.map(
                          (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                        ),
                      ],
                      onChanged: (value) => setState(() => _departmentId = value),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: requestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (items) {
                final query = _searchController.text.trim().toLowerCase();
                final filtered = query.isEmpty
                    ? items
                    : items.where((r) {
                        final hay = '${r.roomNumber} ${r.displayTitle} ${r.notes ?? ''}'
                            .toLowerCase();
                        return hay.contains(query);
                      }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No requests match these filters.'));
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(padding.left, 12, padding.right, padding.bottom),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final request = filtered[index];
                    return _RequestCard(
                      request: request,
                      timeLabel: timeFormat.format(request.createdAt.toLocal()),
                      compact: compact || isMediumLayout(context),
                      onTap: () => context.push('/staff/request/${request.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.timeLabel,
    required this.compact,
    required this.onTap,
  });

  final ServiceRequest request;
  final String timeLabel;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final assignee = request.assignedStaffName ??
        request.assignedDepartmentName ??
        'Unassigned';

    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Room ${request.roomNumber ?? '?'}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        StatusChip(status: request.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      request.displayTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (request.notes != null && request.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        request.notes!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '$timeLabel · $assignee',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                )
              : Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(
                        timeLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        'Room ${request.roomNumber ?? '?'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (request.notes != null && request.notes!.isNotEmpty)
                            Text(
                              request.notes!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    StatusChip(status: request.status),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: Text(
                        assignee,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.muted),
                  ],
                ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  fontSize: 10,
                ),
          ),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.teal : AppColors.card,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppColors.teal : AppColors.border),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? Colors.white : AppColors.navy,
                ),
          ),
        ),
      ),
    );
  }
}
