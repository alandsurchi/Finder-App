import 'package:flutter/material.dart';
import 'package:finder/widgets/fade_in_slide.dart';
import 'package:finder/widgets/filter_bottom_sheet.dart';
import 'package:finder/routes.dart';
import 'package:finder/models/item_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/providers/post_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  SearchFilterData _activeFilters = SearchFilterData.initial();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postsStreamProvider);
    final allItems = postsAsync.value?.map((item) => _SearchEntry(
      id: item.id,
      title: item.title,
      description: item.description,
      location: item.location,
      timeAgo: item.timeAgo,
      imagePath: item.imagePath,
      isLost: item.isLost,
      category: item.category,
      hasReward: item.reward != null && item.reward!.isNotEmpty,
      isVerified: item.isVerified,
      reportedAt: item.createdAt.toDate(),
      item: item,
    )).toList() ?? [];

    final filteredItems = _buildFilteredItems(allItems);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2045), Color(0xFF1A3B70), Color(0xFFD0DEE8)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 60,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: const FadeInSlide(
                  child: Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FadeInSlide(
                delay: 0.1,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search items...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: _openFilterBottomSheet,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(Icons.tune, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FadeInSlide(
                  delay: 0.2,
                  child: Text(
                    '${filteredItems.length} results',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FadeInSlide(
                delay: 0.3,
                child: filteredItems.isEmpty
                    ? _buildNoResultState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 100,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final entry = filteredItems[index];
                          return _buildResultRow(entry);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Handles both Cloudinary URLs (https://...) and local asset paths
  Widget _buildThumb(String path) {
    const size = 72.0;
    final placeholder = Container(
      width: size,
      height: size,
      color: Colors.white.withOpacity(0.12),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.white70),
    );

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : placeholder,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }
    if (path.isEmpty) return placeholder;
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }

  Widget _buildNoResultState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: Colors.white70,
              size: 48,
            ),
            const SizedBox(height: 10),
            Text(
              'No matching items found.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Try a different keyword or adjust your filters.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(_SearchEntry entry) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.itemDetails,
        arguments: entry.item,
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildThumb(entry.imagePath),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: entry.isLost
                            ? const Color(0xFFE64A4A)
                            : const Color(0xFF22C55E), // green, same as home
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        entry.isLost ? 'LOST' : 'FOUND',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white.withOpacity(0.75),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        entry.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      entry.timeAgo,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ), // end Container
    ); // end GestureDetector
  }

  Future<void> _openFilterBottomSheet() async {
    final result = await showModalBottomSheet<SearchFilterData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.82,
        child: FilterBottomSheet(initialFilters: _activeFilters),
      ),
    );

    if (result != null) {
      setState(() {
        _activeFilters = result;
      });
    }
  }

  List<_SearchEntry> _buildFilteredItems(List<_SearchEntry> allItems) {
    final query = _searchController.text.trim().toLowerCase();
    final selectedCategories = _activeFilters.selectedCategories
        .map((e) => e.toLowerCase())
        .toSet();
    final locationFilter = _activeFilters.location.trim().toLowerCase();

    var results = allItems.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query);
      if (!matchesQuery) {
        return false;
      }

      if (_activeFilters.selectedType == 'Lost' && !item.isLost) {
        return false;
      }
      if (_activeFilters.selectedType == 'Found' && item.isLost) {
        return false;
      }

      if (selectedCategories.isNotEmpty &&
          !selectedCategories.contains(item.category.toLowerCase())) {
        return false;
      }

      if (locationFilter.isNotEmpty &&
          !item.location.toLowerCase().contains(locationFilter)) {
        return false;
      }

      if (_activeFilters.hasReward && !item.hasReward) {
        return false;
      }

      if (_activeFilters.verifiedOnly && !item.isVerified) {
        return false;
      }

      if (_activeFilters.dateFrom != null) {
        final start = DateTime(
          _activeFilters.dateFrom!.year,
          _activeFilters.dateFrom!.month,
          _activeFilters.dateFrom!.day,
        );
        if (item.reportedAt.isBefore(start)) {
          return false;
        }
      }

      if (_activeFilters.dateTo != null) {
        final end = DateTime(
          _activeFilters.dateTo!.year,
          _activeFilters.dateTo!.month,
          _activeFilters.dateTo!.day,
          23,
          59,
          59,
        );
        if (item.reportedAt.isAfter(end)) {
          return false;
        }
      }

      return true;
    }).toList();

    if (_activeFilters.selectedSort == 'Most Recent') {
      results.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    } else if (_activeFilters.selectedSort == 'Nearest to Me') {
      // No coordinates are available, so we keep a stable local arrangement.
      results.sort((a, b) => a.location.compareTo(b.location));
    }

    return results;
  }


}

class _SearchEntry {
  final String id;
  final String title;
  final String description;
  final String location;
  final String timeAgo;
  final String imagePath;
  final bool isLost;
  final String category;
  final bool hasReward;
  final bool isVerified;
  final DateTime reportedAt;
  final ItemModel item;

  const _SearchEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.timeAgo,
    required this.imagePath,
    required this.isLost,
    required this.category,
    required this.hasReward,
    required this.isVerified,
    required this.reportedAt,
    required this.item,
  });
}
