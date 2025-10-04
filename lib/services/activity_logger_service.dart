import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ActivityLoggerService {
  static String get baseUrl => AppConfig.baseUrl;
  String? _token;
  static final ActivityLoggerService _instance = ActivityLoggerService._internal();
  
  factory ActivityLoggerService() => _instance;
  
  ActivityLoggerService._internal();

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  void setToken(String token) {
    _token = token;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('auth_token', token);
    });
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Activity Types Constants
  static const String TYPE_QURAN_READING = 'quran_reading';
  static const String TYPE_DZIKIR_SESSION = 'dzikir_session';
  static const String TYPE_BREATHING_EXERCISE = 'breathing_exercise';
  static const String TYPE_AUDIO_RELAXATION = 'audio_relaxation';
  static const String TYPE_JOURNAL_WRITING = 'journal_writing';
  static const String TYPE_QALBU_CHAT = 'qalbu_chat';
  static const String TYPE_PSYCHOLOGY_MATERIAL = 'psychology_material';
  static const String TYPE_APP_OPEN = 'app_open';
  static const String TYPE_MOOD_TRACKING = 'mood_tracking';

  /// Log any activity to the backend for daily recap tracking
  Future<bool> logActivity({
    required String activityType,
    required String activityTitle,
    int? referenceId,
    String? referenceTable,
    int? durationSeconds,
    double? completionPercentage,
    Map<String, dynamic>? metadata,
    DateTime? activityDate,
  }) async {
    try {
      await initialize();
      
      final body = {
        'activity_type': activityType,
        'activity_title': activityTitle,
        if (referenceId != null) 'reference_id': referenceId,
        if (referenceTable != null) 'reference_table': referenceTable,
        if (durationSeconds != null) 'duration_seconds': durationSeconds,
        if (completionPercentage != null) 'completion_percentage': completionPercentage,
        if (metadata != null) 'metadata': metadata,
        if (activityDate != null) 'activity_date': activityDate.toIso8601String().split('T')[0],
      };

      print('🔄 Logging activity: $activityType - $activityTitle');

      final response = await http.post(
        Uri.parse('$baseUrl/sakinah-tracker/log-activity'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Activity logged successfully: $activityTitle');
          return true;
        }
      }
      
      print('⚠️ Failed to log activity: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('❌ Error logging activity: $e');
      return false;
    }
  }

  /// Log QalbuChat session
  Future<bool> logQalbuChatSession({
    required String message,
    required String response,
    int? sessionDurationSeconds,
    String? userEmotion,
  }) async {
    return logActivity(
      activityType: TYPE_QALBU_CHAT,
      activityTitle: 'QalbuChat Session',
      durationSeconds: sessionDurationSeconds,
      completionPercentage: 100.0,
      metadata: {
        'user_message': message.length > 100 ? '${message.substring(0, 100)}...' : message,
        'response_length': response.length,
        'user_emotion': userEmotion,
        'interaction_type': 'chat',
      },
    );
  }

  /// Log Audio Listening session
  Future<bool> logAudioSession({
    required String audioTitle,
    required String categoryName,
    int? audioId,
    int? durationSeconds,
    double? completionPercentage,
    bool? isCompleted,
  }) async {
    return logActivity(
      activityType: TYPE_AUDIO_RELAXATION,
      activityTitle: audioTitle,
      referenceId: audioId,
      referenceTable: 'audio_relax',
      durationSeconds: durationSeconds,
      completionPercentage: isCompleted == true ? 100.0 : completionPercentage,
      metadata: {
        'category_name': categoryName,
        'audio_title': audioTitle,
        'is_completed': isCompleted ?? false,
      },
    );
  }

  /// Log Journal Writing session
  Future<bool> logJournalSession({
    required String journalTitle,
    required String content,
    int? journalId,
    String? mood,
    List<String>? tags,
    int? wordCount,
  }) async {
    return logActivity(
      activityType: TYPE_JOURNAL_WRITING,
      activityTitle: journalTitle,
      referenceId: journalId,
      referenceTable: 'journals',
      completionPercentage: 100.0,
      metadata: {
        'journal_title': journalTitle,
        'word_count': wordCount ?? content.split(' ').length,
        'mood_after': mood,
        'tags': tags,
        'has_reflection': content.isNotEmpty,
      },
    );
  }

  /// Log Quran Reading session
  Future<bool> logQuranReadingSession({
    required String surahName,
    int? surahNumber,
    int? ayahCount,
    int? durationSeconds,
    bool? isCompleted,
  }) async {
    return logActivity(
      activityType: TYPE_QURAN_READING,
      activityTitle: 'Membaca $surahName',
      durationSeconds: durationSeconds,
      completionPercentage: isCompleted == true ? 100.0 : 50.0,
      metadata: {
        'surah_name': surahName,
        'surah_number': surahNumber,
        'ayah_count': ayahCount,
        'reading_type': 'tilawah',
        'is_completed': isCompleted ?? false,
      },
    );
  }

  /// Log Dzikir session
  Future<bool> logDzikirSession({
    required String dzikirName,
    int? targetCount,
    int? completedCount,
    int? durationSeconds,
    String? moodBefore,
    String? moodAfter,
    bool? isCompleted,
  }) async {
    return logActivity(
      activityType: TYPE_DZIKIR_SESSION,
      activityTitle: 'Dzikir $dzikirName',
      durationSeconds: durationSeconds,
      completionPercentage: isCompleted == true ? 100.0 : 
          (targetCount != null && completedCount != null && targetCount > 0) 
              ? (completedCount / targetCount * 100).clamp(0.0, 100.0) 
              : 50.0,
      metadata: {
        'dzikir_name': dzikirName,
        'target_count': targetCount,
        'completed_count': completedCount,
        'mood_before': moodBefore,
        'mood_after': moodAfter,
        'is_completed': isCompleted ?? false,
      },
    );
  }

  /// Log Breathing Exercise session
  Future<bool> logBreathingSession({
    required String exerciseName,
    required String categoryName,
    int? exerciseId,
    int? durationSeconds,
    int? cyclesCompleted,
    bool? isCompleted,
    String? dzikirText,
  }) async {
    return logActivity(
      activityType: TYPE_BREATHING_EXERCISE,
      activityTitle: exerciseName,
      referenceId: exerciseId,
      referenceTable: 'breathing_exercises',
      durationSeconds: durationSeconds,
      completionPercentage: isCompleted == true ? 100.0 : 50.0,
      metadata: {
        'exercise_name': exerciseName,
        'category_name': categoryName,
        'cycles_completed': cyclesCompleted,
        'dzikir_text': dzikirText,
        'is_completed': isCompleted ?? false,
      },
    );
  }

  /// Log Psychology Material progress
  Future<bool> logPsychologyProgress({
    required String materialTitle,
    required String categoryName,
    int? materialId,
    int? durationSeconds,
    double? progressPercentage,
  }) async {
    return logActivity(
      activityType: TYPE_PSYCHOLOGY_MATERIAL,
      activityTitle: materialTitle,
      referenceId: materialId,
      referenceTable: 'psychology_materials',
      durationSeconds: durationSeconds,
      completionPercentage: progressPercentage,
      metadata: {
        'material_title': materialTitle,
        'category_name': categoryName,
        'learning_type': 'self_help',
      },
    );
  }

  /// Log Mood Tracking
  Future<bool> logMoodTracking({
    required String mood,
    required String moodContext,
    double? moodLevel,
    Map<String, dynamic>? additionalData,
  }) async {
    return logActivity(
      activityType: TYPE_MOOD_TRACKING,
      activityTitle: 'Pelacakan Mood',
      completionPercentage: 100.0,
      metadata: {
        'mood_type': mood,
        'mood_context': moodContext,
        'mood_level': moodLevel,
        'tracking_time': DateTime.now().toIso8601String(),
        ...?additionalData,
      },
    );
  }

  /// Log App Opening (for usage analytics)
  Future<bool> logAppOpen({
    String? entryPoint,
    Map<String, dynamic>? sessionData,
  }) async {
    return logActivity(
      activityType: TYPE_APP_OPEN,
      activityTitle: 'Membuka Aplikasi',
      completionPercentage: 100.0,
      metadata: {
        'entry_point': entryPoint ?? 'unknown',
        'session_start': DateTime.now().toIso8601String(),
        ...?sessionData,
      },
    );
  }

  /// Get daily recap (proxy to SakinahTrackerService)
  Future<Map<String, dynamic>?> getDailyRecap({DateTime? date}) async {
    try {
      await initialize();
      
      final dateParam = date?.toIso8601String().split('T')[0] ?? 
                       DateTime.now().toIso8601String().split('T')[0];
      
      final response = await http.get(
        Uri.parse('$baseUrl/sakinah-tracker/daily-recap?date=$dateParam'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting daily recap: $e');
      return null;
    }
  }

  /// Get activity streaks for motivation
  Future<Map<String, int>?> getActivityStreaks() async {
    try {
      await initialize();
      
      final response = await http.get(
        Uri.parse('$baseUrl/sakinah-tracker/streaks'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Map<String, int>.from(data['streaks']);
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting activity streaks: $e');
      return null;
    }
  }

  /// Get dashboard summary for home screen
  Future<Map<String, dynamic>?> getDashboardSummary() async {
    try {
      await initialize();
      
      final response = await http.get(
        Uri.parse('$baseUrl/sakinah-tracker/dashboard-summary'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['summary'];
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting dashboard summary: $e');
      return null;
    }
  }
}