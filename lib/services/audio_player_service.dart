import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'dart:async';

enum AudioPlayerState {
  stopped,
  playing,
  paused,
  loading,
  error,
}

class AudioPlayerService {
  static AudioPlayerService? _instance;
  
  factory AudioPlayerService() {
    _instance ??= AudioPlayerService._internal();
    return _instance!;
  }
  
  AudioPlayerService._internal() {
    _initialize();
  }

  AudioPlayer? _audioPlayer;
  bool _isDisposed = false;
  
  // Stream controllers for state management
  StreamController<AudioPlayerState>? _stateController;
  StreamController<Duration>? _positionController;
  StreamController<Duration>? _durationController;

  // Getters for streams - with safety checks
  Stream<AudioPlayerState> get stateStream {
    if (_isDisposed || _stateController?.isClosed == true) {
      return const Stream.empty();
    }
    return _stateController?.stream ?? const Stream.empty();
  }
  
  Stream<Duration> get positionStream {
    if (_isDisposed || _positionController?.isClosed == true) {
      return const Stream.empty();
    }
    return _positionController?.stream ?? const Stream.empty();
  }
  
  Stream<Duration> get durationStream {
    if (_isDisposed || _durationController?.isClosed == true) {
      return const Stream.empty();
    }
    return _durationController?.stream ?? const Stream.empty();
  }

  // Current state
  AudioPlayerState _currentState = AudioPlayerState.stopped;
  Duration _currentPosition = Duration.zero;
  Duration _currentDuration = Duration.zero;
  String? _currentAudioUrl;
  
  // Getters
  AudioPlayerState get currentState => _currentState;
  Duration get currentPosition => _currentPosition;
  Duration get currentDuration => _currentDuration;
  String? get currentAudioUrl => _currentAudioUrl;
  bool get isPlaying => _currentState == AudioPlayerState.playing;
  bool get isPaused => _currentState == AudioPlayerState.paused;
  bool get isStopped => _currentState == AudioPlayerState.stopped;
  bool get isDisposed => _isDisposed;

  // Initialize the audio player
  Future<void> _initialize() async {
    if (_isDisposed) return;
    
    try {
      // Initialize audio player
      _audioPlayer = AudioPlayer();
      
      // Initialize stream controllers
      _stateController = StreamController<AudioPlayerState>.broadcast();
      _positionController = StreamController<Duration>.broadcast();
      _durationController = StreamController<Duration>.broadcast();

      // Listen to player state changes
      _audioPlayer?.onPlayerStateChanged.listen((PlayerState state) {
        if (_isDisposed) return;
        
        switch (state) {
          case PlayerState.stopped:
            _updateState(AudioPlayerState.stopped);
            break;
          case PlayerState.playing:
            _updateState(AudioPlayerState.playing);
            break;
          case PlayerState.paused:
            _updateState(AudioPlayerState.paused);
            break;
          case PlayerState.completed:
            _updateState(AudioPlayerState.stopped);
            _currentPosition = Duration.zero;
            _safeAddToStream(_positionController, _currentPosition);
            break;
          case PlayerState.disposed:
            _updateState(AudioPlayerState.stopped);
            break;
        }
      });

      // Listen to position changes
      _audioPlayer?.onPositionChanged.listen((Duration position) {
        if (_isDisposed) return;
        _currentPosition = position;
        _safeAddToStream(_positionController, position);
      });

      // Listen to duration changes
      _audioPlayer?.onDurationChanged.listen((Duration duration) {
        if (_isDisposed) return;
        _currentDuration = duration;
        _safeAddToStream(_durationController, duration);
      });
      
      print('🎵 AudioPlayerService initialized successfully');
    } catch (e) {
      print('❌ Error initializing AudioPlayerService: $e');
    }
  }

  // Safe method to add events to stream
  void _safeAddToStream<T>(StreamController<T>? controller, T data) {
    if (!_isDisposed && controller != null && !controller.isClosed) {
      controller.add(data);
    }
  }

  // Play audio from URL
  Future<bool> playFromUrl(String audioUrl) async {
    if (_isDisposed || _audioPlayer == null) {
      print('❌ AudioPlayer is disposed or null');
      return false;
    }
    
    try {
      _updateState(AudioPlayerState.loading);
      _currentAudioUrl = audioUrl;
      
      print('🎵 Starting to play: $audioUrl');
      
      // For web platform, add special handling
      if (kIsWeb) {
        print('🌐 Web platform - attempting to play: $audioUrl');
        
        // Try to play with additional configuration for web
        await _audioPlayer!.play(
          UrlSource(audioUrl),
          mode: PlayerMode.mediaPlayer, // Use media player mode for web
        );
      } else {
        await _audioPlayer!.play(UrlSource(audioUrl));
      }
      
      print('✅ Audio play command sent successfully');
      return true;
    } catch (e) {
      print('❌ Error playing audio: $e');
      _updateState(AudioPlayerState.error);
      
      // For web, provide user-friendly error message
      if (kIsWeb) {
        print('💡 Web platform audio limitation - consider using mobile app for full functionality');
      }
      
      return false;
    }
  }

  // Play local file
  Future<bool> playFromFile(String filePath) async {
    if (_isDisposed || _audioPlayer == null) {
      return false;
    }
    
    try {
      _updateState(AudioPlayerState.loading);
      _currentAudioUrl = filePath;
      
      await _audioPlayer!.play(DeviceFileSource(filePath));
      return true;
    } catch (e) {
      print('Error playing file: $e');
      _updateState(AudioPlayerState.error);
      return false;
    }
  }

  // Play/Resume
  Future<void> play() async {
    if (_isDisposed || _audioPlayer == null) return;
    
    try {
      if (_currentState == AudioPlayerState.paused) {
        await _audioPlayer!.resume();
      } else if (_currentAudioUrl != null) {
        await playFromUrl(_currentAudioUrl!);
      }
    } catch (e) {
      print('Error playing: $e');
      _updateState(AudioPlayerState.error);
    }
  }

  // Pause
  Future<void> pause() async {
    if (_isDisposed || _audioPlayer == null) return;
    
    try {
      await _audioPlayer!.pause();
    } catch (e) {
      print('Error pausing: $e');
    }
  }

  // Stop
  Future<void> stop() async {
    if (_isDisposed || _audioPlayer == null) return;
    
    try {
      await _audioPlayer!.stop();
      _currentPosition = Duration.zero;
      _safeAddToStream(_positionController, _currentPosition);
    } catch (e) {
      print('Error stopping: $e');
    }
  }

  // Seek to position
  Future<void> seekTo(Duration position) async {
    if (_isDisposed || _audioPlayer == null) return;
    
    try {
      await _audioPlayer!.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (_isDisposed || _audioPlayer == null) return;
    
    try {
      await _audioPlayer!.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  // Update state and notify listeners
  void _updateState(AudioPlayerState newState) {
    if (_isDisposed) return;
    
    if (_currentState != newState) {
      _currentState = newState;
      _safeAddToStream(_stateController, _currentState);
    }
  }

  // Format duration to string
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    }
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  // Get progress as percentage (0.0 to 1.0)
  double get progress {
    if (_currentDuration.inMilliseconds == 0) return 0.0;
    return _currentPosition.inMilliseconds / _currentDuration.inMilliseconds;
  }

  // Reset the player for fresh start
  Future<void> reset() async {
    if (_isDisposed) return;
    
    try {
      await stop();
      _currentAudioUrl = null;
      _currentPosition = Duration.zero;
      _currentDuration = Duration.zero;
      _updateState(AudioPlayerState.stopped);
      print('🔄 AudioPlayerService reset');
    } catch (e) {
      print('Error resetting player: $e');
    }
  }

  // Dispose resources
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    
    try {
      await _audioPlayer?.dispose();
      
      if (!(_stateController?.isClosed ?? true)) {
        await _stateController?.close();
      }
      if (!(_positionController?.isClosed ?? true)) {
        await _positionController?.close();
      }
      if (!(_durationController?.isClosed ?? true)) {
        await _durationController?.close();
      }
      
      _audioPlayer = null;
      _stateController = null;
      _positionController = null;
      _durationController = null;
      _instance = null;
      
      print('🗑️ AudioPlayerService disposed');
    } catch (e) {
      print('Error disposing AudioPlayerService: $e');
    }
  }
}