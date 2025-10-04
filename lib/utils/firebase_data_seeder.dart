import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/breathing_exercise.dart';

class FirebaseDataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Populate sample breathing exercises data
  static Future<void> seedBreathingExercises() async {
    try {
      // Ensure user is authenticated (anonymous is fine)
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }

      // Seeding breathing exercises data...

      // Sample Breathing Exercises
      final exercises = [
        BreathingExercise(
          id: 'basic_4_4_4',
          name: 'Nafas Dasar (4-4-4)',
          description: 'Latihan pernapasan dasar dengan pola 4 detik hirup, 4 detik tahan, 4 detik hembuskan',
          category: 'basic',
          difficultyLevel: 1,
          totalDuration: 300, // 5 minutes
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          breathingPattern: BreathingPattern(
            inhaleDuration: 4,
            holdDuration: 4,
            exhaleDuration: 4,
            restDuration: 0,
            totalCycleDuration: 12,
          ),
          dzikirText: DzikirText(
            inhaleText: 'سُبْحَانَ اللهِ',
            inhaleTranslation: 'Maha Suci Allah',
            exhaleText: 'اللهُ أَكْبَرُ',
            exhaleTranslation: 'Allah Maha Besar',
          ),
          audioConfig: AudioConfig(
            inhaleAudio: 'assets/audio/breathing/inhale.mp3',
            exhaleAudio: 'assets/audio/breathing/exhale.mp3',
            backgroundMusic: 'assets/audio/background/calm_quran.mp3',
          ),
          repetition: RepetitionSettings(
            cyclesPerSession: 25,
            totalSessions: 1,
            breakBetweenSessions: 60,
          ),
        ),
        
        BreathingExercise(
          id: 'intermediate_4_7_8',
          name: 'Nafas Tenang (4-7-8)',
          description: 'Teknik pernapasan untuk ketenangan dan tidur yang lebih baik',
          category: 'intermediate',
          difficultyLevel: 2,
          totalDuration: 480, // 8 minutes
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          breathingPattern: BreathingPattern(
            inhaleDuration: 4,
            holdDuration: 7,
            exhaleDuration: 8,
            restDuration: 2,
            totalCycleDuration: 21,
          ),
          dzikirText: DzikirText(
            inhaleText: 'لَا إِلَهَ إِلَّا اللهُ',
            inhaleTranslation: 'Tiada Tuhan selain Allah',
            exhaleText: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
            exhaleTranslation: 'Ya Allah, limpahkanlah shalawat kepada Muhammad',
          ),
          audioConfig: AudioConfig(
            inhaleAudio: 'assets/audio/breathing/inhale_slow.mp3',
            exhaleAudio: 'assets/audio/breathing/exhale_slow.mp3',
            backgroundMusic: 'assets/audio/background/night_quran.mp3',
          ),
          repetition: RepetitionSettings(
            cyclesPerSession: 23,
            totalSessions: 1,
            breakBetweenSessions: 60,
          ),
        ),

        BreathingExercise(
          id: 'advanced_box_breathing',
          name: 'Nafas Kotak (6-6-6-6)',
          description: 'Teknik pernapasan lanjutan untuk kontrol emosi dan spiritual',
          category: 'advanced',
          difficultyLevel: 3,
          totalDuration: 600, // 10 minutes
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          breathingPattern: BreathingPattern(
            inhaleDuration: 6,
            holdDuration: 6,
            exhaleDuration: 6,
            restDuration: 6,
            totalCycleDuration: 24,
          ),
          dzikirText: DzikirText(
            inhaleText: 'أَسْتَغْفِرُ اللهَ',
            inhaleTranslation: 'Aku memohon ampun kepada Allah',
            exhaleText: 'أَسْتَغْفِرُ اللهَ رَبِّي مِنْ كُلِّ ذَنْبٍ',
            exhaleTranslation: 'Aku memohon ampun kepada Allah Tuhanku dari segala dosa',
          ),
          audioConfig: AudioConfig(
            inhaleAudio: 'assets/audio/breathing/inhale_deep.mp3',
            exhaleAudio: 'assets/audio/breathing/exhale_deep.mp3',
            backgroundMusic: 'assets/audio/background/spiritual_quran.mp3',
          ),
          repetition: RepetitionSettings(
            cyclesPerSession: 25,
            totalSessions: 1,
            breakBetweenSessions: 90,
          ),
        ),
      ];

      // Add categories first
      await _addCategories();

      // Add exercises
      for (final exercise in exercises) {
        await _firestore
            .collection('breathing_exercises')
            .doc(exercise.id)
            .set(exercise.toMap());
      }

    } catch (e) {
      rethrow;
    }
  }

  static Future<void> _addCategories() async {
    final categories = [
      {
        'id': 'basic',
        'name': 'Pemula',
        'description': 'Latihan pernapasan dasar untuk memulai',
        'icon': 'leaf',
        'color': '#4CAF50',
        'order': 1,
      },
      {
        'id': 'intermediate',
        'name': 'Menengah', 
        'description': 'Teknik pernapasan untuk pengembangan',
        'icon': 'water',
        'color': '#2196F3',
        'order': 2,
      },
      {
        'id': 'advanced',
        'name': 'Lanjutan',
        'description': 'Latihan pernapasan untuk penguasaan',
        'icon': 'mountain',
        'color': '#9C27B0',
        'order': 3,
      },
    ];

    for (final category in categories) {
      await _firestore
          .collection('breathing_categories')
          .doc(category['id'] as String)
          .set(category);
    }
  }

  /// Clear all breathing exercises data (for testing)
  static Future<void> clearBreathingExercises() async {
    try {
      // Delete all exercises
      final exercisesSnapshot = await _firestore.collection('breathing_exercises').get();
      for (final doc in exercisesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all categories
      final categoriesSnapshot = await _firestore.collection('breathing_categories').get();
      for (final doc in categoriesSnapshot.docs) {
        await doc.reference.delete();
      }

    } catch (e) {
      rethrow;
    }
  }
}