import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quranicare/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'config/app_config.dart';
import 'test_firebase_screen.dart';
import 'test_font_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/notification_screen.dart';
import 'screens/mood_tracker_screen.dart';
import 'screens/breathing_exercise/breathing_exercise_screen.dart';
import 'screens/breathing_exercise/breathing_exercise_test_screen.dart';
import 'screens/audio_relax/audio_relax_screen.dart';
import 'screens/jurnal_refleksi/jurnal_refleksi_screen.dart';
import 'screens/doa_dzikir_screen.dart';
import 'screens/quranic_psychology/quranic_psychology_screen.dart';
import 'screens/qalbuchat/qalbu_chat_screen.dart';
import 'screens/alquran/alquran_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/verification_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/create_profile_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/daily_recap_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AppConfig
  AppConfig.initialize();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuraniCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2D5A5A),
        fontFamily: 'AbhayaLibre',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D5A5A),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'AbhayaLibre', fontWeight: FontWeight.w800), // ExtraBold
          displayMedium: TextStyle(fontFamily: 'AbhayaLibre', fontWeight: FontWeight.w700), // Bold
          displaySmall: TextStyle(fontFamily: 'AbhayaLibre', fontWeight: FontWeight.w600), // SemiBold
          headlineLarge: TextStyle(fontFamily: 'AbhayaLibre', fontWeight: FontWeight.w700), // Bold
          headlineMedium: TextStyle(fontFamily: 'AbhayaLibre', fontWeight: FontWeight.w600), // SemiBold
          headlineSmall: TextStyle(fontFamily: 'AbhayaLibre', fontWeight: FontWeight.w600), // SemiBold
          titleLarge: TextStyle(fontFamily: 'AbhayaLibre', fontWeight: FontWeight.w600), // SemiBold
          titleMedium: TextStyle(fontFamily: 'AbhayaLibre', fontWeight: FontWeight.w500), // Medium
          titleSmall: TextStyle(fontFamily: 'AbhayaLibre', fontWeight: FontWeight.w500), // Medium
          bodyLarge: TextStyle(fontFamily: 'AbhayaLibre', fontWeight: FontWeight.w400), // Regular
          bodyMedium: TextStyle(fontFamily: 'AbhayaLibre', fontWeight: FontWeight.w400), // Regular
          bodySmall: TextStyle(fontFamily: 'AbhayaLibre', fontWeight: FontWeight.w400), // Regular
          labelLarge: TextStyle(fontFamily: 'AbhayaLibre', fontWeight: FontWeight.w500), // Medium
          labelMedium: TextStyle(fontFamily: 'AbhayaLibre', fontWeight: FontWeight.w500), // Medium
          labelSmall: TextStyle(fontFamily: 'AbhayaLibre', fontWeight: FontWeight.w400), // Regular
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      // home: const AdminLoginScreen(),
      // home: const HomeScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/firebase-test': (context) => const TestFirebaseScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/create-profile': (context) => const CreateProfileScreen(),
        '/notification': (context) => const NotificationScreen(),
        '/mood-tracker': (context) => const MoodTrackerScreen(),
        '/breathing-exercise': (context) => const BreathingExerciseScreen(),
        '/breathing-test': (context) => const BreathingExerciseTestScreen(),
        '/audio-relax': (context) => const AudioRelaxScreen(),
        '/jurnal-refleksi': (context) => const JurnalRefleksiScreen(),
        '/doa-dzikir': (context) => const DoaDzikirScreen(),
        '/quranic-psychology': (context) => const QuranicPsychologyScreen(),
        '/qalbu-chat': (context) => const QalbuChatScreen(),
        '/alquran': (context) => const AlQuranScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/daily-recap': (context) => const DailyRecapScreen(),
        '/test-font': (context) => const TestFontScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/verification') {
          final email = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => VerificationScreen(email: email),
          );
        }
        return null;
      },
    );
  }
}
