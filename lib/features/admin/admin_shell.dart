import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  String _heading(String location) {
    if (location.startsWith('/admin/rooms')) return 'Rooms';
    if (location.startsWith('/admin/stays')) return 'Stays / Check-in codes';
    if (location.startsWith('/admin/staff')) return 'Staff accounts';
    return 'Services';
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
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
                      Text(
                        _heading(location),
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => context.go('/staff'),
                          icon: const Icon(Icons.inbox_outlined, size: 18),
                          label: const Text('Back to requests'),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          _heading(location),
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.go('/staff'),
                        icon: const Icon(Icons.inbox_outlined, size: 18),
                        label: const Text('Back to requests'),
                      ),
                    ],
                  ),
          ),
          const Divider(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
