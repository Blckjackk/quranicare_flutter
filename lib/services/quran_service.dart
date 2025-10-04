import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class QuranService {
  static String get baseUrl => AppConfig.baseUrl;
  
  // Get all surahs
  static Future<List<SurahData>> getSurahs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/public/quran/surahs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> surahsJson = data['data'];
          return surahsJson.map((json) => SurahData.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load surahs');
        }
      } else {
        throw Exception('Failed to load surahs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get ayahs for specific surah
  static Future<SurahDetailResponse> getAyahs(int surahNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/public/quran/surahs/$surahNumber/ayahs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return SurahDetailResponse.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load ayahs');
        }
      } else {
        throw Exception('Failed to load ayahs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Search in Quran
  static Future<List<AyahData>> searchQuran(String query, {String type = 'translation'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quran/search?q=${Uri.encodeComponent(query)}&type=$type'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> results = data['data']['results'];
          return results.map((json) => AyahData.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Search failed');
        }
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

// Data models
class SurahData {
  final int id;
  final int number;
  final String nameArabic;
  final String nameIndonesian;
  final String nameEnglish;
  final String nameLatin;
  final String place;
  final int numberOfAyahs;
  final String? descriptionIndonesian;
  final List<AyahData>? ayahs;

  SurahData({
    required this.id,
    required this.number,
    required this.nameArabic,
    required this.nameIndonesian,
    required this.nameEnglish,
    required this.nameLatin,
    required this.place,
    required this.numberOfAyahs,
    this.descriptionIndonesian,
    this.ayahs,
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
      descriptionIndonesian: json['description_indonesian'],
      ayahs: json['ayahs'] != null 
          ? (json['ayahs'] as List).map((e) => AyahData.fromJson(e)).toList()
          : null,
    );
  }

  // Getter untuk kompatibilitas dengan UI yang sudah ada
  String get englishName => nameEnglish;
  String get arabicName => nameArabic;
  String get revelationType => place;
}

class AyahData {
  final int id;
  final int number;
  final String textArabic;
  final String textIndonesian;
  final String? textEnglish;
  final String? textLatin;
  final String? tafsirIndonesian;
  final String? audioUrl;
  final SurahData? surah;

  AyahData({
    required this.id,
    required this.number,
    required this.textArabic,
    required this.textIndonesian,
    this.textEnglish,
    this.textLatin,
    this.tafsirIndonesian,
    this.audioUrl,
    this.surah,
  });

  factory AyahData.fromJson(Map<String, dynamic> json) {
    return AyahData(
      id: json['id'],
      number: json['number'],
      textArabic: json['text_arabic'] ?? '',
      textIndonesian: json['text_indonesian'] ?? '',
      textEnglish: json['text_english'],
      textLatin: json['text_latin'],
      tafsirIndonesian: json['tafsir_indonesian'],
      audioUrl: json['audio_url'],
      surah: json['surah'] != null ? SurahData.fromJson(json['surah']) : null,
    );
  }

  // Getter untuk kompatibilitas dengan UI yang sudah ada
  String get arabicText => textArabic;
  String get transliteration => textLatin ?? '';
  String get translation => textIndonesian;
}

class SurahDetailResponse {
  final SurahData surah;
  final List<AyahData> ayahs;

  SurahDetailResponse({
    required this.surah,
    required this.ayahs,
  });

  factory SurahDetailResponse.fromJson(Map<String, dynamic> json) {
    return SurahDetailResponse(
      surah: SurahData.fromJson(json['surah']),
      ayahs: (json['ayahs'] as List).map((e) => AyahData.fromJson(e)).toList(),
    );
  }
}