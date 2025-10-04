import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class AdminService {
  static String get baseUrl => '${AppConfig.baseUrl}/admin';
  
  String? _token;
  static String? _memoryToken; // Simple in-memory storage

  // Get stored token
  Future<String?> getToken() async {
    if (_token != null) return _token;
    
    _token = _memoryToken;
    return _token;
  }

  // Save token
  Future<void> saveToken(String token) async {
    _token = token;
    _memoryToken = token;
  }

  // Clear token
  Future<void> clearToken() async {
    _token = null;
    _memoryToken = null;
  }

  // Get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Admin Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('AdminService: Attempting login for $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('AdminService: Response status ${response.statusCode}');
      print('AdminService: Response body ${response.body}');

      // Check if response body is empty
      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Handle Laravel nested response format
        final responseData = data['data'] ?? data;
        final token = responseData['token'];
        final admin = responseData['admin'];
        
        // Check if required fields exist
        if (token == null || admin == null) {
          print('AdminService: Missing token or admin in response');
          return {
            'success': false,
            'message': 'Invalid response format from server',
          };
        }
        
        await saveToken(token);
        print('AdminService: Login successful, token saved');
        
        return {
          'success': true,
          'admin': admin,
          'message': data['message'] ?? 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('AdminService: Login error - $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Admin Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _getHeaders(),
      );

      await clearToken();
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Logged out successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Logout failed',
        };
      }
    } catch (e) {
      await clearToken(); // Clear token anyway
      return {
        'success': true,
        'message': 'Logged out (offline)',
      };
    }
  }

  // Get Admin Profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'admin': data['admin'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Get Dashboard Stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      print('AdminService: Getting dashboard stats...');
      final result = await apiCall('dashboard/stats', 'GET');
      print('AdminService: getDashboardStats result: $result');
      
      if (result['status'] == 'success') {
        return {
          'success': true,
          'data': result['data'],
        };
      }
      throw Exception(result['message']);
    } catch (e) {
      print('AdminService: getDashboardStats error: $e');
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;

    // Verify token by getting profile
    final result = await getProfile();
    return result['success'] == true;
  }

  // Generic API call method for CRUD operations
  Future<Map<String, dynamic>> apiCall(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl/$endpoint');
      
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      print('AdminService: API Call - $method $uri');

      http.Response response;
      final headers = await _getHeaders();
      print('AdminService: Headers - $headers');

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      print('AdminService: Response status: ${response.statusCode}');
      print('AdminService: Response body: ${response.body}');

      // Check if response body is empty
      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }

      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Return format consistent with Laravel backend response
        return {
          'status': data['status'] ?? 'success',
          'data': data['data'] ?? data,
          'message': data['message'] ?? 'Success',
        };
      } else {
        return {
          'status': 'error',
          'message': data['error'] ?? data['message'] ?? 'Request failed',
          'errors': data['messages'],
        };
      }
    } catch (e) {
      print('AdminService: API Call error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // ===========================================
  // DZIKIR DOA MANAGEMENT
  // ===========================================
  
  Future<List<Map<String, dynamic>>> getDzikirDoa() async {
    try {
      print('AdminService: Getting dzikir doa data...');
      final result = await apiCall('dashboard/dzikir-doa', 'GET');
      print('AdminService: getDzikirDoa result: $result');
      
      if (result['status'] == 'success') {
        // Handle paginated response
        final responseData = result['data'];
        List<Map<String, dynamic>> data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          // Paginated response
          data = List<Map<String, dynamic>>.from(responseData['data'] ?? []);
        } else if (responseData is List) {
          // Direct array response
          data = List<Map<String, dynamic>>.from(responseData);
        } else {
          data = [];
        }
        
        print('AdminService: getDzikirDoa data count: ${data.length}');
        return data;
      }
      throw Exception(result['message']);
    } catch (e) {
      print('AdminService: getDzikirDoa error: $e');
      throw Exception('Failed to get dzikir doa: $e');
    }
  }

  Future<Map<String, dynamic>> createDzikirDoa(Map<String, dynamic> data) async {
    return await apiCall('dzikir-doa', 'POST', body: data);
  }

  Future<Map<String, dynamic>> updateDzikirDoa(int id, Map<String, dynamic> data) async {
    return await apiCall('dzikir-doa/$id', 'PUT', body: data);
  }

  Future<Map<String, dynamic>> deleteDzikirDoa(int id) async {
    return await apiCall('dzikir-doa/$id', 'DELETE');
  }

  // ===========================================
  // AUDIO RELAX MANAGEMENT
  // ===========================================
  
  Future<List<Map<String, dynamic>>> getAudioRelax() async {
    try {
      print('AdminService: Getting audio relax data...');
      final result = await apiCall('dashboard/audio-relax', 'GET');
      print('AdminService: getAudioRelax result: $result');
      
      if (result['status'] == 'success') {
        // Handle paginated response
        final responseData = result['data'];
        List<Map<String, dynamic>> data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          // Paginated response
          data = List<Map<String, dynamic>>.from(responseData['data'] ?? []);
        } else if (responseData is List) {
          // Direct array response
          data = List<Map<String, dynamic>>.from(responseData);
        } else {
          data = [];
        }
        
        print('AdminService: getAudioRelax data count: ${data.length}');
        return data;
      }
      throw Exception(result['message']);
    } catch (e) {
      print('AdminService: getAudioRelax error: $e');
      throw Exception('Failed to get audio relax: $e');
    }
  }

  Future<Map<String, dynamic>> createAudioRelax(Map<String, dynamic> data) async {
    return await apiCall('audio-relax', 'POST', body: data);
  }

  Future<Map<String, dynamic>> updateAudioRelax(int id, Map<String, dynamic> data) async {
    return await apiCall('audio-relax/$id', 'PUT', body: data);
  }

  Future<Map<String, dynamic>> deleteAudioRelax(int id) async {
    return await apiCall('audio-relax/$id', 'DELETE');
  }

  // ===========================================
  // PSYCHOLOGY MATERIALS MANAGEMENT
  // ===========================================
  
  Future<List<Map<String, dynamic>>> getPsychologyMaterials() async {
    try {
      print('AdminService: Getting psychology materials data...');
      final result = await apiCall('dashboard/psychology', 'GET');
      print('AdminService: getPsychologyMaterials result: $result');
      
      if (result['status'] == 'success') {
        // Handle paginated response
        final responseData = result['data'];
        List<Map<String, dynamic>> data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          // Paginated response
          data = List<Map<String, dynamic>>.from(responseData['data'] ?? []);
        } else if (responseData is List) {
          // Direct array response
          data = List<Map<String, dynamic>>.from(responseData);
        } else {
          data = [];
        }
        
        print('AdminService: getPsychologyMaterials data count: ${data.length}');
        return data;
      }
      throw Exception(result['message']);
    } catch (e) {
      print('AdminService: getPsychologyMaterials error: $e');
      throw Exception('Failed to get psychology materials: $e');
    }
  }

  Future<Map<String, dynamic>> createPsychologyMaterial(Map<String, dynamic> data) async {
    return await apiCall('psychology', 'POST', body: data);
  }

  Future<Map<String, dynamic>> updatePsychologyMaterial(int id, Map<String, dynamic> data) async {
    return await apiCall('psychology/$id', 'PUT', body: data);
  }

  Future<Map<String, dynamic>> deletePsychologyMaterial(int id) async {
    return await apiCall('psychology/$id', 'DELETE');
  }

  // ===========================================
  // NOTIFICATIONS MANAGEMENT
  // ===========================================
  
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      print('AdminService: Getting notifications data...');
      final result = await apiCall('dashboard/notifications', 'GET');
      print('AdminService: getNotifications result: $result');
      
      if (result['status'] == 'success') {
        // Handle paginated response
        final responseData = result['data'];
        List<Map<String, dynamic>> data;
        
        if (responseData is Map && responseData.containsKey('data')) {
          // Paginated response
          data = List<Map<String, dynamic>>.from(responseData['data'] ?? []);
        } else if (responseData is List) {
          // Direct array response
          data = List<Map<String, dynamic>>.from(responseData);
        } else {
          data = [];
        }
        
        print('AdminService: getNotifications data count: ${data.length}');
        return data;
      }
      throw Exception(result['message']);
    } catch (e) {
      print('AdminService: getNotifications error: $e');
      throw Exception('Failed to get notifications: $e');
    }
  }

  Future<Map<String, dynamic>> createNotification(Map<String, dynamic> data) async {
    return await apiCall('notifications', 'POST', body: data);
  }

  Future<Map<String, dynamic>> updateNotification(int id, Map<String, dynamic> data) async {
    return await apiCall('notifications/$id', 'PUT', body: data);
  }

  Future<Map<String, dynamic>> deleteNotification(int id) async {
    return await apiCall('notifications/$id', 'DELETE');
  }

  // ===========================================
  // CATEGORIES MANAGEMENT  
  // ===========================================
  
  Future<List<Map<String, dynamic>>> getDzikirCategories() async {
    try {
      final result = await apiCall('dzikir-categories', 'GET');
      if (result['success']) {
        // Handle paginated response
        final responseData = result['data'];
        if (responseData is Map && responseData.containsKey('data')) {
          return List<Map<String, dynamic>>.from(responseData['data'] ?? []);
        } else if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        }
        return [];
      }
      throw Exception(result['message']);
    } catch (e) {
      throw Exception('Failed to get dzikir categories: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAudioCategories() async {
    try {
      final result = await apiCall('audio-categories', 'GET');
      if (result['success']) {
        // Handle paginated response
        final responseData = result['data'];
        if (responseData is Map && responseData.containsKey('data')) {
          return List<Map<String, dynamic>>.from(responseData['data'] ?? []);
        } else if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        }
        return [];
      }
      throw Exception(result['message']);
    } catch (e) {
      throw Exception('Failed to get audio categories: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPsychologyCategories() async {
    try {
      final result = await apiCall('psychology-categories', 'GET');
      if (result['success']) {
        // Handle paginated response
        final responseData = result['data'];
        if (responseData is Map && responseData.containsKey('data')) {
          return List<Map<String, dynamic>>.from(responseData['data'] ?? []);
        } else if (responseData is List) {
          return List<Map<String, dynamic>>.from(responseData);
        }
        return [];
      }
      throw Exception(result['message']);
    } catch (e) {
      throw Exception('Failed to get psychology categories: $e');
    }
  }
}