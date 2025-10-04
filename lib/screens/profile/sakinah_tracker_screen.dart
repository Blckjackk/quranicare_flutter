import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../services/sakinah_tracker_service.dart';
import '../../models/user_activity.dart';
import '../../models/activity_summary.dart';

class SakinahTrackerScreen extends StatefulWidget {
  const SakinahTrackerScreen({super.key});

  @override
  State<SakinahTrackerScreen> createState() => _SakinahTrackerScreenState();
}

class _SakinahTrackerScreenState extends State<SakinahTrackerScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  final SakinahTrackerService _sakinahService = SakinahTrackerService();
  
  // Activity data
  List<UserActivity> _dailyActivities = [];
  ActivitySummary? _monthlyData;
  Map<String, int> _calendarData = {};
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    // Initialize locale for Indonesian date formatting
    await initializeDateFormatting('id', null);
    await _sakinahService.initialize();
    await _loadInitialData();
  }

  // Load initial data
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    await Future.wait([
      _loadDailyActivities(_selectedDate),
      _loadMonthlyData(_currentMonth.year, _currentMonth.month),
      _loadCalendarData(_currentMonth.year, _currentMonth.month),
    ]);
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadDailyActivities(DateTime date) async {
    try {
      print('Loading activities for date: ${date.toString()}');
      final activities = await _sakinahService.getDailyActivities(date);
      print('Loaded ${activities.length} activities');
      setState(() {
        _dailyActivities = activities;
      });
    } catch (e) {
      print('Error loading daily activities: $e');
      setState(() {
        _dailyActivities = [];
      });
    }
  }

  Future<void> _loadMonthlyData(int year, int month) async {
    final monthlyData = await _sakinahService.getMonthlyRecap(year, month);
    setState(() {
      _monthlyData = monthlyData;
    });
  }

  Future<void> _loadCalendarData(int year, int month) async {
    final calendarData = await _sakinahService.getCalendarData(year, month);
    setState(() {
      _calendarData = calendarData;
    });
  }

  Color _getActivityColor(int activityCount) {
    if (activityCount == 0) {
      return const Color(0xFFE5E7EB); // Abu-abu terang untuk tidak ada aktivitas
    }
    
    // Gradasi hijau berdasarkan intensitas aktivitas
    const baseColor = Color(0xFF8FA68E); // Warna hijau utama   
    if (activityCount == 1) {
      return baseColor.withValues(alpha: 0.2); // Sangat transparan
    } else if (activityCount == 2) {
      return baseColor.withValues(alpha: 0.4); // Sedikit lebih terlihat
    } else if (activityCount <= 4) {
      return baseColor.withValues(alpha: 0.6); // Medium transparan
    } else if (activityCount <= 6) {
      return baseColor.withValues(alpha: 0.8); // Hampir penuh
    } else {
      return baseColor; // Hijau penuh untuk 7+ aktivitas
    }
  }

  String _getActivityAssetFromType(String activityType) {
    switch (activityType) {
      case 'quran_reading':
        return 'assets/images/Asset Alquran.png'; // Al-Qur'an icon
      case 'dzikir_session':
        return 'assets/images/Asset Tasbih.png'; // Tasbih/Dzikir icon
      case 'breathing_exercise':
        return 'assets/images/Asset Hati.png'; // Heart for breathing/meditation
      case 'audio_listening':
      case 'audio_relax':
        return 'assets/images/Asset Headphone.png'; // Headphone for audio
      case 'journal_entry':
        return 'assets/images/Emote Senang.png'; // Happy emote for journaling
      case 'qalbuchat_session':
      case 'chatbot_session':
        return 'assets/images/Chatbot.png'; // Chatbot icon
      case 'psychology_assessment':
        return 'assets/images/Asset Hati.png'; // Heart for psychology
      case 'mood_tracking':
        return 'assets/images/Emote Kacamata Senang.png'; // Happy emote for mood
      case 'doa_dzikir':
        return 'assets/images/Asset Tasbih.png'; // Tasbih for doa & dzikir
      case 'meditation':
        return 'assets/images/Asset Hati.png'; // Heart for meditation
      case 'therapy_session':
        return 'assets/images/Chatbot.png'; // Chatbot for therapy
      case 'spiritual_reading':
        return 'assets/images/Asset Alquran.png'; // Al-Qur'an for spiritual reading
      case 'gratitude_journal':
        return 'assets/images/Emote Senang.png'; // Happy emote for gratitude
      case 'self_reflection':
        return 'assets/images/Asset Hati.png'; // Heart for self reflection
      default:
        return 'assets/images/Emote Datar.png'; // Default neutral emote
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F8F5),
              Color(0xFFF5F8F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8FA68E),
                      Color(0xFF7A9B7A),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8FA68E).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Sakinah Tracker',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: _isLoading ? null : () {
                          _loadInitialData();
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.refresh,
                            color: _isLoading 
                                ? Colors.white.withValues(alpha: 0.5)
                                : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8FA68E)),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Memuat data aktivitas...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            // Activity Calendar
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2D5A5A).withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Calendar Header
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF8FA68E), Color(0xFF7A9B7A)],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        DropdownButton<int>(
                                          value: _currentMonth.month,
                                          dropdownColor: const Color(0xFF8FA68E),
                                          iconEnabledColor: Colors.white,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          underline: const SizedBox(),
                                          items: List.generate(12, (index) {
                                            return DropdownMenuItem(
                                              value: index + 1,
                                              child: Text(
                                                DateFormat.MMMM().format(DateTime(2025, index + 1)),
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            );
                                          }),
                                          onChanged: (month) {
                                            setState(() {
                                              _currentMonth = DateTime(_currentMonth.year, month!, 1);
                                            });
                                            _loadCalendarData(_currentMonth.year, _currentMonth.month);
                                            _loadMonthlyData(_currentMonth.year, _currentMonth.month);
                                          },
                                        ),
                                        DropdownButton<int>(
                                          value: _currentMonth.year,
                                          dropdownColor: const Color(0xFF8FA68E),
                                          iconEnabledColor: Colors.white,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          underline: const SizedBox(),
                                          items: List.generate(10, (index) {
                                            int year = 2020 + index;
                                            return DropdownMenuItem(
                                              value: year,
                                              child: Text(
                                                year.toString(),
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            );
                                          }),
                                          onChanged: (year) {
                                            setState(() {
                                              _currentMonth = DateTime(year!, _currentMonth.month, 1);
                                            });
                                            _loadCalendarData(_currentMonth.year, _currentMonth.month);
                                            _loadMonthlyData(_currentMonth.year, _currentMonth.month);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Weekdays header
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                                        .map((day) => Container(
                                              width: 35,
                                              height: 35,
                                              alignment: Alignment.center,
                                              child: Text(
                                                day,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF64748b),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),

                                  const SizedBox(height: 16),

                                  // Calendar days with activities
                                  Column(
                                    children: _buildCalendarWeeks(),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Daily Activities Summary  
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2D5A5A).withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFF8FA68E),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        DateFormat('EEEE, dd MMMM yyyy', 'id').format(_selectedDate),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2D5A5A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Show activities or empty state
                                  if (_dailyActivities.isNotEmpty) ...[
                                    Text(
                                      '${_dailyActivities.length} aktivitas hari ini',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ..._dailyActivities.map((activity) => _buildActivityTile(activity)),
                                  ] else ...[
                                    // Empty state
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFF8FA68E).withValues(alpha: 0.1),
                                                  const Color(0xFF8FA68E).withValues(alpha: 0.05),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: const Color(0xFF8FA68E).withValues(alpha: 0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Image.asset(
                                                'assets/images/Emote Datar.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Anda tidak memakai fitur apapun pada tanggal ini',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF64748B),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Mulai aktivitas spiritual Anda hari ini untuk melihat progress di sini',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: const Color(0xFF64748B).withOpacity(0.8),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF8FA68E).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: const Color(0xFF8FA68E).withOpacity(0.3),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.tips_and_updates_outlined,
                                                  size: 16,
                                                  color: const Color(0xFF8FA68E),
                                                ),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  'Cobalah baca Al-Qur\'an atau dzikir',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF8FA68E),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Monthly Statistics
                            if (_monthlyData != null)
                              Container(
                                margin: const EdgeInsets.all(20),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2D5A5A).withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.analytics_outlined,
                                          color: Color(0xFF8FA68E),
                                          size: 24,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Statistik Bulan Ini',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2D5A5A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _buildMonthlyStatsGrid(),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile(UserActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8FA68E).withValues(alpha: 0.1),
            const Color(0xFF8FA68E).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8FA68E).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8FA68E).withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8FA68E).withValues(alpha: 0.2),
                  const Color(0xFF7A9B7A).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF8FA68E).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                _getActivityAssetFromType(activity.activityType),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D5A5A),
                  ),
                ),
                if (activity.additionalInfo != null || activity.duration != null)
                  Text(
                    [activity.additionalInfo, activity.duration]
                        .where((info) => info != null)
                        .join(' • '),
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF64748B).withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF8FA68E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              DateFormat('HH:mm').format(activity.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2D5A5A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStatsGrid() {
    if (_monthlyData == null) return const SizedBox();
    
    return Column(
      children: [
        // Overview stats
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Aktivitas',
                _monthlyData!.totalActivities.toString(),
                Icons.analytics,
                const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Hari Aktif',
                _monthlyData!.activeDays.toString(),
                Icons.calendar_month,
                const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Rata-rata/Hari',
                _monthlyData!.averageActivitiesPerDay.toStringAsFixed(1),
                Icons.trending_up,
                const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Aktivitas Terfavorit',
                _monthlyData!.getActivityDisplayName(_monthlyData!.mostActiveType),
                Icons.favorite,
                const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Activity breakdown
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Breakdown Aktivitas:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D5A5A),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._monthlyData!.activityTypeCount.entries.map((entry) {
          return _buildActivityBreakdownTile(entry.key, entry.value);
        }).toList(),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBreakdownTile(String activityType, int count) {
    final percentage = _monthlyData!.getActivityPercentage(activityType);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: _getActivityTypeColor(activityType),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _monthlyData!.getActivityDisplayName(activityType),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D5A5A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getActivityTypeColor(activityType),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5A5A),
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityTypeColor(String activityType) {
    switch (activityType) {
      case 'quran_reading':
        return const Color(0xFF3B82F6);
      case 'dzikir_session':
        return const Color(0xFF10B981);
      case 'breathing_exercise':
        return const Color(0xFF8B5CF6);
      case 'audio_listening':
        return const Color(0xFFF59E0B);
      case 'journal_entry':
        return const Color(0xFFEF4444);
      case 'qalbuchat_session':
        return const Color(0xFF06B6D4);
      case 'psychology_assessment':
        return const Color(0xFFEC4899);
      case 'mood_tracking':
        return const Color(0xFF84CC16);
      default:
        return const Color(0xFF6B7280);
    }
  }

  List<Widget> _buildCalendarWeeks() {
    List<Widget> weeks = [];
    DateTime firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    DateTime lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    
    int startWeekday = firstDay.weekday;
    int totalDays = lastDay.day;
    
    List<Widget> days = [];
    
    // Add empty containers for days before first day of month
    for (int i = 1; i < startWeekday; i++) {
      days.add(const SizedBox(width: 40, height: 40));
    }
    
    // Add days of the month
    for (int day = 1; day <= totalDays; day++) {
      DateTime date = DateTime(_currentMonth.year, _currentMonth.month, day);
      bool isSelected = _isSameDay(date, _selectedDate);
      String dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      int activityCount = _calendarData[dateKey] ?? 0;
      
      days.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
            _loadDailyActivities(date);
          },
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFF8FA68E).withOpacity(0.3)
                  : _getActivityColor(activityCount),
              borderRadius: BorderRadius.circular(10),
              border: isSelected 
                  ? Border.all(color: const Color(0xFF8FA68E), width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: activityCount > 0 ? Colors.white : const Color(0xFF64748b),
                  ),
                ),
                if (activityCount > 0)
                  Text(
                    activityCount.toString(),
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Group days into weeks
    for (int i = 0; i < days.length; i += 7) {
      List<Widget> week = days.sublist(i, (i + 7 > days.length) ? days.length : i + 7);
      while (week.length < 7) {
        week.add(const SizedBox(width: 40, height: 40));
      }
      weeks.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: week,
          ),
        ),
      );
    }
    
    return weeks;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
