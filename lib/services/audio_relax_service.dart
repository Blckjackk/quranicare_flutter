import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/audio_relax.dart';
import '../config/app_config.dart';
import 'activity_logger_service.dart';

class AudioRelaxService {
  final ActivityLoggerService _activityLogger = ActivityLoggerService();
  
  // Track listening session data
  DateTime? _sessionStart;
  String? _currentAudioTitle;
  String? _currentCategoryName;
  int? _currentAudioId;

  // Get all audio categories
  Future<List<AudioCategory>> getAllCategories() async {
    try {
      final response = await http.get(
        Uri.parse(AppConfig.audioCategoriesUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => AudioCategory.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load audio categories');
        }
      } else {
        throw Exception('Failed to load audio categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading audio categories: $e');
    }
  }

  // Get audio by category
  Future<Map<String, dynamic>> getAudioByCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/audio-relax/category/$categoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final audioList = (data['data'] as List)
              .map((json) => AudioRelax.fromJson(json))
              .toList();
          
          return {
            'audio_list': audioList,
            'category': data['category'],
            'total': data['total'] ?? audioList.length,
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to load audio by category');
        }
      } else {
        throw Exception('Failed to load audio by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading audio by category: $e');
    }
  }

  // Get single audio detail
  Future<AudioRelax> getAudioById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/audio-relax/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return AudioRelax.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load audio detail');
        }
      } else {
        throw Exception('Failed to load audio detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading audio detail: $e');
    }
  }

  // Get popular/featured audio
  Future<List<AudioRelax>> getPopularAudio() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/audio-relax/popular'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => AudioRelax.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load popular audio');
        }
      } else {
        throw Exception('Failed to load popular audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading popular audio: $e');
    }
  }

  // Search audio
  Future<List<AudioRelax>> searchAudio(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/audio-relax/search?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => AudioRelax.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to search audio');
        }
      } else {
        throw Exception('Failed to search audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching audio: $e');
    }
  }

  // Update play count
  Future<bool> updatePlayCount(int audioId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/audio-relax/$audioId/play'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Rate audio
  Future<bool> rateAudio(int audioId, double rating) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/audio-relax/$audioId/rate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'rating': rating,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Start audio listening session for activity tracking
  Future<void> startAudioSession({
    required String audioTitle,
    required String categoryName,
    int? audioId,
  }) async {
    try {
      _sessionStart = DateTime.now();
      _currentAudioTitle = audioTitle;
      _currentCategoryName = categoryName;
      _currentAudioId = audioId;
      
      print('🎵 Starting audio session: $audioTitle');
      
      // Update play count
      if (audioId != null) {
        await updatePlayCount(audioId);
      }
    } catch (e) {
      print('⚠ Failed to start audio session: $e');
    }
  }

  /// End audio listening session and log activity
  Future<void> endAudioSession({
    bool? isCompleted,
    double? completionPercentage,
  }) async {
    if (_sessionStart == null || _currentAudioTitle == null) {
      return;
    }

    try {
      final duration = DateTime.now().difference(_sessionStart!).inSeconds;
      
      await _activityLogger.logAudioSession(
        audioTitle: _currentAudioTitle!,
        categoryName: _currentCategoryName ?? 'Unknown',
        audioId: _currentAudioId,
        durationSeconds: duration,
        completionPercentage: completionPercentage,
        isCompleted: isCompleted,
      );

      print('✅ Audio session logged: $_currentAudioTitle (${duration}s)');
      
      // Reset session data
      _sessionStart = null;
      _currentAudioTitle = null;
      _currentCategoryName = null;
      _currentAudioId = null;
    } catch (e) {
      print('⚠ Failed to log audio session: $e');
    }
  }

  /// Log audio progress during playback
  Future<void> logAudioProgress({
    required double progressPercentage,
  }) async {
    if (_sessionStart == null || _currentAudioTitle == null) {
      return;
    }

    // Only log at significant milestones to avoid spam
    if (progressPercentage >= 25 && progressPercentage % 25 == 0) {
      try {
        final duration = DateTime.now().difference(_sessionStart!).inSeconds;
        
        await _activityLogger.logAudioSession(
          audioTitle: _currentAudioTitle!,
          categoryName: _currentCategoryName ?? 'Unknown',
          audioId: _currentAudioId,
          durationSeconds: duration,
          completionPercentage: progressPercentage,
          isCompleted: progressPercentage >= 100,
        );

        print('📊 Audio progress logged: $_currentAudioTitle (${progressPercentage.toInt()}%)');
      } catch (e) {
        print('⚠ Failed to log audio progress: $e');
      }
    }
  }

  /// Get current session info
  Map<String, dynamic>? getCurrentSessionInfo() {
    if (_sessionStart == null) return null;
    
    return {
      'session_start': _sessionStart!.toIso8601String(),
      'duration_seconds': DateTime.now().difference(_sessionStart!).inSeconds,
      'audio_title': _currentAudioTitle,
      'category_name': _currentCategoryName,
      'audio_id': _currentAudioId,
    };
  }

  /// Force end session (for cleanup when app is closed)
  Future<void> forceEndSession() async {
    if (_sessionStart != null) {
      await endAudioSession(
        isCompleted: false,
        completionPercentage: 0,
      );
    }
  }
}