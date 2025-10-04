import 'package:flutter/material.dart';
import 'dart:math' as math;

class MoodSelectorWidget extends StatefulWidget {
  final Function(MoodOption) onMoodSelected;
  final MoodOption? initialMood;

  const MoodSelectorWidget({
    super.key,
    required this.onMoodSelected,
    this.initialMood,
  });

  @override
  State<MoodSelectorWidget> createState() => _MoodSelectorWidgetState();
}

class _MoodSelectorWidgetState extends State<MoodSelectorWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  int? _selectedMoodIndex;
  bool _isSelecting = false;

  final List<MoodOption> _moods = [
    MoodOption(
      emoji: '😢',
      label: 'Sangat Sedih',
      type: 'sedih',
      color: const Color(0xFFDC2626), // Dark red
      position: 0,
    ),
    MoodOption(
      emoji: '😟', 
      label: 'Murung',
      type: 'murung',
      color: const Color(0xFFEA580C), // Orange-red
      position: 1,
    ),
    MoodOption(
      emoji: '😐',
      label: 'Biasa Saja',
      type: 'biasa_saja',
      color: const Color(0xFFF59E0B), // Yellow
      position: 2,
    ),
    MoodOption(
      emoji: '😊',
      label: 'Senang', 
      type: 'senang',
      color: const Color(0xFF16A34A), // Green
      position: 3,
    ),
    MoodOption(
      emoji: '😡',
      label: 'Marah',
      type: 'marah', 
      color: const Color(0xFF7C2D12), // Dark orange
      position: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Set initial mood if provided
    if (widget.initialMood != null) {
      _selectedMoodIndex = _moods.indexWhere(
        (mood) => mood.type == widget.initialMood!.type
      );
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _selectMood(int index) {
    if (_isSelecting) return;
    
    setState(() {
      _isSelecting = true;
      _selectedMoodIndex = index;
    });

    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    // Call the callback with selected mood
    widget.onMoodSelected(_moods[index]);
    
    // Add a small delay for better UX
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isSelecting = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          
          // Mood options positioned in circle
          ...List.generate(_moods.length, (index) {
            final mood = _moods[index];
            final angle = (index * 2 * math.pi / _moods.length) - math.pi / 2;
            final radius = 100.0;
            final isSelected = _selectedMoodIndex == index;
            
            return AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    radius * math.cos(angle),
                    radius * math.sin(angle),
                  ),
                  child: GestureDetector(
                    onTap: () => _selectMood(index),
                    child: Transform.scale(
                      scale: isSelected && _isSelecting ? _scaleAnimation.value : 1.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 70 : 60,
                        height: isSelected ? 70 : 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected 
                              ? mood.color.withOpacity(0.2)
                              : Colors.white,
                          border: Border.all(
                            color: mood.color,
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: mood.color.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ] : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            mood.emoji,
                            style: TextStyle(
                              fontSize: isSelected ? 32 : 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          
          // Center selection indicator
          if (_selectedMoodIndex != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _moods[_selectedMoodIndex!].color,
                boxShadow: [
                  BoxShadow(
                    color: _moods[_selectedMoodIndex!].color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class MoodOption {
  final String emoji;
  final String label;
  final String type;
  final Color color;
  final int position;

  MoodOption({
    required this.emoji,
    required this.label,
    required this.type,
    required this.color,
    required this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'label': label,
      'type': type,
      'position': position,
    };
  }
}