import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String selectedFilter = 'All Messages';

  final List<NotificationData> notifications = [
    NotificationData(
      icon: Icons.notifications,
      iconColor: const Color(0xFF8FA68E),
      title: 'Time to Dzikir',
      subtitle: 'Luangkan waktu sejenak untuk berdzikir...',
      time: '2 min ago',
      isUnread: true,
    ),
    NotificationData(
      icon: Icons.star,
      iconColor: const Color(0xFF8FA68E),
      title: 'Jangan Lupa Baca Qur\'an',
      subtitle: 'Sudah baca Qur\'an hari ini ?\nSatu ayat...',
      time: '1 hour ago',
      isUnread: true,
    ),
    NotificationData(
      icon: Icons.notifications,
      iconColor: const Color(0xFF8FA68E),
      title: 'Dekatkan diri pada Allah',
      subtitle: 'Luangkan waktu sejenak untuk berdzikir...',
      time: '3 hours ago',
      isUnread: false,
    ),
    NotificationData(
      icon: Icons.notifications,
      iconColor: const Color(0xFF8FA68E),
      title: 'Time to Dzikir',
      subtitle: 'Luangkan waktu sejenak untuk berdzikir...',
      time: '1 day ago',
      isUnread: false,
    ),
    NotificationData(
      icon: Icons.star,
      iconColor: const Color(0xFF8FA68E),
      title: 'Time to Dzikir',
      subtitle: 'Luangkan waktu sejenak untuk berdzikir...',
      time: '2 days ago',
      isUnread: false,
    ),
    NotificationData(
      icon: Icons.notifications,
      iconColor: const Color(0xFF8FA68E),
      title: 'Time to Dzikir',
      subtitle: 'Luangkan waktu sejenak untuk berdzikir...',
      time: '3 days ago',
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8F8), // Very light teal
              Color(0xFFE8F5E8), // Light sage green
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8FA68E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF2D5A5A),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Notification',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5A5A),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildFilterTab('All Messages', true),
                    const SizedBox(width: 12),
                    _buildFilterTab('Unread', false),
                    const SizedBox(width: 12),
                    _buildFilterTab('Deleted', false),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Notifications List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _getFilteredNotifications().length,
                  itemBuilder: (context, index) {
                    final notification = _getFilteredNotifications()[index];
                    return _buildNotificationCard(notification);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF8FA68E).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF8FA68E),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationData notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D5A5A).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: notification.iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              notification.icon,
              color: notification.iconColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D5A5A),
                      ),
                    ),
                    if (notification.isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8FA68E),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  notification.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                Text(
                  notification.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<NotificationData> _getFilteredNotifications() {
    switch (selectedFilter) {
      case 'Unread':
        return notifications.where((n) => n.isUnread).toList();
      case 'Deleted':
        return []; // Empty for deleted notifications
      default:
        return notifications;
    }
  }
}

// Data model
class NotificationData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final bool isUnread;

  NotificationData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
  });
}
