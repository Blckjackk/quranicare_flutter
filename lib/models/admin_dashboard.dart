class DashboardStats {
  final UserStats users;
  final ContentStats content;
  final ActivityData activity;

  DashboardStats({
    required this.users,
    required this.content,
    required this.activity,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      users: UserStats.fromJson(json['users']),
      content: ContentStats.fromJson(json['content']),
      activity: ActivityData.fromJson(json['activity']),
    );
  }
}

class UserStats {
  final int total;
  final int active;
  final int newThisMonth;

  UserStats({
    required this.total,
    required this.active,
    required this.newThisMonth,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      total: json['total'],
      active: json['active'],
      newThisMonth: json['new_this_month'],
    );
  }
}

class ContentStats {
  final int dzikirDoa;
  final int audioRelax;
  final int psychologyMaterials;
  final int notifications;

  ContentStats({
    required this.dzikirDoa,
    required this.audioRelax,
    required this.psychologyMaterials,
    required this.notifications,
  });

  factory ContentStats.fromJson(Map<String, dynamic> json) {
    return ContentStats(
      dzikirDoa: json['dzikir_doa'],
      audioRelax: json['audio_relax'],
      psychologyMaterials: json['psychology_materials'],
      notifications: json['notifications'],
    );
  }
}

class ActivityData {
  final List<RecentUser> recentUsers;
  final RecentContent recentContent;

  ActivityData({
    required this.recentUsers,
    required this.recentContent,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      recentUsers: (json['recent_users'] as List)
          .map((user) => RecentUser.fromJson(user))
          .toList(),
      recentContent: RecentContent.fromJson(json['recent_content']),
    );
  }
}

class RecentUser {
  final int id;
  final String name;
  final String email;
  final DateTime createdAt;

  RecentUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory RecentUser.fromJson(Map<String, dynamic> json) {
    return RecentUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class RecentContent {
  final List<ContentItem> dzikir;
  final List<ContentItem> audio;
  final List<ContentItem> psychology;

  RecentContent({
    required this.dzikir,
    required this.audio,
    required this.psychology,
  });

  factory RecentContent.fromJson(Map<String, dynamic> json) {
    return RecentContent(
      dzikir: (json['dzikir'] as List)
          .map((item) => ContentItem.fromJson(item))
          .toList(),
      audio: (json['audio'] as List)
          .map((item) => ContentItem.fromJson(item))
          .toList(),
      psychology: (json['psychology'] as List)
          .map((item) => ContentItem.fromJson(item))
          .toList(),
    );
  }
}

class ContentItem {
  final int id;
  final String title;
  final DateTime createdAt;

  ContentItem({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}