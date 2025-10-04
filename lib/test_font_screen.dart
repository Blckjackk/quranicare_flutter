import 'package:flutter/material.dart';

class TestFontScreen extends StatelessWidget {
  const TestFontScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Font Test - AbhayaLibre',
          style: TextStyle(
            fontFamily: 'AbhayaLibre',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF8FA68E),
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE8F5E8),
              Color(0xFFD4F4DD),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Demo Font AbhayaLibre',
              style: TextStyle(
                fontFamily: 'AbhayaLibre',
                fontSize: 32,
                fontWeight: FontWeight.w800, // ExtraBold
                color: Color(0xFF2D5A5A),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Different weights demo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AbhayaLibre Regular (400)',
                    style: TextStyle(
                      fontFamily: 'AbhayaLibre',
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF2D5A5A),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'AbhayaLibre Medium (500)',
                    style: TextStyle(
                      fontFamily: 'AbhayaLibre',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D5A5A),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'AbhayaLibre SemiBold (600)',
                    style: TextStyle(
                      fontFamily: 'AbhayaLibre',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D5A5A),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'AbhayaLibre Bold (700)',
                    style: TextStyle(
                      fontFamily: 'AbhayaLibre',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D5A5A),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'AbhayaLibre ExtraBold (800)',
                    style: TextStyle(
                      fontFamily: 'AbhayaLibre',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2D5A5A),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Sample text with different sizes
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Judul Utama (28px)',
                    style: TextStyle(
                      fontFamily: 'AbhayaLibre',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D5A5A),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Subjudul atau Caption (20px)',
                    style: TextStyle(
                      fontFamily: 'AbhayaLibre',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8FA68E),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Body text untuk konten utama. Font AbhayaLibre memberikan kesan yang elegan dan mudah dibaca untuk aplikasi spiritual seperti QuraniCare. Dengan berbagai weight yang tersedia, font ini cocok untuk hierarki teks yang baik.',
                    style: TextStyle(
                      fontFamily: 'AbhayaLibre',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748b),
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Teks kecil atau label (14px)',
                    style: TextStyle(
                      fontFamily: 'AbhayaLibre',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94a3b8),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Action button with new font
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8FA68E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kembali ke Home',
                  style: TextStyle(
                    fontFamily: 'AbhayaLibre',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}