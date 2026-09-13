import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/routes.dart';
import 'package:finder/providers/post_provider.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/app/di/app_providers.dart' hide postServiceProvider;
import 'package:finder/models/item_model.dart';
import 'package:finder/core/constants/app_categories.dart';
import 'package:finder/services/image_upload_service.dart';
import 'package:finder/widgets/custom_bottom_nav_bar.dart';
import 'package:finder/widgets/ui/ui.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

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

  // ── Completion (title, category, description, location, photo) ───────────
  int get _completedSteps {
    var n = 0;
    if (_titleCtrl.text.trim().isNotEmpty) n++;
    if ((_category ?? '').isNotEmpty) n++;
    if (_descCtrl.text.trim().length >= 10) n++;
    if (_locationCtrl.text.trim().isNotEmpty) n++;
    if (_imagePath.isNotEmpty) n++;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final navClearance = CustomBottomNavBar.totalHeight(context) + BeaconSpace.lg;

    return Scaffold(
      body: BeaconBackdrop(
        alignment: const Alignment(1.3, -1.2),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                BeaconSpace.page, BeaconSpace.md, BeaconSpace.page, navClearance),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StaggeredEntrance(child: _buildHeader(t)),
                const SizedBox(height: BeaconSpace.xl),
                StaggeredEntrance(index: 1, child: _buildTypeSelector()),
                const SizedBox(height: BeaconSpace.xxl),
                StaggeredEntrance(index: 2, child: _buildPhotoSection(t)),
                const SizedBox(height: BeaconSpace.xxl),
                StaggeredEntrance(index: 3, child: _buildItemInfoCard(t)),
                const SizedBox(height: BeaconSpace.xxl),
                StaggeredEntrance(index: 4, child: _buildLocationTimeSection(t)),
                const SizedBox(height: BeaconSpace.xxl),
                StaggeredEntrance(index: 5, child: _buildPrivacyContactSection(t)),
                const SizedBox(height: BeaconSpace.xxl),
                StaggeredEntrance(index: 6, child: _buildActionButtons(t)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColorTokens t) {
    final text = Theme.of(context).textTheme;
    final done = _completedSteps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('New post', style: text.headlineMedium),
        const SizedBox(height: BeaconSpace.xs),
        Text(
          _isLostItem
              ? 'Tell the community what you lost.'
              : 'Help return what you found.',
          style: text.bodyMedium,
        ),
        const SizedBox(height: BeaconSpace.lg),
        ClipRRect(
          borderRadius: BeaconRadius.rPill,
          child: LinearProgressIndicator(
            value: done / 5,
            minHeight: 6,
            color: done == 5 ? t.found : t.accent,
          ),
        ),
        const SizedBox(height: BeaconSpace.sm),
        Text(
          done == 5 ? 'Ready to post' : '$done of 5 details added',
          style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: LostFoundTypeTile(
            kind: SignalKind.lost,
            selected: _isLostItem,
            onTap: () => setState(() => _isLostItem = true),
          ),
        ),
        const SizedBox(width: BeaconSpace.md),
        Expanded(
          child: LostFoundTypeTile(
            kind: SignalKind.found,
            selected: !_isLostItem,
            onTap: () => setState(() => _isLostItem = false),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(AppColorTokens t) {
    final busy = _isSubmitting || _isUploadingImage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Photos',
          eyebrow: 'Step 1',
        ),
        Text(
          'Clear photos help others identify the item.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: BeaconSpace.md),
        Row(
          children: [
            _MediaTile(
              icon: Icons.photo_camera_outlined,
              label: 'Camera',
              onTap: busy ? null : _pickAndUploadImage,
            ),
            const SizedBox(width: BeaconSpace.md),
            _MediaTile(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              onTap: busy ? null : _pickAndUploadImage,
            ),
            const SizedBox(width: BeaconSpace.md),
            if (_isUploadingImage)
              _MediaTile.loading()
            else if (_imagePath.isNotEmpty)
              _buildSelectedImageTile(t),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedImageTile(AppColorTokens t) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ItemImage(
          url: _imagePath,
          width: 92,
          height: 92,
          borderRadius: BeaconRadius.rLg,
        ),
        Positioned(
          right: -8,
          top: -8,
          child: AppIconButton(
            icon: Icons.close_rounded,
            tooltip: 'Remove photo',
            size: 28,
            iconSize: 16,
            variant: AppIconButtonVariant.filled,
            background: t.error,
            color: t.onError,
            onPressed: _isSubmitting
                ? null
                : () => setState(() {
                      _imagePath = '';
                    }),
          ),
        ),
      ],
    );
  }

  Widget _buildItemInfoCard(AppColorTokens t) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Item details', eyebrow: 'Step 2'),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _titleCtrl,
                label: 'Item name',
                required: true,
                hint: 'e.g. Blue backpack',
                prefixIcon: Icons.label_outline_rounded,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: BeaconSpace.lg),
              AppPickerField(
                label: 'Category',
                value: _category ?? '',
                hint: 'Choose a category',
                prefixIcon: categoryIcon(_category ?? ''),
                onTap: _isSubmitting ? null : _showCategoryPicker,
              ),
              const SizedBox(height: BeaconSpace.md),
              _buildCategoryGrid(t),
              const SizedBox(height: BeaconSpace.lg),
              AppTextField(
                controller: _descCtrl,
                label: 'Description',
                required: true,
                hint:
                    'e.g. Last seen near the fountain at Central Park. It has a small scratch on the front…',
                helper: '${_descCtrl.text.length}/500 · at least 10 characters',
                maxLines: 4,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
              ),
              if (_isLostItem) ...[
                const SizedBox(height: BeaconSpace.lg),
                AppTextField(
                  controller: _rewardCtrl,
                  label: 'Reward (optional)',
                  hint: r'e.g. $100',
                  prefixIcon: Icons.workspace_premium_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: BeaconSpace.sm),
                Text(
                  'A reward is shown as an amber tag on your post.',
                  style: text.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(AppColorTokens t) {
    return Wrap(
      spacing: BeaconSpace.sm,
      runSpacing: BeaconSpace.sm,
      children: _categories.map((category) {
        final isSelected = _category == category;
        return AppChoiceChip(
          label: category,
          icon: categoryIcon(category),
          selected: isSelected,
          onTap: _isSubmitting
              ? null
              : () => setState(() {
                    _category = category;
                  }),
        );
      }).toList(),
    );
  }

  Widget _buildLocationTimeSection(AppColorTokens t) {
    final location = _locationCtrl.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Location & time', eyebrow: 'Step 3'),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(BeaconSpace.sm),
                child: MapPlaceholder(
                  height: 140,
                  label: location.isEmpty ? 'No location selected' : location,
                  onTap: _isSubmitting ? null : _enterLocationManually,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    BeaconSpace.lg, BeaconSpace.sm, BeaconSpace.lg, BeaconSpace.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppButton.tonal(
                            label: 'Use current location',
                            icon: Icons.my_location_rounded,
                            size: AppButtonSize.medium,
                            onPressed: _isSubmitting ? null : _useCurrentLocationNow,
                          ),
                        ),
                        const SizedBox(width: BeaconSpace.sm),
                        AppButton.ghost(
                          label: 'Enter manually',
                          icon: Icons.edit_location_alt_outlined,
                          onPressed: _isSubmitting ? null : _enterLocationManually,
                        ),
                      ],
                    ),
                    const SizedBox(height: BeaconSpace.lg),
                    Row(
                      children: [
                        Expanded(
                          child: AppPickerField(
                            label: 'Date',
                            value: _formatDateBadge(),
                            prefixIcon: Icons.calendar_today_outlined,
                            onTap: _isSubmitting ? null : _pickDateOnly,
                          ),
                        ),
                        const SizedBox(width: BeaconSpace.md),
                        Expanded(
                          child: AppPickerField(
                            label: 'Time',
                            value: _formatTimeBadge(),
                            prefixIcon: Icons.schedule_rounded,
                            onTap: _isSubmitting ? null : _pickTimeOnly,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyContactSection(AppColorTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Privacy & contact', eyebrow: 'Step 4'),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _phoneCtrl,
                label: 'Phone number',
                hint: 'e.g. +1 234 567 8900',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: BeaconSpace.lg),
              AppTextField(
                controller: _emailCtrl,
                label: 'Email address',
                hint: 'e.g. yourname@example.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: BeaconSpace.lg),
              SurfaceCard(
                tone: SurfaceTone.low,
                padding: const EdgeInsets.symmetric(vertical: BeaconSpace.xs),
                child: Column(
                  children: [
                    ToggleTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'In-app chat',
                      subtitle: 'Recommended',
                      value: _useInApp,
                      onChanged: _isSubmitting ? null : (v) => setState(() => _useInApp = v),
                    ),
                    ToggleTile(
                      icon: Icons.visibility_off_outlined,
                      title: 'Hide exact location',
                      subtitle: 'Shows a general area only',
                      value: _hideLocation,
                      onChanged: _isSubmitting ? null : (v) => setState(() => _hideLocation = v),
                    ),
                    ToggleTile(
                      icon: Icons.phone_outlined,
                      title: 'Show phone number publicly',
                      subtitle: 'Visible to all registered users',
                      value: _usePhone,
                      onChanged: _isSubmitting ? null : (v) => setState(() => _usePhone = v),
                    ),
                    ToggleTile(
                      icon: Icons.mail_outline_rounded,
                      title: 'Show email publicly',
                      subtitle: 'Visible to all registered users',
                      value: _useEmail,
                      onChanged: _isSubmitting ? null : (v) => setState(() => _useEmail = v),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppColorTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: 'Post now',
          icon: Icons.send_rounded,
          iconTrailing: true,
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _submitPost,
        ),
        const SizedBox(height: BeaconSpace.sm),
        Center(
          child: AppButton.ghost(
            label: 'Save draft',
            icon: Icons.save_outlined,
            onPressed: _isSubmitting ? null : _saveDraft,
          ),
        ),
      ],
    );
  }

  Future<void> _showCategoryPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return AppBottomSheet(
          title: 'Choose category',
          child: Column(
            children: [
              ..._categories.map(
                (c) => SheetOption(
                  label: c,
                  icon: categoryIcon(c),
                  selected: _category == c,
                  onTap: () => Navigator.pop(context, c),
                ),
              ),
              const SizedBox(height: BeaconSpace.sm),
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
          content: AppTextField(
            controller: localCtrl,
            hint: 'City, street or area',
            prefixIcon: Icons.place_outlined,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (v) => Navigator.pop(context, v.trim()),
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

    final uid = ref.read(authStateProvider).userId;
    if (uid == null) {
      if (mounted) setState(() => _isSubmitting = false);
      _showMessage('You must be logged in to post.', isError: true);
      return;
    }

    // Fetch owner's profile for name
    String ownerDisplayName = 'Finder User';
    try {
      final profileRes = await ref.read(profileRepositoryProvider).getProfile();
      profileRes.fold(
        onSuccess: (profile) {
          ownerDisplayName = profile.fullName.isNotEmpty ? profile.fullName : profile.nickName;
        },
        onFailure: (_) {},
      );
    } catch (_) {}

    final post = ItemModel(
      id: '',
      ownerId: uid,
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
    final uid = ref.read(authStateProvider).userId ?? 'anon';
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

// ── Media tile (camera / gallery / uploading) ────────────────────────────────
class _MediaTile extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback? onTap;
  final bool loading;

  const _MediaTile({required this.icon, required this.label, required this.onTap})
      : loading = false;

  const _MediaTile.loading()
      : icon = null,
        label = null,
        onTap = null,
        loading = true;

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: !loading,
      label: loading ? 'Uploading photo' : 'Add photo from ${label!.toLowerCase()}',
      child: PressScale(
        enabled: onTap != null,
        child: Material(
          color: t.surfaceLow,
          shape: RoundedRectangleBorder(
            borderRadius: BeaconRadius.rLg,
            side: BorderSide(color: t.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 92,
              height: 92,
              child: loading
                  ? Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: t.primary),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: t.primary, size: 24),
                        const SizedBox(height: BeaconSpace.sm),
                        Text(label!, style: text.labelMedium),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
