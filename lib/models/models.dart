enum UserRole { guest, staff, admin }

enum RequestStatus { pending, inProgress, completed }

extension RequestStatusX on RequestStatus {
  String get dbValue => switch (this) {
        RequestStatus.pending => 'pending',
        RequestStatus.inProgress => 'in_progress',
        RequestStatus.completed => 'completed',
      };

  String get label => switch (this) {
        RequestStatus.pending => 'Pending',
        RequestStatus.inProgress => 'In Progress',
        RequestStatus.completed => 'Completed',
      };

  static RequestStatus fromDb(String value) => switch (value) {
        'in_progress' => RequestStatus.inProgress,
        'completed' => RequestStatus.completed,
        _ => RequestStatus.pending,
      };
}

class Department {
  const Department({required this.id, required this.name});

  final String id;
  final String name;

  factory Department.fromMap(Map<String, dynamic> map) => Department(
        id: map['id'] as String,
        name: map['name'] as String,
      );
}

class Room {
  const Room({
    required this.id,
    required this.roomNumber,
    required this.isActive,
  });

  final String id;
  final String roomNumber;
  final bool isActive;

  factory Room.fromMap(Map<String, dynamic> map) => Room(
        id: map['id'] as String,
        roomNumber: map['room_number'] as String,
        isActive: map['is_active'] as bool? ?? true,
      );
}

class Stay {
  const Stay({
    required this.id,
    required this.roomId,
    required this.isActive,
    this.roomNumber,
    this.guestUserId,
  });

  final String id;
  final String roomId;
  final bool isActive;
  final String? roomNumber;
  final String? guestUserId;

  factory Stay.fromMap(Map<String, dynamic> map) {
    final room = map['rooms'];
    String? roomNumber;
    if (room is Map<String, dynamic>) {
      roomNumber = room['room_number'] as String?;
    }
    return Stay(
      id: map['id'] as String,
      roomId: map['room_id'] as String,
      isActive: map['is_active'] as bool? ?? true,
      roomNumber: roomNumber,
      guestUserId: map['guest_user_id'] as String?,
    );
  }
}

class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    required this.role,
    this.departmentId,
    this.departmentName,
    this.isActive = true,
  });

  final String id;
  final String fullName;
  final UserRole role;
  final String? departmentId;
  final String? departmentName;
  final bool isActive;

  factory Profile.fromMap(Map<String, dynamic> map) {
    final dept = map['departments'];
    String? departmentName;
    if (dept is Map<String, dynamic>) {
      departmentName = dept['name'] as String?;
    }
    final roleStr = map['role'] as String? ?? 'staff';
    return Profile(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? 'Staff',
      role: roleStr == 'admin' ? UserRole.admin : UserRole.staff,
      departmentId: map['department_id'] as String?,
      departmentName: departmentName,
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}

class ServiceType {
  const ServiceType({
    required this.id,
    required this.name,
    required this.allowsQuantity,
    required this.sortOrder,
    required this.isHidden,
    this.defaultDepartmentId,
  });

  final String id;
  final String name;
  final bool allowsQuantity;
  final int sortOrder;
  final bool isHidden;
  final String? defaultDepartmentId;

  factory ServiceType.fromMap(Map<String, dynamic> map) => ServiceType(
        id: map['id'] as String,
        name: map['name'] as String,
        allowsQuantity: map['allows_quantity'] as bool? ?? false,
        sortOrder: map['sort_order'] as int? ?? 0,
        isHidden: map['is_hidden'] as bool? ?? false,
        defaultDepartmentId: map['default_department_id'] as String?,
      );

  ServiceType copyWith({
    String? name,
    bool? allowsQuantity,
    int? sortOrder,
    bool? isHidden,
    String? defaultDepartmentId,
  }) =>
      ServiceType(
        id: id,
        name: name ?? this.name,
        allowsQuantity: allowsQuantity ?? this.allowsQuantity,
        sortOrder: sortOrder ?? this.sortOrder,
        isHidden: isHidden ?? this.isHidden,
        defaultDepartmentId:
            defaultDepartmentId ?? this.defaultDepartmentId,
      );
}

class ServiceRequest {
  const ServiceRequest({
    required this.id,
    required this.stayId,
    required this.roomId,
    required this.serviceTypeId,
    required this.status,
    required this.createdAt,
    this.quantity,
    this.notes,
    this.assignedDepartmentId,
    this.assignedStaffId,
    this.updatedAt,
    this.serviceTypeName,
    this.roomNumber,
    this.assignedDepartmentName,
    this.assignedStaffName,
  });

  final String id;
  final String stayId;
  final String roomId;
  final String serviceTypeId;
  final RequestStatus status;
  final DateTime createdAt;
  final int? quantity;
  final String? notes;
  final String? assignedDepartmentId;
  final String? assignedStaffId;
  final DateTime? updatedAt;
  final String? serviceTypeName;
  final String? roomNumber;
  final String? assignedDepartmentName;
  final String? assignedStaffName;

  String get displayTitle {
    final name = serviceTypeName ?? 'Request';
    final short = id.length >= 5 ? id.substring(0, 5).toUpperCase() : id;
    return '$name #$short';
  }

  factory ServiceRequest.fromMap(Map<String, dynamic> map) {
    final serviceType = map['service_types'];
    final room = map['rooms'];
    final dept = map['departments'];
    final staff = map['profiles'];

    String? serviceTypeName;
    if (serviceType is Map<String, dynamic>) {
      serviceTypeName = serviceType['name'] as String?;
    }
    String? roomNumber;
    if (room is Map<String, dynamic>) {
      roomNumber = room['room_number'] as String?;
    }
    String? assignedDepartmentName;
    if (dept is Map<String, dynamic>) {
      assignedDepartmentName = dept['name'] as String?;
    }
    String? assignedStaffName;
    if (staff is Map<String, dynamic>) {
      assignedStaffName = staff['full_name'] as String?;
    }

    return ServiceRequest(
      id: map['id'] as String,
      stayId: map['stay_id'] as String,
      roomId: map['room_id'] as String,
      serviceTypeId: map['service_type_id'] as String,
      status: RequestStatusX.fromDb(map['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(map['created_at'] as String),
      quantity: map['quantity'] as int?,
      notes: map['notes'] as String?,
      assignedDepartmentId: map['assigned_department_id'] as String?,
      assignedStaffId: map['assigned_staff_id'] as String?,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      serviceTypeName: serviceTypeName,
      roomNumber: roomNumber,
      assignedDepartmentName: assignedDepartmentName,
      assignedStaffName: assignedStaffName,
    );
  }
}

class RequestEvent {
  const RequestEvent({
    required this.id,
    required this.requestId,
    required this.eventType,
    required this.actorName,
    required this.createdAt,
    this.fromStatus,
    this.toStatus,
    this.note,
  });

  final String id;
  final String requestId;
  final String eventType;
  final String actorName;
  final DateTime createdAt;
  final String? fromStatus;
  final String? toStatus;
  final String? note;

  factory RequestEvent.fromMap(Map<String, dynamic> map) => RequestEvent(
        id: map['id'] as String,
        requestId: map['request_id'] as String,
        eventType: map['event_type'] as String,
        actorName: map['actor_name'] as String? ?? 'System',
        createdAt: DateTime.parse(map['created_at'] as String),
        fromStatus: map['from_status'] as String?,
        toStatus: map['to_status'] as String?,
        note: map['note'] as String?,
      );
}

class SessionUser {
  const SessionUser({
    required this.id,
    required this.role,
    this.stayId,
    this.roomId,
    this.fullName,
    this.departmentId,
  });

  final String id;
  final UserRole role;
  final String? stayId;
  final String? roomId;
  final String? fullName;
  final String? departmentId;

  bool get isGuest => role == UserRole.guest;
  bool get isStaff => role == UserRole.staff || role == UserRole.admin;
  bool get isAdmin => role == UserRole.admin;
}
