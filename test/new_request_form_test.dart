import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_service_app/features/guest/new_request_screen.dart';
import 'package:hotel_guest_service_app/models/models.dart';
import 'package:hotel_guest_service_app/providers/providers.dart';

void main() {
  testWidgets('shows quantity controls when service allows quantity', (tester) async {
    const towels = ServiceType(
      id: 'towels-id',
      name: 'Towels',
      allowsQuantity: true,
      sortOrder: 1,
      isHidden: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serviceTypesProvider.overrideWith((ref) async => [towels]),
        ],
        child: const MaterialApp(
          home: NewRequestScreen(serviceTypeId: 'towels-id'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Towels'), findsOneWidget);
    expect(find.text('Quantity'), findsOneWidget);
    expect(find.text('Submit request'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('wake-up call hints for notes time', (tester) async {
    const wake = ServiceType(
      id: 'wake-id',
      name: 'Wake-up call',
      allowsQuantity: false,
      sortOrder: 1,
      isHidden: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serviceTypesProvider.overrideWith((ref) async => [wake]),
        ],
        child: const MaterialApp(
          home: NewRequestScreen(serviceTypeId: 'wake-id'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.textContaining('wake-up time'), findsOneWidget);
    expect(find.text('Quantity'), findsNothing);
  });
}
