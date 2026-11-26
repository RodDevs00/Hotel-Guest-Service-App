import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class ServiceMenuScreen extends ConsumerWidget {
  const ServiceMenuScreen({super.key});

  IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('disturb')) return Icons.do_not_disturb_on_outlined;
    if (lower.contains('clean')) return Icons.cleaning_services_outlined;
    if (lower.contains('towel')) return Icons.dry_cleaning_outlined;
    if (lower.contains('toilet')) return Icons.soap_outlined;
    if (lower.contains('maintenance')) return Icons.build_outlined;
    if (lower.contains('room service')) return Icons.room_service_outlined;
    if (lower.contains('laundry')) return Icons.local_laundry_service_outlined;
    if (lower.contains('wake')) return Icons.alarm_outlined;
    return Icons.support_agent_outlined;
  }

  String _blurbFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('disturb')) return 'Pause staff visits';
    if (lower.contains('clean')) return 'Tidy or linen refresh';
    if (lower.contains('towel')) return 'Fresh towels delivered';
    if (lower.contains('toilet')) return 'Amenities restock';
    if (lower.contains('maintenance')) return 'Fix or inspect';
    if (lower.contains('room service')) return 'Food & beverage';
    if (lower.contains('laundry')) return 'Wash & press';
    if (lower.contains('wake')) return 'Morning call';
    return 'Front desk help';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTypes = ref.watch(serviceTypesProvider);
    final session = ref.watch(sessionUserProvider).value;
    final rooms = ref.watch(roomsProvider).value ?? [];
    String roomLabel = 'Your room';
    if (session?.roomId != null) {
      for (final room in rooms) {
        if (room.id == session!.roomId) {
          roomLabel = 'Room ${room.roomNumber}';
          break;
        }
      }
    }

    return asyncTypes.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load services.\n$e')),
      data: (types) {
        if (types.isEmpty) {
          return const Center(child: Text('No services are available right now.'));
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softTealFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bed_outlined, color: AppColors.teal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          roomLabel.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                letterSpacing: 0.6,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Welcome',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('What do you need?', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text(
              'Quiet requests. Fast response.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: types.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final type = types[index];
                return _ServiceTile(
                  type: type,
                  icon: _iconFor(type.name),
                  blurb: _blurbFor(type.name),
                  onTap: () => context.push('/guest/new-request/${type.id}'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.type,
    required this.icon,
    required this.blurb,
    required this.onTap,
  });

  final ServiceType type;
  final IconData icon;
  final String blurb;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.softTealFill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: AppColors.teal, size: 20),
                  ),
                  const Spacer(),
                  if (type.allowsQuantity)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.mist,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'QTY',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              fontSize: 10,
                            ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                type.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                blurb,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
