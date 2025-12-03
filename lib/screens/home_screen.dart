import 'package:flutter/material.dart';
import 'package:finder/widgets/home_app_bar.dart';
import 'package:finder/widgets/item_card.dart';
import 'package:finder/widgets/custom_bottom_nav_bar.dart';
import 'package:finder/widgets/fade_in_slide.dart';

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
          // Main Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            child: _getPage(_currentIndex),
          ),
          
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
          const FadeInSlide(child: HomeAppBar()),
          // Category Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: FadeInSlide(
              delay: 0.1,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF2D8CFF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Item List
          Expanded(
            child: FadeInSlide(
              delay: 0.2,
              child: ListView(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                children: const [
                  ItemCard(
                    title: 'Black iPhone 15 Pro',
                    description:
                        'Lost my black iPhone 15 Pro near Central Park. Has a clear case with a small scratch on the corner. Please if found.',
                    location: 'Central Park, NYC',
                    timeAgo: '4 days ago',
                    imagePath: 'assets/postes/iphone 15 pink.jpg', // Placeholder
                    isLost: true,
                  ),
                  ItemCard(
                    title: 'Brown Leather Wallet',
                    description:
                        'Lost my brown leather wallet somewhere in downtown. Contains important IDs and cards. Reward offered!',
                    location: 'Downtown Area',
                    timeAgo: '5 days ago',
                    imagePath: 'assets/postes/wallet.jpg', // Placeholder
                    isLost: false, // Found
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return Container(
          key: const ValueKey<int>(0),
          child: _buildHomeContent(),
        );
      case 1:
        return const SearchScreen(key: ValueKey<int>(1));
      case 2:
        return const CreatePostScreen(key: ValueKey<int>(2));
      case 3:
        return const MessagesScreen(key: ValueKey<int>(3));
      case 4:
        return const ProfileScreen(key: ValueKey<int>(4));
      default:
        return Container(key: const ValueKey<int>(-1));
    }
  }
}
