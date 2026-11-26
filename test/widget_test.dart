import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_service_app/main.dart';

void main() {
  testWidgets('shows missing config screen without dart-defines', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: HotelGuestServiceApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Supabase config missing'), findsOneWidget);
  });
}
