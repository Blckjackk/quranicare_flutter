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
        Navigator.pushNamed(context, '/alquran');
        break;
      case 2: 
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
              Color(0xFFF0F8F8), // Sesuai mood tracker dan profile
              Color(0xFFE8F5E8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - Simple seperti di gambar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Assalamualaikum Ahmad....',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D5A5A), // Sama dengan profile
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8FA68E), // Sama dengan profile
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

                const SizedBox(height: 30),

                // Mood Selector Card - Simple seperti di gambar
                Container(
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
                      const Text(
                        'Bagaimana Perasaanmu Hari Ini?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D5A5A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Mood Emojis dengan asset yang ada
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMoodEmoji('assets/images/Emote Marah.png', const Color(0xFFEF4444)),
                          _buildMoodEmoji('assets/images/Emote Sedih.png', const Color(0xFFFBBF24)),
                          _buildMoodEmoji('assets/images/Emote Datar.png', const Color(0xFFFBBF24)),
                          _buildMoodEmoji('assets/images/Emote Sedih Kecewa.png', const Color(0xFF9CA3AF)),
                          _buildMoodEmoji('assets/images/Emote Kacamata Senang.png', const Color(0xFFFBBF24)),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      GestureDetector(
                        onTap: _onMoodTap,
                        child: const Text(
                          'Ketuk Untuk Memulai',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8FA68E), // Warna tema
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Feature Grid - Menggunakan asset yang ada
                Row(
                  children: [
                    // Left Column
                    Expanded(
                      child: Column(
                        children: [
                          _buildFeatureCard(
                            'assets/images/Asset Hati.png',
                            'Breathing Islami Exercise',
                            const Color(0xFFEF4444),
                            () => _onFeatureTap('breathing'),
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                            'assets/images/Asset Alquran.png',
                            'Jurnal Refleksi Al-Quran',
                            const Color(0xFFFBBF24),
                            () => _onFeatureTap('journal'),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Right Column
                    Expanded(
                      child: Column(
                        children: [
                          _buildFeatureCard(
                            'assets/images/Asset Headphone.png',
                            'Audio Relax Islami',
                            const Color(0xFF16A34A),
                            () => _onFeatureTap('audio'),
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                            'assets/images/Asset Tasbih.png',
                            'Dzikir dan Doa Ketenangan',
                            const Color(0xFFF97316),
                            () => _onFeatureTap('dzikir'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Quranic Psychology - Simple seperti profile menu
                GestureDetector(
                  onTap: _onPsychologyTap,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8FA68E), Color(0xFF7A9B7A)], // Sama dengan profile
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8FA68E).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.spa,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quranic Psychology Learning',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Kumpulan materi edukatif yang membahas kesehatan mental dari perspektif Islam dan Al-Quran',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 100), // Space for bottom nav
              ],
            ),
          ),
        ),
      ),
      
      // Bottom Navigation - Simple
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
            height: 70,
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

  // Widget helper untuk mood emoji dengan asset
  Widget _buildMoodEmoji(String assetPath, Color backgroundColor) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: backgroundColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              '😊',
              style: const TextStyle(fontSize: 20),
            );
          },
        ),
      ),
    );
  }

  // Widget helper untuk feature cards dengan asset
  Widget _buildFeatureCard(String assetPath, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Asset image dengan background color
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  color: Colors.white,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.apps,
                      color: Colors.white,
                      size: 24,
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D5A5A),
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

  // Widget helper untuk bottom navigation
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
                ? const Color(0xFF8FA68E) // Warna tema hijau
                : const Color(0xFF9CA3AF),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected 
                  ? const Color(0xFF8FA68E) // Warna tema hijau
                  : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}