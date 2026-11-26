import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class AdminStaffScreen extends ConsumerWidget {
  const AdminStaffScreen({super.key});

  Future<void> _createStaff(BuildContext context, WidgetRef ref) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    var role = 'staff';
    String? departmentId;
    final departments = ref.read(departmentsProvider).value ?? [];

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Create staff account'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Full name'),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(labelText: 'Temporary password'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: role,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: const [
                          DropdownMenuItem(value: 'staff', child: Text('Staff')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (v) => setLocal(() => role = v ?? 'staff'),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String?>(
                        initialValue: departmentId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Department'),
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
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;
    try {
      await ref.read(adminRepositoryProvider).createStaffUser(
            email: emailController.text,
            password: passwordController.text,
            fullName: nameController.text,
            role: role,
            departmentId: departmentId,
          );
      ref.invalidate(staffProfilesProvider);
      ref.invalidate(activeStaffProfilesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff account created.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> _editStaff(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) async {
    final nameController = TextEditingController(text: profile.fullName);
    final passwordController = TextEditingController();
    var role = profile.role == UserRole.admin ? 'admin' : 'staff';
    var isActive = profile.isActive;
    String? departmentId = profile.departmentId;
    final departments = ref.read(departmentsProvider).value ?? [];
    final currentUserId = ref.read(sessionUserProvider).value?.id;
    final isSelf = currentUserId == profile.id;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: const Text('Edit staff profile'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Full name'),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: role,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: const [
                          DropdownMenuItem(value: 'staff', child: Text('Staff')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        ],
                        onChanged: (v) => setLocal(() => role = v ?? 'staff'),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String?>(
                        initialValue: departmentId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Department'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('None')),
                          ...departments.map(
                            (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                          ),
                        ],
                        onChanged: (v) => setLocal(() => departmentId = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active'),
                        subtitle: Text(
                          isSelf
                              ? 'You cannot deactivate your own account'
                              : 'Inactive staff cannot sign in or be assigned',
                        ),
                        value: isActive,
                        onChanged: isSelf
                            ? null
                            : (v) => setLocal(() => isActive = v),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'New password (optional)',
                          helperText: 'Leave blank to keep the current password',
                        ),
                        obscureText: true,
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

    if (ok != true) return;
    if (nameController.text.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Full name is required.')),
        );
      }
      return;
    }

    try {
      await ref.read(adminRepositoryProvider).updateStaffUser(
            userId: profile.id,
            fullName: nameController.text,
            role: role,
            departmentId: departmentId,
            password: passwordController.text,
            isActive: isActive,
          );
      ref.invalidate(staffProfilesProvider);
      ref.invalidate(activeStaffProfilesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff profile updated.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> _setActive(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
    bool isActive,
  ) async {
    final currentUserId = ref.read(sessionUserProvider).value?.id;
    if (currentUserId == profile.id && !isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot deactivate your own account.')),
      );
      return;
    }

    try {
      await ref.read(adminRepositoryProvider).updateStaffUser(
            userId: profile.id,
            fullName: profile.fullName,
            role: profile.role == UserRole.admin ? 'admin' : 'staff',
            departmentId: profile.departmentId,
            isActive: isActive,
          );
      ref.invalidate(staffProfilesProvider);
      ref.invalidate(activeStaffProfilesProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffProfilesProvider);
    final currentUserId = ref.watch(sessionUserProvider).value?.id;

    return staffAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (staff) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _createStaff(context, ref),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add staff'),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: staff.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final profile = staff[index];
              final isSelf = currentUserId == profile.id;
              return Material(
                color: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.softTealFill,
                    child: Icon(
                      profile.role == UserRole.admin
                          ? Icons.admin_panel_settings_outlined
                          : Icons.person_outline,
                      color: AppColors.teal,
                    ),
                  ),
                  title: Text(profile.fullName),
                  subtitle: Text(
                    '${profile.role.name}'
                    '${profile.departmentName != null ? ' • ${profile.departmentName}' : ''}'
                    '${profile.isActive ? '' : ' • Inactive'}',
                  ),
                  trailing: Wrap(
                    spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Switch(
                        value: profile.isActive,
                        onChanged: isSelf
                            ? null
                            : (value) => _setActive(context, ref, profile, value),
                      ),
                      IconButton(
                        tooltip: 'Edit profile',
                        onPressed: () => _editStaff(context, ref, profile),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                  onTap: () => _editStaff(context, ref, profile),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
