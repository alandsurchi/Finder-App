import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/l10n.dart';
import '../../../widgets/ui/ui.dart';

enum PhotoEditorMode { avatar, cover }

/// Full-screen crop editor for profile photos. Pinch to zoom, drag to
/// move, rotate in quarter turns; the frame is a circle for the avatar and
/// a wide band for the cover. Returns the cropped image as PNG bytes.
class PhotoEditorScreen extends StatefulWidget {
  final Uint8List bytes;
  final PhotoEditorMode mode;

  const PhotoEditorScreen({super.key, required this.bytes, required this.mode});

  static Future<Uint8List?> open(BuildContext context, Uint8List bytes, PhotoEditorMode mode) {
    return Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PhotoEditorScreen(bytes: bytes, mode: mode),
      ),
    );
  }

  @override
  State<PhotoEditorScreen> createState() => _PhotoEditorScreenState();
}

class _PhotoEditorScreenState extends State<PhotoEditorScreen> {
  ui.Image? _image;
  String? _error;
  double _zoom = 1; // 1 = exactly covers the frame
  Offset _offset = Offset.zero; // image centre relative to frame centre
  int _turns = 0; // quarter turns clockwise
  double _startZoom = 1;
  Offset _startOffset = Offset.zero;
  Offset _startFocal = Offset.zero;
  bool _exporting = false;

  bool get _isAvatar => widget.mode == PhotoEditorMode.avatar;
  double get _aspect => _isAvatar ? 1 : 2.5;
  int get _outputWidth => _isAvatar ? 800 : 1800;
  static const double _maxZoom = 5;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  Future<void> _decode() async {
    try {
      final codec = await ui.instantiateImageCodec(widget.bytes);
      final frame = await codec.getNextFrame();
      if (!mounted) return;
      setState(() => _image = frame.image);
    } catch (e) {
      if (mounted) setState(() => _error = context.l10n.photoOpenFailed);
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  // Rotated image size in source pixels.
  Size _rotatedSize() {
    final img = _image!;
    final odd = _turns.isOdd;
    return Size(odd ? img.height.toDouble() : img.width.toDouble(),
        odd ? img.width.toDouble() : img.height.toDouble());
  }

  double _baseScale(Size frame) {
    final r = _rotatedSize();
    return math.max(frame.width / r.width, frame.height / r.height);
  }

  Offset _clampOffset(Offset o, Size frame, double zoom) {
    final r = _rotatedSize();
    final s = _baseScale(frame) * zoom;
    final maxX = math.max(0.0, r.width * s / 2 - frame.width / 2);
    final maxY = math.max(0.0, r.height * s / 2 - frame.height / 2);
    return Offset(o.dx.clamp(-maxX, maxX), o.dy.clamp(-maxY, maxY));
  }

  void _onScaleStart(ScaleStartDetails d) {
    _startZoom = _zoom;
    _startOffset = _offset;
    _startFocal = d.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails d, Size frame) {
    final zoom = (_startZoom * d.scale).clamp(1.0, _maxZoom);
    // Zoom around the finger: keep the point under the focal point still.
    final centre = Offset(frame.width / 2, frame.height / 2);
    final focalFromCentre = _startFocal - centre;
    final ratio = zoom / _startZoom;
    final scaled = (_startOffset - focalFromCentre) * ratio + focalFromCentre;
    final moved = scaled + (d.localFocalPoint - _startFocal);
    setState(() {
      _zoom = zoom;
      _offset = _clampOffset(moved, frame, zoom);
    });
  }

  void _rotate(Size frame) {
    HapticFeedback.selectionClick();
    setState(() {
      _turns = (_turns + 1) % 4;
      // Rotate the offset with the picture so the same area stays framed.
      _offset = _clampOffset(Offset(-_offset.dy, _offset.dx), frame, _zoom);
    });
  }

  void _reset() {
    setState(() {
      _zoom = 1;
      _offset = Offset.zero;
      _turns = 0;
    });
  }

  Future<void> _export(Size frame) async {
    final img = _image;
    if (img == null || _exporting) return;
    setState(() => _exporting = true);
    try {
      final outW = _outputWidth.toDouble();
      final outH = (outW / _aspect).roundToDouble();
      final k = outW / frame.width; // frame px -> output px
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, outW, outH));
      final s = _baseScale(frame) * _zoom * k;
      canvas.translate(outW / 2 + _offset.dx * k, outH / 2 + _offset.dy * k);
      canvas.rotate(_turns * math.pi / 2);
      canvas.scale(s);
      canvas.drawImage(
        img,
        Offset(-img.width / 2, -img.height / 2),
        Paint()..filterQuality = FilterQuality.high,
      );
      final picture = recorder.endRecording();
      final out = await picture.toImage(outW.toInt(), outH.toInt());
      final data = await out.toByteData(format: ui.ImageByteFormat.png);
      out.dispose();
      picture.dispose();
      if (!mounted) return;
      Navigator.pop(context, data?.buffer.asUint8List());
    } catch (e) {
      if (mounted) {
        setState(() => _exporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.photoPrepareFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final frameW = _isAvatar ? math.min(width - 48, 340.0) : width - 32;
    final frame = Size(frameW, frameW / _aspect);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(BeaconSpace.sm, BeaconSpace.sm, BeaconSpace.md, 0),
              child: Row(
                children: [
                  AppIconButton(
                    icon: Icons.close_rounded,
                    tooltip: l10n.commonCancel,
                    variant: AppIconButtonVariant.ghost,
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      _isAvatar ? l10n.photoAdjustAvatar : l10n.photoAdjustCover,
                      style: text.titleMedium?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(
                    onPressed: _image == null || _exporting ? null : () => _export(frame),
                    child: _exporting
                        ? const SizedBox(
                            width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l10n.photoUse,
                            style: text.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: _error != null
                    ? Text(_error!, style: text.bodyMedium?.copyWith(color: Colors.white70))
                    : _image == null
                        ? const CircularProgressIndicator(color: Colors.white)
                        : GestureDetector(
                            onScaleStart: _onScaleStart,
                            onScaleUpdate: (d) => _onScaleUpdate(d, frame),
                            onDoubleTap: () => setState(() {
                              _zoom = _zoom > 1.5 ? 1 : 2;
                              _offset = _clampOffset(_offset, frame, _zoom);
                            }),
                            child: SizedBox(
                              width: frame.width + 32,
                              height: frame.height + 32,
                              child: ClipRect(
                                child: CustomPaint(
                                  painter: _CropPainter(
                                    image: _image!,
                                    frame: frame,
                                    zoom: _zoom,
                                    offset: _offset,
                                    turns: _turns,
                                    baseScale: _baseScale(frame),
                                    circle: _isAvatar,
                                    accent: t.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(BeaconSpace.lg, 0, BeaconSpace.lg, BeaconSpace.lg),
              child: Column(
                children: [
                  Text(
                    l10n.photoGestureHint,
                    style: text.labelSmall?.copyWith(color: Colors.white60),
                  ),
                  const SizedBox(height: BeaconSpace.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Tool(icon: Icons.rotate_90_degrees_cw_rounded, label: l10n.photoRotate, onTap: _image == null ? null : () => _rotate(frame)),
                      const SizedBox(width: BeaconSpace.xl),
                      _Tool(icon: Icons.zoom_out_map_rounded, label: l10n.photoReset, onTap: _image == null ? null : _reset),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _Tool({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BeaconRadius.rLg,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.lg, vertical: BeaconSpace.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 4),
            Text(label, style: text.labelSmall?.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _CropPainter extends CustomPainter {
  final ui.Image image;
  final Size frame;
  final double zoom;
  final Offset offset;
  final int turns;
  final double baseScale;
  final bool circle;
  final Color accent;

  _CropPainter({
    required this.image,
    required this.frame,
    required this.zoom,
    required this.offset,
    required this.turns,
    required this.baseScale,
    required this.circle,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset((size.width - frame.width) / 2, (size.height - frame.height) / 2);
    final frameRect = origin & frame;
    final s = baseScale * zoom;

    canvas.save();
    canvas.translate(frameRect.center.dx + offset.dx, frameRect.center.dy + offset.dy);
    canvas.rotate(turns * math.pi / 2);
    canvas.scale(s);
    canvas.drawImage(image, Offset(-image.width / 2, -image.height / 2),
        Paint()..filterQuality = FilterQuality.medium);
    canvas.restore();

    // Dim everything outside the frame.
    final hole = circle
        ? (Path()..addOval(frameRect))
        : (Path()..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(BeaconRadius.lg))));
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      hole,
    );
    canvas.drawPath(outside, Paint()..color = Colors.black.withValues(alpha: 0.62));
    canvas.drawPath(
      hole,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.9),
    );
    // Rule-of-thirds guides help framing a face or a landscape.
    final guide = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final x = frameRect.left + frameRect.width * i / 3;
      final y = frameRect.top + frameRect.height * i / 3;
      canvas.drawLine(Offset(x, frameRect.top), Offset(x, frameRect.bottom), guide);
      canvas.drawLine(Offset(frameRect.left, y), Offset(frameRect.right, y), guide);
    }
  }

  @override
  bool shouldRepaint(_CropPainter old) =>
      old.image != image || old.zoom != zoom || old.offset != offset || old.turns != turns ||
      old.frame != frame || old.baseScale != baseScale;
}
