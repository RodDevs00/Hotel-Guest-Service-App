import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';

class AdminStaysScreen extends ConsumerWidget {
  const AdminStaysScreen({super.key});

  static String _generateCheckInCode({int length = 8}) {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }

  Widget _codeField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onGenerate,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: TextButton(
          onPressed: onGenerate,
          child: const Text('Generate'),
        ),
      ),
    );
  }

  Future<void> _createStay(BuildContext context, WidgetRef ref) async {
    final rooms = ref.read(roomsProvider).value ?? [];
    final activeRooms = rooms.where((r) => r.isActive).toList();
    if (activeRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an active room first.')),
      );
      return;
    }

    String? roomId = activeRooms.first.id;
    final codeController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Start stay / set check-in code'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: roomId,
                      decoration: const InputDecoration(labelText: 'Room'),
                      items: activeRooms
                          .map(
                            (r) => DropdownMenuItem(
                              value: r.id,
                              child: Text(r.roomNumber),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setLocal(() => roomId = v),
                    ),
                    const SizedBox(height: 12),
                    _codeField(
                      controller: codeController,
                      label: 'Check-in code',
                      onGenerate: () {
                        codeController.text = _generateCheckInCode();
                        setLocal(() {});
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
              ],
            );
          },
        );
      },
    );

    if (ok == true && roomId != null && codeController.text.trim().isNotEmpty) {
      final code = codeController.text.trim();
      await ref.read(adminRepositoryProvider).createStay(
            roomId: roomId!,
            checkInCode: code,
          );
      await Clipboard.setData(ClipboardData(text: code));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stay created. Code $code copied.')),
        );
      }
      ref.invalidate(activeStaysProvider);
    }
  }

  Future<void> _resetCode(BuildContext context, WidgetRef ref, String stayId) async {
    final codeController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Reset check-in code'),
              content: SizedBox(
                width: 420,
                child: _codeField(
                  controller: codeController,
                  label: 'New check-in code',
                  onGenerate: () {
                    codeController.text = _generateCheckInCode();
                    setLocal(() {});
                  },
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
              ],
            );
          },
        );
      },
    );
    if (ok == true && codeController.text.trim().isNotEmpty) {
      final code = codeController.text.trim();
      await ref.read(adminRepositoryProvider).resetStayCode(
            stayId: stayId,
            checkInCode: code,
          );
      await Clipboard.setData(ClipboardData(text: code));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check-in code updated to $code (copied).')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staysAsync = ref.watch(activeStaysProvider);

    return staysAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (stays) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _createStay(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('New stay'),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stays.length,
            itemBuilder: (context, index) {
              final stay = stays[index];
              return Card(
                child: ListTile(
                  title: Text('Room ${stay.roomNumber ?? stay.roomId}'),
                  subtitle: Text('Stay ${stay.id.substring(0, 8)}…'),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: 'Reset code',
                        onPressed: () => _resetCode(context, ref, stay.id),
                        icon: const Icon(Icons.password),
                      ),
                      IconButton(
                        tooltip: 'End stay',
                        onPressed: () async {
                          await ref.read(adminRepositoryProvider).endStay(stay.id);
                          ref.invalidate(activeStaysProvider);
                        },
                        icon: const Icon(Icons.logout),
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
