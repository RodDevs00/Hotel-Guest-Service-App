import '../models/models.dart';

/// Allowed forward-only status transitions for service requests.
bool canTransition({
  required RequestStatus from,
  required RequestStatus to,
}) {
  if (from == to) return false;
  return switch (from) {
    RequestStatus.pending =>
      to == RequestStatus.inProgress || to == RequestStatus.completed,
    RequestStatus.inProgress => to == RequestStatus.completed,
    RequestStatus.completed => false,
  };
}

List<RequestStatus> nextStatusesFor(RequestStatus current) {
  return RequestStatus.values.where((to) => canTransition(from: current, to: to)).toList();
}
