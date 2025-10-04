import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/audio_relax.dart';
import '../../services/audio_relax_service.dart';
import '../../services/quran_api_service.dart';
import '../../services/audio_player_service.dart';
import '../../services/web_audio_helper.dart';

class AudioRelaxScreen extends StatefulWidget {
  const AudioRelaxScreen({super.key});

  @override
  State<AudioRelaxScreen> createState() => _AudioRelaxScreenState();
}

class _AudioRelaxScreenState extends State<AudioRelaxScreen> with TickerProviderStateMixin {
  final AudioRelaxService _audioService = AudioRelaxService();
  final QuranApiService _quranService = QuranApiService();
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  
  int _currentScreen = 0; // 0: main menu, 1: categories, 2: audio list, 3: player, 4: quran list, 5: quran player
  
  List<AudioCategory> _categories = [];
  List<AudioRelax> _audioList = [];
  List<QuranSurah> _quranSurahs = [];
  List<QuranReciter> _reciters = [];
  
  AudioCategory? _selectedCategory;
  AudioRelax? _selectedAudio;
  QuranSurah? _selectedSurah;
  QuranReciter? _selectedReciter;
  
  bool _isLoadingCategories = true;
  bool _isLoadingAudio = false;
  bool _isLoadingQuran = false;
  String _errorMessage = '';

  // YouTube player controller
  YoutubePlayerController? _youtubeController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // AudioPlayerService now initializes automatically
    _loadCategories();
    _loadQuranData();
  }

  Future<void> _loadQuranData() async {
    try {
      setState(() {
        _isLoadingQuran = true;
      });

      final surahs = await _quranService.getAllSurahs();
      final reciters = QuranApiService.getReciters();
      
      setState(() {
        _quranSurahs = surahs;
        _reciters = reciters;
        _selectedReciter = reciters.first; // Default reciter
        _isLoadingQuran = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingQuran = false;
      });
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    // Stop audio when leaving screen
    _audioPlayerService.stop();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoadingCategories = true;
        _errorMessage = '';
      });

      final categories = await _audioService.getAllCategories();
      
      // Filter to only show specific categories
      final allowedCategories = ['musik islami', 'murrotal', 'dzikir dan doa', 'murottal', 'dzikir & doa'];
      final filteredCategories = categories.where((category) {
        return allowedCategories.any((allowed) => 
          category.name.toLowerCase().contains(allowed.toLowerCase()) ||
          allowed.toLowerCase().contains(category.name.toLowerCase())
        );
      }).toList();
      
      setState(() {
        _categories = filteredCategories;
        _isLoadingCategories = false;
      });
      
      if (_categories.isEmpty) {
        setState(() {
          _errorMessage = 'Kategori audio yang diinginkan belum tersedia di database.\nKategori yang didukung: Musik Islami, Murrotal, dan Dzikir & Doa.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal terhubung ke server audio.\nPastikan koneksi internet stabil dan server aktif.\n\nDetail error: $e';
        _isLoadingCategories = false;
      });
    }
  }

  void _loadAudioByCategory(AudioCategory category) async {
    try {
      setState(() {
        _isLoadingAudio = true;
        _errorMessage = '';
        _selectedCategory = category;
        _currentScreen = 2; // Go to audio list screen
      });

      final result = await _audioService.getAudioByCategory(category.id);
      final audioList = result['audio_list'] as List<AudioRelax>;
      
      setState(() {
        _audioList = audioList;
        _isLoadingAudio = false;
      });
      
      if (_audioList.isEmpty) {
        setState(() {
          _errorMessage = 'Belum ada audio dalam kategori "${category.name}".\nAudio akan segera ditambahkan.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat audio kategori "${category.name}".\nPastikan koneksi internet stabil.\n\nDetail error: $e';
        _isLoadingAudio = false;
      });
    }
  }

  void _playQuranSurah(QuranSurah surah) async {
    if (_selectedReciter == null) return;

    try {
      setState(() {
        _selectedSurah = surah;
        _currentScreen = 5; // Go to Quran player screen
        _isLoadingQuran = true;
      });

      final audioUrl = await _quranService.getSurahAudioUrl(
        surah.number, 
        _selectedReciter!.id
      );

      if (audioUrl != null) {
        final success = await _audioPlayerService.playFromUrl(audioUrl);
        if (!success) {
          setState(() {
            _errorMessage = 'Failed to play audio';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Audio not available';
        });
      }

      setState(() {
        _isLoadingQuran = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingQuran = false;
      });
    }
  }

  void _playAudio(AudioRelax audio) {
    setState(() {
      _selectedAudio = audio;
      _currentScreen = 3; // Go to audio player screen
      _errorMessage = ''; // Clear any previous errors
    });

    // Debug: Print audio information
    print('🎵 Playing audio: ${audio.title}');
    print('🔗 Audio path: ${audio.audioPath}');
    print('🎬 Is YouTube: ${audio.isYouTubeAudio}');
    
    // Validate audio path
    if (audio.audioPath.isEmpty) {
      setState(() {
        _errorMessage = 'Audio path tidak valid untuk "${audio.title}".';
      });
      return;
    }
    
    // Initialize YouTube player if it's a YouTube audio
    if (audio.isYouTubeAudio && audio.youTubeVideoId != null) {
      try {
        print('🚀 Initializing YouTube controller...');
        print('🆔 Video ID: ${audio.youTubeVideoId}');
        
        String videoId = audio.youTubeVideoId!;
        
        // Validate YouTube video ID format
        if (videoId.length != 11) {
          setState(() {
            _errorMessage = 'YouTube Video ID tidak valid: "$videoId".\nPastikan link YouTube sudah benar.';
          });
          return;
        }
        
        _youtubeController?.dispose();
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            disableDragSeek: false,
            loop: false,
            isLive: false,
            forceHD: false,
            enableCaption: false,
            hideControls: false,
            hideThumbnail: false,
          ),
        );
        
        // Add listener to track player state
        _youtubeController!.addListener(() {
          if (_youtubeController!.value.hasError) {
            print('❌ YouTube Error: ${_youtubeController!.value.errorCode}');
            setState(() {
              _errorMessage = 'Gagal memuat video YouTube.\nPastikan koneksi internet stabil dan video masih tersedia.';
            });
          }
          
          if (_youtubeController!.value.isReady) {
            setState(() {
              _isPlaying = _youtubeController!.value.isPlaying;
              _errorMessage = ''; // Clear error when ready
            });
            print('✅ YouTube controller is now ready!');
          }
        });
        
        // Wait for controller to be ready
        _waitForControllerReady();
        
        print('✅ YouTube controller initialized successfully!');
      } catch (e) {
        print('❌ Error initializing YouTube controller: $e');
        setState(() {
          _errorMessage = 'Gagal menginisialisasi pemutar YouTube.\nCoba pilih audio lain atau periksa koneksi internet.';
        });
      }
    } else if (!audio.isYouTubeAudio) {
      // Handle local audio files
      print('🎵 Local audio file detected: ${audio.audioPath}');
      setState(() {
        _errorMessage = 'Audio lokal belum didukung sepenuhnya.\nSementara gunakan audio YouTube atau tunggu update selanjutnya.';
      });
    } else {
      print('❌ No valid YouTube video ID found');
      setState(() {
        _errorMessage = 'Tidak dapat menemukan ID video YouTube yang valid.\nPastikan link audio sudah benar.';
      });
    }

    // Update play count if possible
    try {
      _audioService.updatePlayCount(audio.id);
    } catch (e) {
      print('⚠ Failed to update play count: $e');
    }
  }

  Future<void> _waitForControllerReady() async {
    if (_youtubeController == null) return;
    
    int attempts = 0;
    const maxAttempts = 20; // 10 seconds max wait
    
    while (attempts < maxAttempts && !_youtubeController!.value.isReady) {
      await Future.delayed(Duration(milliseconds: 500));
      attempts++;
      print('⏳ Waiting for controller ready... Attempt $attempts/$maxAttempts');
    }
    
    if (_youtubeController!.value.isReady) {
      print('✅ Controller is ready after ${attempts * 500}ms');
    } else {
      print('❌ Controller failed to become ready after ${maxAttempts * 500}ms');
    }
  }

  void _togglePlayPause() async {
    print('🎮 Toggle play/pause called');
    print('🎮 Controller exists: ${_youtubeController != null}');
    
    if (_youtubeController != null) {
      print('🎮 Controller ready: ${_youtubeController!.value.isReady}');
      print('🎮 Current playing state: ${_youtubeController!.value.isPlaying}');
      
      // If not ready, wait a bit more
      if (!_youtubeController!.value.isReady) {
        print('⏳ Controller not ready, waiting...');
        await _waitForControllerReady();
      }
      
      if (_youtubeController!.value.isReady) {
        if (_isPlaying) {
          print('⏸️ Pausing...');
          _youtubeController!.pause();
        } else {
          print('▶️ Playing...');
          _youtubeController!.play();
        }
        setState(() {
          _isPlaying = !_isPlaying;
        });
        print('🎵 New playing state: $_isPlaying');
      } else {
        print('❌ Controller still not ready after waiting');
      }
    } else {
      print('❌ No YouTube controller available');
    }
  }

  void _stopAudio() {
    if (_youtubeController != null) {
      _youtubeController!.pause();
      _youtubeController!.seekTo(Duration.zero);
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E8), // Soft green background like home screen
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF7CB342)),
          onPressed: () {
            if (_currentScreen == 3 || _currentScreen == 5) { // player screens
              _youtubeController?.dispose();
              _youtubeController = null;
              _audioPlayerService.stop();
              setState(() {
                _currentScreen = _currentScreen == 3 ? 2 : 4;
                _selectedAudio = null;
                _selectedSurah = null;
              });
            } else if (_currentScreen == 2 || _currentScreen == 4) { // list screens
              setState(() {
                _currentScreen = _currentScreen == 2 ? 1 : 0;
                _selectedCategory = null;
                _audioList.clear();
              });
            } else if (_currentScreen == 1) { // categories screen
              setState(() {
                _currentScreen = 0;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _getScreenTitle(),
          style: const TextStyle(
            color: Color(0xFF7CB342),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildCurrentScreen(),
      ),
    );
  }

  String _getScreenTitle() {
    switch (_currentScreen) {
      case 1:
        return 'Audio Database';
      case 2:
        return _selectedCategory?.name ?? 'Audio';
      case 3:
        return _selectedAudio?.title ?? 'Player';
      case 4:
        return 'Murotal Al-Quran';
      case 5:
        return _selectedSurah?.name ?? 'Murotal Player';
      default:
        return 'Audio Relax Islami';
    }
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case 1:
        return _buildCategoriesScreen();
      case 2:
        return _buildAudioListScreen();
      case 3:
        return _buildPlayerScreen();
      case 4:
        return _buildQuranListScreen();
      case 5:
        return _buildQuranPlayerScreen();
      default:
        return _buildMainMenuScreen();
    }
  }

  Widget _buildMainMenuScreen() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF7CB342), Color(0xFF689F38)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7CB342).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.headphones_rounded,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Audio Relax Islami',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nikmati ketenangan dengan audio relaksasi dan murotal Al-Quran',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Menu Options
          Expanded(
            child: Column(
              children: [
                // Audio Database Option
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentScreen = 1;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF7CB342).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7CB342), Color(0xFF689F38)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.library_music_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Audio Relax Database',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D5A5A),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Koleksi audio relaksasi dari database internal',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8FA68E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF7CB342),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Murotal Quran Option
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentScreen = 4;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF7CB342).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7CB342), Color(0xFF689F38)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Murotal Al-Quran',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D5A5A),
                                    ),
                                  ),
                                  if (kIsWeb) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Colors.orange.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Text(
                                        'Terbatas',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                kIsWeb 
                                  ? 'Dengarkan tilawah Al-Quran (Fitur terbatas di web)'
                                  : 'Dengarkan tilawah Al-Quran dari berbagai qari',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8FA68E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF7CB342),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesScreen() {
    if (_isLoadingCategories) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF7CB342),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat kategori',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D5A5A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCategories,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7CB342),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      color: const Color(0xFF8FA68E),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => _loadAudioByCategory(category),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category.name),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D5A5A).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: -30,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          if (category.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              category.description!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAudioListScreen() {
    if (_isLoadingAudio) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF7CB342),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat audio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D5A5A),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_selectedCategory != null) {
                  _loadAudioByCategory(_selectedCategory!);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7CB342),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_audioList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note_outlined,
              size: 64,
              color: const Color(0xFF7CB342).withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada audio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D5A5A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Audio akan segera tersedia',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF7CB342).withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _audioList.length,
      itemBuilder: (context, index) {
        final audio = _audioList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _playAudio(audio),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D5A5A).withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Thumbnail
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFF8FA68E).withOpacity(0.1),
                    ),
                    child: audio.isYouTubeAudio
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              audio.youTubeThumbnail ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.music_note,
                                  color: Color(0xFF7CB342),
                                  size: 24,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.music_note,
                            color: Color(0xFF7CB342),
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          audio.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D5A5A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (audio.artist != null) ...[
                              Text(
                                audio.artist!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF7CB342).withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: TextStyle(
                                  color: const Color(0xFF7CB342).withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              audio.formattedDuration,
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF7CB342).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Play icon
                  Icon(
                    Icons.play_arrow,
                    color: const Color(0xFF7CB342),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerScreen() {
    if (_selectedAudio == null) {
      return const Center(
        child: Text('No audio selected'),
      );
    }

    return Column(
      children: [
        // Error Message (if any)
        if (_errorMessage.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Audio Tidak Dapat Diputar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // YouTube Player or Audio Info
        if (_selectedAudio!.isYouTubeAudio && _youtubeController != null && _errorMessage.isEmpty) ...[
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: const Color(0xFF7CB342),
                  onReady: () {
                    print('🎬 YouTube player ready!');
                    setState(() {
                      _isPlaying = false;
                      _errorMessage = ''; // Clear error when ready
                    });
                  },
                  onEnded: (metaData) {
                    print('🏁 YouTube playback ended');
                    setState(() {
                      _isPlaying = false;
                    });
                  },
                ),
              ),
            ),
          ),
        ] else if (_errorMessage.isEmpty) ...[
          Container(
            margin: const EdgeInsets.all(16),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF7CB342).withOpacity(0.1),
            ),
            child: const Center(
              child: Icon(
                Icons.music_note,
                size: 64,
                color: Color(0xFF7CB342),
              ),
            ),
          ),
        ],

        // Audio Info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text(
                _selectedAudio!.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A5A),
                ),
                textAlign: TextAlign.center,
              ),
              if (_selectedAudio!.artist != null) ...[
                const SizedBox(height: 8),
                Text(
                  _selectedAudio!.artist!,
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF8FA68E).withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Player Controls (only show if no error)
        if (_errorMessage.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Shuffle (disabled)
                IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.shuffle,
                    size: 24,
                    color: const Color(0xFF7CB342).withOpacity(0.3),
                  ),
                ),
                // Previous (disabled)
                IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.skip_previous,
                    size: 32,
                    color: const Color(0xFF7CB342).withOpacity(0.3),
                  ),
                ),
                // Play/Pause
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF7CB342),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7CB342).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                // Next (disabled)
                IconButton(
                  onPressed: null,
                  icon: Icon(
                    Icons.skip_next,
                    size: 32,
                    color: const Color(0xFF7CB342).withOpacity(0.3),
                  ),
                ),
                // Stop
                IconButton(
                  onPressed: _stopAudio,
                  icon: const Icon(
                    Icons.stop,
                    size: 24,
                    color: Color(0xFF7CB342),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Duration
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '00:00',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF7CB342).withOpacity(0.8),
                  ),
                ),
                Text(
                  _selectedAudio!.formattedDuration,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF7CB342).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Show retry button when there's an error
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Retry playing the audio
                    _playAudio(_selectedAudio!);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7CB342),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentScreen = 2; // Go back to audio list
                      _errorMessage = '';
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Kembali ke Daftar Audio'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF7CB342),
                  ),
                ),
              ],
            ),
          ),
        ],

        const Spacer(),
      ],
    );
  }

  Widget _buildQuranListScreen() {
    if (_isLoadingQuran) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF7CB342),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat Al-Quran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D5A5A),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadQuranData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7CB342),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Web Platform Notice
        if (kIsWeb) 
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF7CB342).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF7CB342).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFF7CB342),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mode Web: Audio murotal terbatas karena kebijakan browser.\nUntuk pengalaman terbaik, gunakan aplikasi mobile.',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF7CB342).withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Reciter Selection
        Container(
          margin: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              const Icon(
                Icons.person_rounded,
                color: Color(0xFF7CB342),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Qari: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D5A5A),
                ),
              ),
              Expanded(
                child: DropdownButton<QuranReciter>(
                  value: _selectedReciter,
                  isExpanded: true,
                  underline: const SizedBox(),
                  onChanged: (QuranReciter? newReciter) {
                    setState(() {
                      _selectedReciter = newReciter;
                    });
                  },
                  items: _reciters.map<DropdownMenuItem<QuranReciter>>((QuranReciter reciter) {
                    return DropdownMenuItem<QuranReciter>(
                      value: reciter,
                      child: Text(
                        reciter.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2D5A5A),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Surahs List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _quranSurahs.length,
            itemBuilder: (context, index) {
              final surah = _quranSurahs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => _playQuranSurah(surah),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Surah Number
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7CB342), Color(0xFF689F38)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${surah.number}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Surah Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                surah.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D5A5A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${surah.englishName} • ${surah.ayahCount}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: const Color(0xFF7CB342).withOpacity(0.8),
                                ),
                              ),
                              Text(
                                surah.englishNameTranslation,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF8FA68E).withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Play icon
                        const Icon(
                          Icons.play_arrow,
                          color: Color(0xFF7CB342),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuranPlayerScreen() {
    if (_selectedSurah == null) {
      return const Center(
        child: Text('No surah selected'),
      );
    }

    return StreamBuilder<AudioPlayerState>(
      stream: _audioPlayerService.stateStream,
      builder: (context, stateSnapshot) {
        final playerState = stateSnapshot.data ?? AudioPlayerState.stopped;
        final isPlaying = playerState == AudioPlayerState.playing;
        final isLoading = playerState == AudioPlayerState.loading;
        final hasError = playerState == AudioPlayerState.error;

        return Column(
          children: [
            // Web Error Message
            if (kIsWeb && hasError)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Audio Tidak Dapat Diputar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browser memblokir streaming audio dari Al-Quran.cloud karena kebijakan CORS.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final url = 'https://alquran.cloud/surah/${_selectedSurah!.number}';
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                              }
                            },
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text(
                              'Buka di Al-Quran.cloud',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _currentScreen = 1; // Go to Audio Database
                              });
                            },
                            icon: const Icon(Icons.library_music, size: 16),
                            label: const Text(
                              'Audio Database',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: BorderSide(color: Colors.orange.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            // Surah Info Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7CB342), Color(0xFF689F38)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7CB342).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Surah number in circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${_selectedSurah!.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedSurah!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedSurah!.englishName,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedSurah!.englishNameTranslation,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Reciter Info
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
              child: Row(
                children: [
                  const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF7CB342),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Qari: ${_selectedReciter?.name ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D5A5A),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Progress Bar
            StreamBuilder<Duration>(
              stream: _audioPlayerService.positionStream,
              builder: (context, positionSnapshot) {
                return StreamBuilder<Duration>(
                  stream: _audioPlayerService.durationStream,
                  builder: (context, durationSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;
                    final duration = durationSnapshot.data ?? Duration.zero;
                    final progress = duration.inMilliseconds > 0 
                        ? position.inMilliseconds / duration.inMilliseconds 
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF7CB342),
                              inactiveTrackColor: const Color(0xFF7CB342).withOpacity(0.3),
                              thumbColor: const Color(0xFF7CB342),
                              overlayColor: const Color(0xFF7CB342).withOpacity(0.2),
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: progress.clamp(0.0, 1.0),
                              onChanged: (value) {
                                final newPosition = Duration(
                                  milliseconds: (duration.inMilliseconds * value).round(),
                                );
                                _audioPlayerService.seekTo(newPosition);
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _audioPlayerService.formatDuration(position),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF7CB342).withOpacity(0.8),
                                ),
                              ),
                              Text(
                                _audioPlayerService.formatDuration(duration),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF7CB342).withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            // Player Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous (disabled for now)
                  IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.skip_previous,
                      size: 32,
                      color: const Color(0xFF7CB342).withOpacity(0.3),
                    ),
                  ),
                  // Play/Pause
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7CB342), Color(0xFF689F38)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7CB342).withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: isLoading ? null : () {
                        _audioPlayerService.togglePlayPause();
                      },
                      icon: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                    ),
                  ),
                  // Next (disabled for now)
                  IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.skip_next,
                      size: 32,
                      color: const Color(0xFF7CB342).withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        );
      },
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'nasheed':
        return const Color(0xFF7CB342);
      case 'dzikir dan doa':
        return const Color(0xFF689F38);
      case 'murottal':
        return const Color(0xFF7CB342);
      default:
        return const Color(0xFF689F38);
    }
  }
}