import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils/firebase_data_seeder.dart';

class TestFirebaseScreen extends StatefulWidget {
  const TestFirebaseScreen({super.key});

  @override
  State<TestFirebaseScreen> createState() => _TestFirebaseScreenState();
}

class _TestFirebaseScreenState extends State<TestFirebaseScreen> {
  String _status = 'Initializing...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testFirebase();
  }

  Future<void> _testFirebase() async {
    try {
      setState(() {
        _status = 'Testing Firebase connection...';
      });

      // Test anonymous authentication first
      final FirebaseAuth auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        setState(() {
          _status = 'Signing in anonymously...';
        });
        await auth.signInAnonymously();
      }

      // Test Firestore connection
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      // Try to write a test document
      setState(() {
        _status = 'Writing test data to Firestore...';
      });
      
      await firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Firebase connection test successful',
        'app': 'QuraniCare MTQMN',
        'userId': auth.currentUser?.uid ?? 'anonymous'
      });

      // Try to read the document back
      setState(() {
        _status = 'Reading test data from Firestore...';
      });
      
      final doc = await firestore.collection('test').doc('connection').get();
      
      if (doc.exists) {
        setState(() {
          _status = 'Firebase connection successful!\n\nAuthenticated User: ${auth.currentUser?.uid}\n\nTest data: ${doc.data()}';
          _isLoading = false;
        });
      } else {
        setState(() {
          _status = 'Firebase connected but document not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Firebase connection failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _seedSampleData() async {
    try {
      setState(() {
        _status = 'Populating sample breathing exercises...';
        _isLoading = true;
      });

      await FirebaseDataSeeder.seedBreathingExercises();

      setState(() {
        _status = 'Sample data populated successfully!\n\nBreathing exercises and categories have been added to Firestore.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to populate sample data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _status,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testFirebase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Test Again'),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _seedSampleData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Seed Data'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : () => Navigator.pushNamed(context, '/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF388E3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}