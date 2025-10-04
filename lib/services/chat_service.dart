import 'dart:convert';
import 'package:http/http.dart' as http;
import 'activity_logger_service.dart';
import '../config/app_config.dart';

class ChatService {
  String get baseUrl => AppConfig.baseUrl;
  final ActivityLoggerService _activityLogger = ActivityLoggerService();
  
  DateTime? _sessionStart;
  int _messageCount = 0;

  Future<String> sendMessage(String message) async {
    if (_sessionStart == null) {
      _sessionStart = DateTime.now();
      _messageCount = 0;
      print('🎯 Starting new QalbuChat session');
    }

    _messageCount++;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['reply'];
        
        await _logChatInteraction(message, reply);
        
        return reply;
      } else {
        throw Exception("Failed: ${response.body}");
      }
    } catch (e) {
      print('❌ Chat service error: $e');
      throw Exception("Failed to send message: $e");
    }
  }

  /// Log the chat interaction for activity tracking
  Future<void> _logChatInteraction(String userMessage, String aiResponse) async {
    try {
      final sessionDuration = _sessionStart != null 
          ? DateTime.now().difference(_sessionStart!).inSeconds 
          : 0;

      String? userEmotion = _analyzeUserEmotion(userMessage);

      await _activityLogger.logQalbuChatSession(
        message: userMessage,
        response: aiResponse,
        sessionDurationSeconds: sessionDuration,
        userEmotion: userEmotion,
      );

      print('✅ QalbuChat interaction logged: $_messageCount messages, ${sessionDuration}s');
    } catch (e) {
      print('⚠ Failed to log chat interaction: $e');
    }
  }

  /// Simple emotion analysis based on keywords
  String? _analyzeUserEmotion(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('senang') || lowerMessage.contains('bahagia') || 
        lowerMessage.contains('syukur') || lowerMessage.contains('sukur')) {
      return 'senang';
    }
    
    if (lowerMessage.contains('sedih') || lowerMessage.contains('murung') || 
        lowerMessage.contains('galau') || lowerMessage.contains('kecewa')) {
      return 'sedih';
    }
    
    if (lowerMessage.contains('marah') || lowerMessage.contains('kesal') || 
        lowerMessage.contains('jengkel')) {
      return 'marah';
    }
    
    if (lowerMessage.contains('cemas') || lowerMessage.contains('khawatir') || 
        lowerMessage.contains('takut') || lowerMessage.contains('anxiety')) {
      return 'cemas';
    }
    
    if (lowerMessage.contains('bingung') || lowerMessage.contains('ragu') || 
        lowerMessage.contains('tidak yakin')) {
      return 'bingung';
    }
    
    if (lowerMessage.contains('tenang') || lowerMessage.contains('damai') || 
        lowerMessage.contains('rileks')) {
      return 'tenang';
    }
    
    if (lowerMessage.contains('bagaimana') || lowerMessage.contains('gimana') || 
        lowerMessage.contains('saran') || lowerMessage.contains('bantuan')) {
      return 'mencari_bantuan';
    }
    
    return 'netral';
  }

  /// End session and log final summary
  Future<void> endSession() async {
    if (_sessionStart != null) {
      final totalDuration = DateTime.now().difference(_sessionStart!).inSeconds;
      
      print('🏁 Ending QalbuChat session: $_messageCount messages, ${totalDuration}s total');
      
      _sessionStart = null;
      _messageCount = 0;
    }
  }

  /// Get current session info
  Map<String, dynamic>? getCurrentSessionInfo() {
    if (_sessionStart == null) return null;
    
    return {
      'session_start': _sessionStart!.toIso8601String(),
      'duration_seconds': DateTime.now().difference(_sessionStart!).inSeconds,
      'message_count': _messageCount,
    };
  }
}
