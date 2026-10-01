import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/features/profile/presentation/profile_controller.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/app/di/app_providers.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';
import 'package:finder/widgets/ui/profile_cover.dart';
import 'package:finder/widgets/sheets/image_source_sheet.dart';
import 'package:finder/features/profile/presentation/photo_editor_screen.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _fullNameCtrl = TextEditingController();
  final _nickNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _jobCtrl = TextEditingController();
  String _avatarUrl = '';
  String _coverUrl = '';
  String _email = '';

  bool _seeded = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  bool _isUploadingCover = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).value;
    if (profile != null) _seed(profile);
  }

  void _seed(UserModel profile) {
    _seeded = true;
    _fullNameCtrl.text = profile.fullName;
    _nickNameCtrl.text = profile.nickName;
    _phoneCtrl.text = profile.phone;
    _addressCtrl.text = profile.address;
    _jobCtrl.text = profile.job;
    _avatarUrl = profile.avatarUrl;
    _coverUrl = profile.coverUrl;
    _email = profile.email;
  }

  @override
  void dispose() {
    for (final c in [_fullNameCtrl, _nickNameCtrl, _phoneCtrl, _addressCtrl, _jobCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _dirty {
    final p = ref.read(profileControllerProvider).value;
    if (p == null) return false;
    return _fullNameCtrl.text.trim() != p.fullName ||
        _nickNameCtrl.text.trim() != p.nickName ||
        _phoneCtrl.text.trim() != p.phone ||
        _addressCtrl.text.trim() != p.address ||
        _jobCtrl.text.trim() != p.job ||
        _avatarUrl != p.avatarUrl ||
        _coverUrl != p.coverUrl;
  }

  List<_FieldDef> _fields(AppLocalizations l10n) => [
        _FieldDef(l10n.profileFullName, Icons.person_outline_rounded, _fullNameCtrl,
            hint: l10n.profileFullNameHint, capitalization: TextCapitalization.words,
            autofill: AutofillHints.name),
        _FieldDef(l10n.profileNickname, Icons.alternate_email_rounded, _nickNameCtrl,
            hint: l10n.profileNicknameHint, autofill: AutofillHints.nickname),
        _FieldDef(l10n.profilePhone, Icons.phone_outlined, _phoneCtrl,
            type: TextInputType.phone, hint: l10n.profilePhoneHint,
            autofill: AutofillHints.telephoneNumber),
        _FieldDef(l10n.profileCity, Icons.place_outlined, _addressCtrl,
            hint: l10n.profileCityHint, capitalization: TextCapitalization.words,
            autofill: AutofillHints.addressCity),
        _FieldDef(l10n.profileJob, Icons.work_outline_rounded, _jobCtrl,
            hint: l10n.profileJobHint, capitalization: TextCapitalization.sentences,
            autofill: AutofillHints.jobTitle),
      ];

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final fields = _fields(l10n);
    final profileState = ref.watch(profileControllerProvider);

    // Seed the form once the profile arrives (opened before it loaded).
    final loaded = profileState.value;
    if (!_seeded && loaded != null) _seed(loaded);

    return PopScope(
      canPop: !_dirty || _isSaving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.profileDiscardTitle),
            content: Text(l10n.profileDiscardBody),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.profileKeepEditing)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonDiscard)),
            ],
          ),
        );
        if (leave == true && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppPageHeader(
                title: l10n.profileEdit,
                actions: [
                  AppButton.ghost(
                    label: l10n.commonSave,
                    icon: Icons.check_rounded,
                    isLoading: _isSaving,
                    onPressed: (_isSaving || !_seeded) ? null : _saveProfile,
                  ),
                ],
              ),
              Expanded(
                child: !_seeded
                    ? profileState.when(
                        loading: () => LoadingWidget(message: l10n.profileLoading),
                        error: (err, _) => ErrorStateWidget(
                          message: describeError(err),
                          onRetry: () => ref.read(profileControllerProvider.notifier).loadProfile(),
                        ),
                        data: (_) => const SizedBox.shrink(),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                            BeaconSpace.page, 0, BeaconSpace.page, BeaconSpace.xxl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCoverSection(t),
                    const SizedBox(height: BeaconSpace.lg),
                    _buildAvatarSection(t),
                            const SizedBox(height: BeaconSpace.xxxl),
                            AutofillGroup(
                              child: SurfaceCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    for (var i = 0; i < fields.length; i++) ...[
                                      if (i > 0) const SizedBox(height: BeaconSpace.lg),
                                      AppTextField(
                                        controller: fields[i].ctrl,
                                        label: fields[i].label,
                                        hint: fields[i].hint,
                                        prefixIcon: fields[i].icon,
                                        keyboardType: fields[i].type,
                                        textCapitalization: fields[i].capitalization,
                                        autofillHints: fields[i].autofill == null
                                            ? null
                                            : [fields[i].autofill!],
                                        textInputAction: i == fields.length - 1
                                            ? TextInputAction.done
                                            : TextInputAction.next,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: BeaconSpace.lg),
                            SurfaceCard(
                              tone: SurfaceTone.low,
                              child: Row(
                                children: [
                                  Icon(Icons.mail_outline_rounded, color: t.onSurfaceMuted, size: 20),
                                  const SizedBox(width: BeaconSpace.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(l10n.profileSignInEmailLabel,
                                            style: text.labelSmall?.copyWith(color: t.onSurfaceMuted)),
                                        Text(_email, style: text.titleSmall),
                                        const SizedBox(height: 2),
                                        Text(l10n.profileEmailNote,
                                            style: text.bodySmall),
                                      ],
                                    ),
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
        bottomNavigationBar: !_seeded
            ? null
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      BeaconSpace.page, BeaconSpace.sm, BeaconSpace.page, BeaconSpace.lg),
                  child: AppButton(
                    label: l10n.profileSaveChanges,
                    icon: Icons.check_rounded,
                    isLoading: _isSaving,
                    onPressed: _isSaving ? null : _saveProfile,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCoverSection(AppColorTokens t) {
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return ClipRRect(
      borderRadius: BeaconRadius.rXl,
      child: Stack(
        children: [
          ProfileCover(url: _coverUrl, height: 132),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: _isUploadingCover ? null : _pickCover),
            ),
          ),
          PositionedDirectional(
            end: BeaconSpace.sm,
            bottom: BeaconSpace.sm,
            child: Row(
              children: [
                if (_coverUrl.isNotEmpty && !_isUploadingCover) ...[
                  AppIconButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: l10n.photoRemoveCover,
                    size: 36,
                    iconSize: 18,
                    variant: AppIconButtonVariant.glass,
                    onPressed: () => setState(() => _coverUrl = ''),
                  ),
                  const SizedBox(width: BeaconSpace.sm),
                ],
                _isUploadingCover
                    ? Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: t.primary, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(9),
                        child: CircularProgressIndicator(strokeWidth: 2, color: t.onPrimary),
                      )
                    : AppIconButton(
                        icon: Icons.photo_camera_outlined,
                        tooltip: _coverUrl.isEmpty ? l10n.photoAddCover : l10n.photoChangeCover,
                        size: 36,
                        iconSize: 18,
                        variant: AppIconButtonVariant.filled,
                        onPressed: _pickCover,
                      ),
              ],
            ),
          ),
          if (_coverUrl.isEmpty)
            PositionedDirectional(
              start: BeaconSpace.lg,
              bottom: BeaconSpace.md,
              child: Text(
                l10n.photoAddCover,
                style: text.labelLarge?.copyWith(color: t.onPrimary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(AppColorTokens t) {
    final l10n = context.l10n;
    final name = _fullNameCtrl.text.trim();
    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppAvatar(url: _avatarUrl, name: name, size: 112, ring: true),
              PositionedDirectional(
                end: 0,
                bottom: 0,
                child: _isUploadingAvatar
                    ? Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: t.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: t.surface, width: 2),
                        ),
                        padding: const EdgeInsets.all(9),
                        child: CircularProgressIndicator(strokeWidth: 2, color: t.onPrimary),
                      )
                    : AppIconButton(
                        icon: Icons.camera_alt_rounded,
                        tooltip: l10n.photoChangeProfile,
                        size: 36,
                        iconSize: 18,
                        variant: AppIconButtonVariant.filled,
                        onPressed: _pickAndUploadAvatar,
                      ),
              ),
            ],
          ),
          const SizedBox(height: BeaconSpace.md),
          Wrap(
            spacing: BeaconSpace.sm,
            alignment: WrapAlignment.center,
            children: [
              AppButton.ghost(
                label: _isUploadingAvatar
                    ? l10n.commonUploading
                    : (_avatarUrl.isEmpty ? l10n.photoAddProfile : l10n.photoChangeProfile),
                onPressed: _isUploadingAvatar ? null : _pickAndUploadAvatar,
              ),
              if (_avatarUrl.isNotEmpty && !_isUploadingAvatar)
                AppButton.ghost(
                  label: l10n.commonRemove,
                  onPressed: () => setState(() => _avatarUrl = ''),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Camera or gallery → crop editor → upload. Returns the new URL.
  Future<String?> _pickEditUpload({
    required PhotoEditorMode mode,
    required String folder,
    required String title,
  }) async {
    final source = await showImageSourceSheet(context, title: title);
    if (source == null || !mounted) return null;
    final uploads = ref.read(imageUploadServiceProvider);
    final bytes = await uploads.pickBytes(
      source: source,
      frontCamera: mode == PhotoEditorMode.avatar,
    );
    if (bytes == null || !mounted) return null;
    final edited = await PhotoEditorScreen.open(context, bytes, mode);
    if (edited == null || !mounted) return null;
    return uploads.uploadBytes(edited, folder: folder);
  }

  Future<void> _pickAndUploadAvatar() async {
    final uid = ref.read(authStateProvider).userId;
    if (uid == null || _isUploadingAvatar) return;
    try {
      setState(() => _isUploadingAvatar = true);
      final url = await _pickEditUpload(
        mode: PhotoEditorMode.avatar,
        folder: 'avatars',
        title: context.l10n.photoProfileTitle,
      );
      if (url != null && mounted) setState(() => _avatarUrl = url);
    } catch (e) {
      if (mounted) ActionFeedback.showError(context, context.l10n.commonUploadFailed(describeError(e)));
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _pickCover() async {
    if (_isUploadingCover) return;
    try {
      setState(() => _isUploadingCover = true);
      final url = await _pickEditUpload(
        mode: PhotoEditorMode.cover,
        folder: 'covers',
        title: context.l10n.photoCoverTitle,
      );
      if (url != null && mounted) setState(() => _coverUrl = url);
    } catch (e) {
      if (mounted) ActionFeedback.showError(context, context.l10n.commonUploadFailed(describeError(e)));
    } finally {
      if (mounted) setState(() => _isUploadingCover = false);
    }
  }

  Future<void> _saveProfile() async {
    final current = ref.read(profileControllerProvider).value;
    if (current == null) return;
    if (_fullNameCtrl.text.trim().isEmpty) {
      ActionFeedback.showError(context, context.l10n.profileEnterName);
      return;
    }
    setState(() => _isSaving = true);

    final updated = current.copyWith(
      fullName: _fullNameCtrl.text.trim(),
      nickName: _nickNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      job: _jobCtrl.text.trim(),
      avatarUrl: _avatarUrl,
      coverUrl: _coverUrl,
    );

    final result = await ref.read(profileControllerProvider.notifier).updateProfile(updated);
    if (!mounted) return;
    setState(() => _isSaving = false);
    result.fold(
      onSuccess: (_) {
        Navigator.pop(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = Navigator.of(context, rootNavigator: true).context;
          ActionFeedback.showSuccess(ctx, ctx.l10n.profileUpdated);
        });
      },
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }
}

class _FieldDef {
  final String label;
  final IconData icon;
  final TextEditingController ctrl;
  final TextInputType type;
  final String? hint;
  final TextCapitalization capitalization;
  final String? autofill;
  const _FieldDef(
    this.label,
    this.icon,
    this.ctrl, {
    this.type = TextInputType.text,
    this.hint,
    this.capitalization = TextCapitalization.none,
    this.autofill,
  });
}
