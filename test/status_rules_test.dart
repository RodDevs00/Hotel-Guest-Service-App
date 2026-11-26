import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_guest_service_app/core/status_rules.dart';
import 'package:hotel_guest_service_app/models/models.dart';

void main() {
  group('status transitions', () {
    test('pending may move to in progress or completed', () {
      expect(canTransition(from: RequestStatus.pending, to: RequestStatus.inProgress), isTrue);
      expect(canTransition(from: RequestStatus.pending, to: RequestStatus.completed), isTrue);
      expect(canTransition(from: RequestStatus.pending, to: RequestStatus.pending), isFalse);
    });

    test('in progress may only move to completed', () {
      expect(canTransition(from: RequestStatus.inProgress, to: RequestStatus.completed), isTrue);
      expect(canTransition(from: RequestStatus.inProgress, to: RequestStatus.pending), isFalse);
    });

    test('completed cannot move backward', () {
      expect(canTransition(from: RequestStatus.completed, to: RequestStatus.pending), isFalse);
      expect(canTransition(from: RequestStatus.completed, to: RequestStatus.inProgress), isFalse);
      expect(nextStatusesFor(RequestStatus.completed), isEmpty);
    });
  });
}
