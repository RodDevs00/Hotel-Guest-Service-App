import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class AdminRoomsScreen extends ConsumerWidget {
  const AdminRoomsScreen({super.key});

  Future<void> _upsertRoom(
    BuildContext context,
    WidgetRef ref, [
    Room? existing,
  ]) async {
    final controller = TextEditingController(text: existing?.roomNumber ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add room' : 'Edit room'),
        content: SizedBox(
          width: 360,
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Room number'),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
    if (ok != true || controller.text.trim().isEmpty) return;

    try {
      if (existing == null) {
        await ref.read(adminRepositoryProvider).createRoom(controller.text);
      } else {
        await ref.read(adminRepositoryProvider).updateRoom(
              roomId: existing.id,
              roomNumber: controller.text,
            );
      }
      ref.invalidate(roomsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _deleteRoom(BuildContext context, WidgetRef ref, Room room) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete room?'),
        content: Text(
          'Delete room ${room.roomNumber}? If it has stays or requests, deactivate it instead.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(adminRepositoryProvider).deleteRoom(room.id);
      ref.invalidate(roomsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);

    return roomsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (rooms) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _upsertRoom(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add room'),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return Material(
                color: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: ListTile(
                  title: Text('Room ${room.roomNumber}'),
                  subtitle: Text(room.isActive ? 'Active' : 'Inactive'),
                  trailing: Wrap(
                    spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Switch(
                        value: room.isActive,
                        onChanged: (value) async {
                          await ref
                              .read(adminRepositoryProvider)
                              .setRoomActive(room.id, value);
                          ref.invalidate(roomsProvider);
                        },
                      ),
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () => _upsertRoom(context, ref, room),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () => _deleteRoom(context, ref, room),
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
