import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/status_chip.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class GuestRequestsScreen extends ConsumerWidget {
  const GuestRequestsScreen({super.key, this.historyOnly = false});

  final bool historyOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRequests = ref.watch(guestRequestsProvider);
    final timeFormat = DateFormat.jm();

    return asyncRequests.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load requests.\n$e')),
      data: (all) {
        final items = historyOnly
            ? all.where((r) => r.status == RequestStatus.completed).toList()
            : all.where((r) => r.status != RequestStatus.completed).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              historyOnly ? 'History' : 'My Requests',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 4),
            Text(
              historyOnly
                  ? 'Completed requests from this stay.'
                  : 'Live status for open requests.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  historyOnly
                      ? 'No completed requests yet.'
                      : 'No open requests. Submit one from Services.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              )
            else
              ...items.map((request) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: AppColors.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.push('/guest/request/${request.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.displayTitle,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Submitted ${timeFormat.format(request.createdAt.toLocal())}'
                                    '${request.quantity != null ? ' • Qty ${request.quantity}' : ''}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            StatusChip(status: request.status),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, color: AppColors.muted),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
