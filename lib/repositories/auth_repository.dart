import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  SessionUser? currentSessionUser() {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fromUser(user);
  }

  Stream<SessionUser?> authStateChanges() {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return _fromUser(user);
    });
  }

  SessionUser _fromUser(User user) {
    final meta = user.appMetadata;
    final roleStr = (meta['role'] as String?) ?? 'guest';
    final role = switch (roleStr) {
      'admin' => UserRole.admin,
      'staff' => UserRole.staff,
      _ => UserRole.guest,
    };
    return SessionUser(
      id: user.id,
      role: role,
      stayId: meta['stay_id'] as String?,
      roomId: meta['room_id'] as String?,
      fullName: user.userMetadata?['full_name'] as String?,
      departmentId: meta['department_id'] as String?,
    );
  }

  Future<SessionUser> guestSignIn({
    required String roomNumber,
    required String checkInCode,
  }) async {
    final response = await _client.functions.invoke(
      'guest-sign-in',
      body: {
        'room_number': roomNumber.trim(),
        'check_in_code': checkInCode.trim(),
      },
    );

    if (response.status >= 400) {
      final data = response.data;
      final message = data is Map && data['error'] != null
          ? data['error'].toString()
          : 'Unable to sign in with that room and code.';
      throw Exception(message);
    }

    final data = Map<String, dynamic>.from(response.data as Map);
    final email = data['email'] as String;
    final password = data['password'] as String;

    final auth = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = auth.user;
    if (user == null) {
      throw Exception('Guest sign-in failed.');
    }
    return _fromUser(user);
  }

  Future<SessionUser> staffSignIn({
    required String email,
    required String password,
  }) async {
    try {
      final auth = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = auth.user;
      if (user == null) {
        throw Exception('Unable to sign in. Please try again.');
      }
      final sessionUser = _fromUser(user);
      if (!sessionUser.isStaff) {
        await _client.auth.signOut();
        throw Exception('This account is not a staff account.');
      }
      if (kIsWeb && sessionUser.isGuest) {
        await _client.auth.signOut();
        throw Exception('Guests use the mobile app.');
      }
      final profile = await fetchMyProfile();
      if (profile != null && !profile.isActive) {
        await _client.auth.signOut();
        throw Exception('This staff account is deactivated. Contact an admin.');
      }
      return sessionUser;
    } on AuthException {
      rethrow;
    }
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<Profile?> fetchMyProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final data = await _client
        .from('profiles')
        .select('*, departments(name)')
        .eq('id', user.id)
        .maybeSingle();
    if (data == null) return null;
    return Profile.fromMap(Map<String, dynamic>.from(data));
  }
}
