import 'package:flutter/material.dart';
import 'package:finder/widgets/home_app_bar.dart';
import 'package:finder/widgets/item_card.dart';
import 'package:finder/widgets/custom_bottom_nav_bar.dart';

import 'package:finder/screens/search_screen.dart';
import 'package:finder/screens/create_post_screen.dart';
import 'package:finder/screens/messages_screen.dart';
import 'package:finder/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'All items';

  final List<String> _categories = ['All items', 'Lost', 'Found'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          _currentIndex == 0 
              ? _buildHomeContent() 
              : _currentIndex == 1 
                  ? const SearchScreen()
                  : _currentIndex == 2
                      ? const MessagesScreen()
                      : const ProfileScreen(),
          
          // Bottom Nav Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              onAddTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreatePostScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
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
          const HomeAppBar(),
          // Category Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2D8CFF) : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // Item List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
              children: const [
                ItemCard(
                  title: 'Black iPhone 15 Pro',
                  description:
                      'Lost my black iPhone 15 Pro near Central Park. Has a clear case with a small scratch on the corner. Please if found.',
                  location: 'Central Park, NYC',
                  timeAgo: '4 days ago',
                  imagePath: 'assets/images/iphone_15_pro.png', // Placeholder
                  isLost: true,
                ),
                ItemCard(
                  title: 'Brown Leather Wallet',
                  description:
                      'Lost my brown leather wallet somewhere in downtown. Contains important IDs and cards. Reward offered!',
                  location: 'Downtown Area',
                  timeAgo: '5 days ago',
                  imagePath: 'assets/images/leather_wallet.png', // Placeholder
                  isLost: false, // Found
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
