import 'package:flutter/material.dart';
import 'package:finder/widgets/fade_in_slide.dart';

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

  const FilterBottomSheet({Key? key, required this.initialFilters})
    : super(key: key);

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF0F2045),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInSlide(
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Search',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: _resetFilters,
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FadeInSlide(
              delay: 0.1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Type',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: _types.map((type) {
                      final isSelected = _selectedType == type;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = type;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2D8CFF)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2D8CFF)
                                  : Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FadeInSlide(
              delay: 0.2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategories.contains(
                          category,
                        );
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedCategories.remove(category);
                              } else {
                                _selectedCategories.add(category);
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2D8CFF)
                                  : Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2D8CFF)
                                    : Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FadeInSlide(
              delay: 0.3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: _locationController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter City or Area',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.location_on_outlined,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FadeInSlide(
              delay: 0.35,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date Range',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePickerField(
                          label: 'From',
                          date: _dateFrom,
                          onTap: () => _pickDate(isFrom: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDatePickerField(
                          label: 'To',
                          date: _dateTo,
                          onTap: () => _pickDate(isFrom: false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FadeInSlide(
              delay: 0.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reward Offered',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: _hasReward,
                    onChanged: (value) {
                      setState(() {
                        _hasReward = value;
                      });
                    },
                    activeColor: const Color(0xFF2D8CFF),
                    activeTrackColor: const Color(0xFF2D8CFF).withOpacity(0.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FadeInSlide(
              delay: 0.55,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Verified Users Only',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: _verifiedOnly,
                    onChanged: (value) {
                      setState(() {
                        _verifiedOnly = value;
                      });
                    },
                    activeColor: const Color(0xFF2D8CFF),
                    activeTrackColor: const Color(0xFF2D8CFF).withOpacity(0.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FadeInSlide(
              delay: 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _sortOptions.map((option) {
                      final isSelected = _selectedSort == option;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSort = option;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2D8CFF)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2D8CFF)
                                  : Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            FadeInSlide(
              delay: 0.7,
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D8CFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: Colors.white.withOpacity(0.6),
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date == null ? 'Select date' : _formatDate(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
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
