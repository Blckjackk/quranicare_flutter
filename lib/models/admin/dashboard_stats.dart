class DashboardStats {
  final UserStats userStats;
  final ContentStats contentStats;
  final List<ActivityData> recentActivity;

  DashboardStats({
    required this.userStats,
    required this.contentStats,
    required this.recentActivity,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      userStats: UserStats.fromJson(json['user_stats']),
      contentStats: ContentStats.fromJson(json['content_stats']),
      recentActivity: (json['recent_activity'] as List)
          .map((item) => ActivityData.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_stats': userStats.toJson(),
      'content_stats': contentStats.toJson(),
      'recent_activity': recentActivity.map((item) => item.toJson()).toList(),
    };
  }
}

class UserStats {
  final int totalUsers;
  final int activeUsers;
  final int newUsersToday;
  final int newUsersThisWeek;

  UserStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersToday,
    required this.newUsersThisWeek,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalUsers: json['total_users'],
      activeUsers: json['active_users'],
      newUsersToday: json['new_users_today'],
      newUsersThisWeek: json['new_users_this_week'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'active_users': activeUsers,
      'new_users_today': newUsersToday,
      'new_users_this_week': newUsersThisWeek,
    };
  }
}

class ContentStats {
  final int totalDzikirDoa;
  final int totalAudioRelax;
  final int totalPsychology;
  final int totalNotifications;
  final int newContentToday;
  final int newContentThisWeek;

  ContentStats({
    required this.totalDzikirDoa,
    required this.totalAudioRelax,
    required this.totalPsychology,
    required this.totalNotifications,
    required this.newContentToday,
    required this.newContentThisWeek,
  });

  factory ContentStats.fromJson(Map<String, dynamic> json) {
    return ContentStats(
      totalDzikirDoa: json['total_dzikir_doa'],
      totalAudioRelax: json['total_audio_relax'],
      totalPsychology: json['total_psychology'],
      totalNotifications: json['total_notifications'],
      newContentToday: json['new_content_today'],
      newContentThisWeek: json['new_content_this_week'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_dzikir_doa': totalDzikirDoa,
      'total_audio_relax': totalAudioRelax,
      'total_psychology': totalPsychology,
      'total_notifications': totalNotifications,
      'new_content_today': newContentToday,
      'new_content_this_week': newContentThisWeek,
    };
  }
}

class ActivityData {
  final String type;
  final String description;
  final String? adminName;
  final DateTime timestamp;

  ActivityData({
    required this.type,
    required this.description,
    this.adminName,
    required this.timestamp,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      type: json['type'],
      description: json['description'],
      adminName: json['admin_name'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'admin_name': adminName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}