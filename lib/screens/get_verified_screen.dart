import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/core/utils/relative_time.dart';
import 'package:finder/features/profile/domain/verification_status.dart';
import 'package:finder/features/profile/presentation/verification_controller.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/app/di/app_providers.dart';
import 'package:finder/services/image_upload_service.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/sheets/image_source_sheet.dart';
import 'package:finder/widgets/state/error_widget.dart';
import 'package:finder/widgets/state/loading_widget.dart';
import 'package:finder/widgets/ui/ui.dart';

enum _DocType { passport, identityCard, driversLicense }

extension on _DocType {
  String get apiValue => switch (this) {
        _DocType.passport => 'passport',
        _DocType.identityCard => 'id_card',
        _DocType.driversLicense => 'drivers_license',
      };
  String label(AppLocalizations l10n) => switch (this) {
        _DocType.passport => l10n.verifyPassport,
        _DocType.identityCard => l10n.verifyIdentityCard,
        _DocType.driversLicense => l10n.verifyDriversLicense,
      };
  bool get hasBack => this != _DocType.passport;
}

/// Identity verification: document photos (camera or gallery) and a selfie
/// taken live with the front camera. Files are stored privately and reviewed
/// by a Finder admin; the outcome arrives as a notification.
class GetVerifiedScreen extends ConsumerStatefulWidget {
  const GetVerifiedScreen({super.key});

  @override
  ConsumerState<GetVerifiedScreen> createState() => _GetVerifiedScreenState();
}

class _GetVerifiedScreenState extends ConsumerState<GetVerifiedScreen> {
  _DocType _selectedDoc = _DocType.passport;
  PrivateUpload? _front;
  PrivateUpload? _back;
  PrivateUpload? _selfie;
  String? _uploading; // 'front' | 'back' | 'selfie'
  bool _submitting = false;

  /// After a rejection the form is hidden behind the reason until the user
  /// chooses to try again.
  bool _resubmitting = false;

  bool get _documentDone =>
      _front != null && (!_selectedDoc.hasBack || _back != null);

  int get _completedSteps {
    var s = 1; // a document type is always selected
    if (_documentDone) s++;
    if (_selfie != null) s++;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final statusState = ref.watch(verificationProvider);
    final status = statusState.value;
    final locked = status != null && (status.isPending || status.isApproved);
    final showForm = status != null &&
        !locked &&
        (!status.isRejected || _resubmitting);

    return Scaffold(
      bottomNavigationBar: showForm ? _buildBottomBar(context) : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppPageHeader(
              title: l10n.verifyTitle,
              subtitle: status == null
                  ? null
                  : status.isApproved
                      ? l10n.verifyApprovedSubtitle
                      : status.isPending
                          ? l10n.verifyUnderReview
                          : status.isRejected && !_resubmitting
                              ? l10n.verifyNeedsNewPhotos
                              : l10n.verifyStepsComplete(_completedSteps),
            ),
            Expanded(
              child: statusState.when(
                loading: () =>
                    LoadingWidget(message: l10n.verifyCheckingStatus),
                error: (err, _) => ErrorStateWidget(
                  message: describeError(err),
                  onRetry: () => ref.read(verificationProvider.notifier).load(),
                ),
                data: (s) => SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      BeaconSpace.page,
                      0,
                      BeaconSpace.page,
                      BeaconSpace.xxl + MediaQuery.paddingOf(context).bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StaggeredEntrance(child: _buildHero(t, text, s)),
                      const SizedBox(height: BeaconSpace.xxl),
                      if (locked)
                        StaggeredEntrance(
                            index: 1, child: _buildStatusCard(t, text, s))
                      else if (s.isRejected && !_resubmitting)
                        StaggeredEntrance(
                            index: 1, child: _buildRejectedCard(t, text, s))
                      else ...[
                        StaggeredEntrance(
                            index: 1, child: _buildHowItWorks(t, text)),
                        const SizedBox(height: BeaconSpace.xxl),
                        ..._buildForm(t, text),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(AppColorTokens t, TextTheme text, VerificationStatus s) {
    final l10n = context.l10n;
    return Material(
      color: t.primary,
      borderRadius: BeaconRadius.rXl,
      child: Padding(
        padding: const EdgeInsets.all(BeaconSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: BeaconSpace.md,
                vertical: BeaconSpace.xs + 1,
              ),
              decoration: BoxDecoration(
                color: t.onPrimary.withValues(alpha: 0.15),
                borderRadius: BeaconRadius.rPill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, color: t.onPrimary, size: 14),
                  const SizedBox(width: BeaconSpace.xs + 1),
                  Text(
                    s.isApproved ? l10n.verifyVerifiedMember : l10n.verifyReviewedByPerson,
                    style: text.labelSmall?.copyWith(color: t.onPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: BeaconSpace.lg),
            Text(
              s.isApproved ? l10n.verifyThanks : l10n.verifyHeroHeadline,
              style: text.headlineSmall?.copyWith(color: t.onPrimary),
            ),
            const SizedBox(height: BeaconSpace.md),
            Text(
              s.isApproved ? l10n.verifyApprovedBody : l10n.verifyHeroBody,
              style: text.bodyMedium?.copyWith(
                color: t.onPrimary.withValues(alpha: 0.85),
              ),
            ),
            if (!s.isApproved && !s.isPending) ...[
              const SizedBox(height: BeaconSpace.lg),
              ClipRRect(
                borderRadius: BeaconRadius.rPill,
                child: LinearProgressIndicator(
                  value: _completedSteps / 3,
                  minHeight: 6,
                  color: t.accent,
                  backgroundColor: t.onPrimary.withValues(alpha: 0.2),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks(AppColorTokens t, TextTheme text) {
    final l10n = context.l10n;
    Widget step(IconData icon, String title, String body) => Padding(
          padding: const EdgeInsets.symmetric(vertical: BeaconSpace.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: t.primary, size: 20),
              const SizedBox(width: BeaconSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleSmall),
                    Text(body, style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
    return SurfaceCard(
      tone: SurfaceTone.low,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.verifyHowItWorks, style: text.titleMedium),
          const SizedBox(height: BeaconSpace.sm),
          step(Icons.badge_outlined, l10n.verifyStep1Title, l10n.verifyStep1Body),
          step(Icons.face_retouching_natural_outlined, l10n.verifyStep2Title,
              l10n.verifyStep2Body),
          step(Icons.how_to_reg_outlined, l10n.verifyStep3Title, l10n.verifyStep3Body),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      AppColorTokens t, TextTheme text, VerificationStatus s) {
    final l10n = context.l10n;
    final approved = s.isApproved;
    return SurfaceCard(
      tone: approved ? SurfaceTone.found : SurfaceTone.accent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            approved ? Icons.verified_rounded : Icons.hourglass_top_rounded,
            color: approved ? t.found : t.accent,
            size: 28,
          ),
          const SizedBox(width: BeaconSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        approved ? l10n.verifyIdentityVerified : l10n.verifyPending,
                        style: text.titleMedium,
                      ),
                    ),
                    approved
                        ? StatusBadge.verified()
                        : StatusBadge.neutral(l10n.verifyPendingBadge),
                  ],
                ),
                const SizedBox(height: BeaconSpace.xs),
                Text(
                  approved
                      ? l10n.verifyVerifiedWith(_docLabel(l10n, s.docType))
                      : l10n.verifyReceived(
                          _docLabel(l10n, s.docType),
                          s.createdAtMs == null ? '' : relativeTime(s.createdAtMs, l10n: l10n),
                        ),
                  style: text.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedCard(
      AppColorTokens t, TextTheme text, VerificationStatus s) {
    final l10n = context.l10n;
    return SurfaceCard(
      tone: SurfaceTone.lost,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline_rounded, color: t.error, size: 28),
              const SizedBox(width: BeaconSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(l10n.verifyNotApproved,
                              style: text.titleMedium),
                        ),
                        StatusBadge.custom(
                          label: l10n.verifyNeedsPhotosBadge,
                          color: t.error,
                          icon: Icons.refresh_rounded,
                          small: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: BeaconSpace.xs),
                    Text(
                      s.rejectionReason?.isNotEmpty == true
                          ? s.rejectionReason!
                          : l10n.verifyPhotosRejected,
                      style: text.bodyMedium,
                    ),
                    if (s.reviewedAtMs != null)
                      Text(l10n.verifyReviewedAt(relativeTime(s.reviewedAtMs, l10n: l10n)),
                          style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: BeaconSpace.lg),
          AppButton(
            label: l10n.verifySubmitNewPhotos,
            icon: Icons.photo_camera_outlined,
            size: AppButtonSize.medium,
            onPressed: () => setState(() => _resubmitting = true),
          ),
        ],
      ),
    );
  }

  static String _docLabel(AppLocalizations l10n, String? apiValue) =>
      l10n.verifyDocTypeLower(apiValue ?? '');

  List<Widget> _buildForm(AppColorTokens t, TextTheme text) {
    final l10n = context.l10n;
    return [
      StaggeredEntrance(
        index: 2,
        child: _buildSectionHeader(
          stepIndex: 1,
          done: true,
          icon: Icons.description_outlined,
          title: l10n.verifyDocSelection,
          subtitle: l10n.verifyDocSelectionSubtitle,
        ),
      ),
      const SizedBox(height: BeaconSpace.md),
      StaggeredEntrance(
        index: 2,
        child: SurfaceCard(
          padding: const EdgeInsets.all(BeaconSpace.sm),
          child: Column(
            children: [
              for (final d in _DocType.values)
                SheetOption(
                  label: d.label(l10n),
                  icon: switch (d) {
                    _DocType.passport => Icons.book_outlined,
                    _DocType.identityCard => Icons.badge_outlined,
                    _DocType.driversLicense => Icons.drive_eta_outlined,
                  },
                  selected: _selectedDoc == d,
                  onTap: _submitting
                      ? () {}
                      : () => setState(() => _selectedDoc = d),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: BeaconSpace.xxl),
      StaggeredEntrance(
        index: 3,
        child: _buildSectionHeader(
          stepIndex: 2,
          done: _documentDone,
          icon: Icons.camera_alt_outlined,
          title: l10n.verifyDocPhotos,
          subtitle: _selectedDoc.hasBack ? l10n.verifyBothSides : l10n.verifyPhotoPage,
        ),
      ),
      const SizedBox(height: BeaconSpace.md),
      StaggeredEntrance(
        index: 3,
        child: Row(
          children: [
            Expanded(
              child: _UploadBox(
                label: _selectedDoc.hasBack ? l10n.verifyFrontOfId : l10n.verifyPhotoPageLabel,
                preview: _front?.bytes,
                uploading: _uploading == 'front',
                onTap: () => _uploadDocument('front'),
              ),
            ),
            if (_selectedDoc.hasBack) ...[
              const SizedBox(width: BeaconSpace.md),
              Expanded(
                child: _UploadBox(
                  label: l10n.verifyBackOfId,
                  preview: _back?.bytes,
                  uploading: _uploading == 'back',
                  onTap: () => _uploadDocument('back'),
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: BeaconSpace.xxl),
      StaggeredEntrance(
        index: 4,
        child: _buildSectionHeader(
          stepIndex: 3,
          done: _selfie != null,
          icon: Icons.face_outlined,
          title: l10n.verifyLiveSelfie,
          subtitle: l10n.verifyLiveSelfieSubtitle,
        ),
      ),
      const SizedBox(height: BeaconSpace.md),
      StaggeredEntrance(
        index: 4,
        child: SurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: BeaconSpace.xxl),
          child: Column(
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: t.primaryContainer,
                  boxShadow: [
                    BoxShadow(
                        color: t.accentGlow, blurRadius: 30, spreadRadius: 4),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _selfie != null
                    ? Image.memory(
                        _selfie!.bytes,
                        width: 128,
                        height: 128,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 92,
                            height: 92,
                            child: CustomPaint(
                                painter: _CornerPainter(color: t.primary)),
                          ),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: t.primary,
                              shape: BoxShape.circle,
                            ),
                            child: _uploading == 'selfie'
                                ? Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5, color: t.onPrimary),
                                  )
                                : Icon(Icons.camera_front_outlined,
                                    color: t.onPrimary, size: 26),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: BeaconSpace.xl),
              AppButton(
                label: _selfie != null ? l10n.verifyRetakeSelfie : l10n.verifyTakeSelfie,
                icon: Icons.camera_front_outlined,
                expand: false,
                size: AppButtonSize.medium,
                variant: _selfie != null
                    ? AppButtonVariant.tonal
                    : AppButtonVariant.primary,
                isLoading: _uploading == 'selfie',
                onPressed: _uploading != null ? null : _uploadSelfie,
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: BeaconSpace.lg),
      StaggeredEntrance(
        index: 5,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: t.accent, size: 18),
            const SizedBox(width: BeaconSpace.sm),
            Expanded(
              child: Text(
                l10n.verifyTip,
                style: text.bodySmall,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Future<void> _uploadDocument(String slot) async {
    if (_uploading != null) return;
    final l10n = context.l10n;
    final source = await showImageSourceSheet(
      context,
      title: slot == 'front' ? l10n.verifyFrontOfYourId : l10n.verifyBackOfYourId,
      subtitle: l10n.verifyStoredPrivately,
    );
    if (source == null || !mounted) return;
    await _upload(slot, source: source);
  }

  Future<void> _uploadSelfie() =>
      _upload('selfie', source: ImageSourceKind.camera, frontCamera: true);

  Future<void> _upload(
    String slot, {
    required ImageSourceKind source,
    bool frontCamera = false,
  }) async {
    if (_uploading != null) return;
    setState(() => _uploading = slot);
    try {
      final result =
          await ref.read(imageUploadServiceProvider).pickAndUploadPrivate(
                slot: slot,
                source: source,
                frontCamera: frontCamera,
              );
      if (result == null || !mounted) return;
      setState(() {
        switch (slot) {
          case 'front':
            _front = result;
          case 'back':
            _back = result;
          default:
            _selfie = result;
        }
      });
    } catch (e) {
      if (mounted) {
        ActionFeedback.showError(
            context, context.l10n.commonUploadFailed(describeError(e)));
      }
    } finally {
      if (mounted) setState(() => _uploading = null);
    }
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!_documentDone) {
      ActionFeedback.showError(
          context, l10n.verifyAddDocumentFirst(_selectedDoc.hasBack ? 2 : 1));
      return;
    }
    if (_selfie == null) {
      ActionFeedback.showError(context, l10n.verifyTakeSelfieFirst);
      return;
    }
    setState(() => _submitting = true);
    final result = await ref.read(verificationProvider.notifier).submit(
          VerificationRequest(
            docType: _selectedDoc.apiValue,
            frontUrl: _front!.fileId,
            backUrl: _selectedDoc.hasBack ? _back?.fileId : null,
            selfieUrl: _selfie!.fileId,
          ),
        );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _resubmitting = false;
    });
    result.fold(
      onSuccess: (_) => ActionFeedback.showSuccess(context, l10n.verifySubmitted),
      onFailure: (f) => ActionFeedback.showError(context, f.message),
    );
  }

  Widget _buildSectionHeader({
    required int stepIndex,
    required bool done,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: done ? t.foundContainer : t.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(done ? Icons.check_rounded : icon,
              color: done ? t.found : t.primary, size: 20),
        ),
        const SizedBox(width: BeaconSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.verifyStepLabel(stepIndex),
                  style: text.labelSmall?.copyWith(color: t.onSurfaceMuted)),
              Text(title, style: text.titleMedium),
              const SizedBox(height: 2),
              Text(subtitle, style: text.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final ready = _documentDone && _selfie != null;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(BeaconSpace.page, BeaconSpace.md,
              BeaconSpace.page, BeaconSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: l10n.verifySubmitForReview,
                icon: Icons.verified_user_outlined,
                isLoading: _submitting,
                onPressed:
                    (_submitting || _uploading != null) ? null : _submit,
              ),
              const SizedBox(height: BeaconSpace.md),
              Text(
                ready ? l10n.verifyConfirmOwnership : l10n.verifyAddToContinue,
                style: text.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String label;
  final Uint8List? preview;
  final bool uploading;
  final VoidCallback onTap;

  const _UploadBox({
    required this.label,
    required this.preview,
    required this.uploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final isUploaded = preview != null;
    return Semantics(
      button: true,
      label: isUploaded
          ? l10n.verifyUploadAddedSemantics(label)
          : l10n.verifyUploadAddSemantics(label),
      child: PressScale(
        enabled: !uploading,
        child: AnimatedContainer(
          duration: BeaconMotion.scaled(context, BeaconMotion.state),
          curve: BeaconMotion.standard,
          height: 132,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isUploaded ? t.foundContainer : t.surface,
            borderRadius: BeaconRadius.rXl,
            border: Border.all(
              color: isUploaded ? t.found : t.outlineVariant,
              width: isUploaded ? 1.5 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: uploading ? null : onTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (isUploaded)
                    Opacity(
                      opacity: 0.35,
                      child: Image.memory(preview!,
                          fit: BoxFit.cover, gaplessPlayback: true),
                    ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (uploading)
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: t.primary),
                        )
                      else
                        Icon(
                          isUploaded
                              ? Icons.check_circle_rounded
                              : Icons.add_a_photo_outlined,
                          color: isUploaded ? t.found : t.onSurfaceVar,
                          size: 30,
                        ),
                      const SizedBox(height: BeaconSpace.sm),
                      Text(
                        uploading
                            ? l10n.commonUploading
                            : (isUploaded ? l10n.verifyUploadAdded(label) : label),
                        style: text.titleSmall?.copyWith(
                          color: isUploaded ? t.found : t.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isUploaded ? l10n.verifyTapToReplace : l10n.verifyCameraOrGallery,
                        style: text.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 20.0;
    final w = size.width;
    final h = size.height;
    const r = 6.0;

    canvas.drawLine(Offset(0, len), Offset(0, r), paint);
    canvas.drawArc(Rect.fromLTWH(0, 0, r * 2, r * 2), 3.14, 1.57, false, paint);
    canvas.drawLine(Offset(r, 0), Offset(len, 0), paint);

    canvas.drawLine(Offset(w - len, 0), Offset(w - r, 0), paint);
    canvas.drawArc(Rect.fromLTWH(w - r * 2, 0, r * 2, r * 2), -1.57, 1.57, false, paint);
    canvas.drawLine(Offset(w, r), Offset(w, len), paint);

    canvas.drawLine(Offset(0, h - len), Offset(0, h - r), paint);
    canvas.drawArc(Rect.fromLTWH(0, h - r * 2, r * 2, r * 2), 1.57, 1.57, false, paint);
    canvas.drawLine(Offset(r, h), Offset(len, h), paint);

    canvas.drawLine(Offset(w - len, h), Offset(w - r, h), paint);
    canvas.drawArc(Rect.fromLTWH(w - r * 2, h - r * 2, r * 2, r * 2), 0, 1.57, false, paint);
    canvas.drawLine(Offset(w, h - r), Offset(w, h - len), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) => old.color != color;
}
