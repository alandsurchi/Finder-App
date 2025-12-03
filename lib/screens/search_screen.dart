import 'package:flutter/material.dart';
import 'package:finder/widgets/item_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

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
              child: const Text(
                'Search',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search items...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.tune, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Results Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '5 results',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Results List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
              children: const [
                ItemCard(
                  title: 'Lost iPhone 15 Pro',
                  description: 'Lost my black iPhone 15 Pro near Central Park.',
                  location: 'Central Park, NY',
                  timeAgo: '3 days ago',
                  imagePath: 'assets/images/iphone_15_pro.png', // Placeholder
                  isLost: true,
                ),
                ItemCard(
                  title: 'Found Set of Keys',
                  description: 'Found a set of keys with a car fob.',
                  location: 'Main Street Coffee, Brooklyn',
                  timeAgo: '3 days ago',
                  imagePath: 'assets/images/keys.png', // Placeholder
                  isLost: false,
                ),
                ItemCard(
                  title: 'Missing Golden Retriever',
                  description: 'Our beloved dog is missing. Please help!',
                  location: 'Oak Avenue, Queens',
                  timeAgo: '3 days ago',
                  imagePath: 'assets/images/dog.png', // Placeholder
                  isLost: true,
                ),
                ItemCard(
                  title: 'Found Leather Wallet',
                  description: 'Brown leather wallet found near subway.',
                  location: 'Times Square Station',
                  timeAgo: '3 days ago',
                  imagePath: 'assets/images/leather_wallet.png', // Placeholder
                  isLost: false,
                ),
                ItemCard(
                  title: 'Lost Silver Necklace',
                  description: 'Lost a silver necklace with a heart pendant.',
                  location: 'Life Gym, Manhattan',
                  timeAgo: '4 days ago',
                  imagePath: 'assets/images/necklace.png', // Placeholder
                  isLost: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
