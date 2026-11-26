import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/status_rules.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/request_timeline.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class StaffRequestDetailScreen extends ConsumerStatefulWidget {
  const StaffRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<StaffRequestDetailScreen> createState() =>
      _StaffRequestDetailScreenState();
}

class _StaffRequestDetailScreenState
    extends ConsumerState<StaffRequestDetailScreen> {
  String? _departmentId;
  String? _staffId;
  bool _saving = false;

  Future<void> _saveAssignment() async {
    setState(() => _saving = true);
    try {
      await ref.read(requestRepositoryProvider).updateAssignment(
            requestId: widget.requestId,
            departmentId: _departmentId,
            staffId: _staffId,
          );
      ref.invalidate(requestDetailProvider(widget.requestId));
      ref.invalidate(requestEventsProvider(widget.requestId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment saved.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _setStatus(RequestStatus status) async {
    setState(() => _saving = true);
    try {
      await ref.read(requestRepositoryProvider).updateStatus(
            requestId: widget.requestId,
            status: status,
          );
      ref.invalidate(requestDetailProvider(widget.requestId));
      ref.invalidate(requestEventsProvider(widget.requestId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(requestDetailProvider(widget.requestId));
    final eventsAsync = ref.watch(requestEventsProvider(widget.requestId));
    final departments = ref.watch(departmentsProvider).value ?? [];
    final staff = ref.watch(activeStaffProfilesProvider).value ?? [];
    final timeFormat = DateFormat.yMMMd().add_jm();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request detail'),
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: requestAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (request) {
          _departmentId ??= request.assignedDepartmentId;
          _staffId ??= request.assignedStaffId;

          final nextStatuses = nextStatusesFor(request.status);

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Room ${request.roomNumber ?? '?'} · ${request.displayTitle}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  StatusChip(status: request.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Submitted ${timeFormat.format(request.createdAt.toLocal())}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (request.quantity != null) ...[
                const SizedBox(height: 8),
                Text('Quantity: ${request.quantity}'),
              ],
              if (request.notes != null && request.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.softTealFill,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('Guest note: ${request.notes}'),
                ),
              ],
              const SizedBox(height: 24),
              Text('Assign', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: _departmentId,
                decoration: const InputDecoration(labelText: 'Department'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Unassigned')),
                  ...departments.map(
                    (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                  ),
                ],
                onChanged: (value) => setState(() => _departmentId = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _staffId,
                decoration: const InputDecoration(labelText: 'Staff member'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Unassigned')),
                  ...staff.map(
                    (p) => DropdownMenuItem(value: p.id, child: Text(p.fullName)),
                  ),
                ],
                onChanged: (value) => setState(() => _staffId = value),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 200,
                  child: FilledButton(
                    onPressed: _saving ? null : _saveAssignment,
                    child: const Text('Save assignment'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Update status', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: nextStatuses
                    .map(
                      (status) => FilledButton(
                        onPressed: _saving ? null : () => _setStatus(status),
                        child: Text('Mark ${status.label}'),
                      ),
                    )
                    .toList(),
              ),
              if (nextStatuses.isEmpty)
                Text(
                  'This request is already completed.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 28),
              Text('Timeline', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              eventsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('$e'),
                data: (events) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RequestTimeline(status: request.status, events: events),
                    const SizedBox(height: 16),
                    Text('Audit log', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    ...events.reversed.map(
                      (e) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${e.eventType.replaceAll('_', ' ')}'
                          '${e.toStatus != null ? ' → ${e.toStatus}' : ''}',
                        ),
                        subtitle: Text(
                          '${e.actorName} • ${timeFormat.format(e.createdAt.toLocal())}'
                          '${e.note != null && e.note!.isNotEmpty ? ' • ${e.note}' : ''}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
