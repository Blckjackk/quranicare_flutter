import 'package:flutter/material.dart';
import '../services/sakinah_tracker_service.dart';
import '../models/user_activity.dart';
import '../models/activity_summary.dart';

class SakinahTrackerDemo extends StatefulWidget {
  const SakinahTrackerDemo({super.key});

  @override
  State<SakinahTrackerDemo> createState() => _SakinahTrackerDemoState();
}

class _SakinahTrackerDemoState extends State<SakinahTrackerDemo> {
  final SakinahTrackerService _service = SakinahTrackerService();
  List<UserActivity> _todayActivities = [];
  ActivitySummary? _monthlyData;
  bool _isLoading = false;
  String _statusMessage = 'Ready to test integration';

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Initializing service...';
    });

    try {
      await _service.initialize();
      setState(() {
        _statusMessage = 'Service initialized successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to initialize service: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testDailyActivities() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading today\'s activities...';
    });

    try {
      final activities = await _service.getDailyActivities(DateTime.now());
      setState(() {
        _todayActivities = activities;
        _statusMessage = 'Found ${activities.length} activities today';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading daily activities: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testMonthlyData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading monthly data...';
    });

    try {
      final now = DateTime.now();
      final monthlyData = await _service.getMonthlyRecap(now.year, now.month);
      setState(() {
        _monthlyData = monthlyData;
        _statusMessage = monthlyData != null 
          ? 'Monthly data loaded: ${monthlyData.totalActivities} total activities'
          : 'No monthly data available';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading monthly data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLogActivity() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Logging test activity...';
    });

    try {
      final success = await _service.logActivity(
        activityType: 'mood_tracking',
        activityName: 'Test mood tracking from Flutter demo',
        metadata: {
          'mood_type': 'senang',
          'source': 'integration_test',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        _statusMessage = success 
          ? 'Test activity logged successfully!'
          : 'Failed to log test activity';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error logging activity: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getActivityAssetFromType(String activityType) {
    switch (activityType) {
      case 'quran_reading':
        return 'assets/images/Emote Kacamata Senang.png';
      case 'dzikir_session':
        return 'assets/images/Emote Senang.png';
      case 'breathing_exercise':
        return 'assets/images/Emote Datar.png';
      case 'audio_listening':
        return 'assets/images/Emote Kacamata Senang.png';
      case 'journal_entry':
        return 'assets/images/Emote Senang.png';
      case 'qalbuchat_session':
        return 'assets/images/Emote Kacamata Senang.png';
      case 'psychology_assessment':
        return 'assets/images/Emote Datar.png';
      case 'mood_tracking':
        return 'assets/images/Emote Senang.png';
      default:
        return 'assets/images/Emote Datar.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sakinah Tracker Integration Test'),
        backgroundColor: const Color(0xFF8FA68E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Integration Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (_isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        if (_isLoading) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Buttons
            const Text(
              'Test API Endpoints',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testDailyActivities,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Test Daily Activities'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8FA68E),
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testMonthlyData,
              icon: const Icon(Icons.analytics),
              label: const Text('Test Monthly Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8FA68E),
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testLogActivity,
              icon: const Icon(Icons.add),
              label: const Text('Test Log Activity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8FA68E),
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Results
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Today's Activities
                    if (_todayActivities.isNotEmpty) ...[
                      const Text(
                        'Today\'s Activities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: _todayActivities.map((activity) {
                              return ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF8FA68E).withValues(alpha: 0.2),
                                        const Color(0xFF7A9B7A).withValues(alpha: 0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Image.asset(
                                      _getActivityAssetFromType(activity.activityType),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                title: Text(activity.displayName),
                                subtitle: Text(activity.additionalInfo ?? 'No details'),
                                trailing: Text(
                                  '${activity.createdAt.hour}:${activity.createdAt.minute.toString().padLeft(2, '0')}',
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Monthly Summary
                    if (_monthlyData != null) ...[
                      const Text(
                        'Monthly Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Activities: ${_monthlyData!.totalActivities}'),
                              Text('Active Days: ${_monthlyData!.activeDays}'),
                              Text('Average per Day: ${_monthlyData!.averageActivitiesPerDay.toStringAsFixed(1)}'),
                              const SizedBox(height: 12),
                              const Text('Activity Breakdown:'),
                              ..._monthlyData!.activityTypeCount.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 16, top: 4),
                                  child: Text('${_monthlyData!.getActivityDisplayName(entry.key)}: ${entry.value}'),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}