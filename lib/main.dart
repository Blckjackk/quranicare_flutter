import 'package:flutter/material.dart';
import 'package:quranicare/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize app configuration with error handling
    AppConfig.initialize();
    runApp(const MyApp());
  } catch (e) {
    // Fallback app jika ada error
    runApp(MaterialApp(
      title: 'Quranicare',
      home: Scaffold(
        appBar: AppBar(title: Text('Quranicare')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.book, size: 64, color: Colors.green),
              SizedBox(height: 16),
              Text('Quranicare App', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Initialization error. Please restart app.'),
            ],
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Quranicare Flutter App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _apiStatus = 'Belum dicek';
  bool _isLoadingApi = false;
  bool _offlineMode = false;

  @override
  void initState() {
    super.initState();
    // Auto check connectivity saat app start
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    try {
      // Quick ping ke Google untuk cek internet
      final response = await http.get(
        Uri.parse('https://www.google.com'),
        headers: {'Connection': 'close'},
      ).timeout(const Duration(seconds: 3));
      
      if (mounted) {
        setState(() {
          _offlineMode = response.statusCode != 200;
          if (_offlineMode) {
            _apiStatus = 'Mode Offline - Tidak ada koneksi internet';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _offlineMode = true;
          _apiStatus = 'Mode Offline - Tidak ada koneksi internet';
        });
      }
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _testApi() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingApi = true;
      _apiStatus = 'Menghubungi server...';
    });

    try {
      // First check internet connectivity
      final connectivityCheck = await http.get(
        Uri.parse('https://www.google.com'),
        headers: {'Connection': 'close'},
      ).timeout(const Duration(seconds: 3));

      if (connectivityCheck.statusCode != 200) {
        throw Exception('Tidak ada koneksi internet');
      }

      if (!mounted) return;

      // Then test our API
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/test'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'QuranicareApp/1.1',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          setState(() {
            _apiStatus = '✅ Server Online! ${data['message'] ?? 'Connected'}';
            _offlineMode = false;
          });
        } catch (e) {
          setState(() {
            _apiStatus = '✅ Server Online! (Status: ${response.statusCode})';
            _offlineMode = false;
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _apiStatus = '⚠️ Server Online tapi endpoint /test belum ada';
          _offlineMode = false;
        });
      } else if (response.statusCode >= 500) {
        setState(() {
          _apiStatus = '⚠️ Server Error (${response.statusCode}) - Server sedang maintenance';
          _offlineMode = false;
        });
      } else {
        setState(() {
          _apiStatus = '⚠️ Server Response: ${response.statusCode}';
          _offlineMode = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      String errorMsg;
      if (e.toString().contains('TimeoutException')) {
        errorMsg = '⏱️ Server timeout - Coba lagi nanti';
      } else if (e.toString().contains('SocketException') || e.toString().contains('NetworkException')) {
        errorMsg = '📶 Tidak ada koneksi internet';
      } else if (e.toString().contains('FormatException')) {
        errorMsg = '⚠️ Server response tidak valid';
      } else if (e.toString().contains('HandshakeException')) {
        errorMsg = '🔒 SSL/Security error';
      } else {
        errorMsg = '❌ Backend belum ready atau sedang maintenance';
      }
      
      setState(() {
        _apiStatus = errorMsg;
        _offlineMode = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingApi = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Status indicator
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: _offlineMode ? Colors.orange[100] : Colors.green[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _offlineMode ? Colors.orange : Colors.green,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _offlineMode ? Icons.cloud_off : Icons.cloud_done,
                    color: _offlineMode ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _offlineMode ? 'Mode Offline' : 'Online Mode',
                    style: TextStyle(
                      color: _offlineMode ? Colors.orange[800] : Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'API Base URL: ${AppConfig.baseUrl}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Version: ${AppConfig.version}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoadingApi ? null : _testApi,
              child: _isLoadingApi 
                ? const CircularProgressIndicator()
                : const Text('Test API Connection'),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusBorderColor(), width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getStatusIcon(), color: _getStatusIconColor()),
                      const SizedBox(width: 8),
                      Text(
                        'Status Server:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getStatusIconColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _apiStatus,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _getStatusIconColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor() {
    if (_apiStatus.contains('✅')) return Colors.green[50]!;
    if (_apiStatus.contains('⚠️')) return Colors.orange[50]!;
    if (_apiStatus.contains('❌') || _apiStatus.contains('📶')) return Colors.red[50]!;
    return Colors.grey[100]!;
  }

  Color _getStatusBorderColor() {
    if (_apiStatus.contains('✅')) return Colors.green;
    if (_apiStatus.contains('⚠️')) return Colors.orange;
    if (_apiStatus.contains('❌') || _apiStatus.contains('📶')) return Colors.red;
    return Colors.grey;
  }

  Color _getStatusIconColor() {
    if (_apiStatus.contains('✅')) return Colors.green[700]!;
    if (_apiStatus.contains('⚠️')) return Colors.orange[700]!;
    if (_apiStatus.contains('❌') || _apiStatus.contains('📶')) return Colors.red[700]!;
    return Colors.grey[700]!;
  }

  IconData _getStatusIcon() {
    if (_apiStatus.contains('✅')) return Icons.check_circle;
    if (_apiStatus.contains('⚠️')) return Icons.warning;
    if (_apiStatus.contains('❌')) return Icons.error;
    if (_apiStatus.contains('📶')) return Icons.signal_wifi_off;
    if (_apiStatus.contains('⏱️')) return Icons.access_time;
    return Icons.help_outline;
  }
}