import 'package:cloud_firestore/cloud_firestore.dart';

// Model untuk Audio Configuration
class AudioConfig {
  final String? inhaleAudio;
  final String? holdAudio;
  final String? exhaleAudio;
  final String? backgroundMusic;

  AudioConfig({
    this.inhaleAudio,
    this.holdAudio,
    this.exhaleAudio,
    this.backgroundMusic,
  });

  Map<String, dynamic> toMap() {
    return {
      'inhale_audio': inhaleAudio,
      'hold_audio': holdAudio,
      'exhale_audio': exhaleAudio,
      'background_music': backgroundMusic,
    };
  }

  factory AudioConfig.fromMap(Map<String, dynamic> map) {
    return AudioConfig(
      inhaleAudio: map['inhale_audio'],
      holdAudio: map['hold_audio'],
      exhaleAudio: map['exhale_audio'],
      backgroundMusic: map['background_music'],
    );
  }
}

// Model untuk Dzikir Text
class DzikirText {
  final String inhaleText;
  final String inhaleTranslation;
  final String exhaleText;
  final String exhaleTranslation;

  DzikirText({
    required this.inhaleText,
    required this.inhaleTranslation,
    required this.exhaleText,
    required this.exhaleTranslation,
  });

  Map<String, dynamic> toMap() {
    return {
      'inhale_text': inhaleText,
      'inhale_translation': inhaleTranslation,
      'exhale_text': exhaleText,
      'exhale_translation': exhaleTranslation,
    };
  }

  factory DzikirText.fromMap(Map<String, dynamic> map) {
    return DzikirText(
      inhaleText: map['inhale_text'] ?? '',
      inhaleTranslation: map['inhale_translation'] ?? '',
      exhaleText: map['exhale_text'] ?? '',
      exhaleTranslation: map['exhale_translation'] ?? '',
    );
  }
}

// Model untuk Breathing Pattern (timing)
class BreathingPattern {
  final int inhaleDuration;    // detik
  final int holdDuration;      // detik
  final int exhaleDuration;    // detik
  final int restDuration;      // detik antar siklus
  final int totalCycleDuration; // total durasi per siklus

  BreathingPattern({
    required this.inhaleDuration,
    required this.holdDuration,
    required this.exhaleDuration,
    required this.restDuration,
    required this.totalCycleDuration,
  });

  Map<String, dynamic> toMap() {
    return {
      'inhale_duration': inhaleDuration,
      'hold_duration': holdDuration,
      'exhale_duration': exhaleDuration,
      'rest_duration': restDuration,
      'total_cycle_duration': totalCycleDuration,
    };
  }

  factory BreathingPattern.fromMap(Map<String, dynamic> map) {
    return BreathingPattern(
      inhaleDuration: map['inhale_duration'] ?? 3,
      holdDuration: map['hold_duration'] ?? 2,
      exhaleDuration: map['exhale_duration'] ?? 5,
      restDuration: map['rest_duration'] ?? 1,
      totalCycleDuration: map['total_cycle_duration'] ?? 11,
    );
  }
}

// Model untuk Repetition Settings
class RepetitionSettings {
  final int cyclesPerSession;
  final int totalSessions;
  final int breakBetweenSessions; // detik

  RepetitionSettings({
    required this.cyclesPerSession,
    required this.totalSessions,
    required this.breakBetweenSessions,
  });

  Map<String, dynamic> toMap() {
    return {
      'cycles_per_session': cyclesPerSession,
      'total_sessions': totalSessions,
      'break_between_sessions': breakBetweenSessions,
    };
  }

  factory RepetitionSettings.fromMap(Map<String, dynamic> map) {
    return RepetitionSettings(
      cyclesPerSession: map['cycles_per_session'] ?? 10,
      totalSessions: map['total_sessions'] ?? 1,
      breakBetweenSessions: map['break_between_sessions'] ?? 60,
    );
  }
}

// Main Model untuk Breathing Exercise
class BreathingExercise {
  final String id;
  final String name;
  final String description;
  final String category;
  final int difficultyLevel;
  final int totalDuration; // detik
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AudioConfig audioConfig;
  final DzikirText dzikirText;
  final BreathingPattern breathingPattern;
  final RepetitionSettings repetition;

  BreathingExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficultyLevel,
    required this.totalDuration,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.audioConfig,
    required this.dzikirText,
    required this.breathingPattern,
    required this.repetition,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'difficulty_level': difficultyLevel,
      'total_duration': totalDuration,
      'is_active': isActive,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'audio_config': audioConfig.toMap(),
      'dzikir_text': dzikirText.toMap(),
      'breathing_pattern': breathingPattern.toMap(),
      'repetition': repetition.toMap(),
    };
  }

  factory BreathingExercise.fromMap(Map<String, dynamic> map) {
    return BreathingExercise(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'basic',
      difficultyLevel: map['difficulty_level'] ?? 1,
      totalDuration: map['total_duration'] ?? 300,
      isActive: map['is_active'] ?? true,
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      audioConfig: AudioConfig.fromMap(map['audio_config'] ?? {}),
      dzikirText: DzikirText.fromMap(map['dzikir_text'] ?? {}),
      breathingPattern: BreathingPattern.fromMap(map['breathing_pattern'] ?? {}),
      repetition: RepetitionSettings.fromMap(map['repetition'] ?? {}),
    );
  }

  factory BreathingExercise.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BreathingExercise.fromMap(data);
  }

  // Helper methods
  int get totalSessionDuration => repetition.cyclesPerSession * breathingPattern.totalCycleDuration;
  
  String get formattedDuration {
    int minutes = totalDuration ~/ 60;
    int seconds = totalDuration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get difficultyText {
    switch (difficultyLevel) {
      case 1:
        return 'Pemula';
      case 2:
        return 'Menengah';
      case 3:
        return 'Lanjutan';
      case 4:
        return 'Ahli';
      case 5:
        return 'Master';
      default:
        return 'Pemula';
    }
  }
}

// Model untuk User Session (tracking user progress)
class BreathingSession {
  final String id;
  final String userId;
  final String exerciseId;
  final String exerciseName;
  final DateTime sessionDate;
  final SessionStats sessionStats;
  final MoodTracking moodTracking;

  BreathingSession({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.exerciseName,
    required this.sessionDate,
    required this.sessionStats,
    required this.moodTracking,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'session_date': Timestamp.fromDate(sessionDate),
      'session_stats': sessionStats.toMap(),
      'mood_tracking': moodTracking.toMap(),
    };
  }

  factory BreathingSession.fromMap(Map<String, dynamic> map) {
    return BreathingSession(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      exerciseId: map['exercise_id'] ?? '',
      exerciseName: map['exercise_name'] ?? '',
      sessionDate: (map['session_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sessionStats: SessionStats.fromMap(map['session_stats'] ?? {}),
      moodTracking: MoodTracking.fromMap(map['mood_tracking'] ?? {}),
    );
  }
}

// Model untuk Session Statistics
class SessionStats {
  final int plannedDuration;
  final int actualDuration;
  final int completedCycles;
  final double completionPercentage;
  final bool isCompleted;

  SessionStats({
    required this.plannedDuration,
    required this.actualDuration,
    required this.completedCycles,
    required this.completionPercentage,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'planned_duration': plannedDuration,
      'actual_duration': actualDuration,
      'completed_cycles': completedCycles,
      'completion_percentage': completionPercentage,
      'is_completed': isCompleted,
    };
  }

  factory SessionStats.fromMap(Map<String, dynamic> map) {
    return SessionStats(
      plannedDuration: map['planned_duration'] ?? 0,
      actualDuration: map['actual_duration'] ?? 0,
      completedCycles: map['completed_cycles'] ?? 0,
      completionPercentage: (map['completion_percentage'] ?? 0.0).toDouble(),
      isCompleted: map['is_completed'] ?? false,
    );
  }
}

// Model untuk Mood Tracking
class MoodTracking {
  final String moodBefore;
  final String moodAfter;
  final int stressLevelBefore;
  final int stressLevelAfter;
  final String notes;

  MoodTracking({
    required this.moodBefore,
    required this.moodAfter,
    required this.stressLevelBefore,
    required this.stressLevelAfter,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      'stress_level_before': stressLevelBefore,
      'stress_level_after': stressLevelAfter,
      'notes': notes,
    };
  }

  factory MoodTracking.fromMap(Map<String, dynamic> map) {
    return MoodTracking(
      moodBefore: map['mood_before'] ?? '',
      moodAfter: map['mood_after'] ?? '',
      stressLevelBefore: map['stress_level_before'] ?? 5,
      stressLevelAfter: map['stress_level_after'] ?? 5,
      notes: map['notes'] ?? '',
    );
  }
}

// Model untuk Category
class BreathingCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final int order;

  BreathingCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'order': order,
    };
  }

  factory BreathingCategory.fromMap(Map<String, dynamic> map) {
    return BreathingCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '🌱',
      color: map['color'] ?? '#4CAF50',
      order: map['order'] ?? 1,
    );
  }
}