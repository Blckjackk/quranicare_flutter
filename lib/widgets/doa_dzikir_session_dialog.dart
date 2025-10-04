import 'package:flutter/material.dart';
import '../models/doa_dzikir.dart';
import '../utils/font_styles.dart';

// Session Dialog Widget
class DoaDzikirSessionDialog extends StatefulWidget {
  final DoaDzikir doaDzikir;

  const DoaDzikirSessionDialog({super.key, required this.doaDzikir});

  @override
  State<DoaDzikirSessionDialog> createState() => _DoaDzikirSessionDialogState();
}

class _DoaDzikirSessionDialogState extends State<DoaDzikirSessionDialog> {
  int _currentCount = 0;
  int _targetCount = 33; // Default target
  bool _isSessionActive = false;
  DateTime? _startTime;
  
  final List<int> _targetOptions = [7, 11, 33, 99, 100];

  void _startSession() {
    setState(() {
      _isSessionActive = true;
      _startTime = DateTime.now();
      _currentCount = 0;
    });
  }

  void _incrementCount() {
    if (_isSessionActive && _currentCount < _targetCount) {
      setState(() {
        _currentCount++;
      });
      
      // Check if target reached
      if (_currentCount >= _targetCount) {
        _completeSession();
      }
    }
  }

  void _completeSession() {
    final duration = _startTime != null 
        ? DateTime.now().difference(_startTime!).inSeconds 
        : 0;
        
    setState(() {
      _isSessionActive = false;
    });

    // Show completion dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.mosque,
              color: Color(0xFF8FA68E),
            ),
            SizedBox(width: 8),
            Text('Sesi Dzikir Selesai!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF8FA68E),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'بَارَكَ اللَّهُ فِيْكَ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7D6A),
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            const Text(
              'Barakallahu fiik',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Color(0xFF8FA68E),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Alhamdulillah! Anda telah menyelesaikan $_currentCount kali dzikir "${widget.doaDzikir.nama}" dalam ${duration} detik.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close completion dialog
              Navigator.of(context).pop(); // Close session dialog
            },
            child: const Text(
              'Alhamdulillah',
              style: TextStyle(
                color: Color(0xFF8FA68E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Title
            Text(
              widget.doaDzikir.nama,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B7D6A),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),

            // Arabic text display (always visible and prominent)
            if (widget.doaDzikir.ar.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF8FA68E).withOpacity(0.1),
                      const Color(0xFFF5F8F5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF8FA68E).withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B7D6A).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // "Bacaan Dzikir" label
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8FA68E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '📿 Bacaan Dzikir',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Arabic text - larger and more prominent
                    ArabicText(
                      widget.doaDzikir.ar,
                      style: FontStyles.dzikrText.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7D6A),
                      ),
                    ),
                    
                    if (widget.doaDzikir.tr.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      // Transliteration with background
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.doaDzikir.tr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF6B7D6A),
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    
                    if (widget.doaDzikir.idn.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      // Translation
                      Text(
                        '"${widget.doaDzikir.idn}"',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8FA68E),
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],

            if (!_isSessionActive) ...[
              // Target selection
              const Text(
                'Pilih Target Dzikir:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7D6A),
                ),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                children: _targetOptions.map((count) {
                  return FilterChip(
                    label: Text('$count'),
                    selected: _targetCount == count,
                    onSelected: (selected) {
                      setState(() {
                        _targetCount = count;
                      });
                    },
                    selectedColor: const Color(0xFF8FA68E).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF6B7D6A),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8FA68E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Mulai Dzikir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Session active - Counter and progress
              Column(
                children: [
                  // Counter circle - centered and prominent
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF8FA68E).withOpacity(0.2),
                      border: Border.all(
                        color: const Color(0xFF8FA68E),
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_currentCount',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B7D6A),
                            ),
                          ),
                          Text(
                            '/ $_targetCount',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF8FA68E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Progress bar
                  Column(
                    children: [
                      const Text(
                        'Progress Dzikir',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7D6A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _currentCount / _targetCount,
                        backgroundColor: const Color(0xFF8FA68E).withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8FA68E)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${((_currentCount / _targetCount) * 100).toInt()}% selesai',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8FA68E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Instruction text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7D6A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFF6B7D6A),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Baca dzikir di atas, kemudian tap untuk menghitung',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7D6A),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tap to count button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _incrementCount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8FA68E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    '👆 TAP UNTUK HITUNG 👆',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Complete session button
              TextButton(
                onPressed: _completeSession,
                child: const Text(
                  'Selesai Sekarang',
                  style: TextStyle(
                    color: Color(0xFF8FA68E),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Close button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: Color(0xFF8FA68E),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
