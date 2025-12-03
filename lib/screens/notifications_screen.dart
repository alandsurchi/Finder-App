import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2045), // Dark Blue
              Color(0xFF1A3B70), // Mid Blue
              Color(0xFFD0DEE8), // Light Blue/Whiteish at bottom
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 20),
          children: [
            NotificationItem(
              title: 'Item Found Match',
              message: 'Someone found a "Black Wallet" that matches your lost item report.',
              timeAgo: '2m ago',
              isUnread: true,
              icon: Icons.check_circle_outline,
              iconColor: Color(0xFF4E9F3D),
            ),
            NotificationItem(
              title: 'New Message',
              message: 'Sarah sent you a message regarding "iPhone 15".',
              timeAgo: '1h ago',
              isUnread: true,
              icon: Icons.chat_bubble_outline,
              iconColor: Color(0xFF2D8CFF),
            ),
            NotificationItem(
              title: 'Post Approved',
              message: 'Your post "Lost Keys" has been approved and is now visible.',
              timeAgo: '5h ago',
              isUnread: false,
              icon: Icons.verified_outlined,
              iconColor: Colors.orange,
            ),
            NotificationItem(
              title: 'System Update',
              message: 'We have updated our privacy policy. Please review the changes.',
              timeAgo: '1d ago',
              isUnread: false,
              icon: Icons.info_outline,
              iconColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final String timeAgo;
  final bool isUnread;
  final IconData icon;
  final Color iconColor;

  const NotificationItem({
    Key? key,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.isUnread,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white.withOpacity(0.95) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: isUnread ? Border.all(color: const Color(0xFF2D8CFF).withOpacity(0.5), width: 1) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F2045),
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          if (isUnread)
            Container(
              margin: const EdgeInsets.only(left: 10, top: 5),
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF2D8CFF),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
