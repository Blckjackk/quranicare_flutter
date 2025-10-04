import 'package:flutter/material.dart';
import 'package:quranicare/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize app configuration
  AppConfig.initialize();
  
  runApp(const MyApp());
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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _testApi() async {
    setState(() {
      _isLoadingApi = true;
      _apiStatus = 'Menghubungi API...';
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/test'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _apiStatus = 'API Berhasil! ${data['message'] ?? 'Connected'}';
        });
      } else {
        setState(() {
          _apiStatus = 'API Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _apiStatus = 'API Error: $e';
      });
    } finally {
      setState(() {
        _isLoadingApi = false;
      });
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
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Status API: $_apiStatus',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
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
}