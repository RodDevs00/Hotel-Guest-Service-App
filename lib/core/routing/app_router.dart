import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_rooms_screen.dart';
import '../../features/admin/admin_services_screen.dart';
import '../../features/admin/admin_shell.dart';
import '../../features/admin/admin_staff_screen.dart';
import '../../features/admin/admin_stays_screen.dart';
import '../../features/auth/guest_sign_in_screen.dart';
import '../../features/auth/privacy_notice_screen.dart';
import '../../features/auth/staff_sign_in_screen.dart';
import '../../features/guest/guest_request_detail_screen.dart';
import '../../features/guest/guest_requests_screen.dart';
import '../../features/guest/guest_shell.dart';
import '../../features/guest/new_request_screen.dart';
import '../../features/guest/service_menu_screen.dart';
import '../../features/staff/staff_request_detail_screen.dart';
import '../../features/staff/staff_request_list_screen.dart';
import '../../features/staff/staff_shell.dart';
import '../../providers/providers.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionUserProvider, (_, _) => refresh.value++);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: kIsWeb ? '/staff/sign-in' : '/privacy',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionUserProvider).value;
      final loc = state.matchedLocation;
      final loggingInGuest = loc == '/privacy' || loc == '/guest/sign-in';
      final loggingInStaff = loc == '/staff/sign-in';

      if (kIsWeb) {
        if (session == null) {
          return loggingInStaff ? null : '/staff/sign-in';
        }
        if (!session.isStaff) {
          return '/staff/sign-in';
        }
        if (loggingInStaff) return '/staff';
        if (loc.startsWith('/admin') && !session.isAdmin) return '/staff';
        if (loc.startsWith('/guest') || loc == '/privacy') return '/staff';
        return null;
      }

      // Mobile / guest app
      if (session == null) {
        return loggingInGuest ? null : '/privacy';
      }
      if (session.isGuest) {
        if (loggingInGuest || loc.startsWith('/staff') || loc.startsWith('/admin')) {
          return '/guest';
        }
        return null;
      }
      // Staff accidentally on phone build: send to staff sign-in area is web-only.
      return '/privacy';
    },
    routes: [
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyNoticeScreen(),
      ),
      GoRoute(
        path: '/guest/sign-in',
        builder: (context, state) => const GuestSignInScreen(),
      ),
      GoRoute(
        path: '/staff/sign-in',
        builder: (context, state) => const StaffSignInScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => GuestShell(child: child),
        routes: [
          GoRoute(
            path: '/guest',
            builder: (context, state) => const ServiceMenuScreen(),
          ),
          GoRoute(
            path: '/guest/requests',
            builder: (context, state) => const GuestRequestsScreen(),
          ),
          GoRoute(
            path: '/guest/history',
            builder: (context, state) =>
                const GuestRequestsScreen(historyOnly: true),
          ),
        ],
      ),
      GoRoute(
        path: '/guest/new-request/:serviceTypeId',
        builder: (context, state) => NewRequestScreen(
          serviceTypeId: state.pathParameters['serviceTypeId']!,
        ),
      ),
      GoRoute(
        path: '/guest/request/:id',
        builder: (context, state) => GuestRequestDetailScreen(
          requestId: state.pathParameters['id']!,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => StaffShell(child: child),
        routes: [
          GoRoute(
            path: '/staff',
            builder: (context, state) => const StaffRequestListScreen(),
          ),
          GoRoute(
            path: '/staff/request/:id',
            builder: (context, state) => StaffRequestDetailScreen(
              requestId: state.pathParameters['id']!,
            ),
          ),
          ShellRoute(
            builder: (context, state, child) => AdminShell(child: child),
            routes: [
              GoRoute(
                path: '/admin/services',
                builder: (context, state) => const AdminServicesScreen(),
              ),
              GoRoute(
                path: '/admin/rooms',
                builder: (context, state) => const AdminRoomsScreen(),
              ),
              GoRoute(
                path: '/admin/stays',
                builder: (context, state) => const AdminStaysScreen(),
              ),
              GoRoute(
                path: '/admin/staff',
                builder: (context, state) => const AdminStaffScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
