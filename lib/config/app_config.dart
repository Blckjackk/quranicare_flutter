class AppConfig {
  static const String appName = 'Quranicare';
  static const String packageName = 'com.mtqmn.quranicare';
  
  // Environment configuration
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  static bool get isDevelopment => !isProduction;
  
  // API Configuration
  static String get baseUrl {
    if (isProduction) {
      // URL backend Laravel yang sudah di-deploy
      // Ganti dengan URL server production Anda
      return 'https://your-laravel-backend.com/api';
    } else {
      // URL untuk development (localhost)
      return 'http://127.0.0.1:8000/api';
    }
  }
  
  // API Endpoints
  static String get authLoginUrl => '$baseUrl/auth/login';
  static String get authRegisterUrl => '$baseUrl/auth/register';
  static String get userProfileUrl => '$baseUrl/user/profile';
  static String get audioRelaxUrl => '$baseUrl/audio-relax';
  static String get audioCategoriesUrl => '$baseUrl/audio-categories';
  
  // App Settings
  static const int requestTimeout = 30; // seconds
  static const bool enableLogging = true;
  
  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  
  // Version Info
  static const String version = '1.0.0';
  static const int buildNumber = 1;
  
  static void printConfig() {
    print('🔧 AppConfig initialized:');
    print('   - Environment: ${isProduction ? "Production" : "Development"}');
    print('   - Base URL: $baseUrl');
    print('   - App Version: $version ($buildNumber)');
    print('   - Logging: $enableLogging');
  }
  
  // Initialize method for startup
  static void initialize() {
    printConfig();
  }
}