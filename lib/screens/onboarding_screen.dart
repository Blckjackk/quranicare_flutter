import 'package:flutter/material.dart';
import 'auth/sign_in_screen.dart';
import '../utils/asset_manager.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding data
  final List<OnboardingData> _pages = [
    OnboardingData(
      arabicText: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      description: 'QuraniCare hadir sebagai pendamping spiritual Anda. Temukan ketenangan melalui wisdom Al-Qur\'an.',
    ),
    OnboardingData(
      arabicText: 'وَنُنَزِّلُ مِنَ الْقُرْآنِ مَا هُوَ شِفَاءٌ وَرَحْمَةٌ',
      description: 'Rasakan kedamaian melalui murottal yang menyejukkan, dzikir yang menenangkan, dan breathing exercise Islami yang membawa ketenangan jiwa dan raga.',
    ),
    OnboardingData(
      arabicText: 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
      description: 'Saksikan transformasi diri melalui tracking yang bermakna. Bangun habits positif dan lihat bagaimana setiap langkah kecil membawa Anda menuju sakinah yang hakiki.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to sign in screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    // Navigate to sign in screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
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
              Color(0xFFF8F9FA), // Very light gray at top
              Color(0xFFE8F5E8), // Light mint green
              Color(0xFFD4F4DD), // Soft green at bottom
            ],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top section with logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    // Logo without container
                    Image.asset(
                      AssetManager.quranicareLogo,
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to original icon if image fails to load
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D5A5A),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.menu_book_rounded,
                                size: 60,
                                color: Colors.white,
                              ),
                              Positioned(
                                top: 20,
                                right: 25,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.brightness_2,
                                    size: 10,
                                    color: Color(0xFF2D5A5A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // QuraniCare brand text
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Qurani',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D5A5A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: 'CARE',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF2D5A5A),
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // PageView content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            // Arabic text with proper styling
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                              child: Text(
                                _pages[index].arabicText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF2D5A5A),
                                  height: 1.6,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // White card container for description
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 25,
                                    offset: const Offset(0, 15),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Progress indicator with exact styling
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(_pages.length, (dotIndex) {
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.symmetric(horizontal: 6),
                                        height: 4,
                                        width: dotIndex == index ? 40 : 12,
                                        decoration: BoxDecoration(
                                          color: dotIndex == index 
                                              ? const Color(0xFF8FA68E) 
                                              : const Color(0xFFD0D0D0),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      );
                                    }),
                                  ),

                                  const SizedBox(height: 25),

                                  // Description text with proper styling
                                  Text(
                                    _pages[index].description,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: const Color(0xFF8FA68E),
                                      height: 1.6,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom navigation buttons
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip button with exact styling
                    TextButton(
                      onPressed: _skipOnboarding,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF8FA68E),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    // Navigation arrows with exact styling
                    Row(
                      children: [
                        // Previous arrow (only show after first page)
                        if (_currentPage > 0)
                          GestureDetector(
                            onTap: _previousPage,
                            child: Container(
                              width: 56,
                              height: 56,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8FA68E),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF8FA68E).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),

                        // Next arrow with exact styling
                        GestureDetector(
                          onTap: _nextPage,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8FA68E),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8FA68E).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              _currentPage == _pages.length - 1 
                                  ? Icons.check 
                                  : Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: _currentPage == _pages.length - 1 ? 24 : 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data model for onboarding pages
class OnboardingData {
  final String arabicText;
  final String description;

  OnboardingData({
    required this.arabicText,
    required this.description,
  });
}
