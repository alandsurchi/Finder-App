import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:finder/widgets/ui/ui.dart';

enum _DocType { passport, identityCard, driversLicense }

class GetVerifiedScreen extends StatefulWidget {
  const GetVerifiedScreen({super.key});

  @override
  State<GetVerifiedScreen> createState() => _GetVerifiedScreenState();
}

class _GetVerifiedScreenState extends State<GetVerifiedScreen> {
  _DocType _selectedDoc = _DocType.passport;
  bool _frontUploaded = false;
  bool _backUploaded = false;
  bool _cameraOpened = false;
  bool _submitted = false;

  // ── Progress ────────────────────────────────────────────────────────────────
  int get _completedSteps {
    int s = 0;
    // Step 1 always counts (a doc type is always selected)
    s++;
    // Step 2: both sides uploaded
    if (_frontUploaded && _backUploaded) s++;
    // Step 3: camera opened
    if (_cameraOpened) s++;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      // ── Bottom submit button ────────────────────────────────────────────────
      bottomNavigationBar: _buildBottomBar(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppPageHeader(
              title: 'Verify identity',
              subtitle: '$_completedSteps of 3 steps complete',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    BeaconSpace.page, 0, BeaconSpace.page, BeaconSpace.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Hero banner ───────────────────────────────────────
                    StaggeredEntrance(
                      child: Material(
                        color: t.primary,
                        borderRadius: BeaconRadius.rXl,
                        child: Padding(
                          padding: const EdgeInsets.all(BeaconSpace.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Security badge
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
                                      'Security standards',
                                      style: text.labelSmall?.copyWith(color: t.onPrimary),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: BeaconSpace.lg),
                              Text(
                                'Verified accounts help build a safer community for everyone.',
                                style: text.headlineSmall?.copyWith(color: t.onPrimary),
                              ),
                              const SizedBox(height: BeaconSpace.md),
                              Text(
                                'Your data is encrypted and stored securely. Verification only takes a few minutes.',
                                style: text.bodyMedium?.copyWith(
                                  color: t.onPrimary.withValues(alpha: 0.85),
                                ),
                              ),
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
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: BeaconSpace.xxl),

                    // ── Step 1: Document Selection ─────────────────────────
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
                            _buildDocOption(
                              label: 'Passport',
                              icon: Icons.book_outlined,
                              value: _DocType.passport,
                            ),
                            _buildDocOption(
                              label: 'Identity card',
                              icon: Icons.badge_outlined,
                              value: _DocType.identityCard,
                            ),
                            _buildDocOption(
                              label: "Driver's license",
                              icon: Icons.drive_eta_outlined,
                              value: _DocType.driversLicense,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: BeaconSpace.xxl),

                    // ── Step 2: Upload Photos ──────────────────────────────
                    StaggeredEntrance(
                      index: 2,
                      child: _buildSectionHeader(
                        stepIndex: 2,
                        done: _frontUploaded && _backUploaded,
                        icon: Icons.camera_alt_outlined,
                        title: 'Upload photos',
                        subtitle: 'Upload clear photos of both sides of your ID',
                      ),
                    ),

                    const SizedBox(height: BeaconSpace.md),

                    StaggeredEntrance(
                      index: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildUploadBox(
                              label: 'Front of ID',
                              isUploaded: _frontUploaded,
                              onTap: () => setState(() => _frontUploaded = true),
                            ),
                          ),
                          const SizedBox(width: BeaconSpace.md),
                          Expanded(
                            child: _buildUploadBox(
                              label: 'Back of ID',
                              isUploaded: _backUploaded,
                              onTap: () => setState(() => _backUploaded = true),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: BeaconSpace.xxl),

                    // ── Step 3: Facial Verification ────────────────────────
                    StaggeredEntrance(
                      index: 3,
                      child: _buildSectionHeader(
                        stepIndex: 3,
                        done: _cameraOpened,
                        icon: Icons.face_outlined,
                        title: 'Facial verification',
                        subtitle:
                            "We'll compare your selfie with your document photo.",
                      ),
                    ),

                    const SizedBox(height: BeaconSpace.md),

                    // Camera UI card
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
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Corner brackets
                                  SizedBox(
                                    width: 92,
                                    height: 92,
                                    child: CustomPaint(
                                      painter: _CornerPainter(color: t.primary),
                                    ),
                                  ),
                                  // Camera icon
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: _cameraOpened ? t.found : t.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _cameraOpened
                                          ? Icons.check_rounded
                                          : Icons.camera_alt_outlined,
                                      color: _cameraOpened ? t.onFound : t.onPrimary,
                                      size: 26,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: BeaconSpace.xl),

                            // Open Camera button
                            AppButton(
                              label: _cameraOpened ? 'Retake selfie' : 'Open camera',
                              icon: Icons.camera_alt_outlined,
                              expand: false,
                              size: AppButtonSize.medium,
                              variant: _cameraOpened
                                  ? AppButtonVariant.tonal
                                  : AppButtonVariant.primary,
                              onPressed: () => setState(() => _cameraOpened = true),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: BeaconSpace.lg),

                    // ── Tip row ────────────────────────────────────────────
                    StaggeredEntrance(
                      index: 4,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, color: t.accent, size: 18),
                          const SizedBox(width: BeaconSpace.sm),
                          Expanded(
                            child: Text(
                              'Make sure you are in a well-lit area and not wearing a hat or glasses.',
                              style: text.bodySmall,
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
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────
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

  // ── Document option row ────────────────────────────────────────────────────
  Widget _buildDocOption({
    required String label,
    required IconData icon,
    required _DocType value,
  }) {
    final selected = _selectedDoc == value;
    return SheetOption(
      label: label,
      icon: icon,
      selected: selected,
      onTap: () => setState(() => _selectedDoc = value),
    );
  }

  // ── Upload box ─────────────────────────────────────────────────────────────
  Widget _buildUploadBox({
    required String label,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: isUploaded ? '$label uploaded, tap to replace' : 'Upload $label',
      child: PressScale(
        child: AnimatedContainer(
          duration: BeaconMotion.scaled(context, BeaconMotion.state),
          curve: BeaconMotion.standard,
          height: 132,
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
              borderRadius: BeaconRadius.rXl,
              onTap: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isUploaded
                        ? Icons.check_circle_rounded
                        : Icons.upload_file_outlined,
                    color: isUploaded ? t.found : t.onSurfaceVar,
                    size: 30,
                  ),
                  const SizedBox(height: BeaconSpace.sm),
                  Text(
                    isUploaded ? '$label uploaded' : label,
                    style: text.titleSmall?.copyWith(
                      color: isUploaded ? t.found : t.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUploaded ? 'Tap to replace' : 'JPG, PNG up to 10MB',
                    style: text.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom submit bar ──────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
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
              // Submit button
              AppButton(
                label: _submitted
                    ? 'Verification submitted'
                    : 'Submit for verification',
                icon: _submitted ? Icons.check_rounded : Icons.verified_user_outlined,
                onPressed: _submitted
                    ? null
                    : () {
                        setState(() => _submitted = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: t.found,
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Verification submitted! We\'ll review shortly.',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
              ),

              const SizedBox(height: BeaconSpace.md),

              // Terms text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: text.bodySmall,
                  children: [
                    const TextSpan(text: 'By submitting, you agree to our '),
                    TextSpan(
                      text: 'Verification Terms',
                      style: TextStyle(
                        color: t.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Camera corner brackets ────────────────────────────────────────────────────
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

    // Top-left
    canvas.drawLine(Offset(0, len), Offset(0, r), paint);
    canvas.drawArc(Rect.fromLTWH(0, 0, r * 2, r * 2), 3.14, 1.57, false, paint);
    canvas.drawLine(Offset(r, 0), Offset(len, 0), paint);

    // Top-right
    canvas.drawLine(Offset(w - len, 0), Offset(w - r, 0), paint);
    canvas.drawArc(
      Rect.fromLTWH(w - r * 2, 0, r * 2, r * 2),
      -1.57,
      1.57,
      false,
      paint,
    );
    canvas.drawLine(Offset(w, r), Offset(w, len), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, h - len), Offset(0, h - r), paint);
    canvas.drawArc(
      Rect.fromLTWH(0, h - r * 2, r * 2, r * 2),
      1.57,
      1.57,
      false,
      paint,
    );
    canvas.drawLine(Offset(r, h), Offset(len, h), paint);

    // Bottom-right
    canvas.drawLine(Offset(w - len, h), Offset(w - r, h), paint);
    canvas.drawArc(
      Rect.fromLTWH(w - r * 2, h - r * 2, r * 2, r * 2),
      0,
      1.57,
      false,
      paint,
    );
    canvas.drawLine(Offset(w, h - r), Offset(w, h - len), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) => old.color != color;
}
