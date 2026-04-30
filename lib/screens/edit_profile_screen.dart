import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/features/profile/presentation/profile_controller.dart';
import 'package:finder/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finder/services/image_upload_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

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
  int _editingIndex = -1;

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
        _FieldDef('Full Name', Icons.person_outline, _fullNameCtrl),
        _FieldDef('Nick Name', Icons.alternate_email, _nickNameCtrl),
        _FieldDef('Email', Icons.mail_outline_rounded, _emailCtrl,
            type: TextInputType.emailAddress),
        _FieldDef('Phone', Icons.phone_outlined, _phoneCtrl,
            type: TextInputType.phone),
        _FieldDef('Address', Icons.location_on_outlined, _addressCtrl),
        _FieldDef('Job / Occupation', Icons.work_outline_rounded, _jobCtrl),
      ];

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
        title: const Text('Edit Profile',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _saveProfile,
                  child: const Text('Save',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
        ],
      ),
      body: GestureDetector(
        // Dismiss keyboard / editing on tap outside
        onTap: () => setState(() => _editingIndex = -1),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
          child: Column(
            children: [
              // ── Avatar section ──
              _buildAvatarSection(t),
              const SizedBox(height: 28),

              // ── Fields ──
              ...List.generate(_fields.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildFieldCard(i, t),
                );
              }),

              const SizedBox(height: 12),

              // ── Save full button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Save Changes',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.primary,
                    foregroundColor:
                        t.isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Avatar section ─────────────────────────────────────────────────────────
  Widget _buildAvatarSection(AppColorTokens t) {
    final url = _avatarCtrl.text.trim();
    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.primaryContainer,
                  border: Border.all(color: t.primary, width: 2),
                  image: url.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(url),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        )
                      : null,
                ),
                child: url.isEmpty
                    ? Icon(Icons.person, color: t.onSurfaceVar, size: 60)
                    : null,
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: GestureDetector(
                  onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: t.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: _isUploadingAvatar
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.camera_alt,
                            color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
            child: Text(
              _isUploadingAvatar
                  ? 'Uploading…'
                  : (url.isEmpty ? 'Add profile photo' : 'Change profile photo'),
              style: TextStyle(
                color: _isUploadingAvatar ? t.onSurfaceMuted : t.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
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

  // ── Field card ─────────────────────────────────────────────────────────────
  Widget _buildFieldCard(int index, AppColorTokens t) {
    final def = _fields[index];
    final isEditing = _editingIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _editingIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEditing ? t.primary : t.divider,
            width: isEditing ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isEditing
                    ? t.primary.withOpacity(0.1)
                    : t.surfaceHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(def.icon,
                  color: isEditing ? t.primary : t.onSurfaceMuted,
                  size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    def.label,
                    style: TextStyle(
                      color: t.onSurfaceMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  isEditing
                      ? TextField(
                          controller: def.ctrl,
                          autofocus: true,
                          keyboardType: def.type,
                          style:
                              TextStyle(color: t.onSurface, fontSize: 14),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) =>
                              setState(() => _editingIndex = -1),
                        )
                      : Text(
                          def.ctrl.text.isEmpty ? 'Tap to add' : def.ctrl.text,
                          style: TextStyle(
                            color: def.ctrl.text.isEmpty
                                ? t.onSurfaceMuted
                                : t.onSurface,
                            fontSize: 14,
                            fontStyle: def.ctrl.text.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                        ),
                ],
              ),
            ),
            Icon(
              isEditing ? Icons.check_circle : Icons.edit_outlined,
              color: isEditing ? t.primary : t.onSurfaceMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    setState(() {
      _editingIndex = -1;
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

    // Also update Firebase Auth displayName so other screens see the new name
    try {
      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(_fullNameCtrl.text.trim());
    } catch (_) {}

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
  const _FieldDef(this.label, this.icon, this.ctrl,
      {this.type = TextInputType.text});
}
