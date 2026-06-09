import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:finder/theme/app_color_tokens.dart';

enum _DocType { passport, identityCard, driversLicense }

class GetVerifiedScreen extends StatefulWidget {
  const GetVerifiedScreen({Key? key}) : super(key: key);

  @override
  State<GetVerifiedScreen> createState() => _GetVerifiedScreenState();
}

class _GetVerifiedScreenState extends State<GetVerifiedScreen> {
  _DocType _selectedDoc = _DocType.passport;
  bool _frontUploaded = false;
  bool _backUploaded = false;
  bool _cameraOpened = false;
  bool _submitted = false;

  AppColorTokens get t => AppColorTokens.of(context);
  Color get _bg => t.bg;
  Color get _blue => t.primary;
  Color get _blueLight => t.primaryContainer;
  Color get _white => t.surface;
  Color get _divider => t.divider;
  Color get _textLight => t.onSurfaceMuted;
  Color get _textDark => t.onSurface;

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      // ── Bottom submit button ────────────────────────────────────────────────
      bottomNavigationBar: _buildBottomBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App bar ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Verify Identity',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Hero banner ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: t.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Security badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: Colors.white,
                              size: 13,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Security Standards',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Verified accounts\nhelp build a safer\ncommunity for\neveryone.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Your data is encrypted and stored securely. Verification only takes a few minutes.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Step 1: Document Selection ─────────────────────────────────
              _buildSectionHeader(
                stepIndex: 1,
                icon: Icons.description_outlined,
                title: 'Step 1: Document Selection',
                subtitle: 'Choose the ID you wish to use for verification',
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: t.divider),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildDocOption(
                        label: 'Passport',
                        icon: Icons.book_outlined,
                        value: _DocType.passport,
                      ),
                      Divider(color: t.divider, height: 1),
                      _buildDocOption(
                        label: 'Identity Card',
                        icon: Icons.badge_outlined,
                        value: _DocType.identityCard,
                      ),
                      Divider(color: t.divider, height: 1),
                      _buildDocOption(
                        label: "Driver's License",
                        icon: Icons.drive_eta_outlined,
                        value: _DocType.driversLicense,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Step 2: Upload Photos ──────────────────────────────────────
              _buildSectionHeader(
                stepIndex: 2,
                icon: Icons.camera_alt_outlined,
                title: 'Step 2: Upload Photos',
                subtitle: 'Upload clear photos of both sides of your ID',
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildUploadBox(
                      label: 'Front of ID',
                      isUploaded: _frontUploaded,
                      onTap: () => setState(() => _frontUploaded = true),
                    ),
                    const SizedBox(height: 12),
                    _buildUploadBox(
                      label: 'Back of ID',
                      isUploaded: _backUploaded,
                      onTap: () => setState(() => _backUploaded = true),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Step 3: Facial Verification ────────────────────────────────
              _buildSectionHeader(
                stepIndex: 3,
                icon: Icons.face_outlined,
                title: 'Step 3: Facial Verification',
                subtitle:
                    'We\'ll compare your selfie with your document photo.',
              ),

              const SizedBox(height: 12),

              // Camera UI card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: t.divider),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: t.primary.withOpacity(0.1),
                          border: Border.all(
                            color: t.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Corner brackets
                            _CameraCorners(),
                            // Camera icon
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _blue.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _cameraOpened
                                    ? Icons.check_circle_outline
                                    : Icons.camera_alt_outlined,
                                color: _blue,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Open Camera button
                      SizedBox(
                        width: 200,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: t.primary,
                            foregroundColor: t.isDark
                                ? Colors.black
                                : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => setState(() => _cameraOpened = true),
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: Text(
                            _cameraOpened ? 'Retake Selfie' : 'Open Camera',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Tip row ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: t.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Make sure you are in a well-lit area and not wearing a hat or glasses.',
                        style: TextStyle(
                          color: t.onSurfaceVar,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required int stepIndex,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final t = AppColorTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: t.iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: t.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: t.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: t.onSurfaceVar,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Document option row ────────────────────────────────────────────────────
  Widget _buildDocOption({
    required String label,
    required IconData icon,
    required _DocType value,
  }) {
    final t = AppColorTokens.of(context);
    final selected = _selectedDoc == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedDoc = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? t.primary.withOpacity(0.08) : t.surface,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? t.primary : t.onSurfaceVar, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? t.primary : t.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? t.primary : t.surface,
                border: Border.all(
                  color: selected ? t.primary : t.divider,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Upload box ─────────────────────────────────────────────────────────────
  Widget _buildUploadBox({
    required String label,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: isUploaded ? _blueLight : _white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? _blue : _divider,
            width: isUploaded ? 1.5 : 1,
            style: isUploaded ? BorderStyle.solid : BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUploaded
                  ? Icons.check_circle_outline
                  : Icons.insert_drive_file_outlined,
              color: isUploaded ? _blue : _textLight,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              isUploaded ? '✓ $label Uploaded' : label,
              style: TextStyle(
                color: isUploaded ? _blue : _textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isUploaded ? 'Tap to replace' : 'JPG, PNG up to 10MB',
              style: TextStyle(color: _textLight, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom submit bar ──────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _submitted
                  ? null
                  : () {
                      setState(() => _submitted = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Verification submitted! We\'ll review shortly.',
                              ),
                            ],
                          ),
                          backgroundColor: _blue,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
              child: Text(
                _submitted
                    ? 'Verification Submitted ✓'
                    : 'Submit for Verification',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Terms text
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: _textLight, fontSize: 11),
              children: [
                const TextSpan(text: 'By submitting, you agree to our '),
                TextSpan(
                  text: 'Verification Terms',
                  style: TextStyle(
                    color: _blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Camera corner brackets ────────────────────────────────────────────────────
class _CameraCorners extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: CustomPaint(painter: _CornerPainter()),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB)
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
