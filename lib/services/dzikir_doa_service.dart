import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dzikir_doa.dart';
import '../config/app_config.dart';

class DzikirDoaService {
  static String get baseUrl => AppConfig.baseUrl;

  // Get all dzikir doa
  Future<Map<String, dynamic>> getAllDzikirDoa() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dzikir-doa'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final dzikirDoaList = (data['data'] as List)
              .map((json) => DzikirDoa.fromJson(json))
              .toList();
          
          return {
            'dzikir_doa': dzikirDoaList,
            'total': data['total'] ?? dzikirDoaList.length,
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to load dzikir doa');
        }
      } else {
        throw Exception('Failed to load dzikir doa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading dzikir doa: $e');
    }
  }

  // Get dzikir doa by category
  Future<Map<String, dynamic>> getDzikirDoaByCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dzikir-doa/category/$categoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final dzikirDoaList = (data['data'] as List)
              .map((json) => DzikirDoa.fromJson(json))
              .toList();
          
          return {
            'dzikir_doa': dzikirDoaList,
            'category': data['category'],
            'total': data['total'] ?? dzikirDoaList.length,
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to load dzikir doa by category');
        }
      } else {
        throw Exception('Failed to load dzikir doa by category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading dzikir doa by category: $e');
    }
  }

  // Get single dzikir doa
  Future<DzikirDoa> getDzikirDoaById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dzikir-doa/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return DzikirDoa.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load dzikir doa detail');
        }
      } else {
        throw Exception('Failed to load dzikir doa detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading dzikir doa detail: $e');
    }
  }

  // Get featured dzikir doa
  Future<List<DzikirDoa>> getFeaturedDzikirDoa() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dzikir-doa/featured'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => DzikirDoa.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load featured dzikir doa');
        }
      } else {
        throw Exception('Failed to load featured dzikir doa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading featured dzikir doa: $e');
    }
  }

  // Get all categories
  Future<List<DzikirCategory>> getAllCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dzikir-categories'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => DzikirCategory.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load dzikir categories');
        }
      } else {
        throw Exception('Failed to load dzikir categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading dzikir categories: $e');
    }
  }

  // Search dzikir doa
  Future<List<DzikirDoa>> searchDzikirDoa(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dzikir-doa/search?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => DzikirDoa.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to search dzikir doa');
        }
      } else {
        throw Exception('Failed to search dzikir doa: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching dzikir doa: $e');
    }
  }
}