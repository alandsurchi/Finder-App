import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/routes.dart';
import 'package:finder/providers/post_provider.dart';
import 'package:finder/providers/home_tab_provider.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/features/profile/presentation/privacy_settings_controller.dart';
import 'package:finder/features/profile/domain/privacy_settings.dart';
import 'package:finder/features/profile/presentation/profile_controller.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/core/constants/app_categories.dart';
import 'package:finder/app/di/app_providers.dart';
import 'package:finder/widgets/custom_bottom_nav_bar.dart';
import 'package:finder/features/location/place.dart';
import 'package:finder/screens/location_picker_screen.dart';
import 'package:finder/services/image_upload_service.dart' show ImageSourceKind;
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/l10n/l10n.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  /// Optional preselection for the Lost / Found toggle (presentation only).
  final bool? initialIsLost;
  const CreatePostScreen({super.key, this.initialIsLost});

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
  Place? _place;
  bool _locating = false;
  final _dateCtrl = TextEditingController();
  DateTime? _selectedDateTime;
  final _rewardCtrl = TextEditingController();
  bool _usePhone = false;
  final _phoneCtrl = TextEditingController();
  bool _publicSearch = true;
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
    if (widget.initialIsLost != null) _isLostItem = widget.initialIsLost!;
  }

  @override
  void didUpdateWidget(covariant CreatePostScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The Home hero tiles pre-select Lost/Found while this tab stays alive.
    final prefill = widget.initialIsLost;
    if (prefill != null && prefill != oldWidget.initialIsLost) {
      setState(() => _isLostItem = prefill);
    }
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
    final l10n = context.l10n;
    final done = _completedSteps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.postNewPost, style: text.headlineMedium),
        const SizedBox(height: BeaconSpace.xs),
        Text(
          _isLostItem
              ? l10n.postHeaderLost
              : l10n.postHeaderFound,
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
          done == 5 ? l10n.postReadyToPost : l10n.postDetailsAdded(done),
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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.postPhotos,
          eyebrow: l10n.postStep(1),
        ),
        Text(
          l10n.postPhotosHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: BeaconSpace.md),
        Row(
          children: [
            _MediaTile(
              icon: Icons.photo_camera_outlined,
              label: l10n.postCamera,
              onTap: busy ? null : () => _pickAndUploadImage(ImageSourceKind.camera),
            ),
            const SizedBox(width: BeaconSpace.md),
            _MediaTile(
              icon: Icons.photo_library_outlined,
              label: l10n.postGallery,
              onTap: busy ? null : () => _pickAndUploadImage(ImageSourceKind.gallery),
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
        PositionedDirectional(
          end: -8,
          top: -8,
          child: AppIconButton(
            icon: Icons.close_rounded,
            tooltip: context.l10n.postRemovePhoto,
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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.postItemDetails, eyebrow: l10n.postStep(2)),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _titleCtrl,
                label: l10n.postItemName,
                required: true,
                hint: l10n.postItemNameHint,
                prefixIcon: Icons.label_outline_rounded,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: BeaconSpace.lg),
              AppPickerField(
                label: l10n.postCategory,
                value: AppCategories.label(l10n, _category ?? ''),
                hint: l10n.postChooseCategory,
                prefixIcon: categoryIcon(_category ?? ''),
                onTap: _isSubmitting ? null : _showCategoryPicker,
              ),
              const SizedBox(height: BeaconSpace.md),
              _buildCategoryGrid(t),
              const SizedBox(height: BeaconSpace.lg),
              AppTextField(
                controller: _descCtrl,
                label: l10n.postDescription,
                required: true,
                hint: l10n.postDescriptionHint,
                helper: l10n.postDescriptionHelper(_descCtrl.text.length),
                maxLines: 4,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
              ),
              if (_isLostItem) ...[
                const SizedBox(height: BeaconSpace.lg),
                AppTextField(
                  controller: _rewardCtrl,
                  label: l10n.postRewardOptional,
                  hint: l10n.postRewardHint,
                  prefixIcon: Icons.workspace_premium_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: BeaconSpace.sm),
                Text(
                  l10n.postRewardNote,
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
          label: AppCategories.label(context.l10n, category),
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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.postLocationTime, eyebrow: l10n.postStep(3)),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(BeaconSpace.sm),
                child: MapPreview(
                  latitude: _place?.latitude,
                  longitude: _place?.longitude,
                  height: 150,
                  label: location.isEmpty ? l10n.postNoLocationSelected : location,
                  onTap: _isSubmitting ? null : _pickOnMap,
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
                            label: l10n.postLocateMe,
                            icon: Icons.my_location_rounded,
                            size: AppButtonSize.medium,
                            isLoading: _locating,
                            onPressed: (_isSubmitting || _locating)
                                ? null
                                : _useCurrentLocationNow,
                          ),
                        ),
                        const SizedBox(width: BeaconSpace.sm),
                        Expanded(
                          child: AppButton.tonal(
                            label: _place == null ? l10n.postOpenMap : l10n.postMovePin,
                            icon: Icons.map_outlined,
                            size: AppButtonSize.medium,
                            onPressed: _isSubmitting ? null : _pickOnMap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: BeaconSpace.sm),
                    AppButton.ghost(
                      label: l10n.postTypeAddress,
                      icon: Icons.edit_location_alt_outlined,
                      size: AppButtonSize.medium,
                      onPressed: _isSubmitting ? null : _enterLocationManually,
                    ),
                    const SizedBox(height: BeaconSpace.lg),
                    Row(
                      children: [
                        Expanded(
                          child: AppPickerField(
                            label: l10n.postDate,
                            value: _formatDateBadge(),
                            prefixIcon: Icons.calendar_today_outlined,
                            onTap: _isSubmitting ? null : _pickDateOnly,
                          ),
                        ),
                        const SizedBox(width: BeaconSpace.md),
                        Expanded(
                          child: AppPickerField(
                            label: l10n.postTime,
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
    final text = Theme.of(context).textTheme;
    final profile = ref.watch(profileControllerProvider).value;
    if (_usePhone && _phoneCtrl.text.isEmpty && (profile?.phone.isNotEmpty ?? false)) {
      _phoneCtrl.text = profile!.phone;
    }
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.postHowPeopleReachYou, eyebrow: l10n.postStep(4)),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: t.primaryContainer,
                      borderRadius: BeaconRadius.rMd,
                    ),
                    child: Icon(Icons.chat_bubble_outline_rounded, color: t.primary, size: 20),
                  ),
                  const SizedBox(width: BeaconSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.postInAppChat, style: text.titleSmall),
                        Text(l10n.postInAppChatNote,
                            style: text.bodySmall),
                      ],
                    ),
                  ),
                  StatusBadge.neutral(l10n.postOn, small: true),
                ],
              ),
              const SizedBox(height: BeaconSpace.lg),
              SurfaceCard(
                tone: SurfaceTone.low,
                padding: const EdgeInsets.symmetric(vertical: BeaconSpace.xs),
                child: ToggleTile(
                  icon: Icons.phone_outlined,
                  title: l10n.postShowPhone,
                  subtitle: l10n.postShowPhoneNote,
                  value: _usePhone,
                  onChanged: _isSubmitting ? null : (v) => setState(() => _usePhone = v),
                ),
              ),
              if (_usePhone) ...[
                const SizedBox(height: BeaconSpace.lg),
                AppTextField(
                  controller: _phoneCtrl,
                  label: l10n.postPhoneNumber,
                  hint: l10n.postPhoneHint,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  helper: l10n.postPhoneHelper,
                ),
              ],
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
          label: context.l10n.postPostNow,
          icon: Icons.send_rounded,
          iconTrailing: true,
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _submitPost,
        ),
        const SizedBox(height: BeaconSpace.sm),
        Center(
          child: AppButton.ghost(
            label: context.l10n.postSaveDraft,
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
          title: context.l10n.postChooseCategoryTitle,
          child: Column(
            children: [
              ..._categories.map(
                (c) => SheetOption(
                  label: AppCategories.label(context.l10n, c),
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

  Future<void> _useCurrentLocationNow() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final place = await ref.read(geoServiceProvider).currentPlace();
      if (!mounted) return;
      setState(() {
        _place = place;
        _locationCtrl.text = place.label;
        _publicSearch = true;
      });
      _showMessage(context.l10n.postLocationSetTo(place.label));
    } catch (e) {
      if (mounted) _showMessage(describeError(e), isError: true);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pickOnMap() async {
    final picked = await LocationPickerScreen.pick(context, initial: _place);
    if (!mounted || picked == null) return;
    setState(() {
      _place = picked;
      _locationCtrl.text = picked.label;
      _publicSearch = true;
    });
  }

  Future<void> _enterLocationManually() async {
    final localCtrl = TextEditingController(text: _locationCtrl.text);
    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.postEnterLocation),
          content: AppTextField(
            controller: localCtrl,
            hint: context.l10n.postEnterLocationHint,
            prefixIcon: Icons.place_outlined,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (v) => Navigator.pop(context, v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, localCtrl.text.trim()),
              child: Text(context.l10n.commonSave),
            ),
          ],
        );
      },
    );

    if (!mounted || value == null) return;
    setState(() {
      _locationCtrl.text = value;
      // A typed address has no pin; the map picker sets one again.
      _place = null;
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
    final l10n = context.l10n;

    if (value.year == now.year &&
        value.month == now.month &&
        value.day == now.day) {
      return l10n.commonToday;
    }

    return l10n.commonDayMonth(value.day, l10n.commonMonthShort('${value.month}'));
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
      _showMessage(context.l10n.postErrTitleRequired, isError: true);
      return;
    }

    final description = _descCtrl.text.trim();
    if (description.length < 10) {
      _showMessage(context.l10n.postErrDescriptionShort, isError: true);
      return;
    }

    if (_usePhone && _phoneCtrl.text.trim().isEmpty) {
      _showMessage(context.l10n.postErrPhoneRequired, isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final uid = ref.read(authStateProvider).userId;
    if (uid == null) {
      if (mounted) setState(() => _isSubmitting = false);
      _showMessage(context.l10n.postErrLoginRequired, isError: true);
      return;
    }

    final post = ItemModel(
      id: '',
      ownerId: uid,
      title: title,
      description: description,
      category: _category ?? 'Other',
      isLost: _isLostItem,
      reward: (!_isLostItem || _rewardCtrl.text.trim().isEmpty)
          ? null
          : _rewardCtrl.text.trim(),
      location: _locationCtrl.text.trim().isEmpty
          ? 'Unknown location'
          : _locationCtrl.text.trim(),
      lostOn: _dateCtrl.text.trim().isEmpty ? null : _dateCtrl.text.trim(),
      latitude: _place?.latitude,
      longitude: _place?.longitude,
      imagePath: _imagePath,
    );

    try {
      final created = await ref.read(postServiceProvider).createPost(post);
      if (_usePhone) await _sharePhone(_phoneCtrl.text.trim());
      if (!mounted) return;
      _clearDraft();
      ref.read(myPostsProvider.notifier).prepend(created);
      ref.invalidate(postsStreamProvider);
      _resetForm();
      // Details opens on top of Home, so Back lands on the feed, not here.
      ref.read(createPrefillProvider.notifier).state = null;
      ref.read(homeTabProvider.notifier).state = HomeTabs.home;
      ActionFeedback.showSuccess(context, context.l10n.postSentForReview);
      Navigator.pushNamed(context, AppRoutes.itemDetails, arguments: created);
    } catch (e) {
      if (!mounted) return;
      _showMessage(describeError(e), isError: true);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  /// Stores the phone on the profile and un-hides it in privacy settings.
  Future<void> _sharePhone(String phone) async {
    try {
      final profileCtrl = ref.read(profileControllerProvider.notifier);
      final current = ref.read(profileControllerProvider).value;
      if (current != null && current.phone != phone) {
        await profileCtrl.updateProfile(current.copyWith(phone: phone));
      }
      final privacy = ref.read(privacySettingsProvider).value;
      if (privacy == null || privacy.hidePhone) {
        await ref.read(privacySettingsProvider.notifier).updateSettings(
              (privacy ?? const PrivacySettings(showProfile: true, allowMessages: true, showLocation: false, hidePhone: true)).copyWith(hidePhone: false),
            );
      }
    } catch (_) {
      // The post itself succeeded; phone sharing can be fixed in settings.
    }
  }

  void _resetForm() {
    _titleCtrl.clear();
    _descCtrl.clear();
    _locationCtrl.clear();
    _place = null;
    _rewardCtrl.clear();
    _imagePath = '';
    _selectedDateTime = DateTime.now();
    _dateCtrl.text = _formatDateTime(_selectedDateTime!);
  }

  Future<void> _pickAndUploadImage(ImageSourceKind source) async {
    final uid = ref.read(authStateProvider).userId ?? 'anon';
    setState(() => _isUploadingImage = true);
    try {
      final fileName = '${uid}_${DateTime.now().millisecondsSinceEpoch}';
      final url = await ref.read(imageUploadServiceProvider).pickAndUpload(
        folder: 'posts',
        fileName: fileName,
        source: source,
      );
      if (url != null && mounted) {
        setState(() => _imagePath = url);
        _showMessage(context.l10n.postPhotoAdded);
      }
    } catch (e) {
      if (mounted) _showMessage(context.l10n.commonUploadFailed(describeError(e)), isError: true);
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
      'latitude': _place?.latitude,
      'longitude': _place?.longitude,
      'dateTime': _selectedDateTime?.millisecondsSinceEpoch,
      'reward': _rewardCtrl.text,
      'usePhone': _usePhone,
      'phone': _phoneCtrl.text,
      'publicSearch': _publicSearch,
      'imagePath': _imagePath,
    };
    _showMessage(context.l10n.postDraftSaved);
  }

  void _restoreDraftIfAvailable() {
    final draft = _draftCache;
    if (draft == null) return;

    _isLostItem = draft['isLost'] as bool? ?? _isLostItem;
    _titleCtrl.text = draft['title']?.toString() ?? '';
    _category = draft['category']?.toString() ?? _category;
    _descCtrl.text = draft['description']?.toString() ?? '';
    _locationCtrl.text = draft['location']?.toString() ?? '';
    final lat = draft['latitude'];
    final lng = draft['longitude'];
    if (lat is double && lng is double) {
      _place = Place(latitude: lat, longitude: lng, label: _locationCtrl.text);
    }

    final dateMs = draft['dateTime'];
    if (dateMs is int) {
      _selectedDateTime = DateTime.fromMillisecondsSinceEpoch(dateMs);
      _dateCtrl.text = _formatDateTime(_selectedDateTime!);
    }

    _rewardCtrl.text = draft['reward']?.toString() ?? '';
    _usePhone = draft['usePhone'] as bool? ?? _usePhone;
    _phoneCtrl.text = draft['phone']?.toString() ?? '';
    _publicSearch = draft['publicSearch'] as bool? ?? _publicSearch;
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
    isError
        ? ActionFeedback.showError(context, message)
        : ActionFeedback.showInfo(context, message);
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
    final l10n = context.l10n;
    return Semantics(
      button: !loading,
      label: loading ? l10n.postUploadingPhoto : l10n.postAddPhotoFrom(label!.toLowerCase()),
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
