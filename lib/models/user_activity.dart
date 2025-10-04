class UserActivity {
  final int id;
  final String activityType;
  final String activityName;
  final DateTime activityDate;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  UserActivity({
    required this.id,
    required this.activityType,
    required this.activityName,
    required this.activityDate,
    this.metadata,
    required this.createdAt,
  });

  factory UserActivity.fromJson(Map<String, dynamic> json) {
    return UserActivity(
      id: json['id'] ?? 0,
      activityType: json['activity_type'] ?? '',
      activityName: json['activity_name'] ?? '',
      activityDate: DateTime.parse(json['activity_date'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity_type': activityType,
      'activity_name': activityName,
      'activity_date': activityDate.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper methods
  String get displayName {
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
        return activityName;
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

  // Get duration from metadata if available
  String? get duration {
    if (metadata != null) {
      if (metadata!['session_duration'] != null) {
        final minutes = metadata!['session_duration'];
        return '${minutes} menit';
      }
      if (metadata!['duration'] != null) {
        final minutes = metadata!['duration'];
        return '${minutes} menit';
      }
    }
    return null;
  }

  // Get additional info from metadata
  String? get additionalInfo {
    if (metadata != null) {
      if (metadata!['surah_name'] != null) {
        return 'Surah ${metadata!['surah_name']}';
      }
      if (metadata!['verses_count'] != null) {
        return '${metadata!['verses_count']} ayat';
      }
      if (metadata!['audio_title'] != null) {
        return metadata!['audio_title'];
      }
      if (metadata!['mood_level'] != null) {
        return 'Level: ${metadata!['mood_level']}';
      }
    }
    return null;
  }
}