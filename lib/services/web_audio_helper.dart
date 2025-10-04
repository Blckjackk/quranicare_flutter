import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Web-specific workarounds for CORS issues
class WebAudioHelper {
  
  /// Alternative URLs that might work in web (these are examples, replace with actual working URLs)
  static Map<String, String> getAlternativeAudioUrls() {
    return {
      '1': 'assets/audio/sample_al_fatihah.mp3', // Local assets as fallback
      '18': 'assets/audio/sample_al_kahf.mp3',
      '36': 'assets/audio/sample_yasin.mp3',
    };
  }
  
  /// Check if we're running in web environment
  static bool get isWeb => kIsWeb;
  
  /// Get informative message for web users about CORS
  static String getWebLimitationMessage() {
    return '🌐 Mode Web Terbatas\n\n'
           'Karena kebijakan keamanan browser (CORS Policy), streaming murotal langsung dari API eksternal tidak dapat dilakukan di versi web.\n\n'
           'Untuk mendapatkan pengalaman penuh dengan 114 surah dan 6 qori terbaik, silakan gunakan aplikasi mobile.';
  }
  
  /// Get user-friendly alternatives for web
  static List<WebAlternative> getWebAlternatives() {
    return [
      WebAlternative(
        icon: '📱',
        title: 'Download Aplikasi Mobile',
        description: 'Akses lengkap 114 surah dengan 6 qori terkenal',
        action: () => _downloadMobileApp(),
      ),
      WebAlternative(
        icon: '🔊',
        title: 'Audio Database',
        description: 'Gunakan koleksi audio relaksasi yang tersedia',
        action: () => _navigateToAudioDatabase(),
      ),
      WebAlternative(
        icon: '📖',
        title: 'Al-Quran.cloud',
        description: 'Buka website Al-Quran.cloud langsung',
        action: () => _openAlQuranCloud(),
      ),
      WebAlternative(
        icon: '🎧',
        title: 'Platform Streaming',
        description: 'Cari murotal di Spotify, YouTube Music, dll',
        action: () => _openStreamingPlatforms(),
      ),
    ];
  }
  
  /// Show CORS explanation to users
  static String getCorsExplanation() {
    return 'CORS (Cross-Origin Resource Sharing) adalah kebijakan keamanan browser yang mencegah '
           'website mengakses resource dari domain lain tanpa izin khusus. Hal ini melindungi '
           'pengguna dari serangan berbahaya, namun membatasi fitur streaming audio eksternal.';
  }
  
  // Action methods
  static Future<void> _downloadMobileApp() async {
    // In a real app, this would link to Play Store or App Store
    const url = 'https://play.google.com/store/apps/details?id=com.example.quranicare';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
  
  static void _navigateToAudioDatabase() {
    // This would trigger navigation in the main app
    // Implementation depends on your routing system
  }
  
  static Future<void> _openAlQuranCloud() async {
    const url = 'https://alquran.cloud';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
  
  static Future<void> _openStreamingPlatforms() async {
    const url = 'https://www.google.com/search?q=murotal+quran+streaming';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

/// Data class for web alternative actions
class WebAlternative {
  final String icon;
  final String title;
  final String description;
  final VoidCallback action;
  
  WebAlternative({
    required this.icon,
    required this.title,
    required this.description,
    required this.action,
  });
}