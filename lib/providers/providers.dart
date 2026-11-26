import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import '../repositories/admin_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/request_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  return RequestRepository(ref.watch(supabaseClientProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(supabaseClientProvider));
});

final sessionUserProvider = StreamProvider<SessionUser?>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  return Stream<SessionUser?>.multi((multi) {
    multi.add(auth.currentSessionUser());
    final sub = auth.authStateChanges().listen(multi.add);
    multi.onCancel = sub.cancel;
  });
});

final myProfileProvider = FutureProvider<Profile?>((ref) async {
  final session = ref.watch(sessionUserProvider).value;
  if (session == null || session.isGuest) return null;
  return ref.watch(authRepositoryProvider).fetchMyProfile();
});

final serviceTypesProvider = FutureProvider<List<ServiceType>>((ref) {
  return ref.watch(requestRepositoryProvider).fetchVisibleServiceTypes();
});

final allServiceTypesProvider = FutureProvider<List<ServiceType>>((ref) {
  return ref.watch(requestRepositoryProvider).fetchAllServiceTypes();
});

final departmentsProvider = FutureProvider<List<Department>>((ref) {
  return ref.watch(adminRepositoryProvider).fetchDepartments();
});

final roomsProvider = FutureProvider<List<Room>>((ref) {
  return ref.watch(adminRepositoryProvider).fetchRooms();
});

final activeStaysProvider = FutureProvider<List<Stay>>((ref) {
  return ref.watch(adminRepositoryProvider).fetchActiveStays();
});

final staffProfilesProvider = FutureProvider<List<Profile>>((ref) {
  return ref.watch(adminRepositoryProvider).fetchStaffProfiles();
});

final activeStaffProfilesProvider = FutureProvider<List<Profile>>((ref) {
  return ref.watch(adminRepositoryProvider).fetchStaffProfiles(activeOnly: true);
});

final hotelNameProvider = FutureProvider<String>((ref) async {
  final name = await ref.watch(adminRepositoryProvider).fetchHotelName();
  return name ?? 'Hotel Service';
});

final guestRequestsProvider =
    StreamProvider.autoDispose<List<ServiceRequest>>((ref) {
  final session = ref.watch(sessionUserProvider).value;
  final stayId = session?.stayId;
  final repo = ref.watch(requestRepositoryProvider);
  final controller = StreamController<List<ServiceRequest>>();

  Future<void> load() async {
    if (stayId == null) {
      controller.add(const []);
      return;
    }
    final items = await repo.fetchRequestsForStay(stayId);
    if (!controller.isClosed) controller.add(items);
  }

  load();

  final channel = stayId == null
      ? null
      : repo.subscribeToRequests(stayId: stayId, onChange: load);

  ref.onDispose(() {
    channel?.unsubscribe();
    controller.close();
  });

  return controller.stream;
});

final staffRequestsProvider = StreamProvider.autoDispose
    .family<List<ServiceRequest>, StaffRequestFilter>((ref, filter) {
  final session = ref.watch(sessionUserProvider).value;
  final repo = ref.watch(requestRepositoryProvider);
  final controller = StreamController<List<ServiceRequest>>();

  Future<void> load() async {
    if (session == null || !session.isStaff) {
      controller.add(const []);
      return;
    }
    final items = await repo.fetchAllRequests(
      status: filter.status,
      departmentId: filter.departmentId,
    );
    if (!controller.isClosed) controller.add(items);
  }

  load();

  final channel = (session == null || !session.isStaff)
      ? null
      : repo.subscribeToRequests(onChange: load);

  ref.onDispose(() {
    channel?.unsubscribe();
    controller.close();
  });

  return controller.stream;
});

final requestDetailProvider =
    FutureProvider.autoDispose.family<ServiceRequest, String>((ref, id) {
  return ref.watch(requestRepositoryProvider).fetchRequest(id);
});

final requestEventsProvider =
    FutureProvider.autoDispose.family<List<RequestEvent>, String>((ref, id) {
  return ref.watch(requestRepositoryProvider).fetchEvents(id);
});

class StaffRequestFilter {
  const StaffRequestFilter({this.status, this.departmentId});

  final RequestStatus? status;
  final String? departmentId;

  @override
  bool operator ==(Object other) =>
      other is StaffRequestFilter &&
      other.status == status &&
      other.departmentId == departmentId;

  @override
  int get hashCode => Object.hash(status, departmentId);
}
