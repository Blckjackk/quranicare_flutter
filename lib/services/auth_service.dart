import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService {
  String? _token;

  // Get stored token
  Future<String?> getToken() async {
    if (_token != null) return _token;
    
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('user_token');
    return _token;
  }

  // Save token
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', token);
  }

  // Clear token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');
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

  // Public method to get auth headers for other services
  Future<Map<String, String>> getAuthHeaders() async {
    return await _getHeaders();
  }

  // User Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('AuthService: Attempting login for $email');
      
      final response = await http.post(
        Uri.parse(AppConfig.authLoginUrl),
        headers: await _getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('AuthService: Response status: ${response.statusCode}');
      print('AuthService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle both success: true and success: 1 cases
        final isSuccess = data['success'] == true || 
                         data['success'] == 1 || 
                         data['success'] == 'true';
        
        if (isSuccess && data['data'] != null) {
          // Try both 'token' and 'access_token' fields
          final token = data['data']['token']?.toString() ?? 
                       data['data']['access_token']?.toString();
          final user = data['data']['user'];
          
          if (token != null && token.isNotEmpty) {
            await saveToken(token);
            return {
              'success': true,
              'user': user ?? {},
              'message': data['message']?.toString() ?? 'Login successful',
            };
          } else {
            return {
              'success': false,
              'message': 'Invalid token received',
            };
          }
        } else {
          return {
            'success': false,
            'message': data['message']?.toString() ?? 'Login failed',
            'errors': data['errors'],
          };
        }
      } else if (response.statusCode == 422) {
        // Validation errors
        final data = jsonDecode(response.body);
        String errorMessage = 'Validation failed';
        
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map<String, dynamic>;
          final errorMessages = <String>[];
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessages.add(value.first.toString());
            }
          });
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join(', ');
          }
        } else if (data['message'] != null) {
          errorMessage = data['message'].toString();
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'errors': data['errors'],
        };
      } else if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Invalid credentials',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message']?.toString() ?? 'Login failed with status ${response.statusCode}',
        };
      }
    } catch (e) {
      print('AuthService: Login error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // User Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/logout'),
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

  // Get User Profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      print('🌐 AuthService: Making getProfile request...');
      final headers = await _getHeaders();
      print('🌐 AuthService: Request headers: $headers');
      print('🌐 AuthService: Request URL: ${AppConfig.userProfileUrl}');
      
      final response = await http.get(
        Uri.parse(AppConfig.userProfileUrl),
        headers: headers,
      );

      print('🌐 AuthService: Response status: ${response.statusCode}');
      print('🌐 AuthService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🌐 AuthService: Parsed response data: $data');
        print('🌐 AuthService: User data from response: ${data['data']['user']}');
        
        return {
          'success': true,
          'user': data['data']['user'],
        };
      } else {
        final data = jsonDecode(response.body);
        print('❌ AuthService: Profile request failed');
        print('❌ AuthService: Error data: $data');
        
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      print('❌ AuthService: Exception in getProfile: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    print('🔑 AuthService: Checking if user is logged in...');
    final token = await getToken();
    print('🔑 AuthService: Token from storage: ${token != null ? "Found (${token.substring(0, 10)}...)" : "Not found"}');
    
    if (token == null) {
      print('🔑 AuthService: No token found, user not logged in');
      return false;
    }

    // Verify token by getting profile
    print('🔑 AuthService: Verifying token by getting profile...');
    final result = await getProfile();
    final isValid = result['success'] == true;
    print('🔑 AuthService: Token verification result: $isValid');
    
    return isValid;
  }
}