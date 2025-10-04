import 'package:flutter/material.dart';
import '../widgets/mood_spinner_widget.dart';
import '../services/mood_service.dart';
import '../services/auth_service.dart';
import 'dart:math' as math;

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  MoodOption? _selectedMood;
  bool _isLoading = false;
  bool _canSelectMood = true;
  final MoodService _moodService = MoodService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _fadeController.forward();
    _checkTodayMood();
  }

  void _checkTodayMood() async {
    try {
      // Get token from auth service
      final userToken = await _authService.getToken();
      
      if (userToken == null) {
        print('⚠️ No auth token available');
        setState(() {
          _canSelectMood = true;
        });
        return;
      }
      
      // Test connection first
      final connectionTest = await _moodService.testConnection();
      print('🔍 Connection test: ${connectionTest['message']}');
      
      final result = await _moodService.getTodayMoods(token: userToken);
      
      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        final totalEntries = data['total_entries'] ?? 0;
        
        setState(() {
          _canSelectMood = totalEntries == 0;
        });
        
        if (totalEntries > 0) {
          print('✅ User already selected mood today (${totalEntries} entries)');
        } else {
          print('⭕ User hasn\'t selected mood today');
        }
      } else {
        print('⚠️ Failed to get today moods: ${result['message']}');
        setState(() {
          _canSelectMood = true;
        });
      }
    } catch (e) {
      print('❌ Error checking today mood: $e');
      // If error, allow selection
      setState(() {
        _canSelectMood = true;
      });
    }
  }



  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onMoodSelected(MoodOption mood) {
    setState(() {
      _selectedMood = mood;
    });
  }



  void _saveMood() async {
    if (_selectedMood == null) {
      _showErrorSnackBar('Silakan pilih mood terlebih dahulu');
      return;
    }

    if (!_canSelectMood) {
      _showErrorSnackBar('Anda sudah memilih mood hari ini');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get token from auth service
      final userToken = await _authService.getToken();
      
      if (userToken == null) {
        _showErrorSnackBar('Tidak ada token autentikasi. Silakan login kembali.');
        return;
      }
      
      print('💾 Saving mood: ${_selectedMood!.type} (${_selectedMood!.label})');
      
      final result = await _moodService.saveMoodByType(
        token: userToken,
        moodType: _selectedMood!.type,
        moodDate: DateTime.now(),
        moodTime: DateTime.now(),
        notes: 'Dipilih menggunakan spinner wheel',
      );

      print('📋 Save result: ${result['success']} - ${result['message']}');

      if (result['success']) {
        _showSuccessSnackBar('Mood "${_selectedMood!.label}" berhasil disimpan!');
        
        // Update state to prevent multiple selections
        setState(() {
          _canSelectMood = false;
        });
        
        // Don't pop immediately, let user see the success message
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context, _selectedMood);
          }
        });
      } else {
        String errorMsg = result['message'] ?? 'Gagal menyimpan mood';
        
        if (result['status_code'] == 422 && result['errors'] != null) {
          // Handle validation errors
          final errors = result['errors'];
          if (errors is Map) {
            final errorMessages = <String>[];
            errors.forEach((key, value) {
              if (value is List && value.isNotEmpty) {
                errorMessages.add(value.first.toString());
              }
            });
            if (errorMessages.isNotEmpty) {
              errorMsg = errorMessages.join(', ');
            }
          }
        }
        
        _showErrorSnackBar(errorMsg);
      }
    } catch (e) {
      print('❌ Exception saving mood: $e');
      _showErrorSnackBar('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF8FA68E), // Brand color
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
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
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  children: [
                    // Header dengan back button saja
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
                        ],
                      ),
                    ),

                    // Main content area
                    Expanded(
                      child: Column(
                        children: [
                          // Top section dengan scroll
                          Expanded(
                            flex: 6,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),

                                  // Title section - simple and clean
                                  const Text(
                                    'Bagaimana Perasaan\nKamu Hari Ini??',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D5A5A),
                                      height: 1.3,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 50),

                                  // Current selected mood display - large and centered
                                  if (_selectedMood != null)
                                    Column(
                                      children: [
                                        Container(
                                          width: 180,
                                          height: 180,
                                          decoration: BoxDecoration(
                                            color: _selectedMood!.color.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: _selectedMood!.color.withOpacity(0.2),
                                                blurRadius: 30,
                                                offset: const Offset(0, 15),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: _selectedMood!.imagePath != null
                                                ? ClipOval(
                                                    child: Image.asset(
                                                      _selectedMood!.imagePath!,
                                                      width: 120,
                                                      height: 120,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Text(
                                                          _selectedMood!.emoji,
                                                          style: const TextStyle(fontSize: 80),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : Text(
                                                    _selectedMood!.emoji,
                                                    style: const TextStyle(fontSize: 80),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          _selectedMood!.label,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                            color: _selectedMood!.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  
                                  if (_selectedMood == null)
                                    Column(
                                      children: [
                                        Container(
                                          width: 180,
                                          height: 180,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey.withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.touch_app,
                                              size: 60,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'Ketuk Untuk Memulai',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),

                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ),

                          // Bottom section - Spinner dan Button (fixed)
                          Container(
                            child: Column(
                              children: [
                                // Mood Spinner Widget - responsive container
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final availableWidth = constraints.maxWidth;
                                    final containerWidth = availableWidth - 40; // 20px margin each side
                                    final containerHeight = math.min(containerWidth * 0.8, 280.0).toDouble(); // Responsive height
                                    
                                    return Container(
                                      height: containerHeight,
                                      margin: const EdgeInsets.symmetric(horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.95),
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 25,
                                            offset: const Offset(0, 15),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          // Background Spin Emote
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(30),
                                              child: Opacity(
                                                opacity: 0.1,
                                                child: Image.asset(
                                                  'assets/images/Spin Emote.png',
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF8FA68E).withValues(alpha: 0.05),
                                                        borderRadius: BorderRadius.circular(30),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Spinner Widget
                                          Center(
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: containerWidth - 40,
                                                maxHeight: containerHeight - 40,
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(30),
                                                child: MoodSpinnerWidget(
                                                  onMoodSelected: _onMoodSelected,
                                                  initialMood: _selectedMood,
                                                  canSpin: _canSelectMood,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Save Button Section
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    children: [
                                      // Status indicator jika sudah memilih
                                      if (!_canSelectMood)
                                        Container(
                                          margin: const EdgeInsets.only(bottom: 20),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8FA68E).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: const Color(0xFF8FA68E),
                                              width: 1,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF8FA68E),
                                                size: 24,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Sudah Memilih Hari Ini',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF8FA68E),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      
                                      // Save button
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: (_isLoading || !_canSelectMood || _selectedMood == null) ? null : _saveMood,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _selectedMood?.color ?? const Color(0xFF8FA68E),
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor: Colors.grey.shade300,
                                            padding: const EdgeInsets.symmetric(vertical: 18),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            elevation: 8,
                                            shadowColor: (_selectedMood?.color ?? const Color(0xFF8FA68E)).withOpacity(0.3),
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.5,
                                                  ),
                                                )
                                              : Text(
                                                  !_canSelectMood 
                                                      ? 'Sudah Memilih Hari Ini' 
                                                      : _selectedMood == null 
                                                          ? 'Pilih Mood Dulu'
                                                          : 'Simpan Mood Saya',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
