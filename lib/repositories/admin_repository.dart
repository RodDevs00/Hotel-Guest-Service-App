import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';

class AdminRepository {
  AdminRepository(this._client);

  final SupabaseClient _client;

  Future<List<Department>> fetchDepartments() async {
    final rows = await _client.from('departments').select().order('name');
    return rows
        .map((row) => Department.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<List<Room>> fetchRooms() async {
    final rows =
        await _client.from('rooms').select().order('room_number');
    return rows
        .map((row) => Room.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<Room> createRoom(String roomNumber) async {
    final row = await _client
        .from('rooms')
        .insert({'room_number': roomNumber.trim(), 'is_active': true})
        .select()
        .single();
    return Room.fromMap(Map<String, dynamic>.from(row));
  }

  Future<Room> updateRoom({
    required String roomId,
    required String roomNumber,
  }) async {
    final row = await _client
        .from('rooms')
        .update({'room_number': roomNumber.trim()})
        .eq('id', roomId)
        .select()
        .single();
    return Room.fromMap(Map<String, dynamic>.from(row));
  }

  Future<Room> setRoomActive(String roomId, bool isActive) async {
    final row = await _client
        .from('rooms')
        .update({'is_active': isActive})
        .eq('id', roomId)
        .select()
        .single();
    return Room.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      await _client.from('rooms').delete().eq('id', roomId);
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        throw Exception(
          'This room has stays or requests. Deactivate it instead of deleting.',
        );
      }
      rethrow;
    }
  }

  Future<List<Stay>> fetchActiveStays() async {
    final rows = await _client
        .from('stays')
        .select('*, rooms(room_number)')
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return rows
        .map((row) => Stay.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<Stay> createStay({
    required String roomId,
    required String checkInCode,
  }) async {
    final row = await _client.rpc(
      'admin_create_stay',
      params: {
        'p_room_id': roomId,
        'p_check_in_code': checkInCode,
      },
    );
    return Stay.fromMap(Map<String, dynamic>.from(row as Map));
  }

  Future<void> resetStayCode({
    required String stayId,
    required String checkInCode,
  }) async {
    await _client.rpc(
      'admin_reset_stay_code',
      params: {
        'p_stay_id': stayId,
        'p_check_in_code': checkInCode,
      },
    );
  }

  Future<void> endStay(String stayId) async {
    await _client.from('stays').update({'is_active': false}).eq('id', stayId);
  }

  Future<ServiceType> upsertServiceType({
    String? id,
    required String name,
    required bool allowsQuantity,
    required bool isHidden,
    required int sortOrder,
    String? defaultDepartmentId,
  }) async {
    final payload = {
      'id': ?id,
      'name': name.trim(),
      'allows_quantity': allowsQuantity,
      'is_hidden': isHidden,
      'sort_order': sortOrder,
      'default_department_id': defaultDepartmentId,
    };
    final row = await _client
        .from('service_types')
        .upsert(payload)
        .select()
        .single();
    return ServiceType.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> deleteServiceType(String id) async {
    try {
      await _client.from('service_types').delete().eq('id', id);
    } on PostgrestException catch (e) {
      if (e.code == '23503') {
        throw Exception(
          'This service has existing requests. Hide it from guests instead of deleting.',
        );
      }
      rethrow;
    }
  }

  Future<List<Profile>> fetchStaffProfiles({bool activeOnly = false}) async {
    var query = _client
        .from('profiles')
        .select('*, departments(name)')
        .inFilter('role', ['staff', 'admin']);
    if (activeOnly) {
      query = query.eq('is_active', true);
    }
    final rows = await query.order('full_name');
    return rows
        .map((row) => Profile.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<void> createStaffUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? departmentId,
  }) async {
    final response = await _client.functions.invoke(
      'admin-create-user',
      body: {
        'email': email.trim(),
        'password': password,
        'full_name': fullName.trim(),
        'role': role,
        'department_id': departmentId,
      },
    );
    if (response.status >= 400) {
      final data = response.data;
      final message = data is Map && data['error'] != null
          ? data['error'].toString()
          : 'Unable to create staff account.';
      throw Exception(message);
    }
  }

  Future<void> updateStaffUser({
    required String userId,
    required String fullName,
    required String role,
    String? departmentId,
    String? password,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{
      'user_id': userId,
      'full_name': fullName.trim(),
      'role': role,
      'department_id': departmentId,
      'is_active': ?isActive,
    };
    final trimmedPassword = password?.trim() ?? '';
    if (trimmedPassword.isNotEmpty) {
      body['password'] = trimmedPassword;
    }

    final response = await _client.functions.invoke(
      'admin-update-user',
      body: body,
    );
    if (response.status >= 400) {
      final data = response.data;
      final message = data is Map && data['error'] != null
          ? data['error'].toString()
          : 'Unable to update staff profile.';
      throw Exception(message);
    }
  }

  Future<String?> fetchHotelName() async {
    final row =
        await _client.from('hotel_settings').select('hotel_name').maybeSingle();
    return row?['hotel_name'] as String?;
  }

  Future<void> updateHotelName(String name) async {
    await _client.from('hotel_settings').upsert({
      'id': 1,
      'hotel_name': name.trim(),
    });
  }
}
