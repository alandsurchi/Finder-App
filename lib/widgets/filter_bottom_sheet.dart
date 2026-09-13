import 'package:flutter/material.dart';
import 'package:finder/widgets/ui/ui.dart';

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
      title: 'Filters',
      subtitle: 'Narrow down what you are looking for',
      actions: [
        AppButton.secondary(label: 'Reset', onPressed: _resetFilters),
        AppButton(label: 'Apply filters', onPressed: _applyFilters),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          section(
            'Type',
            SegmentedPills(
              options: _types,
              selectedIndex: _types.indexOf(_selectedType).clamp(0, _types.length - 1),
              onChanged: (i) => setState(() => _selectedType = _types[i]),
            ),
          ),
          section(
            'Category',
            Wrap(
              spacing: BeaconSpace.sm,
              runSpacing: BeaconSpace.sm,
              children: _categories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return AppChoiceChip(
                  label: category,
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
            'Location',
            AppTextField(
              controller: _locationController,
              hint: 'Enter city or area',
              prefixIcon: Icons.place_outlined,
              textInputAction: TextInputAction.done,
            ),
            index: 2,
          ),
          section(
            'Date range',
            Row(
              children: [
                Expanded(
                  child: AppPickerField(
                    label: 'From',
                    value: _dateFrom == null ? '' : _formatDate(_dateFrom!),
                    hint: 'Select date',
                    prefixIcon: Icons.calendar_today_outlined,
                    onTap: () => _pickDate(isFrom: true),
                  ),
                ),
                const SizedBox(width: BeaconSpace.md),
                Expanded(
                  child: AppPickerField(
                    label: 'To',
                    value: _dateTo == null ? '' : _formatDate(_dateTo!),
                    hint: 'Select date',
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
                      title: 'Reward offered',
                      subtitle: 'Only posts that offer a reward',
                      value: _hasReward,
                      onChanged: (value) => setState(() => _hasReward = value),
                    ),
                    Divider(color: t.outlineVariant, height: 1, indent: 64),
                    ToggleTile(
                      icon: Icons.verified_outlined,
                      title: 'Verified users only',
                      subtitle: 'Posted by identity-verified members',
                      value: _verifiedOnly,
                      onChanged: (value) => setState(() => _verifiedOnly = value),
                    ),
                  ],
                ),
              ),
            ),
          ),
          section(
            'Sort by',
            Wrap(
              spacing: BeaconSpace.sm,
              runSpacing: BeaconSpace.sm,
              children: _sortOptions.map((option) {
                final isSelected = _selectedSort == option;
                return AppChoiceChip(
                  label: option,
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

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

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
