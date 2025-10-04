import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/mood_selector_widget.dart';
import '../config/app_config.dart';

class MoodService {
  // Base URL - sesuaikan dengan backend Anda
  static String get baseUrl => AppConfig.baseUrl;
  
  // Singleton pattern
  static final MoodService _instance = MoodService._internal();
  factory MoodService() => _instance;
  MoodService._internal();
  
  // Debug mode untuk logging
  bool get isDebugMode => true;

  // Headers untuk request
  Map<String, String> _getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Menyimpan mood ke database
  Future<Map<String, dynamic>> saveMood({
    required String token,
    required MoodOption mood,
    String? notes,
    DateTime? moodDate,
    DateTime? moodTime,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/mood');
      
      final body = {
        'mood_type': mood.type,
        'notes': notes,
        'mood_date': (moodDate ?? DateTime.now()).toIso8601String().split('T')[0],
        'mood_time': (moodTime ?? DateTime.now()).toIso8601String().split('T')[1].split('.')[0],
      };

      final response = await http.post(
        url,
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Mood berhasil disimpan',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menyimpan mood',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Menyimpan mood ke database berdasarkan type saja
  Future<Map<String, dynamic>> saveMoodByType({
    required String token,
    required String moodType,
    String? notes,
    DateTime? moodDate,
    DateTime? moodTime,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/mood');
      
      final body = {
        'mood_type': moodType,
        'notes': notes,
        'mood_date': (moodDate ?? DateTime.now()).toIso8601String().split('T')[0],
        'mood_time': (moodTime ?? DateTime.now()).toIso8601String().split('T')[1].split('.')[0],
      };

      if (isDebugMode) {
        print('🔄 Sending mood data:');
        print('URL: $url');
        print('Headers: ${_getHeaders(token: token)}');
        print('Body: ${jsonEncode(body)}');
      }

      final response = await http.post(
        url,
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      if (isDebugMode) {
        print('📡 Response status: ${response.statusCode}');
        print('📡 Response body: ${response.body}');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Mood berhasil disimpan',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menyimpan mood',
          'errors': data['errors'] ?? {},
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      if (isDebugMode) {
        print('❌ Error saving mood: $e');
      }
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Test connection to backend
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final url = Uri.parse('$baseUrl/mood/today');
      final response = await http.get(
        url,
        headers: _getHeaders(token: 'test'),
      );
      
      return {
        'success': response.statusCode < 500,
        'status_code': response.statusCode,
        'message': 'Backend ${response.statusCode < 500 ? 'accessible' : 'error'}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed: $e',
      };
    }
  }

  /// Mengambil mood hari ini
  Future<Map<String, dynamic>> getTodayMoods({
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/mood/today');
      
      final response = await http.get(
        url,
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil data mood',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Mengambil history mood
  Future<Map<String, dynamic>> getMoodHistory({
    required String token,
    int page = 1,
    String? date,
    String? moodType,
  }) async {
    try {
      var url = Uri.parse('$baseUrl/mood');
      
      // Add query parameters
      Map<String, String> queryParams = {
        'page': page.toString(),
      };
      
      if (date != null) queryParams['date'] = date;
      if (moodType != null) queryParams['mood_type'] = moodType;
      
      url = url.replace(queryParameters: queryParams);
      
      final response = await http.get(
        url,
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil history mood',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Mengambil statistik mood
  Future<Map<String, dynamic>> getMoodStatistics({
    required String token,
    String period = 'week', // week, month, year
  }) async {
    try {
      final url = Uri.parse('$baseUrl/mood/statistics?period=$period');
      
      final response = await http.get(
        url,
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengambil statistik mood',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Update mood
  Future<Map<String, dynamic>> updateMood({
    required String token,
    required int moodId,
    required MoodOption mood,
    String? notes,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/mood/$moodId');
      
      final body = {
        'mood_type': mood.type,
        'notes': notes,
      };

      final response = await http.put(
        url,
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
          'message': 'Mood berhasil diupdate',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengupdate mood',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Delete mood
  Future<Map<String, dynamic>> deleteMood({
    required String token,
    required int moodId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/mood/$moodId');
      
      final response = await http.delete(
        url,
        headers: _getHeaders(token: token),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Mood berhasil dihapus',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal menghapus mood',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Konversi string mood type ke MoodOption
  static MoodOption? getMoodOptionFromType(String type) {
    final moods = [
      MoodOption(
        emoji: '😢',
        label: 'Sangat Sedih',
        type: 'sedih',
        color: Color(0xFFDC2626),
        position: 0,
      ),
      MoodOption(
        emoji: '😟',
        label: 'Murung',
        type: 'murung',
        color: Color(0xFFEA580C),
        position: 1,
      ),
      MoodOption(
        emoji: '😐',
        label: 'Biasa Saja',
        type: 'biasa_saja',
        color: Color(0xFFF59E0B),
        position: 2,
      ),
      MoodOption(
        emoji: '😊',
        label: 'Senang',
        type: 'senang',
        color: Color(0xFF16A34A),
        position: 3,
      ),
      MoodOption(
        emoji: '😡',
        label: 'Marah',
        type: 'marah',
        color: Color(0xFF7C2D12),
        position: 4,
      ),
    ];

    try {
      return moods.firstWhere((mood) => mood.type == type);
    } catch (e) {
      return null;
    }
  }

  /// Get all available mood options
  static List<MoodOption> getAllMoodOptions() {
    return [
      MoodOption(
        emoji: '😢',
        label: 'Sangat Sedih',
        type: 'sedih',
        color: Color(0xFFDC2626),
        position: 0,
      ),
      MoodOption(
        emoji: '😟',
        label: 'Murung',
        type: 'murung',
        color: Color(0xFFEA580C),
        position: 1,
      ),
      MoodOption(
        emoji: '😐',
        label: 'Biasa Saja',
        type: 'biasa_saja',
        color: Color(0xFFF59E0B),
        position: 2,
      ),
      MoodOption(
        emoji: '😊',
        label: 'Senang',
        type: 'senang',
        color: Color(0xFF16A34A),
        position: 3,
      ),
      MoodOption(
        emoji: '😡',
        label: 'Marah',
        type: 'marah',
        color: Color(0xFF7C2D12),
        position: 4,
      ),
    ];
  }
}

/// Model untuk mood data dari API
class MoodData {
  final int id;
  final int userId;
  final String moodType;
  final String? notes;
  final DateTime moodDate;
  final DateTime moodTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  MoodData({
    required this.id,
    required this.userId,
    required this.moodType,
    this.notes,
    required this.moodDate,
    required this.moodTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MoodData.fromJson(Map<String, dynamic> json) {
    return MoodData(
      id: json['id'],
      userId: json['user_id'],
      moodType: json['mood_type'],
      notes: json['notes'],
      moodDate: DateTime.parse(json['mood_date']),
      moodTime: DateTime.parse('${json['mood_date']} ${json['mood_time']}'),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  MoodOption? getMoodOption() {
    return MoodService.getMoodOptionFromType(moodType);
  }
}