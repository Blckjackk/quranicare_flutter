import 'package:flutter/material.dart';
import '../profile/profile_screen.dart';
import '../mood_tracker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0: break; // Home - already here
      case 1: 
        // Navigate to Al-Quran
        Navigator.pushNamed(context, '/alquran');
        break;
      case 2: 
        // Navigate to Qalbu Chat
        Navigator.pushNamed(context, '/qalbu-chat');
        break;
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

  void _onMoodTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MoodTrackerScreen(),
      ),
    );
  }

  void _onFeatureTap(String feature) {
    switch (feature) {
      case 'breathing':
        Navigator.pushNamed(context, '/breathing-exercise');
        break;
      case 'audio':
        Navigator.pushNamed(context, '/audio-relax');
        break;
      case 'journal':
        Navigator.pushNamed(context, '/journal');
        break;
      case 'dzikir':
        Navigator.pushNamed(context, '/dzikir-doa');
        break;
    }
  }

  void _onPsychologyTap() {
    Navigator.pushNamed(context, '/psychology-learning');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8F8), // Light mint green top - exact from image
              Color(0xFFE8F5E8), // Light green bottom - exact from image
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section - exact positioning from image
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Greeting Text - exact styling from image
                    const Text(
                      'Assalamualaikum Ahmad....',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D5A5A), // Dark green from image
                        letterSpacing: 0.5,
                      ),
                    ),
                    // Notification Bell - exact color and size from image
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB8C5B0), // Muted green from image
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24), // Exact spacing from image

              // Mood Selector Card - pixel perfect from image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: _onMoodTap,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Title - exact text and styling from image
                        const Text(
                          'Bagaimana Perasaanmu Hari Ini?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5A5A5A), // Gray from image
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Mood Emojis Row - exact colors and layout from image
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Angry - Red background (exact from image)
                            _buildMoodEmoji('😠', const Color(0xFFEF4444)),
                            // Sad - Yellow background (exact from image)
                            _buildMoodEmoji('😢', const Color(0xFFFBBF24)),
                            // Neutral - Yellow background (exact from image)
                            _buildMoodEmoji('😐', const Color(0xFFFBBF24)),
                            // Sleepy - Gray background (exact from image)
                            _buildMoodEmoji('😴', const Color(0xFF9CA3AF)),
                            // Cool/Sunglasses - Yellow background (exact from image)
                            _buildMoodEmoji('😎', const Color(0xFFFBBF24)),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Bottom Text - exact styling from image
                        Text(
                          'Ketuk Untuk Memulai',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF5A5A5A).withOpacity(0.7),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28), // Exact spacing from image

              // Feature Grid (2x2) - exact layout and colors from image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Left Column
                    Expanded(
                      child: Column(
                        children: [
                          // Breathing Exercise - red heart icon (exact from image)
                          _buildFeatureCard(
                            icon: Icons.favorite,
                            iconColor: const Color(0xFFEF4444), // Red heart from image
                            title: 'Breathing Islami Exercise',
                            onTap: () => _onFeatureTap('breathing'),
                          ),
                          const SizedBox(height: 16), // Exact spacing
                          // Journal Refleksi - yellow book icon (exact from image)
                          _buildFeatureCard(
                            icon: Icons.menu_book,
                            iconColor: const Color(0xFFFBBF24), // Yellow book from image
                            title: 'Jurnal Refleksi Al-Quran',
                            onTap: () => _onFeatureTap('journal'),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16), // Exact spacing
                    
                    // Right Column
                    Expanded(
                      child: Column(
                        children: [
                          // Audio Relax - green headphones icon (exact from image)
                          _buildFeatureCard(
                            icon: Icons.headphones,
                            iconColor: const Color(0xFF10B981), // Green headphones from image
                            title: 'Audio Relax Islami',
                            onTap: () => _onFeatureTap('audio'),
                          ),
                          const SizedBox(height: 16), // Exact spacing
                          // Dzikir dan Doa - orange beads icon (exact from image)
                          _buildFeatureCard(
                            icon: Icons.blur_circular,
                            iconColor: const Color(0xFFF97316), // Orange beads from image
                            title: 'Dzikir dan Doa Ketenangan',
                            onTap: () => _onFeatureTap('dzikir'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28), // Exact spacing from image

              // Quranic Psychology Learning Section - exact styling from image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: _onPsychologyTap,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE8F5E8), // Light green from image
                          Color(0xFFD1E7DD), // Slightly darker green from image
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lotus Icon - exact styling from image
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.spa, // Lotus-like icon from image
                            color: Color(0xFF10B981),
                            size: 28,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Title - exact text and styling from image
                        const Text(
                          'Quranic Psychology Learning',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937), // Dark gray from image
                            letterSpacing: 0.3,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Description - exact text and styling from image
                        Text(
                          'Kumpulan materi edukatif yang membahas kesehatan mental dari perspektif Islam dan Al-Quran dengan pendekatan modern',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280), // Medium gray from image
                            height: 1.4,
                            letterSpacing: 0.2,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // See More Button - exact styling from image
                        Text(
                          'See more',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF10B981), // Green from image
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
      
      // Bottom Navigation Bar - exact styling from image
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 80, // Exact height from image
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  isSelected: _selectedIndex == 0,
                  onTap: () => _onBottomNavTap(0),
                ),
                _buildBottomNavItem(
                  icon: Icons.menu_book,
                  label: 'Al-Quran',
                  isSelected: _selectedIndex == 1,
                  onTap: () => _onBottomNavTap(1),
                ),
                _buildBottomNavItem(
                  icon: Icons.favorite,
                  label: 'Qalbu Chat',
                  isSelected: _selectedIndex == 2,
                  onTap: () => _onBottomNavTap(2),
                ),
                _buildBottomNavItem(
                  icon: Icons.person,
                  label: 'Profil',
                  isSelected: _selectedIndex == 3,
                  onTap: () => _onBottomNavTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for mood emojis - exact styling from image
  Widget _buildMoodEmoji(String emoji, Color backgroundColor) {
    return Container(
      width: 44, // Exact size from image
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.15), // Exact opacity from image
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: backgroundColor.withOpacity(0.3), // Exact border from image
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(
            fontSize: 20, // Exact size from image
          ),
        ),
      ),
    );
  }

  // Helper widget for feature cards - exact styling from image
  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16), // Exact padding from image
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Exact radius from image
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06), // Exact shadow from image
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon - exact styling from image
            Container(
              width: 48, // Exact size from image
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15), // Exact opacity from image
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28, // Exact size from image
              ),
            ),
            
            const SizedBox(height: 12), // Exact spacing from image
            
            // Title - exact styling from image
            Text(
              title,
              style: const TextStyle(
                fontSize: 13, // Exact size from image
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151), // Dark gray from image
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for bottom navigation items - exact styling from image
  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                ? const Color(0xFF10B981) // Green when selected (from image)
                : const Color(0xFF9CA3AF), // Gray when unselected (from image)
              size: 24, // Exact size from image
            ),
            const SizedBox(height: 4), // Exact spacing from image
            Text(
              label,
              style: TextStyle(
                fontSize: 12, // Exact size from image
                fontWeight: FontWeight.w500,
                color: isSelected 
                  ? const Color(0xFF10B981) // Green when selected
                  : const Color(0xFF9CA3AF), // Gray when unselected
              ),
            ),
          ],
        ),
      ),
    );
  }
}