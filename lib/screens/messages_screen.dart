import 'package:flutter/material.dart';
import 'package:finder/routes.dart';
import 'package:finder/widgets/fade_in_slide.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0, bottom: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const FadeInSlide(
                child: Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: FadeInSlide(
              delay: 0.1,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search conversations...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Messages List
          Expanded(
            child: FadeInSlide(
              delay: 0.2,
              child: ListView(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                children: const [
                  MessageCard(
                    name: 'Sarah Johnson',
                    message: 'Yes, I found it near the park',
                    timeAgo: '2m ago',
                    unreadCount: 2,
                    itemName: 'Black Wallet',
                    itemIcon: Icons.account_balance_wallet,
                    isOnline: true,
                    imagePath: 'assets/images/sarah.png',
                  ),
                  MessageCard(
                    name: 'Mike Chen',
                    message: 'Can we meet tomorrow at 3pm?',
                    timeAgo: '1h ago',
                    unreadCount: 0,
                    itemName: 'iPhone 14',
                    itemIcon: Icons.phone_iphone,
                    isOnline: true,
                    imagePath: 'assets/images/mike.png',
                  ),
                  MessageCard(
                    name: 'Emily Davis',
                    message: 'Thank you so much for finding it!',
                    timeAgo: '3h ago',
                    unreadCount: 0,
                    itemName: 'House Keys',
                    itemIcon: Icons.vpn_key,
                    isOnline: false,
                    imagePath: 'assets/images/emily.png',
                  ),
                  MessageCard(
                    name: 'James Wilson',
                    message: 'Is the reward still available?',
                    timeAgo: '1d ago',
                    unreadCount: 1,
                    itemName: 'Backpack',
                    itemIcon: Icons.backpack,
                    isOnline: false,
                    imagePath: 'assets/images/james.png',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageCard extends StatelessWidget {
  final String name;
  final String message;
  final String timeAgo;
  final int unreadCount;
  final String itemName;
  final IconData itemIcon;
  final bool isOnline;
  final String imagePath;

  const MessageCard({
    Key? key,
    required this.name,
    required this.message,
    required this.timeAgo,
    required this.unreadCount,
    required this.itemName,
    required this.itemIcon,
    required this.isOnline,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.chat,
          arguments: {
            'userName': name,
            'itemName': itemName,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4E9F3D),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 15),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F2045),
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                      fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Related Item
                      Row(
                        children: [
                          Icon(itemIcon, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 5),
                          Text(
                            itemName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      // Unread Badge
                      if (unreadCount > 0)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFF8A2BE2), // Purple badge
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
