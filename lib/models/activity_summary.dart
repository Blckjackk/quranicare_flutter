class ActivitySummary {
  final int totalActivities;
  final Map<String, int> activityTypeCount;
  final Map<String, dynamic> monthlyStats;
  final List<ActivityStreak> streaks;
  final double averageActivitiesPerDay;
  final int activeDays;

  ActivitySummary({
    required this.totalActivities,
    required this.activityTypeCount,
    required this.monthlyStats,
    required this.streaks,
    required this.averageActivitiesPerDay,
    required this.activeDays,
  });

  factory ActivitySummary.fromJson(Map<String, dynamic> json) {
    return ActivitySummary(
      totalActivities: json['total_activities'] ?? 0,
      activityTypeCount: Map<String, int>.from(json['activity_type_count'] ?? {}),
      monthlyStats: Map<String, dynamic>.from(json['monthly_stats'] ?? {}),
      streaks: (json['streaks'] as List? ?? [])
          .map((streak) => ActivityStreak.fromJson(streak))
          .toList(),
      averageActivitiesPerDay: (json['average_activities_per_day'] ?? 0.0).toDouble(),
      activeDays: json['active_days'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_activities': totalActivities,
      'activity_type_count': activityTypeCount,
      'monthly_stats': monthlyStats,
      'streaks': streaks.map((streak) => streak.toJson()).toList(),
      'average_activities_per_day': averageActivitiesPerDay,
      'active_days': activeDays,
    };
  }

  // Get the most active activity type
  String get mostActiveType {
    if (activityTypeCount.isEmpty) return '';
    
    String mostActive = '';
    int maxCount = 0;
    
    activityTypeCount.forEach((type, count) {
      if (count > maxCount) {
        maxCount = count;
        mostActive = type;
      }
    });
    
    return mostActive;
  }

  // Get display name for activity type
  String getActivityDisplayName(String activityType) {
    switch (activityType) {
      case 'quran_reading':
        return 'Membaca Al-Qur\'an';
      case 'dzikir_session':
        return 'Sesi Dzikir';
      case 'breathing_exercise':
        return 'Latihan Pernapasan';
      case 'audio_listening':
        return 'Mendengarkan Audio';
      case 'journal_entry':
        return 'Menulis Jurnal';
      case 'qalbuchat_session':
        return 'Sesi QalbuChat';
      case 'psychology_assessment':
        return 'Asesmen Psikologi';
      case 'mood_tracking':
        return 'Pelacakan Mood';
      default:
        return activityType;
    }
  }

  // Get activity percentage
  double getActivityPercentage(String activityType) {
    if (totalActivities == 0) return 0.0;
    final count = activityTypeCount[activityType] ?? 0;
    return (count / totalActivities) * 100;
  }
}

class ActivityStreak {
  final String activityType;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;

  ActivityStreak({
    required this.activityType,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
  });

  factory ActivityStreak.fromJson(Map<String, dynamic> json) {
    return ActivityStreak(
      activityType: json['activity_type'] ?? '',
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.parse(json['last_activity_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_type': activityType,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_activity_date': lastActivityDate?.toIso8601String(),
    };
  }

  String get displayName {
    switch (activityType) {
      case 'quran_reading':
        return 'Al-Qur\'an';
      case 'dzikir_session':
        return 'Dzikir';
      case 'breathing_exercise':
        return 'Pernapasan';
      case 'audio_listening':
        return 'Audio';
      case 'journal_entry':
        return 'Jurnal';
      case 'qalbuchat_session':
        return 'QalbuChat';
      case 'psychology_assessment':
        return 'Psikologi';
      case 'mood_tracking':
        return 'Mood';
      default:
        return activityType;
    }
  }

  String get iconEmoji {
    switch (activityType) {
      case 'quran_reading':
        return '📖';
      case 'dzikir_session':
        return '🤲';
      case 'breathing_exercise':
        return '🧘';
      case 'audio_listening':
        return '🎧';
      case 'journal_entry':
        return '📝';
      case 'qalbuchat_session':
        return '💬';
      case 'psychology_assessment':
        return '🧠';
      case 'mood_tracking':
        return '😊';
      default:
        return '✨';
    }
  }
}

class DailyActivityStats {
  final DateTime date;
  final int totalActivities;
  final Map<String, int> activityBreakdown;
  final bool hasActivity;

  DailyActivityStats({
    required this.date,
    required this.totalActivities,
    required this.activityBreakdown,
    required this.hasActivity,
  });

  factory DailyActivityStats.fromJson(Map<String, dynamic> json, DateTime date) {
    return DailyActivityStats(
      date: date,
      totalActivities: json['total'] ?? 0,
      activityBreakdown: Map<String, int>.from(json['activities'] ?? {}),
      hasActivity: (json['total'] ?? 0) > 0,
    );
  }
}