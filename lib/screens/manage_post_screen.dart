import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finder/core/constants/app_categories.dart';
import 'package:finder/widgets/ui/ui.dart';

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
  const ManagePostScreen({super.key, this.post});

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

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final post = widget.post;
    final isLost = post?.isLost ?? true;
    final imageUrl = post?.imagePath ?? '';
    final kind = isLost ? SignalKind.lost : SignalKind.found;

    return Scaffold(
      bottomNavigationBar: _buildSaveBar(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppPageHeader(
              title: 'Manage post',
              subtitle: _hasChanges ? 'Unsaved changes' : null,
              actions: [
                AppButton.ghost(
                  label: 'Discard',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    BeaconSpace.page, 0, BeaconSpace.page, BeaconSpace.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Hero image ───────────────────────────────────────
                    Stack(
                      children: [
                        ItemImage(
                          url: imageUrl,
                          height: 220,
                          borderRadius: BeaconRadius.rXl,
                          fallbackIcon: categoryIcon(_category),
                        ),
                        Positioned(
                          top: BeaconSpace.md,
                          left: BeaconSpace.md,
                          child: StatusBadge.signal(kind),
                        ),
                        Positioned(
                          bottom: BeaconSpace.md,
                          right: BeaconSpace.md,
                          child: AppButton.tonal(
                            label: 'Change photo',
                            icon: Icons.camera_alt_outlined,
                            size: AppButtonSize.small,
                            expand: false,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Photo picker is not connected yet. Please update this post image from the media step.',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: BeaconSpace.xl),

                    // ── Status ────────────────────────────────────────────
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('STATUS',
                              style: text.labelSmall?.copyWith(color: t.onSurfaceMuted)),
                          const SizedBox(height: BeaconSpace.xs),
                          Row(
                            children: [
                              Icon(
                                _isActive
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.verified_rounded,
                                color: _isActive ? t.primary : t.found,
                                size: 20,
                              ),
                              const SizedBox(width: BeaconSpace.sm),
                              Text(
                                _isActive ? 'Active' : 'Resolved',
                                style: text.headlineSmall?.copyWith(
                                  color: _isActive ? t.primary : t.found,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: BeaconSpace.lg),
                          AppButton(
                            label: _isActive ? 'Mark as resolved' : 'Reactivate post',
                            icon: _isActive
                                ? Icons.check_circle_outline_rounded
                                : Icons.refresh_rounded,
                            variant: _isActive
                                ? AppButtonVariant.primary
                                : AppButtonVariant.tonal,
                            size: AppButtonSize.medium,
                            onPressed: () => setState(() => _isActive = !_isActive),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: BeaconSpace.md),

                    // ── Stats row ─────────────────────────────────────────
                    Row(
                      children: [
                        _StatCard(
                          icon: Icons.visibility_outlined,
                          iconColor: t.primary,
                          value: '1.2k',
                          label: 'Views',
                        ),
                        const SizedBox(width: BeaconSpace.md),
                        _StatCard(
                          icon: Icons.bookmark_outline_rounded,
                          iconColor: t.accent,
                          value: '48',
                          label: 'Saves',
                        ),
                      ],
                    ),

                    const SizedBox(height: BeaconSpace.xxl),

                    // ── General Details ───────────────────────────────────
                    const SectionHeader(title: 'General details'),
                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            controller: _nameCtrl,
                            label: 'Item name',
                            prefixIcon: Icons.label_outline_rounded,
                            onChanged: (_) => _markChanged(),
                          ),
                          const SizedBox(height: BeaconSpace.lg),
                          _dropdownField(
                            label: 'Category',
                            value: _category,
                            items: _categories,
                            icon: categoryIcon(_category),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _category = v);
                                _markChanged();
                              }
                            },
                          ),
                          const SizedBox(height: BeaconSpace.lg),
                          _dropdownField(
                            label: 'Visibility',
                            value: _visibility,
                            items: _visibilities,
                            icon: Icons.lock_outline_rounded,
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _visibility = v);
                                _markChanged();
                              }
                            },
                          ),
                          const SizedBox(height: BeaconSpace.lg),
                          AppTextField(
                            controller: _descCtrl,
                            label: 'Description',
                            hint: 'Describe the item',
                            maxLines: 5,
                            onChanged: (_) => _markChanged(),
                          ),
                          const SizedBox(height: BeaconSpace.lg),
                          AppTextField(
                            controller: _locationCtrl,
                            label: 'Last seen location',
                            hint: 'City, street or area',
                            prefixIcon: Icons.place_outlined,
                            onChanged: (_) => _markChanged(),
                          ),
                          const SizedBox(height: BeaconSpace.md),
                          MapPlaceholder(
                            height: 120,
                            label: _locationCtrl.text.trim().isEmpty
                                ? null
                                : _locationCtrl.text.trim(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: BeaconSpace.xxl),

                    // ── Incentive section ─────────────────────────────────
                    const SectionHeader(title: 'Incentive'),
                    SurfaceCard(
                      padding: const EdgeInsets.symmetric(vertical: BeaconSpace.xs),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ToggleTile(
                            icon: Icons.workspace_premium_outlined,
                            title: 'Reward offered',
                            subtitle: 'Encourages safe returns',
                            value: _rewardOn,
                            onChanged: (v) {
                              setState(() => _rewardOn = v);
                              _markChanged();
                            },
                          ),
                          if (_rewardOn)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  BeaconSpace.lg, BeaconSpace.sm, BeaconSpace.lg, BeaconSpace.md),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      controller: _amountCtrl,
                                      label: 'Amount (\$)',
                                      hint: '0',
                                      prefixIcon: Icons.attach_money_rounded,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (_) => _markChanged(),
                                    ),
                                  ),
                                  const SizedBox(width: BeaconSpace.md),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: MergeSemantics(
                                      child: InkWell(
                                        borderRadius: BeaconRadius.rMd,
                                        onTap: () {
                                          setState(() => _negotiable = !_negotiable);
                                          _markChanged();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: BeaconSpace.sm),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Checkbox(
                                                value: _negotiable,
                                                onChanged: (v) {
                                                  setState(() => _negotiable = v ?? false);
                                                  _markChanged();
                                                },
                                              ),
                                              Text('Negotiable', style: text.bodyMedium),
                                              const SizedBox(width: BeaconSpace.sm),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: BeaconSpace.xxl),

                    // ── Danger Zone ───────────────────────────────────────
                    SurfaceCard(
                      tone: SurfaceTone.error,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Danger zone',
                              style: text.titleMedium?.copyWith(color: t.error)),
                          const SizedBox(height: BeaconSpace.sm),
                          Text(
                            'Deleting this post permanently removes all data, photos and messages associated with it. This cannot be undone.',
                            style: text.bodySmall,
                          ),
                          const SizedBox(height: BeaconSpace.lg),
                          AppButton.danger(
                            label: 'Delete this post',
                            icon: Icons.delete_outline_rounded,
                            size: AppButtonSize.medium,
                            onPressed: () => _confirmDelete(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Save bar ────────────────────────────────────────────────────────────────
  Widget _buildSaveBar(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              BeaconSpace.page, BeaconSpace.md, BeaconSpace.page, BeaconSpace.lg),
          child: AppButton(
            label: 'Save changes',
            icon: Icons.check_rounded,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Changes saved successfully'),
                ),
              );
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  // ── Delete confirmation dialog ───────────────────────────────────────────────
  void _confirmDelete(BuildContext context) {
    final t = AppColorTokens.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text(
          'This will permanently remove the post and all associated data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: t.error,
              foregroundColor: t.onError,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.titleSmall),
        const SizedBox(height: BeaconSpace.sm),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          dropdownColor: t.surface,
          borderRadius: BeaconRadius.rLg,
          icon: Icon(Icons.expand_more_rounded, color: t.onSurfaceVar),
          style: text.bodyLarge,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, size: BeaconIcon.md) : null,
          ),
          onChanged: onChanged,
          items: items
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, style: text.bodyLarge),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

// ─── Stat card ────────────────────────────────────────────────────────────────
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
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: SurfaceCard(
        padding: const EdgeInsets.all(BeaconSpace.lg),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: t.isDark ? 0.18 : 0.12),
                borderRadius: BeaconRadius.rMd,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: BeaconSpace.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: text.titleLarge),
                Text(label.toUpperCase(),
                    style: text.labelSmall?.copyWith(color: t.onSurfaceMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
