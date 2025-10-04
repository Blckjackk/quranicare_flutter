import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doa_dzikir.dart';
import '../config/app_config.dart';

class DoaDzikirService {
  static String get baseUrl => AppConfig.baseUrl;

  // Get all doa dzikir
  Future<Map<String, dynamic>> getAllDoaDzikir({
    String? grup,
    String? tag,
    String? search,
    bool? featured,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (grup != null && grup.isNotEmpty) {
        queryParams['grup'] = grup;
      }

      if (tag != null && tag.isNotEmpty) {
        queryParams['tag'] = tag;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (featured == true) {
        queryParams['featured'] = 'true';
      }

      final uri = Uri.parse('$baseUrl/dzikir-doa').replace(queryParameters: queryParams);
      print('🔥 Requesting URL: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('🔥 Response Status: ${response.statusCode}');
      print('🔥 Response Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔥 Parsed JSON success: ${data['success']}');
        
        if (data['success'] == true) {
          final doaDzikirData = data['doa_dzikir'];
          print('🔥 DoaDzikir data type: ${doaDzikirData.runtimeType}');
          print('🔥 DoaDzikir data length: ${doaDzikirData is List ? doaDzikirData.length : 'not list'}');
          
          List<DoaDzikir> doaDzikirList = [];
          
          if (doaDzikirData != null && doaDzikirData is List) {
            for (int i = 0; i < doaDzikirData.length; i++) {
              try {
                final item = doaDzikirData[i];
                final doaDzikir = DoaDzikir.fromJson(item as Map<String, dynamic>);
                doaDzikirList.add(doaDzikir);
                if (i < 2) print('🔥 Successfully parsed item $i: ${doaDzikir.nama}');
              } catch (e) {
                print('❌ Error parsing DoaDzikir item $i: $e');
                print('❌ Item data: ${doaDzikirData[i]}');
              }
            }
          }
          
          print('🔥 Final list length: ${doaDzikirList.length}');
          
          return {
            'doa_dzikir': doaDzikirList,
            'pagination': data['pagination'] ?? {},
          };
        } else {
          final errorMsg = data['message'] ?? 'Failed to load doa dzikir';
          print('❌ API returned success=false: $errorMsg');
          throw Exception(errorMsg);
        }
      } else {
        final errorMsg = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
        print('❌ HTTP Error: $errorMsg');
        print('❌ Response body: ${response.body}');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('❌ Service Exception: $e');
      if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        throw Exception('Tidak dapat terhubung ke server. Pastikan server Laravel berjalan di ${AppConfig.baseUrl}');
      }
      throw Exception('Error loading doa dzikir: $e');
    }
  }

  // Get single doa dzikir
  Future<DoaDzikir> getDoaDzikirById(int id) async {
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
          return DoaDzikir.fromJson(data['doa_dzikir']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load doa dzikir detail');
        }
      } else {
        throw Exception('Failed to load doa dzikir detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading doa dzikir detail: $e');
    }
  }

  // Get available groups
  Future<List<String>> getGroups() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dzikir-doa/groups'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final groupsData = data['groups'];
          if (groupsData != null && groupsData is List) {
            return groupsData.map((e) => e.toString()).toList();
          }
          return [];
        } else {
          throw Exception(data['message'] ?? 'Failed to load groups');
        }
      } else {
        throw Exception('Failed to load groups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading groups: $e');
    }
  }

  // Get available tags
  Future<List<String>> getTags() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dzikir-doa/tags'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final tagsData = data['tags'];
          if (tagsData != null && tagsData is List) {
            return tagsData.map((e) => e.toString()).toList();
          }
          return [];
        } else {
          throw Exception(data['message'] ?? 'Failed to load tags');
        }
      } else {
        throw Exception('Failed to load tags: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading tags: $e');
    }
  }

  // Start dzikir session (requires authentication)
  Future<Map<String, dynamic>> startSession({
    required int doaDzikirId,
    int? targetCount,
    String? moodBefore,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/doa-dzikir/sessions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'doa_dzikir_id': doaDzikirId,
          if (targetCount != null) 'target_count': targetCount,
          if (moodBefore != null) 'mood_before': moodBefore,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['session'];
        } else {
          throw Exception(data['message'] ?? 'Failed to start session');
        }
      } else {
        throw Exception('Failed to start session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error starting session: $e');
    }
  }

  // Update session progress (requires authentication)
  Future<Map<String, dynamic>> updateSession({
    required int sessionId,
    required int completedCount,
    int? durationSeconds,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/doa-dzikir/sessions/$sessionId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'completed_count': completedCount,
          if (durationSeconds != null) 'duration_seconds': durationSeconds,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['session'];
        } else {
          throw Exception(data['message'] ?? 'Failed to update session');
        }
      } else {
        throw Exception('Failed to update session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating session: $e');
    }
  }

  // Complete session (requires authentication)
  Future<Map<String, dynamic>> completeSession({
    required int sessionId,
    required int completedCount,
    required int durationSeconds,
    String? moodAfter,
    String? notes,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/doa-dzikir/sessions/$sessionId/complete'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'completed_count': completedCount,
          'duration_seconds': durationSeconds,
          if (moodAfter != null) 'mood_after': moodAfter,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['session'];
        } else {
          throw Exception(data['message'] ?? 'Failed to complete session');
        }
      } else {
        throw Exception('Failed to complete session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error completing session: $e');
    }
  }

  // Get user sessions history (requires authentication)
  Future<Map<String, dynamic>> getUserSessions({
    bool? completed,
    String? fromDate,
    String? toDate,
    int page = 1,
    int perPage = 15,
    required String token,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (completed != null) {
        queryParams['completed'] = completed.toString();
      }

      if (fromDate != null) {
        queryParams['from_date'] = fromDate;
      }

      if (toDate != null) {
        queryParams['to_date'] = toDate;
      }

      final uri = Uri.parse('$baseUrl/doa-dzikir/sessions/history').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'sessions': data['sessions'],
            'pagination': data['pagination'],
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to load sessions history');
        }
      } else {
        throw Exception('Failed to load sessions history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading sessions history: $e');
    }
  }

  // Get user statistics (requires authentication)
  Future<Map<String, dynamic>> getUserStats({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doa-dzikir/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['stats'];
        } else {
          throw Exception(data['message'] ?? 'Failed to load user stats');
        }
      } else {
        throw Exception('Failed to load user stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading user stats: $e');
    }
  }
}