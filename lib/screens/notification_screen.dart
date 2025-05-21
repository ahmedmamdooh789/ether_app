import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Color primaryPurple = const Color.fromRGBO(148, 15, 252, 1);
  
  // List of notifications grouped by time
  final Map<String, List<Map<String, dynamic>>> _notifications = {
    'Today': [
      {
        'username': 'Feky',
        'userImage': 'assets/user3.png',
        'message': 'liked your post',
        'time': '2m',
      },
      {
        'username': 'Feky',
        'userImage': 'assets/user3.png',
        'message': 'commented on your post',
        'time': '5m',
      },
      {
        'username': 'Sheta',
        'userImage': 'assets/user4.png',
        'message': 'liked your post',
        'time': '10m',
      },
    ],
    'Yesterday': [
      {
        'username': 'Feky',
        'userImage': 'assets/user3.png',
        'message': 'sent Add to you',
        'time': '1h',
      },
      {
        'username': 'Sheta',
        'userImage': 'assets/user4.png',
        'message': 'replied your comment',
        'time': '1d',
      },
    ],
    'This week': [
      {
        'username': 'Sheta',
        'userImage': 'assets/user4.png',
        'message': 'sent Add to you',
        'time': '3d',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.normal,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, sectionIndex) {
          final timeSection = _notifications.keys.elementAt(sectionIndex);
          final notificationsInSection = _notifications[timeSection]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time section header
              Container(
                padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      timeSection,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 1,
                      width: 40,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
              
              // Notifications in this section
              ...notificationsInSection.map((notification) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Purple dot with animation effect
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryPurple,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryPurple.withOpacity(0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // User image with border
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(notification['userImage']),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Notification text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  notification['username'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    notification['message'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Time with container
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          notification['time'],
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
