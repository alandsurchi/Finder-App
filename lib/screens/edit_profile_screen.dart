import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/features/profile/presentation/profile_controller.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/features/auth/presentation/auth_state_provider.dart';
import 'package:finder/services/image_upload_service.dart';
import 'package:finder/widgets/ui/ui.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _fullNameCtrl;
  late TextEditingController _nickNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _jobCtrl;
  late TextEditingController _avatarCtrl;

  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final profile =
        ref.read(profileControllerProvider).value ?? UserModel.empty();
    _fullNameCtrl = TextEditingController(text: profile.fullName);
    _nickNameCtrl = TextEditingController(text: profile.nickName);
    _emailCtrl = TextEditingController(text: profile.email);
    _phoneCtrl = TextEditingController(text: profile.phone);
    _addressCtrl = TextEditingController(text: profile.address);
    _jobCtrl = TextEditingController(text: profile.job);
    _avatarCtrl = TextEditingController(text: profile.avatarUrl);
  }

  @override
  void dispose() {
    for (final c in [
      _fullNameCtrl,
      _nickNameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _addressCtrl,
      _jobCtrl,
      _avatarCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Field definitions ──────────────────────────────────────────────────────
  List<_FieldDef> get _fields => [
        _FieldDef('Full name', Icons.person_outline_rounded, _fullNameCtrl,
            hint: 'Your name', capitalization: TextCapitalization.words,
            autofill: AutofillHints.name),
        _FieldDef('Nickname', Icons.alternate_email_rounded, _nickNameCtrl,
            hint: 'How friends know you', autofill: AutofillHints.nickname),
        _FieldDef('Email', Icons.mail_outline_rounded, _emailCtrl,
            type: TextInputType.emailAddress, hint: 'you@example.com',
            autofill: AutofillHints.email),
        _FieldDef('Phone', Icons.phone_outlined, _phoneCtrl,
            type: TextInputType.phone, hint: '+1 234 567 8900',
            autofill: AutofillHints.telephoneNumber),
        _FieldDef('Address', Icons.place_outlined, _addressCtrl,
            hint: 'City, country', capitalization: TextCapitalization.words,
            autofill: AutofillHints.addressCity),
        _FieldDef('Job / occupation', Icons.work_outline_rounded, _jobCtrl,
            hint: 'What do you do?', capitalization: TextCapitalization.sentences,
            autofill: AutofillHints.jobTitle),
      ];

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);

    return Scaffold(
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
                  onPressed: _isSaving ? null : _saveProfile,
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
                    // ── Avatar section ──
                    _buildAvatarSection(t),
                    const SizedBox(height: BeaconSpace.xxxl),

                    // ── Fields ──
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
                              ),
                            ],
                          ],
                        ),
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
            onPressed: _isSaving ? null : _saveProfile,
          ),
        ),
      ),
    );
  }

  // ── Avatar section ─────────────────────────────────────────────────────────
  Widget _buildAvatarSection(AppColorTokens t) {
    final url = _avatarCtrl.text.trim();
    final name = _fullNameCtrl.text.trim();
    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppAvatar(url: url, name: name, size: 112, ring: true),
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
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: t.onPrimary),
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
          AppButton.ghost(
            label: _isUploadingAvatar
                ? 'Uploading…'
                : (url.isEmpty ? 'Add profile photo' : 'Change profile photo'),
            onPressed: _isUploadingAvatar ? null : _pickAndUploadAvatar,
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
      if (url != null && mounted) {
        setState(() => _avatarCtrl.text = url);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    final current =
        ref.read(profileControllerProvider).value ?? UserModel.empty();
    final updated = current.copyWith(
      fullName: _fullNameCtrl.text.trim(),
      nickName: _nickNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      job: _jobCtrl.text.trim(),
      avatarUrl: _avatarCtrl.text.trim(),
    );

    await ref.read(profileControllerProvider.notifier).updateProfile(updated);



    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}

// ── Field definition helper ────────────────────────────────────────────────
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
