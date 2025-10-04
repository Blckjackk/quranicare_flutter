import 'package:flutter/material.dart';
import 'dart:math' as math;

class MoodSpinnerWidget extends StatefulWidget {
  final Function(MoodOption) onMoodSelected;
  final MoodOption? initialMood;
  final bool canSpin;

  const MoodSpinnerWidget({
    super.key,
    required this.onMoodSelected,
    this.initialMood,
    this.canSpin = true,
  });

  @override
  State<MoodSpinnerWidget> createState() => _MoodSpinnerWidgetState();
}

class _MoodSpinnerWidgetState extends State<MoodSpinnerWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isSpinning = false;
  double _currentRotation = 0;
  int? _selectedMoodIndex;
  
  // Manual spinning variables
  double _totalRotation = 0;
  bool _isDragging = false;

  final List<MoodOption> _moods = [
    MoodOption(
      emoji: '😊',
      label: 'Senang',
      type: 'senang',
      color: const Color(0xFF16A34A), // Green
      position: 0,
      imagePath: 'assets/images/Emote Kacamata Senang.png',
    ),
    MoodOption(
      emoji: '😐',
      label: 'Biasa Saja',
      type: 'biasa_saja',
      color: const Color(0xFFF59E0B), // Yellow
      position: 1,
      imagePath: 'assets/images/Emote Datar.png',
    ),
    MoodOption(
      emoji: '😢',
      label: 'Sedih',
      type: 'sedih',
      color: const Color(0xFFDC2626), // Red
      position: 2,
      imagePath: 'assets/images/Emote Sedih.png',
    ),
    MoodOption(
      emoji: '😡',
      label: 'Marah',
      type: 'marah',
      color: const Color(0xFF7C2D12), // Dark orange
      position: 3,
      imagePath: 'assets/images/Emote Marah.png',
    ),
    MoodOption(
      emoji: '😟', 
      label: 'Murung',
      type: 'murung',
      color: const Color(0xFFEA580C), // Orange-red
      position: 4,
      imagePath: 'assets/images/Emote Sedih Kecewa.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
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

  void _handlePanStart(DragStartDetails details) {
    if (!widget.canSpin || _isSpinning) return;
    
    setState(() {
      _isDragging = true;
    });
    
    _rotationController.stop();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.canSpin || _isSpinning) return;
    
    // Get current widget size dynamically
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height * 0.375); // Adjust center for spinner wheel position
    final position = details.localPosition - center;
    
    // Calculate angle based on position relative to center
    final currentAngle = math.atan2(position.dy, position.dx);
    
    // Calculate delta based on drag direction and distance from center
    final distance = position.distance;
    final wheelRadius = math.min(size.width, size.height) * 0.3; // Estimated wheel radius
    final normalizedDistance = math.min(distance / wheelRadius, 1.0); // Normalize distance
    
    // More sensitive and smoother rotation calculation
    final deltaAngle = (details.delta.dx * math.cos(currentAngle) + details.delta.dy * math.sin(currentAngle)) 
                      * 0.015 * normalizedDistance; // Improved sensitivity
    
    _totalRotation += deltaAngle;
    
    setState(() {
      _currentRotation = _totalRotation / (2 * math.pi);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!widget.canSpin || _isSpinning) return;
    
    setState(() {
      _isDragging = false;
      _isSpinning = true;
    });

    // Calculate velocity from pan end velocity with better physics
    final velocity = details.velocity.pixelsPerSecond;
    final speed = velocity.distance;
    
    // More realistic momentum calculation
    final momentum = (speed / 2000.0) * 3.0; // Adjusted momentum
    final finalRotation = _totalRotation + momentum;
    
    // Store target rotation for animation
    final targetRotation = finalRotation / (2 * math.pi);
    final startRotation = _currentRotation;
    
    // Smooth deceleration animation
    _rotationController.reset();
    
    // Custom animation with easing
    final animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeOut,
    ));
    
    animation.addListener(() {
      setState(() {
        _currentRotation = startRotation + (targetRotation - startRotation) * animation.value;
      });
    });
    
    _rotationController.animateTo(1.0).then((_) {
      _onSpinComplete();
    });
  }

  void _onSpinComplete() {
    // Calculate which mood was selected based on final rotation
    // The wheel has pointer at top, so we calculate based on that
    final normalizedRotation = (_currentRotation % 1.0);
    final sectionSize = 1.0 / _moods.length;
    
    // Adjust for pointer position (top of wheel)
    final adjustedRotation = (normalizedRotation + 0.25) % 1.0; // +0.25 for top pointer
    final selectedIndex = (adjustedRotation / sectionSize).floor() % _moods.length;
    
    setState(() {
      _selectedMoodIndex = selectedIndex;
      _isSpinning = false;
    });

    // Scale back up if it was scaled down
    if (_scaleController.value > 0) {
      _scaleController.reverse();
    }

    // Call callback with selected mood
    widget.onMoodSelected(_moods[selectedIndex]);

    // Show selection animation
    Future.delayed(const Duration(milliseconds: 300), () {
      _showSelectionAnimation();
    });
  }

  void _showSelectionAnimation() {
    if (!mounted) return;
    
    // Add a glow effect or celebration animation here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              _moods[_selectedMoodIndex!].emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 10),
            Text(
              'Mood ${_moods[_selectedMoodIndex!].label} dipilih!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: _moods[_selectedMoodIndex!].color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSpinnerWheel([double? size]) {
    final wheelSize = size ?? 280.0;
    final moodRadius = wheelSize * 0.32; // Proportional radius for mood positions
    final moodSize = wheelSize * 0.21; // Proportional size for mood containers
    final moodImageSize = moodSize * 0.75; // Proportional image size
    
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
        builder: (context, child) {
          // Use current rotation directly when dragging, otherwise use animation
          final rotation = _isDragging 
              ? _currentRotation * 2 * math.pi 
              : _currentRotation * _rotationAnimation.value * 2 * math.pi;
          
          return Transform.scale(
            scale: _isDragging ? 1.0 : _scaleAnimation.value,
            child: Transform.rotate(
              angle: rotation,
              child: Container(
                width: wheelSize,
                height: wheelSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background spinner image
                    Container(
                      width: wheelSize,
                      height: wheelSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/Spin Emote.png',
                          width: wheelSize,
                          height: wheelSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: wheelSize,
                              height: wheelSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.withValues(alpha: 0.3),
                                    Colors.purple.withValues(alpha: 0.3),
                                    Colors.pink.withValues(alpha: 0.3),
                                    Colors.orange.withValues(alpha: 0.3),
                                    Colors.green.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '🎯',
                                  style: TextStyle(fontSize: wheelSize * 0.14),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    // Mood sections overlay
                    ...List.generate(_moods.length, (index) {
                      final mood = _moods[index];
                      final angle = (index * 2 * math.pi / _moods.length) - math.pi / 2;
                      
                      return Transform.translate(
                        offset: Offset(
                          moodRadius * math.cos(angle),
                          moodRadius * math.sin(angle),
                        ),
                        child: Container(
                          width: moodSize,
                          height: moodSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.95),
                            border: Border.all(
                              color: mood.color,
                              width: wheelSize * 0.01, // Proportional border
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: mood.color.withValues(alpha: 0.4),
                                blurRadius: wheelSize * 0.04,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: mood.imagePath != null 
                                ? ClipOval(
                                    child: Image.asset(
                                      mood.imagePath!,
                                      width: moodImageSize,
                                      height: moodImageSize,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Text(
                                          mood.emoji,
                                          style: TextStyle(fontSize: wheelSize * 0.085),
                                        );
                                      },
                                    ),
                                  )
                                : Text(
                                    mood.emoji,
                                    style: TextStyle(fontSize: wheelSize * 0.085),
                                  ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Make widget responsive to available space
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        
        // Calculate optimal sizes based on available space
        final wheelSize = math.min(availableWidth * 0.8, availableHeight * 0.7).clamp(200.0, 280.0);
        final totalHeight = math.min(availableHeight, wheelSize + 120);
        
        return Container(
          width: availableWidth,
          height: totalHeight,
          child: Column(
            children: [
              // Spinner Wheel
              Expanded(
                flex: 3,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildSpinnerWheel(wheelSize),
                    
                    // Disabled overlay
                    if (!widget.canSpin)
                    Container(
                      width: wheelSize,
                      height: wheelSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withValues(alpha: 0.4),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            '🔒',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    
                    // Center pointer/indicator
                    Positioned(
                      top: wheelSize * 0.05,
                      child: Container(
                        width: wheelSize * 0.1,
                        height: wheelSize * 0.1,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.canSpin ? Colors.red : Colors.grey,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: wheelSize * 0.08,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom content - flexible
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Instruction Text
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.canSpin && !_isSpinning
                              ? const Color(0xFF16A34A).withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: widget.canSpin && !_isSpinning
                                ? const Color(0xFF16A34A)
                                : Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.canSpin && !_isSpinning
                                  ? (_isSpinning ? Icons.hourglass_empty : Icons.touch_app)
                                  : Icons.check_circle,
                              color: widget.canSpin && !_isSpinning
                                  ? const Color(0xFF16A34A)
                                  : Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                widget.canSpin && !_isSpinning
                                    ? (_isSpinning ? 'Menunggu hasil...' : 'Seret roda untuk pilih')
                                    : 'Sudah memilih hari ini',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: widget.canSpin && !_isSpinning
                                      ? const Color(0xFF16A34A)
                                      : Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Selected mood display
                      if (_selectedMoodIndex != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _moods[_selectedMoodIndex!].color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _moods[_selectedMoodIndex!].color,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _moods[_selectedMoodIndex!].emoji,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _moods[_selectedMoodIndex!].label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _moods[_selectedMoodIndex!].color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                      if (!widget.canSpin && _selectedMoodIndex == null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.orange,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.orange,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              const Flexible(
                                child: Text(
                                  'Sudah memilih mood hari ini',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MoodOption {
  final String emoji;
  final String label;
  final String type;
  final Color color;
  final int position;
  final String? imagePath;

  MoodOption({
    required this.emoji,
    required this.label,
    required this.type,
    required this.color,
    required this.position,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'label': label,
      'type': type,
      'position': position,
      'imagePath': imagePath,
    };
  }
}