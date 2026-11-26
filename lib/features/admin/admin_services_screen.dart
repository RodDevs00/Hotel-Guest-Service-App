import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class AdminServicesScreen extends ConsumerWidget {
  const AdminServicesScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, [ServiceType? existing]) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    var allowsQuantity = existing?.allowsQuantity ?? false;
    var isHidden = existing?.isHidden ?? false;
    var sortOrder = existing?.sortOrder ?? 0;
    String? departmentId = existing?.defaultDepartmentId;
    final departments = ref.read(departmentsProvider).value ?? [];

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(existing == null ? 'Add service' : 'Edit service'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Allows quantity'),
                        value: allowsQuantity,
                        onChanged: (v) => setLocal(() => allowsQuantity = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Hidden from guests'),
                        value: isHidden,
                        onChanged: (v) => setLocal(() => isHidden = v),
                      ),
                      TextFormField(
                        initialValue: '$sortOrder',
                        decoration: const InputDecoration(labelText: 'Sort order'),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => sortOrder = int.tryParse(v) ?? 0,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String?>(
                        initialValue: departmentId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Default department'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('None')),
                          ...departments.map(
                            (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                          ),
                        ],
                        onChanged: (v) => setLocal(() => departmentId = v),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
              ],
            );
          },
        );
      },
    );

    if (saved != true) return;
    if (nameController.text.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service name is required.')),
        );
      }
      return;
    }

    try {
      await ref.read(adminRepositoryProvider).upsertServiceType(
            id: existing?.id,
            name: nameController.text,
            allowsQuantity: allowsQuantity,
            isHidden: isHidden,
            sortOrder: sortOrder,
            defaultDepartmentId: departmentId,
          );
      ref.invalidate(allServiceTypesProvider);
      ref.invalidate(serviceTypesProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, ServiceType type) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete service?'),
        content: Text(
          'Delete "${type.name}"? If it has requests, hide it from guests instead.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(adminRepositoryProvider).deleteServiceType(type.id);
      ref.invalidate(allServiceTypesProvider);
      ref.invalidate(serviceTypesProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTypes = ref.watch(allServiceTypesProvider);

    return asyncTypes.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (types) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _edit(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add service'),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: types.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final type = types[index];
              return Material(
                color: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: ListTile(
                  title: Text(type.name),
                  subtitle: Text(
                    'Order ${type.sortOrder}'
                    '${type.allowsQuantity ? ' • Quantity' : ''}'
                    '${type.isHidden ? ' • Hidden' : ' • Visible'}',
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      Switch(
                        value: !type.isHidden,
                        onChanged: (visible) async {
                          await ref.read(adminRepositoryProvider).upsertServiceType(
                                id: type.id,
                                name: type.name,
                                allowsQuantity: type.allowsQuantity,
                                isHidden: !visible,
                                sortOrder: type.sortOrder,
                                defaultDepartmentId: type.defaultDepartmentId,
                              );
                          ref.invalidate(allServiceTypesProvider);
                          ref.invalidate(serviceTypesProvider);
                        },
                      ),
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _edit(context, ref, type),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => _delete(context, ref, type),
                      ),
                    ],
                  ),
                  onTap: () => _edit(context, ref, type),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
