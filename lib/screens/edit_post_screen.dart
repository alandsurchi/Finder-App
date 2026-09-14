import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/core/constants/app_categories.dart';
import 'package:finder/app/di/app_providers.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/features/location/place.dart';
import 'package:finder/screens/location_picker_screen.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  final ItemModel post;
  const EditPostScreen({super.key, required this.post});

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
  Place? _place;

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
    _place = p.place;
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

    final updated = widget.post.copyWith(
      title: title,
      description: desc,
      category: _category ?? 'Other',
      isLost: _isLostItem,
      location: _locationCtrl.text.trim().isEmpty
          ? 'Unknown location'
          : _locationCtrl.text.trim(),
      lostOn: _lostOnCtrl.text.trim().isEmpty ? null : _lostOnCtrl.text.trim(),
      latitude: _place?.latitude,
      longitude: _place?.longitude,
      clearCoordinates: _place == null,
      reward: _rewardCtrl.text.trim().isEmpty ? null : _rewardCtrl.text.trim(),
      clearReward: _rewardCtrl.text.trim().isEmpty,
      imagePath: _imageCtrl.text.trim(),
    );

    final result = await ref.read(myPostsProvider.notifier).updatePost(updated);
    if (!mounted) return;
    setState(() => _isSaving = false);
    result.fold(
      onSuccess: (_) {
        Navigator.pop(context, true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = Navigator.of(context, rootNavigator: true).context;
          ActionFeedback.showSuccess(ctx, 'Post updated.');
        });
      },
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  void _snack(String msg) => ActionFeedback.showError(context, msg);

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppPageHeader(
              title: 'Edit post',
              subtitle: widget.post.title,
              actions: [
                AppButton.ghost(
                  label: 'Save',
                  icon: Icons.check_rounded,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _save,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(BeaconSpace.page, 0,
                    BeaconSpace.page, BeaconSpace.huge + bottomInset + 64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Lost / Found toggle ──
                    Row(
                      children: [
                        Expanded(
                          child: LostFoundTypeTile(
                            kind: SignalKind.lost,
                            compact: true,
                            selected: _isLostItem,
                            onTap: () => setState(() => _isLostItem = true),
                          ),
                        ),
                        const SizedBox(width: BeaconSpace.md),
                        Expanded(
                          child: LostFoundTypeTile(
                            kind: SignalKind.found,
                            compact: true,
                            selected: !_isLostItem,
                            onTap: () => setState(() => _isLostItem = false),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: BeaconSpace.xxl),

                    // ── Image ──
                    const SectionHeader(title: 'Photo'),
                    _buildImagePicker(t),

                    const SizedBox(height: BeaconSpace.xxl),

                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            controller: _titleCtrl,
                            label: 'Item name',
                            required: true,
                            hint: 'e.g. Black wallet',
                            prefixIcon: Icons.label_outline_rounded,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: BeaconSpace.lg),
                          _categoryDropdown(t),
                          const SizedBox(height: BeaconSpace.lg),
                          AppTextField(
                            controller: _descCtrl,
                            label: 'Description',
                            required: true,
                            hint: 'Describe the item in detail…',
                            helper: 'At least 10 characters',
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: BeaconSpace.xxl),

                    SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          MapPreview(
                            latitude: _place?.latitude,
                            longitude: _place?.longitude,
                            height: 140,
                            label: _locationCtrl.text.trim().isEmpty
                                ? 'No location selected'
                                : _locationCtrl.text.trim(),
                            onTap: _isSaving ? null : _pickOnMap,
                          ),
                          const SizedBox(height: BeaconSpace.md),
                          AppTextField(
                            controller: _locationCtrl,
                            label: 'Location',
                            hint: 'Where was it lost or found?',
                            prefixIcon: Icons.place_outlined,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: BeaconSpace.sm),
                          AppButton.ghost(
                            label: _place == null ? 'Pick on map' : 'Move pin on map',
                            icon: Icons.map_outlined,
                            size: AppButtonSize.medium,
                            onPressed: _isSaving ? null : _pickOnMap,
                          ),
                          const SizedBox(height: BeaconSpace.lg),
                          AppTextField(
                            controller: _lostOnCtrl,
                            label: 'Date / time',
                            hint: 'Tap to pick date',
                            prefixIcon: Icons.calendar_today_outlined,
                            readOnly: true,
                            onTap: _pickDate,
                          ),
                          const SizedBox(height: BeaconSpace.lg),
                          AppTextField(
                            controller: _rewardCtrl,
                            label: 'Reward (optional)',
                            hint: 'e.g. 50',
                            prefixIcon: Icons.workspace_premium_outlined,
                            keyboardType: TextInputType.number,
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              BeaconSpace.page, BeaconSpace.sm, BeaconSpace.page, BeaconSpace.lg),
          child: AppButton(
            label: 'Save changes',
            icon: Icons.check_rounded,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _save,
          ),
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _categoryDropdown(AppColorTokens t) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: text.titleSmall),
        const SizedBox(height: BeaconSpace.sm),
        DropdownButtonFormField<String>(
          initialValue: _category,
          isExpanded: true,
          dropdownColor: t.surface,
          borderRadius: BeaconRadius.rLg,
          icon: Icon(Icons.expand_more_rounded, color: t.onSurfaceVar),
          style: text.bodyLarge,
          decoration: InputDecoration(
            prefixIcon: Icon(categoryIcon(_category ?? ''), size: BeaconIcon.md),
          ),
          onChanged: (v) {
            if (v != null) setState(() => _category = v);
          },
          items: _categories
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c, style: text.bodyLarge),
                  ))
              .toList(),
        ),
      ],
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
        '${combined.year}-${combined.month.toString().padLeft(2, '0')}-${combined.day.toString().padLeft(2, '0')} '
        '${combined.hour.toString().padLeft(2, '0')}:'
        '${combined.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickOnMap() async {
    final picked = await LocationPickerScreen.pick(context, initial: _place);
    if (!mounted || picked == null) return;
    setState(() {
      _place = picked;
      _locationCtrl.text = picked.label;
    });
  }

  Widget _buildImagePicker(AppColorTokens t) {
    final url = _imageCtrl.text.trim();
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: url.isEmpty ? 'Add a photo' : 'Change photo',
      child: PressScale(
        enabled: !_isUploadingImage,
        scale: 0.985,
        child: Material(
          color: t.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BeaconRadius.rXl,
            side: BorderSide(
              color: url.isNotEmpty ? t.primary.withValues(alpha: 0.4) : t.outlineVariant,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _isUploadingImage ? null : _pickAndUploadImage,
            child: SizedBox(
              height: 168,
              child: _isUploadingImage
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: t.primary),
                          ),
                          const SizedBox(height: BeaconSpace.sm),
                          Text('Uploading image…', style: text.bodySmall),
                        ],
                      ),
                    )
                  : url.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ItemImage(url: url, height: 168),
                            Positioned(
                              top: BeaconSpace.sm,
                              right: BeaconSpace.sm,
                              child: AppIconButton(
                                icon: Icons.close_rounded,
                                tooltip: 'Remove photo',
                                size: 36,
                                iconSize: 18,
                                variant: AppIconButtonVariant.filled,
                                background: t.error,
                                color: t.onError,
                                onPressed: () => setState(() => _imageCtrl.text = ''),
                              ),
                            ),
                            Positioned(
                              bottom: BeaconSpace.sm,
                              right: BeaconSpace.sm,
                              child: StatusBadge.neutral('Tap to change',
                                  icon: Icons.edit_outlined, small: true),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: t.primary, size: 32),
                            const SizedBox(height: BeaconSpace.sm),
                            Text('Tap to pick from gallery', style: text.bodyMedium),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final uid = ref.read(authStateProvider).userId ?? 'anon';
    setState(() => _isUploadingImage = true);
    try {
      final fileName = '${uid}_${DateTime.now().millisecondsSinceEpoch}';
      final url = await ref.read(imageUploadServiceProvider).pickAndUpload(
        folder: 'posts',
        fileName: fileName,
      );
      if (url != null && mounted) {
        setState(() => _imageCtrl.text = url);
      }
    } catch (e) {
      if (mounted) ActionFeedback.showError(context, 'Upload failed. $e');
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

}
