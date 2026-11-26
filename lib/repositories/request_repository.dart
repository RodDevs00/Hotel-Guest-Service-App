import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';

class RequestRepository {
  RequestRepository(this._client);

  final SupabaseClient _client;

  static const _requestSelect =
      '*, service_types(name), rooms(room_number), departments(name), profiles!requests_assigned_staff_id_fkey(full_name)';

  Future<List<ServiceType>> fetchVisibleServiceTypes() async {
    final rows = await _client
        .from('service_types')
        .select()
        .eq('is_hidden', false)
        .order('sort_order');
    return rows
        .map((row) => ServiceType.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<List<ServiceType>> fetchAllServiceTypes() async {
    final rows =
        await _client.from('service_types').select().order('sort_order');
    return rows
        .map((row) => ServiceType.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<ServiceRequest> createRequest({
    required String stayId,
    required String roomId,
    required String serviceTypeId,
    int? quantity,
    String? notes,
  }) async {
    final inserted = await _client
        .from('requests')
        .insert({
          'stay_id': stayId,
          'room_id': roomId,
          'service_type_id': serviceTypeId,
          'quantity': quantity,
          'notes': notes,
          'status': 'pending',
        })
        .select(_requestSelect)
        .single();
    return ServiceRequest.fromMap(Map<String, dynamic>.from(inserted));
  }

  Future<List<ServiceRequest>> fetchRequestsForStay(String stayId) async {
    final rows = await _client
        .from('requests')
        .select(_requestSelect)
        .eq('stay_id', stayId)
        .order('created_at', ascending: false);
    return rows
        .map((row) => ServiceRequest.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<List<ServiceRequest>> fetchAllRequests({
    RequestStatus? status,
    String? departmentId,
  }) async {
    var query = _client.from('requests').select(_requestSelect);
    if (status != null) {
      query = query.eq('status', status.dbValue);
    }
    if (departmentId != null) {
      query = query.eq('assigned_department_id', departmentId);
    }
    final rows = await query.order('created_at', ascending: false);
    return rows
        .map((row) => ServiceRequest.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<ServiceRequest> fetchRequest(String id) async {
    final row = await _client
        .from('requests')
        .select(_requestSelect)
        .eq('id', id)
        .single();
    return ServiceRequest.fromMap(Map<String, dynamic>.from(row));
  }

  Future<List<RequestEvent>> fetchEvents(String requestId) async {
    final rows = await _client
        .from('request_events')
        .select()
        .eq('request_id', requestId)
        .order('created_at');
    return rows
        .map((row) => RequestEvent.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<ServiceRequest> updateAssignment({
    required String requestId,
    String? departmentId,
    String? staffId,
  }) async {
    final updated = await _client
        .from('requests')
        .update({
          'assigned_department_id': departmentId,
          'assigned_staff_id': staffId,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', requestId)
        .select(_requestSelect)
        .single();
    return ServiceRequest.fromMap(Map<String, dynamic>.from(updated));
  }

  Future<ServiceRequest> updateStatus({
    required String requestId,
    required RequestStatus status,
  }) async {
    final updated = await _client
        .from('requests')
        .update({
          'status': status.dbValue,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', requestId)
        .select(_requestSelect)
        .single();
    return ServiceRequest.fromMap(Map<String, dynamic>.from(updated));
  }

  RealtimeChannel subscribeToRequests({
    required void Function() onChange,
    String? stayId,
  }) {
    final channel = _client.channel('requests-changes-${stayId ?? 'all'}');

    if (stayId != null) {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'requests',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'stay_id',
          value: stayId,
        ),
        callback: (_) => onChange(),
      );
    } else {
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'requests',
        callback: (_) => onChange(),
      );
    }
    channel.subscribe();
    return channel;
  }
}
