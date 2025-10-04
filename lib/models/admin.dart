class Admin {
  final int id;
  final String name;
  final String email;
  final String role;
  final Map<String, dynamic> permissions;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    this.lastLoginAt,
    this.createdAt,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      permissions: Map<String, dynamic>.from(json['permissions'] ?? {}),
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at']) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'permissions': permissions,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool get isSuperAdmin => role == 'super_admin';
  bool get isContentAdmin => role == 'content_admin';
  bool get isModerator => role == 'moderator';

  bool canManageContent() {
    return ['super_admin', 'content_admin'].contains(role) || 
           (permissions['manage_content'] == true);
  }

  bool canManageUsers() {
    return role == 'super_admin' || 
           (permissions['manage_users'] == true);
  }

  bool canModerate() {
    return ['super_admin', 'moderator'].contains(role) || 
           (permissions['moderate_content'] == true);
  }

  bool hasPermission(String permission) {
    return role == 'super_admin' || (permissions[permission] == true);
  }
}