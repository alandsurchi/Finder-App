import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/core/constants/app_categories.dart';

// ─── Post data passed from My Posts ──────────────────────────────────────────
class ManagePostData {
  final String title;
  final String imagePath; // network URL
  final bool isLost;

  const ManagePostData({
    required this.title,
    required this.imagePath,
    required this.isLost,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class ManagePostScreen extends StatefulWidget {
  final ManagePostData? post;
  const ManagePostScreen({Key? key, this.post}) : super(key: key);

  @override
  State<ManagePostScreen> createState() => _ManagePostScreenState();
}

class _ManagePostScreenState extends State<ManagePostScreen> {
  // ── Controllers ─────────────────────────────────────────────────────────────
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _amountCtrl;

  // ── State ────────────────────────────────────────────────────────────────────
  String _category = AppCategories.postCategories.first;
  String _visibility = 'Public';
  bool _isActive = true;
  bool _rewardOn = true;
  bool _negotiable = true;
  bool _hasChanges = false;

  final List<String> _categories = AppCategories.postCategories;
  final List<String> _visibilities = AppCategories.managePostVisibilities;

  @override
  void initState() {
    super.initState();
    final p = widget.post;
    _nameCtrl = TextEditingController(text: p?.title ?? '');
    _descCtrl = TextEditingController(text: '');
    _locationCtrl = TextEditingController(text: '');
    _amountCtrl = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _markChanged() => setState(() => _hasChanges = true);

  AppColorTokens get t => AppColorTokens.of(context);
  Color get _bg => t.bg;
  Color get _textDark => t.onSurface;
  Color get _textLight => t.onSurfaceMuted;
  Color get _textMid => t.onSurfaceVar;
  Color get _red => t.error;
  Color get _redLight => t.errorSurface;
  Color get _orange => t.warning;
  Color get _blue => t.primary;
  Color get _green => t.success;
  Color get _white => t.surface;
  Color get _divider => t.divider;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isLost = post?.isLost ?? true;
    final imageUrl = post?.imagePath ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: _buildSaveBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _textDark,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Manage Post',
                        style: TextStyle(
                          color: _textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Discard',
                        style: TextStyle(
                          color: _red,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Hero image ─────────────────────────────────────────────────
              Stack(
                children: [
                  // Photo
                  SizedBox(
                    width: double.infinity,
                    height: 220,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: const Color(0xFF1E293B),
                        child: const Icon(
                          Icons.pets,
                          color: Colors.white24,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                  // LOST / FOUND badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isLost ? _orange : _blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isLost ? 'LOST' : 'FOUND',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Change Photo button
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Photo picker is not connected yet. Please update this post image from the media step.',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Change Photo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Status ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STATUS',
                        style: TextStyle(
                          color: _textLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isActive ? 'Active' : 'Resolved',
                        style: TextStyle(
                          color: _isActive ? _blue : _green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Mark as Resolved button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isActive ? _blue : _green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () =>
                              setState(() => _isActive = !_isActive),
                          icon: Icon(
                            _isActive
                                ? Icons.check_circle_outline
                                : Icons.refresh_rounded,
                            size: 18,
                          ),
                          label: Text(
                            _isActive ? 'Mark as Resolved' : 'Reactivate Post',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Stats row ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _StatCard(
                      icon: Icons.visibility_outlined,
                      iconColor: _blue,
                      value: '1.2k',
                      label: 'VIEWS',
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      icon: Icons.bookmark_outlined,
                      iconColor: _orange,
                      value: '48',
                      label: 'SAVES',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ── General Details ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'General Details',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Item name
                    _buildField(
                      label: 'ITEM NAME',
                      child: _inputField(
                        controller: _nameCtrl,
                        onChanged: (_) => _markChanged(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Category
                    _buildField(
                      label: 'CATEGORY',
                      child: _dropdownField(
                        value: _category,
                        items: _categories,
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _category = v);
                            _markChanged();
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Visibility
                    _buildField(
                      label: 'VISIBILITY',
                      child: _dropdownField(
                        value: _visibility,
                        items: _visibilities,
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _visibility = v);
                            _markChanged();
                          }
                        },
                        suffixIcon: Icons.lock_outline,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description
                    _buildField(
                      label: 'DESCRIPTION',
                      child: Container(
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _divider),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: TextField(
                          controller: _descCtrl,
                          onChanged: (_) => _markChanged(),
                          maxLines: 5,
                          style: TextStyle(
                            color: _textDark,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Last seen location
                    _buildField(
                      label: 'LAST SEEN LOCATION',
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: _bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _divider),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: _blue,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _locationCtrl,
                                onChanged: (_) => _markChanged(),
                                style: TextStyle(
                                  color: _textDark,
                                  fontSize: 14,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Map placeholder
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        color: const Color(0xFFD1E8D0),
                        child: CustomPaint(painter: _MapPainter()),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Incentive section ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Incentive',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reward Offered toggle
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _orange.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.emoji_events_outlined,
                              color: _orange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reward Offered',
                                  style: TextStyle(
                                    color: _textDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Encourages safe returns',
                                  style: TextStyle(
                                    color: _textLight,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _rewardOn,
                            onChanged: (v) {
                              setState(() => _rewardOn = v);
                              _markChanged();
                            },
                            activeColor: _orange,
                          ),
                        ],
                      ),

                      if (_rewardOn) ...[
                        const SizedBox(height: 16),
                        Text(
                          'AMOUNT (\$)',
                          style: TextStyle(
                            color: _textLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Amount field
                            Expanded(
                              child: Container(
                                height: 46,
                                decoration: BoxDecoration(
                                  color: _bg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _divider),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                child: TextField(
                                  controller: _amountCtrl,
                                  onChanged: (_) => _markChanged(),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  style: TextStyle(
                                    color: _textDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Negotiable checkbox
                            GestureDetector(
                              onTap: () {
                                setState(() => _negotiable = !_negotiable);
                                _markChanged();
                              },
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _negotiable ? _blue : _white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: _negotiable ? _blue : _divider,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: _negotiable
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 13,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Negotiable',
                                    style: TextStyle(
                                      color: _textMid,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Danger Zone ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _redLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _red.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danger Zone',
                        style: TextStyle(
                          color: _red,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Deleting this post will permanently remove all data, photos, and messages associated with it. This action cannot be undone.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _red,
                            side: BorderSide(color: _red, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _confirmDelete(context),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text(
                            'Delete This Post',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Save bar ────────────────────────────────────────────────────────────────
  Widget _buildSaveBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Changes saved successfully'),
                backgroundColor: _blue,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.pop(context);
          },
          child: const Text(
            'Save Changes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  // ── Delete confirmation dialog ───────────────────────────────────────────────
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Post?',
          style: TextStyle(fontWeight: FontWeight.bold, color: _textDark),
        ),
        content: Text(
          'This will permanently remove the post and all associated data. This action cannot be undone.',
          style: TextStyle(color: _textMid, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: _textMid)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _buildField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _textDark,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: _textDark, fontSize: 14),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? suffixIcon,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: value,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
              underline: const SizedBox(),
              style: TextStyle(color: _textDark, fontSize: 14),
              isExpanded: true,
              icon: suffixIcon != null
                  ? Icon(suffixIcon, color: _textLight, size: 18)
                  : Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _textLight,
                      size: 22,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats card ───────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: t.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: t.onSurfaceMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Map placeholder painter ──────────────────────────────────────────────────
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFF9EC89A).withOpacity(0.5)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Horizontal road
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      linePaint,
    );

    // Diagonal road
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.7, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.7, size.height),
      linePaint,
    );

    // Vertical road
    canvas.drawLine(
      Offset(size.width * 0.75, 0),
      Offset(size.width * 0.75, size.height),
      roadPaint,
    );

    // Location pin
    final pinX = size.width * 0.48;
    final pinY = size.height * 0.35;
    final pinPaint = Paint()..color = const Color(0xFF2563EB);
    canvas.drawCircle(Offset(pinX, pinY - 8), 10, pinPaint);
    final path = Path()
      ..moveTo(pinX - 6, pinY - 4)
      ..lineTo(pinX + 6, pinY - 4)
      ..lineTo(pinX, pinY + 6)
      ..close();
    canvas.drawPath(path, pinPaint);
    // Center white dot
    canvas.drawCircle(Offset(pinX, pinY - 9), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
