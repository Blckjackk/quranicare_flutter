import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class JournalData {
  final int id;
  final String title;
  final String content;
  final int? quranAyahId;
  final String? mood;
  final List<String> tags;
  final String reflectionDate;
  final bool isFavorite;
  final DateTime createdAt;
  final AyahData? ayah;

  JournalData({
    required this.id,
    required this.title,
    required this.content,
    this.quranAyahId,
    this.mood,
    required this.tags,
    required this.reflectionDate,
    required this.isFavorite,
    required this.createdAt,
    this.ayah,
  });

  factory JournalData.fromJson(Map<String, dynamic> json) {
    return JournalData(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      quranAyahId: json['quran_ayah_id'],
      mood: json['mood'],
      tags: List<String>.from(json['tags'] ?? []),
      reflectionDate: json['reflection_date'],
      isFavorite: json['is_favorite'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      ayah: json['ayah'] != null ? AyahData.fromJson(json['ayah']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'quran_ayah_id': quranAyahId,
      'mood': mood,
      'tags': tags,
      'reflection_date': reflectionDate,
    };
  }
}

class AyahData {
  final int id;
  final int surahId;
  final int ayahNumber;
  final String arabicText;
  final String translation;
  final String transliteration;
  final SurahData? surah;

  AyahData({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    required this.arabicText,
    required this.translation,
    required this.transliteration,
    this.surah,
  });

  factory AyahData.fromJson(Map<String, dynamic> json) {
    return AyahData(
      id: json['id'],
      surahId: json['surah_id'],
      ayahNumber: json['ayah_number'],
      arabicText: json['arabic_text'],
      translation: json['translation'],
      transliteration: json['transliteration'],
      surah: json['surah'] != null ? SurahData.fromJson(json['surah']) : null,
    );
  }
}

class SurahData {
  final int id;
  final String name;
  final String arabicName;
  final String translation;
  final int totalAyahs;

  SurahData({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.translation,
    required this.totalAyahs,
  });

  factory SurahData.fromJson(Map<String, dynamic> json) {
    return SurahData(
      id: json['id'],
      name: json['name'],
      arabicName: json['arabic_name'],
      translation: json['translation'],
      totalAyahs: json['total_ayahs'],
    );
  }
}

class JournalStats {
  final int totalReflections;
  final int thisMonth;
  final int thisWeek;
  final int favorites;
  final int withAyah;
  final Map<String, int> moodDistribution;
  final Map<String, int> mostUsedTags;
  final int reflectionStreak;

  JournalStats({
    required this.totalReflections,
    required this.thisMonth,
    required this.thisWeek,
    required this.favorites,
    required this.withAyah,
    required this.moodDistribution,
    required this.mostUsedTags,
    required this.reflectionStreak,
  });

  factory JournalStats.fromJson(Map<String, dynamic> json) {
    return JournalStats(
      totalReflections: json['total_reflections'] ?? 0,
      thisMonth: json['this_month'] ?? 0,
      thisWeek: json['this_week'] ?? 0,
      favorites: json['favorites'] ?? 0,
      withAyah: json['with_ayah'] ?? 0,
      moodDistribution: Map<String, int>.from(json['mood_distribution'] ?? {}),
      mostUsedTags: Map<String, int>.from(json['most_used_tags'] ?? {}),
      reflectionStreak: json['reflection_streak'] ?? 0,
    );
  }
}

class JournalService {
  static String get baseUrl => AppConfig.baseUrl;

  // Get auth token from shared preferences
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get reflections for specific ayah
  Future<Map<String, dynamic>> getAyahReflections(int ayahId) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/test/journal/ayah/$ayahId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final ayah = AyahData.fromJson(data['data']['ayah']);
          final reflections = (data['data']['reflections'] as List)
              .map((json) => JournalData.fromJson(json))
              .toList();
          
          return {
            'ayah': ayah,
            'reflections': reflections,
            'reflection_count': data['data']['reflection_count'] ?? 0,
          };
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load ayah reflections');
      }
    } catch (e) {
      throw Exception('Error loading ayah reflections: $e');
    }
  }

  // Create reflection for specific ayah
  Future<JournalData> createAyahReflection({
    required int ayahId,
    required String title,
    required String content,
    String? mood,
    List<String>? tags,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      
      final body = {
        'title': title,
        'content': content,
        if (mood != null) 'mood': mood,
        if (tags != null) 'tags': tags,
      };

      print('🔍 DEBUG: Sending journal reflection request...');
      print('📍 URL: $baseUrl/test/journal/ayah/$ayahId/reflection');
      print('📦 Body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse('$baseUrl/test/journal/ayah/$ayahId/reflection'),
        headers: headers,
        body: json.encode(body),
      );

      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success']) {
          return JournalData.fromJson(data['data']);
        } else {
          throw Exception(data['message']);
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create reflection');
      }
    } catch (e) {
      print('❌ Error creating reflection: $e');
      throw Exception('Error creating reflection: $e');
    }
  }

  // Get tag suggestions
  Future<List<String>> getTagSuggestions() async {
    try {
      final headers = await _getAuthHeaders();
      
      print('🔍 DEBUG: Getting tag suggestions...');
      print('📍 URL: $baseUrl/test/journal/tags/suggestions');
      
      final response = await http.get(
        Uri.parse('$baseUrl/test/journal/tags/suggestions'),
        headers: headers,
      );

      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return List<String>.from(data['data']);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load tag suggestions');
      }
    } catch (e) {
      print('❌ Error loading tag suggestions: $e');
      throw Exception('Error loading tag suggestions: $e');
    }
  }

  // Get recent reflections
  Future<List<JournalData>> getRecentReflections({
    int days = 7,
    int limit = 10,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/test/journal/reflections/recent?days=$days&limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final reflections = (data['data']['reflections'] as List)
              .map((json) => JournalData.fromJson(json))
              .toList();
          return reflections;
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load recent reflections');
      }
    } catch (e) {
      throw Exception('Error loading recent reflections: $e');
    }
  }

  // Get reflection statistics
  Future<JournalStats> getReflectionStats() async {
    try {
      final headers = await _getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/test/journal/reflections/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return JournalStats.fromJson(data['data']);
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load reflection stats');
      }
    } catch (e) {
      throw Exception('Error loading reflection stats: $e');
    }
  }

  // Get mood options (static)
  static List<Map<String, String>> getMoodOptions() {
    return [
      {'value': 'bahagia', 'label': '😊 Bahagia'},
      {'value': 'sedih', 'label': '😔 Sedih'},
      {'value': 'tenang', 'label': '😌 Tenang'},
      {'value': 'bersyukur', 'label': '🙏 Bersyukur'},
      {'value': 'khawatir', 'label': '😰 Khawatir'},
      {'value': 'penuh_harap', 'label': '🌟 Penuh Harap'},
      {'value': 'terharu', 'label': '🥺 Terharu'},
    ];
  }

  // Get mood emoji
  static String getMoodEmoji(String mood) {
    final moodMap = {
      'bahagia': '😊',
      'sedih': '😔',
      'tenang': '😌',
      'bersyukur': '🙏',
      'khawatir': '😰',
      'penuh_harap': '🌟',
      'terharu': '🥺',
    };
    return moodMap[mood] ?? '😐';
  }
}