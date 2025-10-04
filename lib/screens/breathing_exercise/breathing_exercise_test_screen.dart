import 'package:flutter/material.dart';
import '../../services/breathing_exercise_service.dart';
import '../../models/breathing_exercise.dart';

/// Contoh penggunaan BreathingExerciseService
/// Tambahkan widget ini untuk testing Firebase operations
class BreathingExerciseTestScreen extends StatefulWidget {
  const BreathingExerciseTestScreen({super.key});

  @override
  State<BreathingExerciseTestScreen> createState() => _BreathingExerciseTestScreenState();
}

class _BreathingExerciseTestScreenState extends State<BreathingExerciseTestScreen> {
  final BreathingExerciseService _service = BreathingExerciseService();
  List<BreathingExercise> _exercises = [];
  List<BreathingCategory> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Listen to breathing exercises
    _service.getBreathingExercises().listen((exercises) {
      setState(() {
        _exercises = exercises;
      });
    });

    // Listen to categories
    _service.getBreathingCategories().listen((categories) {
      setState(() {
        _categories = categories;
      });
    });
  }

  Future<void> _createSampleData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _service.createSampleCategories();
      await _service.createSampleBreathingExercises();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample data berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTestSession() async {
    if (_exercises.isEmpty) return;

    String userId = 'test_user_123'; // In real app, get from authentication
    BreathingExercise exercise = _exercises.first;

    BreathingSession session = BreathingSession(
      id: '',
      userId: userId,
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      sessionDate: DateTime.now(),
      sessionStats: SessionStats(
        plannedDuration: exercise.totalDuration,
        actualDuration: 280, // 4 minutes 40 seconds
        completedCycles: 25,
        completionPercentage: 92.6,
        isCompleted: false,
      ),
      moodTracking: MoodTracking(
        moodBefore: 'anxious',
        moodAfter: 'calm',
        stressLevelBefore: 7,
        stressLevelAfter: 3,
        notes: 'Merasa lebih tenang setelah dzikir',
      ),
    );

    String? sessionId = await _service.saveBreathingSession(session);
    if (sessionId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing Exercise Test'),
        backgroundColor: const Color(0xFF2C6E49),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createSampleData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C6E49),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Buat Sample Data'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exercises.isEmpty ? null : _saveTestSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test Session'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // Categories Section
            Text(
              'Categories (${_categories.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C6E49),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  BreathingCategory category = _categories[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _hexToColor(category.color),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Exercises Section
            Text(
              'Breathing Exercises (${_exercises.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C6E49),
              ),
            ),
            const SizedBox(height: 8),
            
            Expanded(
              child: ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  BreathingExercise exercise = _exercises[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C6E49),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exercise.description),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C6E49).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  exercise.category.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C6E49),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${exercise.formattedDuration} • ${exercise.difficultyText}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dzikir: ${exercise.dzikirText.inhaleTranslation} - ${exercise.dzikirText.exhaleTranslation}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF2C6E49),
                            ),
                          ),
                          Text(
                            'Pattern: ${exercise.breathingPattern.inhaleDuration}s in, ${exercise.breathingPattern.holdDuration}s hold, ${exercise.breathingPattern.exhaleDuration}s out',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C6E49),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                '${exercise.difficultyLevel}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${exercise.repetition.cyclesPerSession} cycles',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        _showExerciseDetails(exercise);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExerciseDetails(BreathingExercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Arabic: ${exercise.dzikirText.inhaleText} - ${exercise.dzikirText.exhaleText}'),
              const SizedBox(height: 8),
              Text('Translation: ${exercise.dzikirText.inhaleTranslation} - ${exercise.dzikirText.exhaleTranslation}'),
              const SizedBox(height: 8),
              Text('Duration: ${exercise.formattedDuration}'),
              Text('Cycles: ${exercise.repetition.cyclesPerSession}'),
              const SizedBox(height: 8),
              Text('Audio Files:'),
              Text('- Inhale: ${exercise.audioConfig.inhaleAudio ?? "None"}'),
              Text('- Exhale: ${exercise.audioConfig.exhaleAudio ?? "None"}'),
              Text('- Background: ${exercise.audioConfig.backgroundMusic ?? "None"}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.substring(1, 7), radix: 16) + 0xFF000000);
    } catch (e) {
      return const Color(0xFF4CAF50);
    }
  }
}

/* 
==========================================
CARA PENGGUNAAN:
==========================================

1. Tambahkan route di main.dart:
   '/breathing-test': (context) => const BreathingExerciseTestScreen(),

2. Atau buka langsung untuk testing:
   Navigator.push(
     context,
     MaterialPageRoute(builder: (context) => const BreathingExerciseTestScreen()),
   );

3. Untuk menggunakan di screen lain:

   final BreathingExerciseService service = BreathingExerciseService();
   
   // Get all exercises
   StreamBuilder<List<BreathingExercise>>(
     stream: service.getBreathingExercises(),
     builder: (context, snapshot) {
       if (snapshot.hasData) {
         List<BreathingExercise> exercises = snapshot.data!;
         return ListView.builder(...);
       }
       return CircularProgressIndicator();
     },
   );

   // Save user session
   BreathingSession session = BreathingSession(...);
   String? sessionId = await service.saveBreathingSession(session);

   // Get user stats
   Map<String, dynamic> stats = await service.getUserBreathingStats(userId);

==========================================
*/