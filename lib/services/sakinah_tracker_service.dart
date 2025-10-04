import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_activity.dart';
import '../models/activity_summary.dart';
import 'auth_service.dart';
import '../config/app_config.dart';

class SakinahTrackerService {
  static String get baseUrl => AppConfig.baseUrl;
  final AuthService _authService = AuthService();
  String? _token;
  static final SakinahTrackerService _instance = SakinahTrackerService._internal();
  
  factory SakinahTrackerService() => _instance;
  
  SakinahTrackerService._internal();

  Future<void> initialize() async {
    _token = await _authService.getToken();
    print('🔑 SakinahTrackerService initialized with token: ${_token != null ? 'YES' : 'NO'}');
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

  // Get daily activities for a specific date
  Future<List<UserActivity>> getDailyActivities(DateTime date) async {
    try {
      final formattedDate = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      final url = Uri.parse('$baseUrl/sakinah-tracker/daily/$formattedDate');
      
      print('📅 Making request to: $url for date: $formattedDate');
      print('🔑 Headers: $_headers');
      
      final response = await http.get(url, headers: _headers);
      
      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          if (data['data'] != null && data['data'] is List && (data['data'] as List).isNotEmpty) {
            final activities = (data['data'] as List)
                .map((activity) => UserActivity.fromJson(activity))
                .toList();
            print('✅ Loaded ${activities.length} REAL activities from database for $formattedDate');
            return activities;
          } else {
            print('📝 No activities found for $formattedDate in database - returning empty list');
            return []; // Return empty list if no activities for this date
          }
        }
      } else if (response.statusCode == 401) {
        print('🔐 Unauthorized - token invalid');
        return []; // Return empty instead of mock data
      } else if (response.statusCode == 404) {
        print('🔍 No data found for $formattedDate');
        return []; // Return empty instead of mock data
      }
      
      print('⚠️ API error - returning empty list (no fake data)');
      return [];
    } catch (e) {
      print('❌ Network error getting daily activities: $e');
      print('🔄 Returning empty list - check your backend connection');
      return []; // Return empty instead of mock data when there's network issues
    }
  }

  // Get monthly activity summary
  Future<ActivitySummary?> getMonthlyRecap(int year, int month) async {
    try {
      final url = Uri.parse('$baseUrl/sakinah-tracker/monthly/$year/$month');
      
      print('📊 Getting monthly recap for $year-$month from: $url');
      
      final response = await http.get(url, headers: _headers);
      
      print('📡 Monthly recap response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Loaded monthly recap from database');
          return ActivitySummary.fromJson(data['data']);
        }
      } else if (response.statusCode == 401) {
        print('🔐 Unauthorized monthly recap access');
        return null; // Return null instead of mock
      } else if (response.statusCode == 404) {
        print('📊 No monthly recap data found for $year-$month');
        return null; // Return null instead of mock
      }
      
      print('⚠️ No valid monthly recap data');
      return null;
    } catch (e) {
      print('❌ Network error getting monthly recap: $e');
      return null; // Return null instead of mock
    }
  }

  // Get weekly activities
  Future<List<UserActivity>> getWeeklyActivities(DateTime startDate) async {
    try {
      final formattedDate = startDate.toIso8601String().split('T')[0];
      final url = Uri.parse('$baseUrl/sakinah-tracker/weekly/$formattedDate');
      
      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((activity) => UserActivity.fromJson(activity))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error getting weekly activities: $e');
      return [];
    }
  }

  // Get calendar data for a month (activity counts per day)
  Future<Map<String, int>> getCalendarData(int year, int month) async {
    try {
      final url = Uri.parse('$baseUrl/sakinah-tracker/calendar/$year/$month');
      
      print('📅 Getting calendar data for $year-$month from: $url');
      
      final response = await http.get(url, headers: _headers);
      
      print('📡 Calendar response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final calendarData = Map<String, int>.from(data['data']);
          print('✅ Loaded calendar data: ${calendarData.length} days with activities');
          return calendarData;
        }
      } else if (response.statusCode == 401) {
        print('🔐 Unauthorized calendar access');
        return {}; // Return empty instead of mock
      } else if (response.statusCode == 404) {
        print('📅 No calendar data found for $year-$month');
        return {}; // Return empty instead of mock
      }
      
      print('⚠️ No valid calendar data found');
      return {};
    } catch (e) {
      print('❌ Network error getting calendar data: $e');
      return {}; // Return empty instead of mock
    }
  }

  // Get activity summary statistics
  Future<Map<String, dynamic>?> getActivitySummary() async {
    try {
      final url = Uri.parse('$baseUrl/sakinah-tracker/summary');
      
      final response = await http.get(url, headers: _headers);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting activity summary: $e');
      return null;
    }
  }

  // Log a custom activity (for manual logging)
  Future<bool> logActivity({
    required String activityType,
    required String activityName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/sakinah-tracker/log-activity');
      
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode({
          'activity_type': activityType,
          'activity_name': activityName,
          'metadata': metadata ?? {},
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('Error logging activity: $e');
      return false;
    }
  }

  // Helper methods for generating realistic mock data (kept for reference if needed)
  // Note: Mock data methods removed to ensure only real database data is shown
}