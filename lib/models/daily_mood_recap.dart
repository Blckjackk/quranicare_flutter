class DailyMoodRecap {
  final String date;
  final List<MoodEntry> moodEntries;
  final DailyStats? dailyStats;
  final Map<String, dynamic> weeklyContext;
  final Map<String, dynamic> insights;

  DailyMoodRecap({
    required this.date,
    required this.moodEntries,
    this.dailyStats,
    required this.weeklyContext,
    required this.insights,
  });

  factory DailyMoodRecap.fromJson(Map<String, dynamic> json) {
    return DailyMoodRecap(
      date: json['date'] ?? '',
      moodEntries: (json['mood_entries'] as List?)
          ?.map((e) => MoodEntry.fromJson(e))
          .toList() ?? [],
      dailyStats: json['daily_stats'] != null 
          ? DailyStats.fromJson(json['daily_stats'])
          : null,
      weeklyContext: json['weekly_context'] ?? {},
      insights: json['insights'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'mood_entries': moodEntries.map((e) => e.toJson()).toList(),
      'daily_stats': dailyStats?.toJson(),
      'weekly_context': weeklyContext,
      'insights': insights,
    };
  }
}

class MoodEntry {
  final int id;
  final String moodType;
  final String moodLabel;
  final String moodEmoji;
  final double moodScore;
  final String? notes;
  final DateTime timestamp;

  MoodEntry({
    required this.id,
    required this.moodType,
    required this.moodLabel,
    required this.moodEmoji,
    required this.moodScore,
    this.notes,
    required this.timestamp,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] ?? 0,
      moodType: json['mood_type'] ?? '',
      moodLabel: json['mood_label'] ?? '',
      moodEmoji: json['mood_emoji'] ?? '😐',
      moodScore: (json['mood_score'] ?? 0).toDouble(),
      notes: json['notes'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood_type': moodType,
      'mood_label': moodLabel,
      'mood_emoji': moodEmoji,
      'mood_score': moodScore,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get timeFormatted {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class DailyStats {
  final double averageMood;
  final int totalEntries;
  final String dominantMood;
  final Map<String, int> moodCounts;

  DailyStats({
    required this.averageMood,
    required this.totalEntries,
    required this.dominantMood,
    required this.moodCounts,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      averageMood: (json['average_mood'] ?? 0).toDouble(),
      totalEntries: json['total_entries'] ?? 0,
      dominantMood: json['dominant_mood'] ?? '',
      moodCounts: Map<String, int>.from(json['mood_counts'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_mood': averageMood,
      'total_entries': totalEntries,
      'dominant_mood': dominantMood,
      'mood_counts': moodCounts,
    };
  }
}

class MonthlyOverview {
  final int year;
  final int month;
  final Map<String, MoodData> calendarData;
  final Map<String, dynamic> monthlyStats;

  MonthlyOverview({
    required this.year,
    required this.month,
    required this.calendarData,
    required this.monthlyStats,
  });

  factory MonthlyOverview.fromJson(Map<String, dynamic> json) {
    return MonthlyOverview(
      year: json['year'] ?? DateTime.now().year,
      month: json['month'] ?? DateTime.now().month,
      calendarData: (json['calendar_data'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, MoodData.fromJson(value)))
          ?? {},
      monthlyStats: json['monthly_stats'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'calendar_data': calendarData.map((key, value) => MapEntry(key, value.toJson())),
      'monthly_stats': monthlyStats,
    };
  }
}

class MoodData {
  final double moodScore;
  final int entryCount;
  final String dominantMood;

  MoodData({
    required this.moodScore,
    required this.entryCount,
    required this.dominantMood,
  });

  factory MoodData.fromJson(Map<String, dynamic> json) {
    return MoodData(
      moodScore: (json['mood_score'] ?? 0).toDouble(),
      entryCount: json['entry_count'] ?? 0,
      dominantMood: json['dominant_mood'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mood_score': moodScore,
      'entry_count': entryCount,
      'dominant_mood': dominantMood,
    };
  }
}