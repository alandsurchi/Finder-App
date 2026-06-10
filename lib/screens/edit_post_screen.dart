import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/core/constants/app_categories.dart';
import 'package:finder/services/image_upload_service.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  final ItemModel post;
  const EditPostScreen({Key? key, required this.post}) : super(key: key);

  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  static const _categories = AppCategories.postCategories;

  late bool _isLostItem;
  late String? _category;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _lostOnCtrl;
  late final TextEditingController _rewardCtrl;
  late final TextEditingController _imageCtrl;

  bool _isSaving = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    final p = widget.post;
    _isLostItem = p.isLost;
    _category =
        _categories.contains(p.category) ? p.category : _categories.last;
    _titleCtrl = TextEditingController(text: p.title);
    _descCtrl = TextEditingController(text: p.description);
    _locationCtrl = TextEditingController(text: p.location);
    _lostOnCtrl = TextEditingController(text: p.lostOn ?? '');
    _rewardCtrl = TextEditingController(text: p.reward ?? '');
    _imageCtrl = TextEditingController(text: p.imagePath);
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl,
      _descCtrl,
      _locationCtrl,
      _lostOnCtrl,
      _rewardCtrl,
      _imageCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _snack('Please enter a title.');
      return;
    }
    final desc = _descCtrl.text.trim();
    if (desc.length < 10) {
      _snack('Description must be at least 10 characters.');
      return;
    }

    setState(() => _isSaving = true);

    final updated = ItemModel(
      id: widget.post.id,
      ownerId: widget.post.ownerId,
      ownerName: widget.post.ownerName,
      title: title,
      description: desc,
      category: _category ?? 'Other',
      isLost: _isLostItem,
      location:
          _locationCtrl.text.trim().isEmpty ? 'Unknown' : _locationCtrl.text.trim(),
      lastSeenAt: _locationCtrl.text.trim().isEmpty
          ? widget.post.lastSeenAt
          : _locationCtrl.text.trim(),
      lostOn:
          _lostOnCtrl.text.trim().isEmpty ? null : _lostOnCtrl.text.trim(),
      reward: _rewardCtrl.text.trim().isEmpty ? null : _rewardCtrl.text.trim(),
      imagePath: _imageCtrl.text.trim(),
      timeAgo: widget.post.timeAgo,
      createdAt: widget.post.createdAt,
      isVerified: widget.post.isVerified,
      ownerTrustScore: widget.post.ownerTrustScore,
      isResolved: widget.post.isResolved,
    );

    await ref.read(myPostsProvider.notifier).updatePost(updated);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post updated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true); // return true = refresh needed
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Post',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Save',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Lost / Found toggle ──
            _sectionLabel('Post Type', t),
            Row(
              children: [
                Expanded(
                  child: _typeTile(
                    selected: _isLostItem,
                    icon: Icons.search_rounded,
                    label: 'Lost Item',
                    onTap: () => setState(() => _isLostItem = true),
                    t: t,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _typeTile(
                    selected: !_isLostItem,
                    icon: Icons.back_hand_rounded,
                    label: 'Found Item',
                    onTap: () => setState(() => _isLostItem = false),
                    t: t,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Image ──
            _sectionLabel('Photo', t),
            _buildImagePicker(t),

            const SizedBox(height: 16),

            // ── Title ──
            _sectionLabel('Item Name *', t),
            _field(_titleCtrl, 'e.g. Black wallet', Icons.label_outline, t),

            const SizedBox(height: 16),

            // ── Category ──
            _sectionLabel('Category', t),
            _categoryDropdown(t),

            const SizedBox(height: 16),

            // ── Description ──
            _sectionLabel('Description *', t),
            _field(_descCtrl, 'Describe the item in detail…',
                Icons.description_outlined, t,
                maxLines: 4),

            const SizedBox(height: 16),

            // ── Location ──
            _sectionLabel('Location', t),
            _field(_locationCtrl, 'Where was it lost/found?',
                Icons.location_on_outlined, t),

            const SizedBox(height: 16),

            // ── Date ──
            _sectionLabel('Date / Time', t),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: _field(_lostOnCtrl,
                    'Tap to pick date', Icons.calendar_today_outlined, t),
              ),
            ),

            const SizedBox(height: 16),

            // ── Reward ──
            _sectionLabel('Reward (optional)', t),
            _field(_rewardCtrl, 'e.g. 50', Icons.monetization_on_outlined, t,
                keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, AppColorTokens t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    AppColorTokens t, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.divider),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: t.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              TextStyle(color: t.onSurfaceMuted, fontSize: 14),
          prefixIcon:
              Icon(icon, color: t.onSurfaceMuted, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _categoryDropdown(AppColorTokens t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _category,
          isExpanded: true,
          dropdownColor: t.surface,
          icon: Icon(Icons.expand_more, color: t.onSurfaceMuted),
          style: TextStyle(color: t.onSurface, fontSize: 14),
          onChanged: (v) {
            if (v != null) setState(() => _category = v);
          },
          items: _categories
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c,
                        style: TextStyle(color: t.onSurface)),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _typeTile({
    required bool selected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppColorTokens t,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF123D73).withOpacity(0.65)
              : t.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF2D8CFF)
                : t.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: selected
                    ? const Color(0xFF2D8CFF)
                    : t.onSurfaceMuted,
                size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF2D8CFF)
                    : t.onSurfaceMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (!mounted || picked == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (!mounted) return;
    final combined = time == null
        ? picked
        : DateTime(
            picked.year, picked.month, picked.day, time.hour, time.minute);
    _lostOnCtrl.text =
        '${combined.day}/${combined.month}/${combined.year} '
        '${combined.hour.toString().padLeft(2, '0')}:'
        '${combined.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildImagePicker(AppColorTokens t) {
    final url = _imageCtrl.text.trim();
    return GestureDetector(
      onTap: _isUploadingImage ? null : _pickAndUploadImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 130,
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: url.isNotEmpty ? t.primary.withOpacity(0.4) : t.divider,
          ),
        ),
        child: _isUploadingImage
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(strokeWidth: 2),
                    SizedBox(height: 8),
                    Text('Uploading image...',
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
              )
            : url.isNotEmpty
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(Icons.broken_image_outlined,
                                color: t.onSurfaceMuted, size: 36),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _imageCtrl.text = ''),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD83838),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Tap to change',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 11)),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          color: t.onSurfaceMuted, size: 36),
                      const SizedBox(height: 8),
                      Text('Tap to pick from gallery',
                          style: TextStyle(
                              color: t.onSurfaceMuted, fontSize: 13)),
                    ],
                  ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final uid = ref.read(authStateProvider).userId ?? 'anon';
    setState(() => _isUploadingImage = true);
    try {
      final fileName = '${uid}_${DateTime.now().millisecondsSinceEpoch}';
      final url = await ImageUploadService.pickAndUpload(
        folder: 'posts',
        fileName: fileName,
      );
      if (url != null && mounted) {
        setState(() => _imageCtrl.text = url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: $e'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

}
