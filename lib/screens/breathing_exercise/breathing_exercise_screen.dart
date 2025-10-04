import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/breathing_exercise_service.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  int _currentStep = 0; // 0: main, 1: categories, 2: exercises, 3: animation
  
  final BreathingExerciseService _breathingService = BreathingExerciseService();
  List<BreathingCategoryModel> _categories = [];
  List<BreathingExerciseModel> _exercises = [];
  BreathingCategoryModel? _selectedCategory;
  BreathingExerciseModel? _selectedExercise;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    setState(() => _isLoading = true);
    await _breathingService.initialize();
    await _loadCategories();
    setState(() => _isLoading = false);
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _breathingService.getDynamicCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadExercisesByCategory(int categoryId) async {
    setState(() => _isLoading = true);
    try {
      final exercises = await _breathingService.getDynamicExercisesByCategory(categoryId);
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading exercises: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA), // Light gray - consistent with brand
              Color(0xFFE8F5E8), // Light green 
              Color(0xFFD4F4DD), // Softer green - brand consistent
            ],
          ),
        ),
        child: SafeArea(
          child: _buildCurrentScreen(),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8FA68E)),
        ),
      );
    }

    switch (_currentStep) {
      case 1:
        return _buildCategorySelection();
      case 2:
        return _buildExerciseSelection();
      case 3:
        return BreathingAnimationScreen(exercise: _selectedExercise);
      default:
        return _buildMainMenu();
    }
  }

  Widget _buildMainMenu() {
    return Column(
      children: [
        // Header dengan design yang konsisten
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF2D5A5A),
                    size: 20,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'Latihan Pernapasan Islami',
                  style: TextStyle(
                    color: Color(0xFF2D5A5A),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
        
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lotus decoration with Islamic twist
                Container(
                  width: 200,
                  height: 150,
                  child: CustomPaint(
                    painter: IslamicBreathingPainter(),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Description text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Latihan pernapasan dengan panduan dzikir dan asmaul husna untuk menenangkan jiwa dan memperkuat spiritualitas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF2D5A5A).withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Start Button dengan design yang konsisten
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _currentStep = 1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8FA68E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 12,
                        shadowColor: const Color(0xFF8FA68E).withOpacity(0.4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Mulai Latihan',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Quick info cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoCard(
                      icon: Icons.psychology,
                      title: '${_categories.length}+',
                      subtitle: 'Kategori',
                    ),
                    _buildInfoCard(
                      icon: Icons.air,
                      title: 'Dzikir',
                      subtitle: 'Panduan',
                    ),
                    _buildInfoCard(
                      icon: Icons.timer,
                      title: '3-15',
                      subtitle: 'Menit',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D5A5A).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF8FA68E),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5A5A),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF2D5A5A).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      children: [
        // Header dengan design yang konsisten
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _currentStep = 0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF2D5A5A),
                    size: 18,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'Pilih Kategori Latihan',
                  style: TextStyle(
                    color: Color(0xFF2D5A5A),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      setState(() {
                        _selectedCategory = category;
                      });
                      await _loadExercisesByCategory(category.id);
                      setState(() => _currentStep = 2);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFFFFF),
                            Color(0xFFF8F9FA),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF8FA68E).withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8FA68E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                _getIconData(category.icon),
                                color: const Color(0xFF8FA68E),
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D5A5A),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              category.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF2D5A5A).withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseSelection() {
    return Column(
      children: [
        // Header dengan design yang konsisten
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _currentStep = 1),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF2D5A5A),
                    size: 18,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  _selectedCategory?.name ?? 'Pilih Latihan',
                  style: const TextStyle(
                    color: Color(0xFF2D5A5A),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        
        Expanded(
          child: _exercises.isEmpty 
              ? const Center(
                  child: Text(
                    'Tidak ada latihan tersedia',
                    style: TextStyle(
                      color: Color(0xFF8FA68E),
                      fontSize: 20,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _exercises[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedExercise = exercise;
                                _currentStep = 3;
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xFFF8F9FA),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF8FA68E).withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          exercise.name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2D5A5A),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8FA68E).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          exercise.formattedDuration,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF8FA68E),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    exercise.description,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: const Color(0xFF2D5A5A).withOpacity(0.7),
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F8F8),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF8FA68E).withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Dzikir:',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF8FA68E),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          exercise.dzikirText,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            color: Color(0xFF2D5A5A),
                                            fontWeight: FontWeight.w500,
                                            height: 1.3,
                                          ),
                                          textAlign: TextAlign.right,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          exercise.patternText,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: const Color(0xFF2D5A5A).withOpacity(0.6),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${exercise.defaultRepetitions} siklus',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF8FA68E),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'spa':
        return Icons.spa;
      case 'center_focus_strong':
        return Icons.center_focus_strong;
      case 'bolt':
        return Icons.bolt;
      case 'bedtime':
        return Icons.bedtime;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'psychology':
        return Icons.psychology;
      default:
        return Icons.air;
    }
  }

}

// Breathing Animation Screen with Dynamic Exercise
class BreathingAnimationScreen extends StatefulWidget {
  final BreathingExerciseModel? exercise;
  
  const BreathingAnimationScreen({super.key, this.exercise});

  @override
  State<BreathingAnimationScreen> createState() => _BreathingAnimationScreenState();
}

class _BreathingAnimationScreenState extends State<BreathingAnimationScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _breathingController;
  late AnimationController _timerController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _timerAnimation;
  
  late int _totalTimeMinutes;
  String _currentPhase = 'Tarik Napas';
  bool _isRunning = false;
  int _currentCycle = 0;
  late int _totalCycles;
  late int _inhaleDuration;
  late int _holdDuration;
  late int _exhaleDuration;
  String _currentDzikir = '';
  
  @override
  void initState() {
    super.initState();
    _initializeExercise();
    _setupAnimations();
  }

  void _initializeExercise() {
    final exercise = widget.exercise;
    if (exercise != null) {
      _totalTimeMinutes = exercise.estimatedDurationMinutes;
      _totalCycles = exercise.defaultRepetitions;
      _inhaleDuration = exercise.inhaleDuration;
      _holdDuration = exercise.holdDuration;
      _exhaleDuration = exercise.exhaleDuration;
      _currentDzikir = exercise.dzikirText;
    } else {
      // Default values
      _totalTimeMinutes = 7;
      _totalCycles = 20;
      _inhaleDuration = 4;
      _holdDuration = 4;
      _exhaleDuration = 4;
      _currentDzikir = 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ';
    }
  }

  void _setupAnimations() {
    final totalCycleDuration = _inhaleDuration + _holdDuration + _exhaleDuration;
    
    _breathingController = AnimationController(
      duration: Duration(seconds: totalCycleDuration),
      vsync: this,
    );
    
    _timerController = AnimationController(
      duration: Duration(minutes: _totalTimeMinutes),
      vsync: this,
    );
    
    // Create a more complex breathing animation
    _breathingAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: _inhaleDuration.toDouble(),
      ),
      if (_holdDuration > 0)
        TweenSequenceItem(
          tween: ConstantTween<double>(1.0),
          weight: _holdDuration.toDouble(),
        ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.3).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: _exhaleDuration.toDouble(),
      ),
    ]).animate(_breathingController);
    
    _timerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_timerController);
    
    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentCycle++;
          if (_currentCycle >= _totalCycles) {
            _isRunning = false;
            _breathingController.stop();
            _timerController.stop();
            _showCompletionDialog();
          } else {
            _breathingController.forward(from: 0);
          }
        });
      }
    });

    // Update phase text based on animation progress
    _breathingController.addListener(() {
      final progress = _breathingController.value;
      final totalDuration = _inhaleDuration + _holdDuration + _exhaleDuration;
      final inhaleThreshold = _inhaleDuration / totalDuration;
      final holdThreshold = (_inhaleDuration + _holdDuration) / totalDuration;
      
      String newPhase;
      if (progress < inhaleThreshold) {
        newPhase = 'Tarik Napas';
      } else if (progress < holdThreshold && _holdDuration > 0) {
        newPhase = 'Tahan';
      } else {
        newPhase = 'Hembuskan';
      }
      
      if (newPhase != _currentPhase) {
        setState(() {
          _currentPhase = newPhase;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _breathingController.dispose();
    _timerController.dispose();
    super.dispose();
  }
  
  void _toggleBreathing() {
    setState(() {
      _isRunning = !_isRunning;
    });
    
    if (_isRunning) {
      _breathingController.forward();
      _timerController.forward();
    } else {
      _breathingController.stop();
      _timerController.stop();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Selamat! 🎉',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2D5A5A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Anda telah menyelesaikan latihan pernapasan dengan sempurna.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2D5A5A),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Total Siklus: $_currentCycle',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8FA68E),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Selesai',
                style: TextStyle(
                  color: Color(0xFF8FA68E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.exercise?.name ?? 'Latihan Pernapasan Islami',
                      style: const TextStyle(
                        color: Color(0xFF2D5A5A),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            // Cycle Progress
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D5A5A).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Siklus: $_currentCycle/$_totalCycles',
                    style: const TextStyle(
                      color: Color(0xFF2D5A5A),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _timerAnimation,
                    builder: (context, child) {
                      final remainingMinutes = _totalTimeMinutes * (1 - _timerAnimation.value);
                      return Text(
                        '${remainingMinutes.toInt()}:${((remainingMinutes % 1) * 60).toInt().toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Color(0xFF8FA68E),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Breathing Animation
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dzikir Text
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2D5A5A).withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        _currentDzikir,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D5A5A),
                          height: 1.5,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Enhanced Breathing Circle Animation
                    AnimatedBuilder(
                      animation: _breathingAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 350,
                          height: 350,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow rings
                              for (int i = 0; i < 3; i++)
                                Container(
                                  width: (320 - i * 40) * _breathingAnimation.value,
                                  height: (320 - i * 40) * _breathingAnimation.value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF8FA68E).withOpacity(0.2 - i * 0.05),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              
                              // Glowing effect
                              Container(
                                width: 280 * _breathingAnimation.value,
                                height: 280 * _breathingAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8FA68E).withOpacity(0.4),
                                      blurRadius: 40 * _breathingAnimation.value,
                                      spreadRadius: 20 * _breathingAnimation.value,
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Main circle with Islamic pattern
                              Container(
                                width: 250 * _breathingAnimation.value,
                                height: 250 * _breathingAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFF8FA68E).withOpacity(0.8),
                                      const Color(0xFF8FA68E),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    child: CustomPaint(
                                      painter: IslamicPatternPainter(
                                        progress: _breathingAnimation.value,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Phase Text with Animation
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _currentPhase,
                        key: ValueKey(_currentPhase),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5A5A),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Control Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Reset
                        GestureDetector(
                          onTap: () {
                            _breathingController.reset();
                            _timerController.reset();
                            setState(() {
                              _currentCycle = 0;
                              _isRunning = false;
                              _currentPhase = 'Tarik Napas';
                            });
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8FA68E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFF8FA68E),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: Color(0xFF8FA68E),
                              size: 30,
                            ),
                          ),
                        ),
                        
                        // Play/Pause
                        GestureDetector(
                          onTap: _toggleBreathing,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8FA68E),
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8FA68E).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isRunning ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        
                        // Stop
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.stop,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painters
class IslamicBreathingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8FA68E).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw Islamic geometric pattern (simplified star)
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      final x = centerX + 60 * math.cos(angle);
      final y = centerY + 40 * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Draw center circle with Arabic calligraphy effect
    canvas.drawCircle(
      Offset(centerX, centerY),
      30,
      paint..color = const Color(0xFF2D5A5A).withOpacity(0.8),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class IslamicPatternPainter extends CustomPainter {
  final double progress;

  IslamicPatternPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 4;

    // Draw animated Islamic star pattern
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45 + progress * 360) * (3.14159 / 180);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Draw center dot
    canvas.drawCircle(center, 3, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(IslamicPatternPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
