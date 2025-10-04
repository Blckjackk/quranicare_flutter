import 'dart:convert';
import 'package:http/http.dart' as http;
import 'activity_logger_service.dart';
import 'auth_service.dart';
import '../config/app_config.dart';

class JournalData {
  final int id;
  final String title;
  final String content;
  final String? reflection;
  final int? quranAyahId;
  final String? mood;
  final List<String> tags;
  final String journalDate;
  final bool isFavorite;
  final bool isPrivate;
  final DateTime createdAt;
  final AyahData? ayah;

  JournalData({
    required this.id,
    required this.title,
    required this.content,
    this.reflection,
    this.quranAyahId,
    this.mood,
    required this.tags,
    required this.journalDate,
    required this.isFavorite,
    required this.isPrivate,
    required this.createdAt,
    this.ayah,
  });

  factory JournalData.fromJson(Map<String, dynamic> json) {
    return JournalData(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      reflection: json['reflection'],
      quranAyahId: json['quran_ayah_id'],
      mood: json['mood_after'],
      tags: json['tags'] != null ? 
          (json['tags'] is String ? 
            List<String>.from(jsonDecode(json['tags'])) : 
            List<String>.from(json['tags'])) : [],
      journalDate: json['journal_date'],
      isFavorite: json['is_favorite'] == 1,
      isPrivate: json['is_private'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      ayah: json['ayah'] != null ? AyahData.fromJson(json['ayah']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'reflection': reflection,
      'quran_ayah_id': quranAyahId,
      'mood_after': mood,
      'tags': tags, // Kirim sebagai array langsung
      'journal_date': journalDate,
      'is_private': isPrivate,
    };
  }
}

class AyahData {
  final int id;
  final int number;
  final String textArabic;
  final String textIndonesian;
  final String? textLatin;
  final SurahData? surah;

  AyahData({
    required this.id,
    required this.number,
    required this.textArabic,
    required this.textIndonesian,
    this.textLatin,
    this.surah,
  });

  factory AyahData.fromJson(Map<String, dynamic> json) {
    return AyahData(
      id: json['id'],
      number: json['number'],
      textArabic: json['text_arabic'] ?? '',
      textIndonesian: json['text_indonesian'] ?? '',
      textLatin: json['text_latin'],
      surah: json['surah'] != null ? SurahData.fromJson(json['surah']) : null,
    );
  }
}

class SurahData {
  final int id;
  final int number;
  final String nameArabic;
  final String nameIndonesian;
  final String nameEnglish;
  final String nameLatin;
  final String place;
  final int numberOfAyahs;

  SurahData({
    required this.id,
    required this.number,
    required this.nameArabic,
    required this.nameIndonesian,
    required this.nameEnglish,
    required this.nameLatin,
    required this.place,
    required this.numberOfAyahs,
  });

  factory SurahData.fromJson(Map<String, dynamic> json) {
    return SurahData(
      id: json['id'],
      number: json['number'],
      nameArabic: json['name_arabic'] ?? '',
      nameIndonesian: json['name_indonesian'] ?? '',
      nameEnglish: json['name_english'] ?? '',
      nameLatin: json['name_latin'] ?? '',
      place: json['place'] ?? '',
      numberOfAyahs: json['number_of_ayahs'] ?? 0,
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
  final ActivityLoggerService _activityLogger = ActivityLoggerService();
  final AuthService _authService = AuthService();

  // Get user's journal entries (authenticated)
  Future<List<JournalData>> getUserJournals({
    int page = 1,
    int perPage = 20,
    String? tag,
    String? mood,
    bool? favorite,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      
      if (tag != null) queryParams['tag'] = tag;
      if (mood != null) queryParams['mood'] = mood;
      if (favorite != null) queryParams['favorite'] = favorite.toString();
      
      final uri = Uri.parse('$baseUrl/journal').replace(queryParameters: queryParams);
      
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(uri, headers: headers);

      print('📚 Getting user journals: ${response.statusCode}');
      print('📚 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final journalsData = data['data']['data'] as List; // Pagination format
          final journals = journalsData
              .map((json) => JournalData.fromJson(json))
              .toList();
          
          print('📚 Successfully loaded ${journals.length} journals');
          return journals;
        } else {
          throw Exception(data['message'] ?? 'Failed to load user journals');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login first.');
      } else {
        throw Exception('Failed to load user journals: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading user journals: $e');
      throw Exception('Error loading user journals: $e');
    }
  }

  // Get reflections for specific ayah (uses test endpoint - no auth required)
  Future<Map<String, dynamic>> getAyahReflections(int ayahId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test/journal/ayah/$ayahId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
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
          throw Exception(data['message'] ?? 'Failed to load reflections');
        }
      } else {
        throw Exception('Failed to load ayah reflections: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading ayah reflections: $e');
    }
  }

  // Create reflection for specific ayah (uses test endpoint - no auth required)
  Future<JournalData> createAyahReflection({
    required int ayahId,
    required String title,
    required String content,
    String? mood,
    List<String>? tags,
  }) async {
    try {
      final body = {
        'title': title,
        'content': content,
        if (mood != null) 'mood_after': mood,
        if (tags != null && tags.isNotEmpty) 'tags': tags, // Kirim sebagai array langsung
        'journal_date': DateTime.now().toIso8601String().split('T')[0],
        'is_private': true,
      };

      // Debug logging removed for production

      final response = await http.post(
        Uri.parse('$baseUrl/test/journal/ayah/$ayahId/reflection'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final journalData = JournalData.fromJson(data['data']);
          
          // Log journal writing activity
          await _logJournalActivity(journalData, ayahId);
          
          return journalData;
        } else {
          throw Exception(data['message'] ?? 'Failed to create reflection');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create reflection');
      }
    } catch (e) {
      throw Exception('Error creating reflection: $e');
    }
  }

  // Get tag suggestions (uses test endpoint - no auth required)
  Future<List<String>> getTagSuggestions() async {
    try {
      // Getting tag suggestions...
      
      final response = await http.get(
        Uri.parse('$baseUrl/test/journal/tags/suggestions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<String>.from(data['data'] ?? []);
        } else {
          throw Exception(data['message'] ?? 'Failed to load tag suggestions');
        }
      } else {
        throw Exception('Failed to load tag suggestions: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading tag suggestions: $e');
      throw Exception('Error loading tag suggestions: $e');
    }
  }

  // Get recent reflections (uses test endpoint - no auth required)
  Future<List<JournalData>> getRecentReflections({
    int days = 7,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test/journal/reflections/recent?days=$days&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final reflections = (data['data']['reflections'] as List)
              .map((json) => JournalData.fromJson(json))
              .toList();
          return reflections;
        } else {
          throw Exception(data['message'] ?? 'Failed to load recent reflections');
        }
      } else {
        throw Exception('Failed to load recent reflections: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading recent reflections: $e');
    }
  }

  // Get reflection statistics (uses test endpoint - no auth required)
  Future<JournalStats> getReflectionStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test/journal/reflections/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return JournalStats.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load reflection stats');
        }
      } else {
        throw Exception('Failed to load reflection stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading reflection stats: $e');
    }
  }

  // Get mood options (static)
  static List<Map<String, String>> getMoodOptions() {
    return [
      {'value': 'senang', 'label': '😊 Senang'},
      {'value': 'sedih', 'label': '😔 Sedih'},
      {'value': 'biasa_saja', 'label': '😐 Biasa Saja'},
      {'value': 'marah', 'label': '😠 Marah'},
      {'value': 'murung', 'label': '😞 Murung'},
      {'value': 'tenang', 'label': '😌 Tenang'},
      {'value': 'bersyukur', 'label': '🙏 Bersyukur'},
    ];
  }

  // Get mood emoji
  static String getMoodEmoji(String mood) {
    final moodMap = {
      'senang': '😊',
      'sedih': '😔',
      'biasa_saja': '😐',
      'marah': '😠',
      'murung': '😞',
      'tenang': '😌',
      'bersyukur': '🙏',
    };
    return moodMap[mood] ?? '😐';
  }

  /// Log journal writing activity for daily recap tracking
  Future<void> _logJournalActivity(JournalData journalData, int? ayahId) async {
    try {
      await _activityLogger.logJournalSession(
        journalTitle: journalData.title,
        content: journalData.content,
        journalId: journalData.id,
        mood: journalData.mood,
        tags: journalData.tags,
        wordCount: journalData.content.split(' ').length,
      );

      print('✅ Journal activity logged: ${journalData.title}');
    } catch (e) {
      print('⚠ Failed to log journal activity: $e');
    }
  }

  /// Log journal reading activity (when user views/reads existing journals)
  Future<void> logJournalReadingActivity({
    required String journalTitle,
    required int journalId,
    int? readingDurationSeconds,
  }) async {
    try {
      await _activityLogger.logActivity(
        activityType: ActivityLoggerService.TYPE_JOURNAL_WRITING,
        activityTitle: 'Membaca: $journalTitle',
        referenceId: journalId,
        referenceTable: 'journals',
        durationSeconds: readingDurationSeconds,
        completionPercentage: 100.0,
        metadata: {
          'action_type': 'reading',
          'journal_title': journalTitle,
        },
      );

      print('✅ Journal reading logged: $journalTitle');
    } catch (e) {
      print('⚠ Failed to log journal reading: $e');
    }
  }
}