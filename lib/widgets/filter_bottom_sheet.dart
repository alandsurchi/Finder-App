import 'package:flutter/material.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/core/constants/app_categories.dart';
import 'package:finder/l10n/l10n.dart';

class SearchFilterData {
  final String selectedType;
  final List<String> selectedCategories;
  final bool hasReward;
  final String selectedSort;
  final String location;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool verifiedOnly;

  const SearchFilterData({
    required this.selectedType,
    required this.selectedCategories,
    required this.hasReward,
    required this.selectedSort,
    required this.location,
    required this.dateFrom,
    required this.dateTo,
    required this.verifiedOnly,
  });

  factory SearchFilterData.initial() {
    return const SearchFilterData(
      selectedType: 'All',
      selectedCategories: [],
      hasReward: false,
      selectedSort: 'Most Recent',
      location: '',
      dateFrom: null,
      dateTo: null,
      verifiedOnly: false,
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final SearchFilterData initialFilters;

  const FilterBottomSheet({super.key, required this.initialFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedType;
  late List<String> _selectedCategories;
  late bool _hasReward;
  late String _selectedSort;
  late bool _verifiedOnly;
  late DateTime? _dateFrom;
  late DateTime? _dateTo;

  final TextEditingController _locationController = TextEditingController();

  final List<String> _types = ['All', 'Lost', 'Found'];
  final List<String> _categories = [
    'Electronics',
    'Wallet',
    'Keys',
    'Pets',
    'Jewelry',
    'Documents',
    'Others',
  ];
  final List<String> _sortOptions = ['Most Recent', 'Nearest to Me'];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialFilters.selectedType;
    _selectedCategories = List<String>.from(
      widget.initialFilters.selectedCategories,
    );
    _hasReward = widget.initialFilters.hasReward;
    _selectedSort = widget.initialFilters.selectedSort;
    _verifiedOnly = widget.initialFilters.verifiedOnly;
    _dateFrom = widget.initialFilters.dateFrom;
    _dateTo = widget.initialFilters.dateTo;
    _locationController.text = widget.initialFilters.location;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;

    Widget section(String title, Widget child, {int index = 0}) {
      return StaggeredEntrance(
        index: index,
        baseDelay: const Duration(milliseconds: 40),
        child: Padding(
          padding: const EdgeInsets.only(bottom: BeaconSpace.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text.titleMedium),
              const SizedBox(height: BeaconSpace.md),
              child,
            ],
          ),
        ),
      );
    }

    return AppBottomSheet(
      title: l10n.filterTitle,
      subtitle: l10n.filterSubtitle,
      actions: [
        AppButton.secondary(label: l10n.filterReset, onPressed: _resetFilters),
        AppButton(label: l10n.filterApply, onPressed: _applyFilters),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          section(
            l10n.filterType,
            SegmentedPills(
              options: _types.map((v) => AppCategories.label(l10n, v)).toList(),
              selectedIndex: _types.indexOf(_selectedType).clamp(0, _types.length - 1),
              onChanged: (i) => setState(() => _selectedType = _types[i]),
            ),
          ),
          section(
            l10n.postCategory,
            Wrap(
              spacing: BeaconSpace.sm,
              runSpacing: BeaconSpace.sm,
              children: _categories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return AppChoiceChip(
                  label: AppCategories.label(l10n, category),
                  icon: categoryIcon(category),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedCategories.remove(category);
                      } else {
                        _selectedCategories.add(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            index: 1,
          ),
          section(
            l10n.commonLocation,
            AppTextField(
              controller: _locationController,
              hint: l10n.filterLocationHint,
              prefixIcon: Icons.place_outlined,
              textInputAction: TextInputAction.done,
            ),
            index: 2,
          ),
          section(
            l10n.filterDateRange,
            Row(
              children: [
                Expanded(
                  child: AppPickerField(
                    label: l10n.filterFrom,
                    value: _dateFrom == null ? '' : _formatDate(l10n, _dateFrom!),
                    hint: l10n.filterSelectDate,
                    prefixIcon: Icons.calendar_today_outlined,
                    onTap: () => _pickDate(isFrom: true),
                  ),
                ),
                const SizedBox(width: BeaconSpace.md),
                Expanded(
                  child: AppPickerField(
                    label: l10n.filterTo,
                    value: _dateTo == null ? '' : _formatDate(l10n, _dateTo!),
                    hint: l10n.filterSelectDate,
                    prefixIcon: Icons.event_outlined,
                    onTap: () => _pickDate(isFrom: false),
                  ),
                ),
              ],
            ),
            index: 3,
          ),
          StaggeredEntrance(
            index: 4,
            baseDelay: const Duration(milliseconds: 40),
            child: Padding(
              padding: const EdgeInsets.only(bottom: BeaconSpace.xxl),
              child: SurfaceCard(
                tone: SurfaceTone.low,
                padding: const EdgeInsets.symmetric(vertical: BeaconSpace.xs),
                child: Column(
                  children: [
                    ToggleTile(
                      icon: Icons.workspace_premium_outlined,
                      title: l10n.filterRewardOffered,
                      subtitle: l10n.filterRewardSubtitle,
                      value: _hasReward,
                      onChanged: (value) => setState(() => _hasReward = value),
                    ),
                    Divider(color: t.outlineVariant, height: 1, indent: 64),
                    ToggleTile(
                      icon: Icons.verified_outlined,
                      title: l10n.filterVerifiedOnly,
                      subtitle: l10n.filterVerifiedSubtitle,
                      value: _verifiedOnly,
                      onChanged: (value) => setState(() => _verifiedOnly = value),
                    ),
                  ],
                ),
              ),
            ),
          ),
          section(
            l10n.filterSortBy,
            Wrap(
              spacing: BeaconSpace.sm,
              runSpacing: BeaconSpace.sm,
              children: _sortOptions.map((option) {
                final isSelected = _selectedSort == option;
                return AppChoiceChip(
                  label: AppCategories.label(l10n, option),
                  icon: option == 'Most Recent'
                      ? Icons.schedule_rounded
                      : Icons.near_me_outlined,
                  selected: isSelected,
                  onTap: () => setState(() => _selectedSort = option),
                );
              }).toList(),
            ),
            index: 5,
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final current = DateTime.now();
    final initial = isFrom
        ? (_dateFrom ?? current)
        : (_dateTo ?? _dateFrom ?? current);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      if (isFrom) {
        _dateFrom = picked;
        if (_dateTo != null && _dateTo!.isBefore(picked)) {
          _dateTo = picked;
        }
      } else {
        _dateTo = picked;
      }
    });
  }

  String _formatDate(AppLocalizations l10n, DateTime date) =>
      l10n.filterDate(date.day, l10n.commonMonthShort('${date.month}'), date.year);

  void _resetFilters() {
    setState(() {
      _selectedType = 'All';
      _selectedCategories.clear();
      _hasReward = false;
      _selectedSort = 'Most Recent';
      _verifiedOnly = false;
      _dateFrom = null;
      _dateTo = null;
      _locationController.clear();
    });
  }

  void _applyFilters() {
    Navigator.pop(
      context,
      SearchFilterData(
        selectedType: _selectedType,
        selectedCategories: List<String>.from(_selectedCategories),
        hasReward: _hasReward,
        selectedSort: _selectedSort,
        location: _locationController.text.trim(),
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        verifiedOnly: _verifiedOnly,
      ),
    );
  }
}
