class BreathingCategoryDb {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<BreathingExerciseDb>? exercises;

  BreathingCategoryDb({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.exercises,
  });

  factory BreathingCategoryDb.fromJson(Map<String, dynamic> json) {
    return BreathingCategoryDb(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      exercises: json['exercises'] != null 
          ? (json['exercises'] as List).map((e) => BreathingExerciseDb.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'exercises': exercises?.map((e) => e.toJson()).toList(),
    };
  }
}

class BreathingExerciseDb {
  final int id;
  final int breathingCategoryId;
  final String name;
  final String? description;
  final String dzikirText;
  final String? audioPath;
  final int inhaleDuration;
  final int holdDuration;
  final int exhaleDuration;
  final int totalCycleDuration;
  final int defaultRepetitions;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final BreathingCategoryDb? breathingCategory;

  BreathingExerciseDb({
    required this.id,
    required this.breathingCategoryId,
    required this.name,
    this.description,
    required this.dzikirText,
    this.audioPath,
    required this.inhaleDuration,
    required this.holdDuration,
    required this.exhaleDuration,
    required this.totalCycleDuration,
    required this.defaultRepetitions,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.breathingCategory,
  });

  factory BreathingExerciseDb.fromJson(Map<String, dynamic> json) {
    return BreathingExerciseDb(
      id: json['id'],
      breathingCategoryId: json['breathing_category_id'],
      name: json['name'],
      description: json['description'],
      dzikirText: json['dzikir_text'],
      audioPath: json['audio_path'],
      inhaleDuration: json['inhale_duration'] ?? 4,
      holdDuration: json['hold_duration'] ?? 4,
      exhaleDuration: json['exhale_duration'] ?? 4,
      totalCycleDuration: json['total_cycle_duration'] ?? 12,
      defaultRepetitions: json['default_repetitions'] ?? 7,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      breathingCategory: json['breathing_category'] != null 
          ? BreathingCategoryDb.fromJson(json['breathing_category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'breathing_category_id': breathingCategoryId,
      'name': name,
      'description': description,
      'dzikir_text': dzikirText,
      'audio_path': audioPath,
      'inhale_duration': inhaleDuration,
      'hold_duration': holdDuration,
      'exhale_duration': exhaleDuration,
      'total_cycle_duration': totalCycleDuration,
      'default_repetitions': defaultRepetitions,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'breathing_category': breathingCategory?.toJson(),
    };
  }

  // Calculate duration for given repetitions in seconds
  int calculateDurationSeconds(int repetitions) {
    return totalCycleDuration * repetitions;
  }

  // Calculate duration for given repetitions in minutes
  double calculateDurationMinutes(int repetitions) {
    return calculateDurationSeconds(repetitions) / 60.0;
  }

  // Calculate repetitions needed for given minutes
  int getRepetitionsForMinutes(int minutes) {
    return ((minutes * 60) / totalCycleDuration).ceil();
  }

  // Get audio URL if exists
  bool get hasAudio => audioPath != null && audioPath!.isNotEmpty;

  // Check if this is a YouTube audio
  bool get isYouTubeAudio {
    if (!hasAudio) return false;
    return audioPath!.contains('youtube.com') || audioPath!.contains('youtu.be');
  }

  // Extract YouTube video ID
  String? get youTubeVideoId {
    if (!isYouTubeAudio) return null;
    final regex = RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]+)');
    final match = regex.firstMatch(audioPath!);
    return match?.group(1);
  }

  // Get formatted duration text
  String get formattedDuration {
    int totalSeconds = totalCycleDuration;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Get breathing cycle text
  String get breathingCycleText {
    return 'Tarik $inhaleDuration"s • Tahan $holdDuration"s • Hembuskan $exhaleDuration"s';
  }
}

class BreathingSessionDb {
  final int id;
  final int userId;
  final int breathingExerciseId;
  final int plannedDurationMinutes;
  final int? actualDurationSeconds;
  final int completedCycles;
  final bool completed;
  final String? notes;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final BreathingExerciseDb? breathingExercise;

  BreathingSessionDb({
    required this.id,
    required this.userId,
    required this.breathingExerciseId,
    required this.plannedDurationMinutes,
    this.actualDurationSeconds,
    required this.completedCycles,
    required this.completed,
    this.notes,
    required this.startedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.breathingExercise,
  });

  factory BreathingSessionDb.fromJson(Map<String, dynamic> json) {
    return BreathingSessionDb(
      id: json['id'],
      userId: json['user_id'],
      breathingExerciseId: json['breathing_exercise_id'],
      plannedDurationMinutes: json['planned_duration_minutes'],
      actualDurationSeconds: json['actual_duration_seconds'],
      completedCycles: json['completed_cycles'] ?? 0,
      completed: json['completed'] ?? false,
      notes: json['notes'],
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      breathingExercise: json['breathing_exercise'] != null 
          ? BreathingExerciseDb.fromJson(json['breathing_exercise'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'breathing_exercise_id': breathingExerciseId,
      'planned_duration_minutes': plannedDurationMinutes,
      'actual_duration_seconds': actualDurationSeconds,
      'completed_cycles': completedCycles,
      'completed': completed,
      'notes': notes,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'breathing_exercise': breathingExercise?.toJson(),
    };
  }

  // Calculate actual duration in minutes
  double get actualDurationMinutes {
    return actualDurationSeconds != null ? actualDurationSeconds! / 60.0 : 0.0;
  }

  // Calculate progress percentage
  double get progressPercentage {
    if (plannedDurationMinutes == 0) return 0.0;
    return (actualDurationMinutes / plannedDurationMinutes * 100).clamp(0.0, 100.0);
  }

  // Check if session is currently in progress
  bool get isInProgress {
    return !completed && completedAt == null;
  }

  // Get formatted actual duration
  String get formattedActualDuration {
    if (actualDurationSeconds == null) return '00:00';
    int minutes = actualDurationSeconds! ~/ 60;
    int seconds = actualDurationSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Get formatted planned duration
  String get formattedPlannedDuration {
    return '${plannedDurationMinutes.toString().padLeft(2, '0')}:00';
  }
}