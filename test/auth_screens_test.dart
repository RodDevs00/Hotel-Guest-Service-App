import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_service_app/core/theme/app_theme.dart';
import 'package:hotel_guest_service_app/features/auth/privacy_notice_screen.dart';
import 'package:hotel_guest_service_app/features/auth/staff_sign_in_screen.dart';
import 'package:hotel_guest_service_app/features/guest/service_menu_screen.dart';
import 'package:hotel_guest_service_app/models/models.dart';
import 'package:hotel_guest_service_app/providers/providers.dart';

void main() {
  testWidgets('privacy notice shows Hotel Service protection copy', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const PrivacyNoticeScreen(),
        ),
      ),
    );

    expect(find.text('Your stay, respected'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.textContaining('room number'), findsOneWidget);
  });

  testWidgets('staff sign-in shows email and password fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const StaffSignInScreen(),
        ),
      ),
    );

    expect(find.text('Staff sign-in'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('service menu lists seeded-style service types', (tester) async {
    final types = [
      const ServiceType(
        id: '1',
        name: 'Room cleaning',
        allowsQuantity: false,
        sortOrder: 1,
        isHidden: false,
      ),
      const ServiceType(
        id: '2',
        name: 'Towels',
        allowsQuantity: true,
        sortOrder: 2,
        isHidden: false,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serviceTypesProvider.overrideWith((ref) async => types),
          roomsProvider.overrideWith((ref) async => const <Room>[]),
          sessionUserProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: ServiceMenuScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('What do you need?'), findsOneWidget);
    expect(find.text('Room cleaning'), findsOneWidget);
    expect(find.text('Towels'), findsOneWidget);
    expect(find.text('QTY'), findsOneWidget);
  });
}
