import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'activity_logger_service.dart';
import 'auth_service.dart';
import '../config/app_config.dart';

class DailyRecapService {
  static String get baseUrl => AppConfig.baseUrl;
  final ActivityLoggerService _activityLogger = ActivityLoggerService();
  final AuthService _authService = AuthService();
  String? _token;
  static final DailyRecapService _instance = DailyRecapService._internal();
  
  factory DailyRecapService() => _instance;
  
  DailyRecapService._internal();

  Future<void> initialize() async {
    _token = await _authService.getToken();
    print('🔑 DailyRecapService initialized with token: ${_token != null ? 'YES' : 'NO'}');
  }

  void setToken(String token) {
    _token = token;
    _authService.saveToken(token);
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// Get comprehensive daily recap including all activities (Primary method to use)
  Future<Map<String, dynamic>?> getComprehensiveDailyRecap({DateTime? date}) async {
    try {
      await initialize();
      
      // Get comprehensive activity data from SakinahTrackerService
      final activityRecap = await _activityLogger.getDailyRecap(date: date);
      
      if (activityRecap != null) {
        print('✅ Comprehensive daily recap loaded from activity tracker');
        return {
          'success': true,
          'data': {
            'activities': activityRecap['activities'] ?? [],
            'summary': activityRecap['summary'] ?? {},
            'streaks': activityRecap['streaks'] ?? {},
            'goals_achieved': activityRecap['goals_achieved'] ?? {},
            'date': date?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
            'has_activities': (activityRecap['summary']?['total_activities'] ?? 0) > 0,
          }
        };
      }

      // Fallback to mood-only recap if activity tracker fails
      return await getDailyMoodRecap(date: date);
    } catch (e) {
      print('❌ Error getting comprehensive daily recap: $e');
      // Fallback to mood-only recap
      return await getDailyMoodRecap(date: date);
    }
  }

  /// Get dashboard summary for home screen
  Future<Map<String, dynamic>?> getDashboardSummary() async {
    try {
      await initialize();
      
      final dashboardData = await _activityLogger.getDashboardSummary();
      
      if (dashboardData != null) {
        print('✅ Dashboard summary loaded from activity tracker');
        return {
          'success': true,
          'data': dashboardData,
        };
      }

      return null;
    } catch (e) {
      print('❌ Error getting dashboard summary: $e');
      return null;
    }
  }

  /// Get activity streaks for motivation
  Future<Map<String, int>?> getActivityStreaks() async {
    try {
      await initialize();
      
      final streaks = await _activityLogger.getActivityStreaks();
      
      if (streaks != null) {
        print('✅ Activity streaks loaded');
        return streaks;
      }

      return null;
    } catch (e) {
      print('❌ Error getting activity streaks: $e');
      return null;
    }
  }

  /// Original mood-only daily recap (kept for backward compatibility)
  Future<Map<String, dynamic>?> getDailyMoodRecap({DateTime? date}) async {
    try {
      await initialize(); // Ensure token is loaded
      
      final targetDate = date ?? DateTime.now();
      final formattedDate = targetDate.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      final url = Uri.parse('$baseUrl/daily-recap/$formattedDate');
      
      print('🔍 Fetching daily recap for: $formattedDate');
      print('🔑 Using token: ${_token != null ? 'YES' : 'NO'}');
      print('📡 URL: $url');
      
      final response = await http.get(url, headers: _headers);
      
      print('📊 Daily recap response status: ${response.statusCode}');
      print('📋 Daily recap response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Daily recap loaded successfully');
          return {
            'success': true,
            'data': data['data'],
          };
        }
      } else if (response.statusCode == 401) {
        print('🔐 Unauthorized access - token may be invalid');
        // Try to refresh token
        await initialize();
        
        // Return empty data structure for fallback
        return {
          'success': true,
          'data': {
            'date': formattedDate,
            'mood_entries': [],
            'daily_stats': null,
            'weekly_context': {},
            'insights': {},
          },
        };
      } else if (response.statusCode == 404) {
        print('📅 No data found for this date - returning empty structure');
        return {
          'success': true,
          'data': {
            'date': formattedDate,
            'mood_entries': [],
            'daily_stats': null,
            'weekly_context': {},
            'insights': {},
          },
        };
      }
      
      // Fallback for other status codes
      print('⚠️ Unexpected response, using fallback data');
      return {
        'success': true,
        'data': {
          'date': formattedDate,
          'mood_entries': [],
          'daily_stats': null,
          'weekly_context': {},
          'insights': {},
        },
      };
    } catch (e) {
      print('❌ Error getting daily recap: $e');
      final targetDate = date ?? DateTime.now();
      final formattedDate = targetDate.toIso8601String().split('T')[0];
      return {
        'success': true,
        'data': {
          'date': formattedDate,
          'mood_entries': [],
          'daily_stats': null,
          'weekly_context': {},
          'insights': {},
        },
      };
    }
  }

  /// Create mood entry (delegate to backend)
  Future<bool> createMoodEntry({
    required String moodType,
    String? notes,
    DateTime? timestamp,
  }) async {
    try {
      await initialize();
      
      final url = Uri.parse('$baseUrl/mood');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode({
          'mood_type': moodType,
          'notes': notes,
          'created_at': timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error creating mood entry: $e');
      return false;
    }
  }

  /// Update an existing mood entry
  Future<bool> updateMoodEntry({
    required int entryId,
    required String moodType,
    String? notes,
  }) async {
    try {
      await initialize();
      
      final url = Uri.parse('$baseUrl/mood/$entryId');
      final response = await http.put(
        url,
        headers: _headers,
        body: json.encode({
          'mood_type': moodType,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error updating mood entry: $e');
      return false;
    }
  }

  /// Delete a mood entry
  Future<bool> deleteMoodEntry(int entryId) async {
    try {
      await initialize();
      
      final url = Uri.parse('$baseUrl/mood/$entryId');
      final response = await http.delete(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error deleting mood entry: $e');
      return false;
    }
  }

  /// Get mood insights and trends (weekly/monthly analysis)
  Future<Map<String, dynamic>?> getMoodInsights({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await initialize();
      
      final start = startDate?.toIso8601String().split('T')[0] ?? 
                   DateTime.now().subtract(Duration(days: 30)).toIso8601String().split('T')[0];
      final end = endDate?.toIso8601String().split('T')[0] ?? 
                 DateTime.now().toIso8601String().split('T')[0];
      
      final url = Uri.parse('$baseUrl/mood/insights?start_date=$start&end_date=$end');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting mood insights: $e');
      return null;
    }
  }

  /// Get monthly overview for calendar
  Future<Map<String, dynamic>?> getMonthlyOverview(int year, int month) async {
    try {
      await initialize(); // Ensure token is loaded
      
      final url = Uri.parse('$baseUrl/monthly-overview/$year/$month');
      
      print('🔍 Fetching monthly overview for: $year-$month');
      print('🔑 Using token: ${_token != null ? 'YES' : 'NO'}');
      print('📡 URL: $url');
      
      final response = await http.get(url, headers: _headers);
      
      print('📊 Monthly overview response status: ${response.statusCode}');
      print('📋 Monthly overview response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Monthly overview loaded successfully');
          return data['data'];
        }
      } else if (response.statusCode == 401) {
        print('🔐 Unauthorized access for monthly overview - token may be invalid');
        await initialize(); // Try to refresh token
      } else if (response.statusCode == 404) {
        print('📅 No monthly data found - returning empty structure');
      }
      
      // Return empty data for fallback
      print('⚠️ Using fallback data for monthly overview');
      return {
        'year': year,
        'month': month,
        'calendar_data': {},
        'monthly_stats': {},
      };
    } catch (e) {
      print('❌ Error getting monthly overview: $e');
      // Return empty data for fallback
      return {
        'year': year,
        'month': month,
        'calendar_data': {},
        'monthly_stats': {},
      };
    }
  }

  /// Legacy method for backward compatibility - use getComprehensiveDailyRecap instead
  Future<Map<String, dynamic>?> getDailyRecap(DateTime date) async {
    return await getComprehensiveDailyRecap(date: date);
  }
}