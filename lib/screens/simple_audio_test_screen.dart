import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:html' as html;
import '../config/app_config.dart';

class SimpleAudioTestScreen extends StatefulWidget {
  const SimpleAudioTestScreen({super.key});

  @override
  State<SimpleAudioTestScreen> createState() => _SimpleAudioTestScreenState();
}

class _SimpleAudioTestScreenState extends State<SimpleAudioTestScreen> {
  AudioPlayer? _audioPlayer;
  html.AudioElement? _webAudioElement;
  bool _isPlaying = false;
  String _status = 'Ready to test';

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  Future<void> _testAudioPlayback() async {
    final testUrl = '${AppConfig.baseUrl.replaceAll('/api', '')}/storage/audio/islamic_music/astaghfirullah_nasheed.mp3';
    
    setState(() {
      _status = 'Testing audio playback...';
    });

    if (kIsWeb) {
      // Test dengan HTML5 Audio untuk web
      try {
        _webAudioElement = html.AudioElement(testUrl);
        _webAudioElement!.crossOrigin = 'anonymous';
        _webAudioElement!.preload = 'auto';
        
        _webAudioElement!.onLoadedData.listen((_) {
          setState(() {
            _status = '✅ Web: Audio loaded successfully';
          });
        });
        
        _webAudioElement!.onPlay.listen((_) {
          setState(() {
            _isPlaying = true;
            _status = '▶️ Web: Playing audio';
          });
        });
        
        _webAudioElement!.onPause.listen((_) {
          setState(() {
            _isPlaying = false;
            _status = '⏸️ Web: Audio paused';
          });
        });
        
        _webAudioElement!.onError.listen((e) {
          setState(() {
            _status = '❌ Web: Error - $e';
          });
        });

        await _webAudioElement!.play();
        
      } catch (e) {
        setState(() {
          _status = '❌ Web: Failed - $e';
        });
      }
    } else {
      // Test dengan AudioPlayer untuk mobile
      try {
        await _audioPlayer!.play(UrlSource(testUrl));
        setState(() {
          _isPlaying = true;
          _status = '▶️ Mobile: Playing audio';
        });
      } catch (e) {
        setState(() {
          _status = '❌ Mobile: Failed - $e';
        });
      }
    }
  }

  Future<void> _stopAudio() async {
    if (kIsWeb && _webAudioElement != null) {
      _webAudioElement!.pause();
      _webAudioElement!.currentTime = 0;
    } else if (_audioPlayer != null) {
      await _audioPlayer!.stop();
    }
    
    setState(() {
      _isPlaying = false;
      _status = '⏹️ Audio stopped';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Audio Test'),
        backgroundColor: const Color(0xFF2E5E3A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isPlaying ? Icons.volume_up : Icons.volume_off,
              size: 64,
              color: const Color(0xFF2E5E3A),
            ),
            const SizedBox(height: 24),
            Text(
              _status,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isPlaying ? null : _testAudioPlayback,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Test Audio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5E3A),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isPlaying ? _stopAudio : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Platform: ${kIsWeb ? "Web Browser" : "Mobile"}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _webAudioElement?.pause();
    super.dispose();
  }
}