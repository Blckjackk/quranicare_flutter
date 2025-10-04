import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/breathing_exercise_db.dart';

class BreathingExerciseService {
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // iOS simulator

  // Fetch all breathing categories with exercises
  Future<List<BreathingCategoryDb>> getCategories() async {
    try {
      print('🔗 Fetching breathing categories from: $baseUrl/breathing-exercise/categories');
      
      final response = await http.get(
        Uri.parse('$baseUrl/breathing-exercise/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final categoriesData = jsonData['data'] as List;
          return categoriesData
              .map((category) => BreathingCategoryDb.fromJson(category))
              .toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching categories: $e');
      throw Exception('Failed to fetch breathing categories: $e');
    }
  }

  // Fetch exercises by category ID
  Future<List<BreathingExerciseDb>> getExercisesByCategory(int categoryId) async {
    try {
      print('🔗 Fetching exercises for category $categoryId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/breathing-exercise/categories/$categoryId/exercises'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final exercisesData = jsonData['data'] as List;
          return exercisesData
              .map((exercise) => BreathingExerciseDb.fromJson(exercise))
              .toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load exercises: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching exercises: $e');
      throw Exception('Failed to fetch exercises: $e');
    }
  }

  // Fetch specific exercise details
  Future<BreathingExerciseDb> getExercise(int exerciseId) async {
    try {
      print('🔗 Fetching exercise details for ID: $exerciseId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/breathing-exercise/exercises/$exerciseId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          return BreathingExerciseDb.fromJson(jsonData['data']);
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load exercise: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching exercise: $e');
      throw Exception('Failed to fetch exercise: $e');
    }
  }

  // Start a new breathing session
  Future<BreathingSessionDb> startSession({
    required int exerciseId,
    required int plannedDurationMinutes,
    required int userId,
  }) async {
    try {
      print('🚀 Starting breathing session...');
      
      final requestBody = {
        'breathing_exercise_id': exerciseId,
        'planned_duration_minutes': plannedDurationMinutes,
        'user_id': userId,
      };

      print('📤 Request body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/breathing-exercise/sessions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          return BreathingSessionDb.fromJson(jsonData['data']);
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to start session: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error starting session: $e');
      throw Exception('Failed to start session: $e');
    }
  }

  // Update session progress
  Future<BreathingSessionDb> updateSessionProgress({
    required int sessionId,
    required int completedCycles,
    int? actualDurationSeconds,
    String? notes,
  }) async {
    try {
      print('📊 Updating session progress...');
      
      final requestBody = {
        'completed_cycles': completedCycles,
        if (actualDurationSeconds != null) 'actual_duration_seconds': actualDurationSeconds,
        if (notes != null) 'notes': notes,
      };

      print('📤 Request body: ${json.encode(requestBody)}');
      
      final response = await http.put(
        Uri.parse('$baseUrl/breathing-exercise/sessions/$sessionId/progress'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          return BreathingSessionDb.fromJson(jsonData['data']);
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to update progress: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating progress: $e');
      throw Exception('Failed to update progress: $e');
    }
  }

  // Complete breathing session
  Future<BreathingSessionDb> completeSession({
    required int sessionId,
    required int completedCycles,
    required int actualDurationSeconds,
    String? notes,
  }) async {
    try {
      print('✅ Completing breathing session...');
      
      final requestBody = {
        'completed_cycles': completedCycles,
        'actual_duration_seconds': actualDurationSeconds,
        if (notes != null) 'notes': notes,
      };

      print('📤 Request body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/breathing-exercise/sessions/$sessionId/complete'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          return BreathingSessionDb.fromJson(jsonData['data']);
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to complete session: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error completing session: $e');
      throw Exception('Failed to complete session: $e');
    }
  }

  // Get user's breathing sessions history
  Future<List<BreathingSessionDb>> getUserSessions(int userId) async {
    try {
      print('📊 Fetching user sessions history...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/breathing-exercise/users/$userId/sessions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final sessionsData = jsonData['data']['data'] as List; // pagination data
          return sessionsData
              .map((session) => BreathingSessionDb.fromJson(session))
              .toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load sessions: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching sessions: $e');
      throw Exception('Failed to fetch sessions: $e');
    }
  }

  // Get user's breathing exercise statistics
  Future<Map<String, dynamic>> getUserStats(int userId) async {
    try {
      print('📈 Fetching user stats...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/breathing-exercise/users/$userId/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          return jsonData['data'];
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching stats: $e');
      throw Exception('Failed to fetch stats: $e');
    }
  }

  // Helper method to get popular exercises
  Future<List<BreathingExerciseDb>> getPopularExercises() async {
    try {
      final categories = await getCategories();
      List<BreathingExerciseDb> allExercises = [];
      
      for (var category in categories) {
        if (category.exercises != null) {
          allExercises.addAll(category.exercises!);
        }
      }
      
      // Sort by default repetitions (assuming popular ones have more repetitions)
      allExercises.sort((a, b) => b.defaultRepetitions.compareTo(a.defaultRepetitions));
      
      // Return top 6 exercises
      return allExercises.take(6).toList();
    } catch (e) {
      print('❌ Error fetching popular exercises: $e');
      throw Exception('Failed to fetch popular exercises: $e');
    }
  }

  // Helper method to calculate session duration based on exercise and repetitions
  Duration calculateSessionDuration(BreathingExerciseDb exercise, int repetitions) {
    int totalSeconds = exercise.totalCycleDuration * repetitions;
    return Duration(seconds: totalSeconds);
  }

  // Helper method to get breathing phase text
  String getBreathingPhaseText(BreathingExerciseDb exercise, String phase) {
    switch (phase) {
      case 'inhale':
        return 'Tarik Napas • ${exercise.inhaleDuration}s';
      case 'hold':
        return 'Tahan • ${exercise.holdDuration}s';
      case 'exhale':
        return 'Hembuskan • ${exercise.exhaleDuration}s';
      default:
        return 'Bersiap...';
    }
  }
}