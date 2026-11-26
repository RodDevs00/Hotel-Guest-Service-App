import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/request_timeline.dart';
import '../../core/widgets/status_chip.dart';
import '../../providers/providers.dart';

class GuestRequestDetailScreen extends ConsumerWidget {
  const GuestRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestAsync = ref.watch(requestDetailProvider(requestId));
    final eventsAsync = ref.watch(requestEventsProvider(requestId));

    return Scaffold(
      appBar: AppBar(title: const Text('Request details')),
      body: requestAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (request) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      request.displayTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  StatusChip(status: request.status),
                ],
              ),
              if (request.quantity != null) ...[
                const SizedBox(height: 8),
                Text('Quantity: ${request.quantity}'),
              ],
              if (request.notes != null && request.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Notes: ${request.notes}'),
              ],
              const SizedBox(height: 24),
              Text(
                'Status timeline',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              eventsAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('$e'),
                data: (events) => RequestTimeline(
                  status: request.status,
                  events: events,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
