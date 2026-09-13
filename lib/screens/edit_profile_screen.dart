import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/features/profile/presentation/profile_controller.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/services/image_upload_service.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';

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
  String _email = '';

  bool _seeded = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

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
        _avatarUrl != p.avatarUrl;
  }

  List<_FieldDef> get _fields => [
        _FieldDef('Full name', Icons.person_outline_rounded, _fullNameCtrl,
            hint: 'Your name', capitalization: TextCapitalization.words,
            autofill: AutofillHints.name),
        _FieldDef('Nickname', Icons.alternate_email_rounded, _nickNameCtrl,
            hint: 'How friends know you', autofill: AutofillHints.nickname),
        _FieldDef('Phone', Icons.phone_outlined, _phoneCtrl,
            type: TextInputType.phone, hint: '+1 234 567 8900',
            autofill: AutofillHints.telephoneNumber),
        _FieldDef('City', Icons.place_outlined, _addressCtrl,
            hint: 'City, country', capitalization: TextCapitalization.words,
            autofill: AutofillHints.addressCity),
        _FieldDef('Job / occupation', Icons.work_outline_rounded, _jobCtrl,
            hint: 'What do you do?', capitalization: TextCapitalization.sentences,
            autofill: AutofillHints.jobTitle),
      ];

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
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
            title: const Text('Discard changes?'),
            content: const Text('Your edits have not been saved.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep editing')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Discard')),
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
                title: 'Edit profile',
                actions: [
                  AppButton.ghost(
                    label: 'Save',
                    icon: Icons.check_rounded,
                    isLoading: _isSaving,
                    onPressed: (_isSaving || !_seeded) ? null : _saveProfile,
                  ),
                ],
              ),
              Expanded(
                child: !_seeded
                    ? profileState.when(
                        loading: () => const LoadingWidget(message: 'Loading your profile...'),
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
                            _buildAvatarSection(t),
                            const SizedBox(height: BeaconSpace.xxxl),
                            AutofillGroup(
                              child: SurfaceCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    for (var i = 0; i < _fields.length; i++) ...[
                                      if (i > 0) const SizedBox(height: BeaconSpace.lg),
                                      AppTextField(
                                        controller: _fields[i].ctrl,
                                        label: _fields[i].label,
                                        hint: _fields[i].hint,
                                        prefixIcon: _fields[i].icon,
                                        keyboardType: _fields[i].type,
                                        textCapitalization: _fields[i].capitalization,
                                        autofillHints: _fields[i].autofill == null
                                            ? null
                                            : [_fields[i].autofill!],
                                        textInputAction: i == _fields.length - 1
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
                                        Text('SIGN-IN E-MAIL',
                                            style: text.labelSmall?.copyWith(color: t.onSurfaceMuted)),
                                        Text(_email, style: text.titleSmall),
                                        const SizedBox(height: 2),
                                        Text('Your e-mail is used to sign in and cannot be changed here.',
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
                    label: 'Save changes',
                    icon: Icons.check_rounded,
                    isLoading: _isSaving,
                    onPressed: _isSaving ? null : _saveProfile,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAvatarSection(AppColorTokens t) {
    final name = _fullNameCtrl.text.trim();
    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppAvatar(url: _avatarUrl, name: name, size: 112, ring: true),
              Positioned(
                right: 0,
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
                        tooltip: 'Change profile photo',
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
                    ? 'Uploading…'
                    : (_avatarUrl.isEmpty ? 'Add profile photo' : 'Change profile photo'),
                onPressed: _isUploadingAvatar ? null : _pickAndUploadAvatar,
              ),
              if (_avatarUrl.isNotEmpty && !_isUploadingAvatar)
                AppButton.ghost(
                  label: 'Remove',
                  onPressed: () => setState(() => _avatarUrl = ''),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    final uid = ref.read(authStateProvider).userId;
    if (uid == null) return;
    setState(() => _isUploadingAvatar = true);
    try {
      final url = await ImageUploadService.pickAndUpload(
        folder: 'avatars',
        fileName: uid,
      );
      if (url != null && mounted) setState(() => _avatarUrl = url);
    } catch (e) {
      if (mounted) ActionFeedback.showError(context, 'Upload failed. ${describeError(e)}');
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _saveProfile() async {
    final current = ref.read(profileControllerProvider).value;
    if (current == null) return;
    if (_fullNameCtrl.text.trim().isEmpty) {
      ActionFeedback.showError(context, 'Please enter your name.');
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
    );

    final result = await ref.read(profileControllerProvider.notifier).updateProfile(updated);
    if (!mounted) return;
    setState(() => _isSaving = false);
    result.fold(
      onSuccess: (_) {
        Navigator.pop(context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = Navigator.of(context, rootNavigator: true).context;
          ActionFeedback.showSuccess(ctx, 'Profile updated.');
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
