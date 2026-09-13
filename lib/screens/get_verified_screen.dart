import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finder/core/utils/relative_time.dart';
import 'package:finder/features/profile/domain/verification_status.dart';
import 'package:finder/features/profile/presentation/verification_controller.dart';
import 'package:finder/providers/my_posts_provider.dart';
import 'package:finder/services/image_upload_service.dart';
import 'package:finder/widgets/common/action_feedback.dart';
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
  String get label => switch (this) {
        _DocType.passport => 'Passport',
        _DocType.identityCard => 'Identity card',
        _DocType.driversLicense => "Driver's license",
      };
  bool get hasBack => this != _DocType.passport;
}

class GetVerifiedScreen extends ConsumerStatefulWidget {
  const GetVerifiedScreen({super.key});

  @override
  ConsumerState<GetVerifiedScreen> createState() => _GetVerifiedScreenState();
}

class _GetVerifiedScreenState extends ConsumerState<GetVerifiedScreen> {
  _DocType _selectedDoc = _DocType.passport;
  String? _frontUrl;
  String? _backUrl;
  String? _selfieUrl;
  String? _uploading; // 'front' | 'back' | 'selfie'
  bool _submitting = false;

  bool get _documentDone =>
      _frontUrl != null && (!_selectedDoc.hasBack || _backUrl != null);

  int get _completedSteps {
    var s = 1; // a document type is always selected
    if (_documentDone) s++;
    if (_selfieUrl != null) s++;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final statusState = ref.watch(verificationProvider);
    final status = statusState.value;
    final locked = status != null && (status.isPending || status.isApproved);

    return Scaffold(
      bottomNavigationBar: locked || status == null ? null : _buildBottomBar(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppPageHeader(
              title: 'Verify identity',
              subtitle: status == null
                  ? null
                  : status.isApproved
                      ? 'Your identity is verified'
                      : status.isPending
                          ? 'Under review'
                          : '$_completedSteps of 3 steps complete',
            ),
            Expanded(
              child: statusState.when(
                loading: () => const LoadingWidget(message: 'Checking your status...'),
                error: (err, _) => ErrorStateWidget(
                  message: describeError(err),
                  onRetry: () => ref.read(verificationProvider.notifier).load(),
                ),
                data: (s) => SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(BeaconSpace.page, 0, BeaconSpace.page,
                      BeaconSpace.xxl + MediaQuery.paddingOf(context).bottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StaggeredEntrance(child: _buildHero(t, text, s)),
                      const SizedBox(height: BeaconSpace.xxl),
                      if (locked)
                        StaggeredEntrance(index: 1, child: _buildStatusCard(t, text, s))
                      else
                        ..._buildForm(t, text),
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
                    s.isApproved ? 'Verified member' : 'Security standards',
                    style: text.labelSmall?.copyWith(color: t.onPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: BeaconSpace.lg),
            Text(
              s.isApproved
                  ? 'Thanks for helping keep Finder trustworthy.'
                  : 'Verified accounts help build a safer community for everyone.',
              style: text.headlineSmall?.copyWith(color: t.onPrimary),
            ),
            const SizedBox(height: BeaconSpace.md),
            Text(
              s.isApproved
                  ? 'Your posts and messages now show the verified badge.'
                  : 'Your documents are only used to confirm who you are. Review usually takes a day.',
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

  Widget _buildStatusCard(AppColorTokens t, TextTheme text, VerificationStatus s) {
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
                        approved ? 'Identity verified' : 'Verification pending',
                        style: text.titleMedium,
                      ),
                    ),
                    approved ? StatusBadge.verified() : StatusBadge.neutral('PENDING'),
                  ],
                ),
                const SizedBox(height: BeaconSpace.xs),
                Text(
                  approved
                      ? 'Verified with your ${_docLabel(s.docType)}.'
                      : 'We received your ${_docLabel(s.docType)} ${s.createdAtMs == null ? '' : relativeTime(s.createdAtMs)}. You will be notified when the review is complete.',
                  style: text.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _docLabel(String? apiValue) => switch (apiValue) {
        'id_card' => 'identity card',
        'drivers_license' => "driver's license",
        'passport' => 'passport',
        _ => 'document',
      };

  List<Widget> _buildForm(AppColorTokens t, TextTheme text) {
    return [
      StaggeredEntrance(
        index: 1,
        child: _buildSectionHeader(
          stepIndex: 1,
          done: true,
          icon: Icons.description_outlined,
          title: 'Document selection',
          subtitle: 'Choose the ID you wish to use for verification',
        ),
      ),
      const SizedBox(height: BeaconSpace.md),
      StaggeredEntrance(
        index: 1,
        child: SurfaceCard(
          padding: const EdgeInsets.all(BeaconSpace.sm),
          child: Column(
            children: [
              for (final d in _DocType.values)
                SheetOption(
                  label: d.label,
                  icon: switch (d) {
                    _DocType.passport => Icons.book_outlined,
                    _DocType.identityCard => Icons.badge_outlined,
                    _DocType.driversLicense => Icons.drive_eta_outlined,
                  },
                  selected: _selectedDoc == d,
                  onTap: _submitting ? () {} : () => setState(() => _selectedDoc = d),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: BeaconSpace.xxl),
      StaggeredEntrance(
        index: 2,
        child: _buildSectionHeader(
          stepIndex: 2,
          done: _documentDone,
          icon: Icons.camera_alt_outlined,
          title: 'Upload photos',
          subtitle: _selectedDoc.hasBack
              ? 'Clear photos of both sides of your ID'
              : 'A clear photo of the photo page',
        ),
      ),
      const SizedBox(height: BeaconSpace.md),
      StaggeredEntrance(
        index: 2,
        child: Row(
          children: [
            Expanded(
              child: _UploadBox(
                label: _selectedDoc.hasBack ? 'Front of ID' : 'Photo page',
                url: _frontUrl,
                uploading: _uploading == 'front',
                onTap: () => _upload('front'),
              ),
            ),
            if (_selectedDoc.hasBack) ...[
              const SizedBox(width: BeaconSpace.md),
              Expanded(
                child: _UploadBox(
                  label: 'Back of ID',
                  url: _backUrl,
                  uploading: _uploading == 'back',
                  onTap: () => _upload('back'),
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: BeaconSpace.xxl),
      StaggeredEntrance(
        index: 3,
        child: _buildSectionHeader(
          stepIndex: 3,
          done: _selfieUrl != null,
          icon: Icons.face_outlined,
          title: 'Selfie',
          subtitle: "We'll compare your selfie with your document photo.",
        ),
      ),
      const SizedBox(height: BeaconSpace.md),
      StaggeredEntrance(
        index: 3,
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
                    BoxShadow(color: t.accentGlow, blurRadius: 30, spreadRadius: 4),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _selfieUrl != null
                    ? ItemImage(
                        url: _selfieUrl!,
                        width: 128,
                        height: 128,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(64),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 92,
                            height: 92,
                            child: CustomPaint(painter: _CornerPainter(color: t.primary)),
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
                                : Icon(Icons.camera_alt_outlined,
                                    color: t.onPrimary, size: 26),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: BeaconSpace.xl),
              AppButton(
                label: _selfieUrl != null ? 'Retake selfie' : 'Add a selfie',
                icon: Icons.camera_alt_outlined,
                expand: false,
                size: AppButtonSize.medium,
                variant: _selfieUrl != null
                    ? AppButtonVariant.tonal
                    : AppButtonVariant.primary,
                isLoading: _uploading == 'selfie',
                onPressed: _uploading != null ? null : () => _upload('selfie'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: BeaconSpace.lg),
      StaggeredEntrance(
        index: 4,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: t.accent, size: 18),
            const SizedBox(width: BeaconSpace.sm),
            Expanded(
              child: Text(
                'Use a well-lit area, keep the whole document in frame and remove hats or sunglasses for the selfie.',
                style: text.bodySmall,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Future<void> _upload(String slot) async {
    if (_uploading != null) return;
    setState(() => _uploading = slot);
    try {
      final url = await ImageUploadService.pickAndUpload(
        folder: 'verification',
        fileName: '${slot}_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (url == null || !mounted) return;
      setState(() {
        switch (slot) {
          case 'front':
            _frontUrl = url;
          case 'back':
            _backUrl = url;
          default:
            _selfieUrl = url;
        }
      });
    } catch (e) {
      if (mounted) ActionFeedback.showError(context, 'Upload failed. ${describeError(e)}');
    } finally {
      if (mounted) setState(() => _uploading = null);
    }
  }

  Future<void> _submit() async {
    if (!_documentDone) {
      ActionFeedback.showError(context, 'Please upload your document photo${_selectedDoc.hasBack ? 's' : ''} first.');
      return;
    }
    if (_selfieUrl == null) {
      ActionFeedback.showError(context, 'Please add a selfie to finish.');
      return;
    }
    setState(() => _submitting = true);
    final result = await ref.read(verificationProvider.notifier).submit(
          VerificationRequest(
            docType: _selectedDoc.apiValue,
            frontUrl: _frontUrl!,
            backUrl: _selectedDoc.hasBack ? _backUrl : null,
            selfieUrl: _selfieUrl!,
          ),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    result.fold(
      onSuccess: (_) => ActionFeedback.showSuccess(
        context,
        'Verification submitted. We will review it shortly.',
      ),
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
              Text('STEP $stepIndex',
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
    final ready = _documentDone && _selfieUrl != null;
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: 'Submit for verification',
                icon: Icons.verified_user_outlined,
                isLoading: _submitting,
                onPressed: (_submitting || _uploading != null) ? null : _submit,
              ),
              const SizedBox(height: BeaconSpace.md),
              Text(
                ready
                    ? 'By submitting you confirm the documents are yours.'
                    : 'Upload your document and a selfie to continue.',
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
  final String? url;
  final bool uploading;
  final VoidCallback onTap;

  const _UploadBox({
    required this.label,
    required this.url,
    required this.uploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final isUploaded = url != null;
    return Semantics(
      button: true,
      label: isUploaded ? '$label uploaded, tap to replace' : 'Upload $label',
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
                      child: ItemImage(url: url!, fit: BoxFit.cover, borderRadius: BorderRadius.zero),
                    ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (uploading)
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: t.primary),
                        )
                      else
                        Icon(
                          isUploaded ? Icons.check_circle_rounded : Icons.upload_file_outlined,
                          color: isUploaded ? t.found : t.onSurfaceVar,
                          size: 30,
                        ),
                      const SizedBox(height: BeaconSpace.sm),
                      Text(
                        uploading ? 'Uploading…' : (isUploaded ? '$label added' : label),
                        style: text.titleSmall?.copyWith(
                          color: isUploaded ? t.found : t.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isUploaded ? 'Tap to replace' : 'JPG or PNG',
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
