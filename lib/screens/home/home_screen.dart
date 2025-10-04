import 'package:flutter/material.dart';
import '../../utils/asset_manager.dart';
import '../../services/auth_service.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _selectedMood = -1;
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  
  // Auth service and user data
  final AuthService _authService = AuthService();
  String _userName = 'Ahmad Rifai'; // default value
  bool _isLoadingUser = true;

  final List<MoodData> _moods = [
    MoodData(emoji: AssetManager.moodSad, color: const Color(0xFFFF7043), label: 'Sedih'), // Orange-red like screenshot
    MoodData(emoji: AssetManager.moodDown, color: const Color(0xFFFFA726), label: 'Down'), // Yellow-orange
    MoodData(emoji: AssetManager.moodNeutral, color: const Color(0xFFFFCA28), label: 'Biasa'), // Yellow
    MoodData(emoji: AssetManager.moodHappy, color: const Color(0xFF66BB6A), label: 'Senang'), // Light green
    MoodData(emoji: AssetManager.moodHappy, color: const Color(0xFF42A5F5), label: 'Bahagia'), // Blue like sunglasses
  ];

  final List<FeatureData> _features = [
    FeatureData(
      icon: Icons.air,
      color: const Color(0xFF7CB342),
      title: 'Breathing Islami',
      subtitle: 'Teknik nafas untuk ketenangan',
      iconData: Icons.air,
      assetPath: AssetManager.heartIcon,
      gradientColors: [Color(0xFF7CB342), Color(0xFF689F38)],
    ),
    FeatureData(
      icon: Icons.headphones_outlined,
      color: const Color(0xFF7CB342),
      title: 'Audio Relax',
      subtitle: 'Murottal & musik relaksasi',
      iconData: Icons.headphones_outlined,
      assetPath: AssetManager.headphoneIcon,
      gradientColors: [Color(0xFF7CB342), Color(0xFF689F38)],
    ),
    FeatureData(
      icon: Icons.menu_book_outlined,
      color: const Color(0xFF7CB342),
      title: 'Jurnal Refleksi',
      subtitle: 'Refleksi dari Al-Quran',
      iconData: Icons.menu_book_outlined,
      assetPath: AssetManager.quranIcon, // Changed from heartIcon to quranIcon
      gradientColors: [Color(0xFF7CB342), Color(0xFF689F38)],
    ),
    FeatureData(
      icon: Icons.circle_outlined,
      color: const Color(0xFF7CB342),
      title: 'Dzikir & Doa',
      subtitle: 'Kumpulan dzikir harian',
      iconData: Icons.circle_outlined,
      assetPath: AssetManager.tasbihIcon,
      gradientColors: [Color(0xFF7CB342), Color(0xFF689F38)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Load user data
    _loadUserData();
    
    // Debug: Print asset paths
    print('=== DEBUG ASSET PATHS ===');
    for (var feature in _features) {
      print('${feature.title}: ${feature.assetPath}');
    }
    print('========================');
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOutQuart),
    );
    
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeOutQuart),
    );
    
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final result = await _authService.getProfile();
      if (result['success'] == true && result['user'] != null) {
        final user = result['user'];
        setState(() {
          _userName = user['name'] ?? user['username'] ?? 'User';
          _isLoadingUser = false;
        });
      } else {
        setState(() {
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0: break;
      case 1: Navigator.pushNamed(context, '/alquran'); break;
      case 2: Navigator.pushNamed(context, '/qalbu-chat'); break;
      case 3: 
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
        break;
    }
  }

  void _selectMood(int index) {
    setState(() {
      _selectedMood = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8), // Soft green background like in screenshot
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Modern Animated Header
              AnimatedBuilder(
                animation: _headerAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - _headerAnimation.value)),
                    child: Opacity(
                      opacity: _headerAnimation.value,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF7CB342), Color(0xFF689F38)], // Soft natural green like screenshot
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7CB342).withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF7CB342), Color(0xFF689F38)], // Soft natural green
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7CB342).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Assalamualaikum',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _isLoadingUser ? 'Loading...' : _userName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/notification'),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    const Center(
                                      child: Icon(
                                        Icons.notifications_none_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Color(0xFFef4444), Color(0xFFdc2626)],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Modern Mood Tracker
              AnimatedBuilder(
                animation: _cardAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _cardAnimation.value)),
                    child: Opacity(
                      opacity: _cardAnimation.value,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF2C6E49), Color(0xFF1B5E20)], // Islamic green
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2C6E49).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.mood_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mood Check',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1e293b),
                                        ),
                                      ),
                                      Text(
                                        'Bagaimana perasaanmu hari ini?',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748b),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: _moods.asMap().entries.map((entry) {
                                int index = entry.key;
                                MoodData mood = entry.value;
                                bool isSelected = _selectedMood == index;

                                return GestureDetector(
                                  onTap: () => _selectMood(index),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                    width: isSelected ? 62 : 56,
                                    height: isSelected ? 62 : 56,
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(colors: [mood.color, mood.color.withOpacity(0.8)])
                                          : null,
                                      color: isSelected ? null : const Color(0xFFf1f5f9),
                                      borderRadius: BorderRadius.circular(isSelected ? 20 : 18),
                                      boxShadow: isSelected ? [
                                        BoxShadow(
                                          color: mood.color.withOpacity(0.4),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ] : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        mood.emoji,
                                        width: isSelected ? 36 : 32,
                                        height: isSelected ? 36 : 32,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Text(
                                            mood.label.substring(0, 1),
                                            style: TextStyle(
                                              fontSize: isSelected ? 28 : 24,
                                              color: isSelected ? Colors.white : const Color(0xFF64748b),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 20),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: _selectedMood == -1 
                                    ? const LinearGradient(colors: [Color(0xFFe2e8f0), Color(0xFFcbd5e1)])
                                    : LinearGradient(colors: [
                                        _moods[_selectedMood].color.withOpacity(0.1),
                                        _moods[_selectedMood].color.withOpacity(0.05),
                                      ]),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedMood == -1 
                                      ? const Color(0xFFe2e8f0)
                                      : _moods[_selectedMood].color.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _selectedMood == -1 ? Icons.touch_app_rounded : Icons.check_circle_rounded,
                                    size: 16,
                                    color: _selectedMood == -1 
                                        ? const Color(0xFF64748b)
                                        : _moods[_selectedMood].color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedMood == -1 
                                        ? 'Pilih mood untuk tracking' 
                                        : 'Mood tersimpan!',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _selectedMood == -1 
                                          ? const Color(0xFF64748b)
                                          : _moods[_selectedMood].color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // New Mood Selector Button
                            const SizedBox(height: 12),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final selectedMood = await Navigator.pushNamed(
                                    context,
                                    '/mood-tracker',
                                  );
                                  if (selectedMood != null) {
                                    // Update home screen mood if needed
                                    // You can handle the returned mood here
                                    print('Selected mood: $selectedMood');
                                  }
                                },
                                icon: const Icon(
                                  Icons.casino_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Pilih dengan Spin',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C6E49),
                                  elevation: 4,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  shadowColor: const Color(0xFF2C6E49).withOpacity(0.3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Modern Section Title
              AnimatedBuilder(
                animation: _cardAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 10 * (1 - _cardAnimation.value)),
                    child: Opacity(
                      opacity: _cardAnimation.value,
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7CB342), Color(0xFF689F38)], // Soft natural green accent
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Fitur Utama',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7CB342), // Soft natural green for title
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Modern Features Grid
              AnimatedBuilder(
                animation: _cardAnimation,
                builder: (context, child) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: _features.asMap().entries.map((entry) {
                      int index = entry.key;
                      FeatureData feature = entry.value;
                      
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 800 + (index * 100)),
                        curve: Curves.easeOutQuart,
                        transform: Matrix4.identity()
                          ..translate(0.0, 30 * (1 - _cardAnimation.value)),
                        child: Opacity(
                          opacity: _cardAnimation.value,
                          child: GestureDetector(
                            onTap: () {
                              if (feature.title.contains('Breathing')) {
                                Navigator.pushNamed(context, '/breathing-exercise');
                              } else if (feature.title.contains('Audio')) {
                                Navigator.pushNamed(context, '/audio-relax');
                              } else if (feature.title.contains('Jurnal')) {
                                Navigator.pushNamed(context, '/jurnal-refleksi');
                              } else if (feature.title.contains('Dzikir')) {
                                Navigator.pushNamed(context, '/doa-dzikir');
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.1),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16), // Reduced from 20 to 16
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Feature image with better error handling
                                    Container(
                                      width: 56, // Reduced from 64 to 56
                                      height: 56, // Reduced from 64 to 56
                                      child: feature.assetPath != null 
                                        ? Image.asset(
                                            feature.assetPath!,
                                            width: 56, // Reduced from 64 to 56
                                            height: 56, // Reduced from 64 to 56
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              print('Error loading image: ${feature.assetPath}');
                                              print('Error: $error');
                                              return Container(
                                                width: 56, // Reduced from 64 to 56
                                                height: 56, // Reduced from 64 to 56
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF2C6E49).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  feature.iconData,
                                                  color: const Color(0xFF2C6E49),
                                                  size: 32,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            width: 56, // Reduced from 64 to 56
                                            height: 56, // Reduced from 64 to 56
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2C6E49).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              feature.iconData,
                                              color: const Color(0xFF2C6E49),
                                              size: 28, // Reduced from 32 to 28
                                            ),
                                          ),
                                    ),

                                    const SizedBox(height: 12), // Reduced from 16 to 12

                                    Text(
                                      feature.title,
                                      style: const TextStyle(
                                        fontSize: 14, // Reduced from 15 to 14
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1e293b),
                                        letterSpacing: 0.2,
                                        height: 1.2,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 4), // Reduced from 6 to 4

                                    Text(
                                      feature.subtitle,
                                      style: const TextStyle(
                                        fontSize: 10, // Reduced from 11 to 10
                                        color: Color(0xFF64748b),
                                        height: 1.3,
                                        fontWeight: FontWeight.w500,
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
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Modern Quranic Psychology Card
              AnimatedBuilder(
                animation: _cardAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _cardAnimation.value)),
                    child: Opacity(
                      opacity: _cardAnimation.value,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF7CB342), Color(0xFF689F38)], // Soft natural green theme
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7CB342).withOpacity(0.25),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF7CB342), Color(0xFF689F38)], // Soft natural green
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF7CB342).withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.auto_stories_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                'Quranic Psychology',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                'Jelajahi kesehatan mental dari perspektif Al-Quran dengan pendekatan psikologi modern yang terintegrasi',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 20),

                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/quranic-psychology'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF7CB342), Color(0xFF689F38)], // Soft natural green
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF7CB342).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Mulai Belajar',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModernNavItem(0, Icons.home_rounded, 'Home'),
                _buildModernNavItem(1, Icons.book_rounded, 'Al-Quran'),
                _buildModernNavItem(2, Icons.chat_bubble_rounded, 'Qalbu Chat'),
                _buildModernNavItem(3, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onBottomNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? const LinearGradient(colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)])
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF6366f1).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF64748b),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF64748b),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Models
class MoodData {
  final String emoji;
  final Color color;
  final String label;

  MoodData({required this.emoji, required this.color, required this.label});
}

class FeatureData {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final IconData iconData;
  final String? assetPath;
  final List<Color> gradientColors;

  FeatureData({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.iconData,
    this.assetPath,
    required this.gradientColors,
  });
}