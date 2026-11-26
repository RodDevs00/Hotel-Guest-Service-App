import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/haven_logo.dart';
import '../../providers/providers.dart';

class StaffShell extends ConsumerWidget {
  const StaffShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionUserProvider).value;
    final location = GoRouterState.of(context).uri.toString();
    final isAdmin = session?.isAdmin ?? false;
    final compact = isCompactLayout(context);

    final nav = _SideNav(
      location: location,
      isAdmin: isAdmin,
      fullName: session?.fullName ?? 'Staff',
      roleLabel: session?.isAdmin == true ? 'Admin' : 'Staff',
      onSignOut: () async {
        await ref.read(authRepositoryProvider).signOut();
        if (context.mounted) context.go('/staff/sign-in');
      },
    );

    if (compact) {
      return Scaffold(
        appBar: AppBar(
          title: const HavenLogo(compact: true),
          actions: [
            IconButton(
              tooltip: 'Sign out',
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) context.go('/staff/sign-in');
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: AppColors.card,
          child: SafeArea(child: nav),
        ),
        body: child,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: isMediumLayout(context) ? 200 : 240,
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border(right: BorderSide(color: AppColors.border)),
            ),
            child: nav,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.location,
    required this.isAdmin,
    required this.fullName,
    required this.roleLabel,
    required this.onSignOut,
  });

  final String location;
  final bool isAdmin;
  final String fullName;
  final String roleLabel;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: HavenLogo(compact: true),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'LIVE OPERATIONS',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
          ),
        ),
        const SizedBox(height: 8),
        _NavItem(
          icon: Icons.inbox_outlined,
          selectedIcon: Icons.inbox,
          label: 'Requests',
          selected: location.startsWith('/staff') && !location.startsWith('/admin'),
          onTap: () {
            Navigator.of(context).maybePop();
            context.go('/staff');
          },
        ),
        if (isAdmin) ...[
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'ADMINISTRATION',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          _NavItem(
            icon: Icons.menu_book_outlined,
            selectedIcon: Icons.menu_book,
            label: 'Services',
            selected: location.startsWith('/admin/services'),
            onTap: () {
              Navigator.of(context).maybePop();
              context.go('/admin/services');
            },
          ),
          _NavItem(
            icon: Icons.meeting_room_outlined,
            selectedIcon: Icons.meeting_room,
            label: 'Rooms',
            selected: location.startsWith('/admin/rooms'),
            onTap: () {
              Navigator.of(context).maybePop();
              context.go('/admin/rooms');
            },
          ),
          _NavItem(
            icon: Icons.key_outlined,
            selectedIcon: Icons.key,
            label: 'Stays',
            selected: location.startsWith('/admin/stays'),
            onTap: () {
              Navigator.of(context).maybePop();
              context.go('/admin/stays');
            },
          ),
          _NavItem(
            icon: Icons.group_outlined,
            selectedIcon: Icons.group,
            label: 'Staff',
            selected: location.startsWith('/admin/staff'),
            onTap: () {
              Navigator.of(context).maybePop();
              context.go('/admin/staff');
            },
          ),
        ],
        const Spacer(),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(fullName, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(roleLabel, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onSignOut,
                icon: const Icon(Icons.logout, size: 16),
                label: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: selected ? AppColors.teal.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  size: 18,
                  color: selected ? AppColors.teal : AppColors.muted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected ? AppColors.teal : AppColors.navy,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
