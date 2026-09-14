import 'dart:async';

import 'package:flutter/material.dart';
import 'package:finder/widgets/custom_bottom_nav_bar.dart';
import 'package:finder/widgets/filter_bottom_sheet.dart';
import 'package:finder/widgets/state/empty_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/routes.dart';
import 'package:finder/models/item_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/providers/post_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  SearchFilterData _activeFilters = SearchFilterData.initial();
  /// Returned (resolved) posts stay searchable so people can see outcomes.
  bool _showReturned = true;

  Timer? _queryDebounce;

  /// Re-filters 250 ms after the last keystroke instead of on every one.
  void _onQueryChanged(String _) {
    _queryDebounce?.cancel();
    _queryDebounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _queryDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters {
    final f = _activeFilters;
    return f.selectedType != 'All' ||
        f.selectedCategories.isNotEmpty ||
        f.hasReward ||
        f.verifiedOnly ||
        f.location.trim().isNotEmpty ||
        f.dateFrom != null ||
        f.dateTo != null ||
        f.selectedSort != 'Most Recent';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
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
      hasReward: item.hasReward,
      isVerified: item.isVerified,
      reportedAt: item.createdAt.toDate(),
      item: item,
    )).toList() ?? [];

    final filteredItems = _buildFilteredItems(allItems);
    final navClearance = CustomBottomNavBar.totalHeight(context) + BeaconSpace.lg;

    return Scaffold(
      body: BeaconBackdrop(
        alignment: const Alignment(-1.2, -1.1),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StaggeredEntrance(
                child: AppPageHeader(
                  title: 'Search',
                  subtitle: 'Find lost and found items near you',
                  showBack: false,
                  large: true,
                  padding: EdgeInsets.fromLTRB(
                      BeaconSpace.page, BeaconSpace.md, BeaconSpace.page, BeaconSpace.lg),
                ),
              ),
              StaggeredEntrance(
                index: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
                  child: SearchField(
                    controller: _searchController,
                    hint: 'Search items, places…',
                    onChanged: _onQueryChanged,
                    onFilterTap: _openFilterBottomSheet,
                    filterActive: _hasActiveFilters,
                  ),
                ),
              ),
              const SizedBox(height: BeaconSpace.lg),
              StaggeredEntrance(
                index: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
                  child: Row(
                    children: [
                      Text(
                        '${filteredItems.length} result${filteredItems.length == 1 ? '' : 's'}',
                        style: text.labelLarge?.copyWith(color: t.onSurfaceVar),
                      ),
                      const SizedBox(width: BeaconSpace.sm),
                      AppChoiceChip(
                        label: 'Returned',
                        icon: Icons.assignment_turned_in_outlined,
                        selected: _showReturned,
                        onTap: () =>
                            setState(() => _showReturned = !_showReturned),
                      ),
                      const Spacer(),
                      if (_hasActiveFilters)
                        AppButton.ghost(
                          label: 'Clear filters',
                          size: AppButtonSize.small,
                          icon: Icons.close_rounded,
                          onPressed: () => setState(
                              () => _activeFilters = SearchFilterData.initial()),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: BeaconSpace.sm),
              Expanded(
                child: postsAsync.isLoading && allItems.isEmpty
                    ? const LoadingWidget(variant: LoadingVariant.rows)
                    : filteredItems.isEmpty
                        ? _buildNoResultState()
                        : ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              BeaconSpace.page,
                              BeaconSpace.xs,
                              BeaconSpace.page,
                              navClearance,
                            ),
                            itemCount: filteredItems.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: BeaconSpace.md),
                            itemBuilder: (context, index) {
                              final entry = filteredItems[index];
                              final row = _buildResultRow(entry);
                              if (index >= 8) return row;
                              return StaggeredEntrance(
                                index: index,
                                baseDelay: const Duration(milliseconds: 35),
                                child: row,
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultState() {
    return EmptyWidget(
      icon: Icons.search_off_rounded,
      title: 'No matching items found',
      subtitle: 'Try a different keyword or adjust your filters.',
      actionLabel: _hasActiveFilters ? 'Reset filters' : null,
      onAction: _hasActiveFilters
          ? () => setState(() => _activeFilters = SearchFilterData.initial())
          : null,
    );
  }

  Widget _buildResultRow(_SearchEntry entry) {
    final item = entry.item;
    final t = AppColorTokens.of(context);
    return ItemCard(
      item: item,
      layout: ItemCardLayout.row,
      heroTag: 'item-image-${entry.id}',
      subtitle: (item.isVerified || item.ownerIsAdmin)
          ? NameWithMarks(
              name: (item.ownerName?.isNotEmpty ?? false) ? item.ownerName! : 'Finder User',
              verified: item.isVerified,
              admin: item.ownerIsAdmin,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: t.primary),
              markSize: 14,
            )
          : null,
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.itemDetails,
        arguments: entry.item,
      ),
    );
  }

  Future<void> _openFilterBottomSheet() async {
    final result = await showModalBottomSheet<SearchFilterData>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => FilterBottomSheet(initialFilters: _activeFilters),
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

      if (!_showReturned && item.item.isResolved) {
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

    // Open posts first; returned ones keep their order after them.
    final open = results.where((e) => !e.item.isResolved).toList();
    final returned = results.where((e) => e.item.isResolved).toList();
    return [...open, ...returned];
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
