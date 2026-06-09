import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/routes.dart';
import 'package:finder/providers/post_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/core/constants/app_categories.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/services/image_upload_service.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  static Map<String, dynamic>? _draftCache;

  bool _isLostItem = true;
  final _titleCtrl = TextEditingController();
  String? _category;
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  DateTime? _selectedDateTime;
  final _rewardCtrl = TextEditingController();
  bool _useInApp = true;
  bool _usePhone = false;
  bool _useEmail = false;
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _publicSearch = true;
  bool _hideLocation = false;
  bool _isSubmitting = false;
  bool _isUploadingImage = false;
  String _imagePath = '';

  static const _categories = AppCategories.postCategories;

  @override
  void initState() {
    super.initState();
    _category = _categories.contains('Wallets & Bags')
        ? 'Wallets & Bags'
        : _categories.first;
    _selectedDateTime = DateTime.now();
    _dateCtrl.text = _formatDateTime(_selectedDateTime!);
    _restoreDraftIfAvailable();
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl,
      _descCtrl,
      _locationCtrl,
      _dateCtrl,
      _rewardCtrl,
      _phoneCtrl,
      _emailCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressHeader(),
              const SizedBox(height: 16),
              _buildTypeSelector(),
              const SizedBox(height: 22),
              _buildPhotoSection(),
              const SizedBox(height: 18),
              _buildItemInfoCard(),
              const SizedBox(height: 18),
              _buildLocationTimeSection(),
              const SizedBox(height: 18),
              _buildPrivacyContactSection(t),
              const SizedBox(height: 18),
              _buildActionButtons(t),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 1 / 6,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2D8CFF),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'STEP 1 OF 6 · BASICS',
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeTile(
            selected: _isLostItem,
            icon: Icons.search_rounded,
            title: 'I Lost Something',
            subtitle: 'Report a lost item',
            onTap: () => setState(() => _isLostItem = true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeTile(
            selected: !_isLostItem,
            icon: Icons.back_hand_rounded,
            title: 'I Found Something',
            subtitle: 'Report a found item',
            onTap: () => setState(() => _isLostItem = false),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeTile({
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 136,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF123D73).withOpacity(0.65)
              : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF2D8CFF)
                : Colors.white.withOpacity(0.14),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? const Color(0xFF2D8CFF).withOpacity(0.25)
                    : Colors.white.withOpacity(0.08),
              ),
              child: Icon(icon, color: const Color(0xFF2D8CFF), size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add Photos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 31,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add clear photos to help others identify the item',
          style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildMediaActionButton(
              icon: Icons.photo_camera_outlined,
              label: 'Camera',
              onTap: (_isSubmitting || _isUploadingImage)
                  ? null
                  : _pickAndUploadImage,
            ),
            const SizedBox(width: 10),
            _buildMediaActionButton(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              onTap: (_isSubmitting || _isUploadingImage)
                  ? null
                  : _pickAndUploadImage,
            ),
            const SizedBox(width: 10),
            if (_isUploadingImage)
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.28)),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else if (_imagePath.isNotEmpty)
              _buildSelectedImageTile(),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.13),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.28)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImageTile() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 92,
            height: 92,
            child: _buildImagePreview(_imagePath),
          ),
        ),
        Positioned(
          right: -6,
          top: -6,
          child: GestureDetector(
            onTap: _isSubmitting
                ? null
                : () => setState(() {
                    _imagePath = '';
                  }),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFD83838),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImageTile(),
      );
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImageTile(),
      );
    }

    return _fallbackImageTile();
  }

  Widget _fallbackImageTile() {
    return Container(
      color: Colors.white.withOpacity(0.13),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.white70, size: 30),
    );
  }

  Widget _buildItemInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFC7D0E4).withOpacity(0.65),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel('ITEM NAME'),
          _buildSoftInput(controller: _titleCtrl, hint: 'e.g. Blue Backpack'),
          const SizedBox(height: 14),
          _buildInputLabel('CATEGORY'),
          GestureDetector(
            onTap: _isSubmitting ? null : _showCategoryPicker,
            child: _buildSoftInput(
              controller: TextEditingController(text: _category ?? ''),
              hint: 'Search categories...',
              prefixIcon: Icons.search,
              readOnly: true,
            ),
          ),
          const SizedBox(height: 10),
          _buildCategoryGrid(),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInputLabel('DESCRIPTION'),
              Text(
                '${_descCtrl.text.length}/500',
                style: const TextStyle(
                  color: Color(0xFF7E879C),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          _buildSoftInput(
            controller: _descCtrl,
            hint:
                'e.g. Last seen near the fountain at Central Park. It has a small scratch on the front...',
            maxLines: 4,
            maxLength: 500,
            onChanged: (_) => setState(() {}),
          ),
          if (_isLostItem) ...[
            const SizedBox(height: 14),
            _buildInputLabel('REWARD (OPTIONAL)'),
            _buildSoftInput(
              controller: _rewardCtrl,
              hint: r'e.g. $100',
              keyboardType: TextInputType.number,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF5C6882),
          fontSize: 10,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSoftInput({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3E8F7).withOpacity(0.85),
        borderRadius: BorderRadius.circular(22),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onChanged: onChanged,
        style: const TextStyle(
          color: Color(0xFF24314E),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF8D97AF), fontSize: 14),
          border: InputBorder.none,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: const Color(0xFF607097), size: 18)
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: 14,
      runSpacing: 12,
      children: _categories.map((category) {
        final isSelected = _category == category;
        final icon = _categoryIconFor(category);
        final shortLabel = _shortCategory(category);

        return GestureDetector(
          onTap: _isSubmitting
              ? null
              : () => setState(() {
                  _category = category;
                }),
          child: SizedBox(
            width: 55,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF2D8CFF)
                        : const Color(0xFFE4E9F8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1D64C6)
                          : const Color(0xFFCDD5EA),
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? const Color(0xFF0A1533)
                        : const Color(0xFF6B7691),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  shortLabel,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF2D8CFF)
                        : const Color(0xFF6B7691),
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _shortCategory(String category) {
    switch (category) {
      case 'Watches & Jewelry':
        return 'Wallet';
      case 'Wallets & Bags':
        return 'Bag';
      case 'Clothing':
        return 'Gadgets';
      case 'Documents':
        return 'Docs';
      default:
        return category.length > 9 ? '${category.substring(0, 8)}.' : category;
    }
  }

  IconData _categoryIconFor(String category) {
    switch (category) {
      case 'Electronics':
        return Icons.devices_other_rounded;
      case 'Watches & Jewelry':
        return Icons.account_balance_wallet_rounded;
      case 'Wallets & Bags':
        return Icons.key_rounded;
      case 'Keys':
        return Icons.work_outline_rounded;
      case 'Pets':
        return Icons.pets_rounded;
      case 'Clothing':
        return Icons.headphones_rounded;
      case 'Documents':
        return Icons.description_outlined;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  Widget _buildLocationTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            'Location & Time',
            style: TextStyle(
              color: Color(0xFF0D1C3E),
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FD).withOpacity(0.88),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              _buildMapPreview(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF1E63C5),
                            width: 1.3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : _useCurrentLocationNow,
                        icon: const Icon(
                          Icons.my_location_rounded,
                          size: 16,
                          color: Color(0xFF1E63C5),
                        ),
                        label: const Text(
                          'Use current location',
                          style: TextStyle(
                            color: Color(0xFF1E63C5),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _isSubmitting ? null : _enterLocationManually,
                      icon: const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF2D3F67),
                      ),
                      label: const Text(
                        'Enter manually',
                        style: TextStyle(
                          color: Color(0xFF2D3F67),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildDateTimeRow(),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF8B9098),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.25,
            child: Icon(
              Icons.map_rounded,
              size: 120,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const Icon(Icons.location_pin, color: Color(0xFF2D8CFF), size: 34),
          Positioned(
            bottom: 10,
            child: Text(
              _locationCtrl.text.trim().isEmpty
                  ? 'No location selected'
                  : _locationCtrl.text.trim(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDateTimeChip(
            label: 'DATE',
            value: _formatDateBadge(),
            icon: Icons.calendar_today_rounded,
            onTap: _isSubmitting ? null : _pickDateOnly,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildDateTimeChip(
            label: 'TIME',
            value: _formatTimeBadge(),
            icon: Icons.access_time_filled_rounded,
            onTap: _isSubmitting ? null : _pickTimeOnly,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeChip({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE3E8F7).withOpacity(0.9),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6F7A95),
                fontSize: 9,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1E63C5), size: 14),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF26385E),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyContactSection(AppColorTokens t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB).withOpacity(0.98),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Privacy & Contact',
            style: TextStyle(
              color: Color(0xFF142341),
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _buildInputLabel('PHONE NUMBER'),
          _buildSoftInput(
            controller: _phoneCtrl,
            hint: 'e.g. +1 234 567 8900',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 10),
          _buildInputLabel('EMAIL ADDRESS'),
          _buildSoftInput(
            controller: _emailCtrl,
            hint: 'e.g. yourname@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          _buildSwitchRow(
            title: 'In-app Chat',
            subtitle: 'Recommended',
            value: _useInApp,
            onChanged: (v) => setState(() => _useInApp = v),
          ),
          _buildSwitchRow(
            title: 'Hide exact location',
            subtitle: 'Shows a general area only',
            value: _hideLocation,
            onChanged: (v) => setState(() => _hideLocation = v),
          ),
          _buildSwitchRow(
            title: 'Show phone number publicly',
            subtitle: 'Visible to all registered users',
            value: _usePhone,
            onChanged: (v) => setState(() => _usePhone = v),
          ),
          _buildSwitchRow(
            title: 'Show email publicly',
            subtitle: 'Visible to all registered users',
            value: _useEmail,
            onChanged: (v) => setState(() => _useEmail = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF11203F),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF7A849C),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch.adaptive(
              value: value,
              onChanged: _isSubmitting ? null : onChanged,
              activeColor: const Color(0xFF0D55BC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppColorTokens t) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D55BC),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            onPressed: _isSubmitting ? null : _submitPost,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Post Now',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _isSubmitting ? null : _saveDraft,
          child: const Text(
            'Save Draft',
            style: TextStyle(
              color: Color(0xFF12254A),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showCategoryPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
          decoration: BoxDecoration(
            color: const Color(0xFF0F2045),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ..._categories.map(
                (c) => ListTile(
                  onTap: () => Navigator.pop(context, c),
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _categoryIconFor(c),
                    color: const Color(0xFF2D8CFF),
                  ),
                  title: Text(c, style: const TextStyle(color: Colors.white)),
                  trailing: _category == c
                      ? const Icon(Icons.check, color: Color(0xFF2D8CFF))
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _category = selected;
      });
    }
  }

  void _useCurrentLocationNow() {
    setState(() {
      _locationCtrl.text = 'Current location';
      _publicSearch = true;
    });
    _showMessage('Using your current location.');
  }

  Future<void> _enterLocationManually() async {
    final localCtrl = TextEditingController(text: _locationCtrl.text);
    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter location'),
          content: TextField(
            controller: localCtrl,
            decoration: const InputDecoration(hintText: 'City, street or area'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, localCtrl.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted || value == null) return;
    setState(() {
      _locationCtrl.text = value;
      _publicSearch = true;
    });
  }

  Future<void> _pickDateOnly() async {
    final now = DateTime.now();
    final current = _selectedDateTime ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );

    if (!mounted || pickedDate == null) return;

    final base = _selectedDateTime ?? now;
    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      base.hour,
      base.minute,
    );

    setState(() {
      _selectedDateTime = combined;
      _dateCtrl.text = _formatDateTime(combined);
    });
  }

  Future<void> _pickTimeOnly() async {
    final now = DateTime.now();
    final current = _selectedDateTime ?? now;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );

    if (!mounted || pickedTime == null) return;

    final base = _selectedDateTime ?? now;
    final combined = DateTime(
      base.year,
      base.month,
      base.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _selectedDateTime = combined;
      _dateCtrl.text = _formatDateTime(combined);
    });
  }

  String _formatDateBadge() {
    final value = _selectedDateTime ?? DateTime.now();
    final now = DateTime.now();

    if (value.year == now.year &&
        value.month == now.month &&
        value.day == now.day) {
      return 'Today';
    }

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

    return '${value.day} ${months[value.month - 1]}';
  }

  String _formatTimeBadge() {
    final value = _selectedDateTime ?? DateTime.now();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _submitPost() async {
    if (_isSubmitting) return;

    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _showMessage('Please enter the item name before posting.', isError: true);
      return;
    }

    final description = _descCtrl.text.trim();
    if (description.length < 10) {
      _showMessage(
        'Please add at least 10 characters in the description.',
        isError: true,
      );
      return;
    }

    if (!_useInApp && !_usePhone && !_useEmail) {
      _showMessage('Please enable at least one contact method.', isError: true);
      return;
    }

    if (_usePhone && _phoneCtrl.text.trim().isEmpty) {
      _showMessage(
        'Please enter a phone number or disable phone sharing.',
        isError: true,
      );
      return;
    }

    if (_useEmail && !_emailCtrl.text.contains('@')) {
      _showMessage(
        'Please enter a valid email or disable email sharing.',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isSubmitting = false);
      _showMessage('You must be logged in to post.', isError: true);
      return;
    }

    // Fetch owner's profile for name
    String ownerDisplayName = user.displayName ?? '';
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        ownerDisplayName = userDoc.data()?['fullName'] ?? ownerDisplayName;
      }
    } catch (_) {}
    if (ownerDisplayName.isEmpty) {
      ownerDisplayName = user.email?.split('@').first ?? 'Finder User';
    }

    final post = ItemModel(
      id: FirebaseFirestore.instance.collection('posts').doc().id,
      ownerId: user.uid,
      ownerName: ownerDisplayName,
      title: title,
      description: description,
      category: _category ?? 'Other',
      isLost: _isLostItem,
      reward: _rewardCtrl.text.trim().isEmpty ? null : _rewardCtrl.text.trim(),
      location: _locationCtrl.text.trim().isEmpty
          ? 'Unknown Location'
          : _locationCtrl.text.trim(),
      lastSeenAt: _locationCtrl.text.trim().isEmpty
          ? null
          : _locationCtrl.text.trim(),
      lostOn: _dateCtrl.text.trim().isEmpty ? null : _dateCtrl.text.trim(),
      imagePath: _imagePath,
      timeAgo: 'Just now',
    );

    try {
      await ref.read(postServiceProvider).createPost(post);
      if (!mounted) return;
      _clearDraft();
      _showMessage('Post published successfully.');
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString(), isError: true);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    setState(() => _isUploadingImage = true);
    try {
      final fileName = '${uid}_${DateTime.now().millisecondsSinceEpoch}';
      final url = await ImageUploadService.pickAndUpload(
        folder: 'posts',
        fileName: fileName,
      );
      if (url != null && mounted) {
        setState(() => _imagePath = url);
        _showMessage('Image uploaded successfully!');
      }
    } catch (e) {
      if (mounted) _showMessage('Upload failed: $e');
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _saveDraft() {
    _draftCache = {
      'isLost': _isLostItem,
      'title': _titleCtrl.text,
      'category': _category,
      'description': _descCtrl.text,
      'location': _locationCtrl.text,
      'dateTime': _selectedDateTime?.millisecondsSinceEpoch,
      'reward': _rewardCtrl.text,
      'useInApp': _useInApp,
      'usePhone': _usePhone,
      'useEmail': _useEmail,
      'phone': _phoneCtrl.text,
      'email': _emailCtrl.text,
      'publicSearch': _publicSearch,
      'hideLocation': _hideLocation,
      'imagePath': _imagePath,
    };
    _showMessage('Draft saved locally.');
  }

  void _restoreDraftIfAvailable() {
    final draft = _draftCache;
    if (draft == null) return;

    _isLostItem = draft['isLost'] as bool? ?? _isLostItem;
    _titleCtrl.text = draft['title']?.toString() ?? '';
    _category = draft['category']?.toString() ?? _category;
    _descCtrl.text = draft['description']?.toString() ?? '';
    _locationCtrl.text = draft['location']?.toString() ?? '';

    final dateMs = draft['dateTime'];
    if (dateMs is int) {
      _selectedDateTime = DateTime.fromMillisecondsSinceEpoch(dateMs);
      _dateCtrl.text = _formatDateTime(_selectedDateTime!);
    }

    _rewardCtrl.text = draft['reward']?.toString() ?? '';
    _useInApp = draft['useInApp'] as bool? ?? _useInApp;
    _usePhone = draft['usePhone'] as bool? ?? _usePhone;
    _useEmail = draft['useEmail'] as bool? ?? _useEmail;
    _phoneCtrl.text = draft['phone']?.toString() ?? '';
    _emailCtrl.text = draft['email']?.toString() ?? '';
    _publicSearch = draft['publicSearch'] as bool? ?? _publicSearch;
    _hideLocation = draft['hideLocation'] as bool? ?? _hideLocation;
    _imagePath = draft['imagePath']?.toString() ?? '';
  }

  void _clearDraft() {
    _draftCache = null;
  }

  String _formatDateTime(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    final t = AppColorTokens.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? t.error : t.success,
      ),
    );
  }
}
