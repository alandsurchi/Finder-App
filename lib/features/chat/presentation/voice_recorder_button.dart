import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/voice_recorder_service.dart';
import '../../../widgets/ui/ui.dart';
import 'voice_message_bubble.dart' show formatClip;

/// Hold-to-record microphone. Press and hold starts a recording; release
/// sends it; sliding the finger left past [cancelDistance] throws it away.
/// A plain tap explains the gesture.
class VoiceRecorderButton extends StatefulWidget {
  final VoiceRecorderService recorder;
  final ValueChanged<VoiceRecording> onRecorded;
  final ValueChanged<bool> onRecordingChanged;
  final VoidCallback? onPermissionDenied;
  final double size;

  const VoiceRecorderButton({
    super.key,
    required this.recorder,
    required this.onRecorded,
    required this.onRecordingChanged,
    this.onPermissionDenied,
    this.size = 48,
  });

  static const double cancelDistance = 96;
  static const int minDurationMs = 800;

  @override
  State<VoiceRecorderButton> createState() => _VoiceRecorderButtonState();
}

class _VoiceRecorderButtonState extends State<VoiceRecorderButton> {
  bool _recording = false;
  bool _starting = false;
  double _dragX = 0;

  Future<void> _start() async {
    if (_recording || _starting) return;
    _starting = true;
    final ok = await widget.recorder.start();
    _starting = false;
    if (!mounted) return;
    if (!ok) {
      widget.onPermissionDenied?.call();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _recording = true;
      _dragX = 0;
    });
    widget.onRecordingChanged(true);
  }

  Future<void> _finish({required bool cancel}) async {
    if (!_recording) return;
    setState(() => _recording = false);
    widget.onRecordingChanged(false);
    if (cancel) {
      HapticFeedback.lightImpact();
      await widget.recorder.cancel();
      return;
    }
    final rec = await widget.recorder.stop();
    if (!mounted) return;
    if (rec == null || rec.durationMs < VoiceRecorderButton.minDurationMs) {
      ActionHint.show(context, 'Hold the microphone to record a voice message.');
      return;
    }
    HapticFeedback.selectionClick();
    widget.onRecorded(rec);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ActionHint.show(context, 'Hold to record a voice message.'),
      onLongPressStart: (_) => _start(),
      onLongPressMoveUpdate: (d) {
        if (!_recording) return;
        setState(() => _dragX = d.offsetFromOrigin.dx);
        if (_dragX < -VoiceRecorderButton.cancelDistance) _finish(cancel: true);
      },
      onLongPressEnd: (_) => _finish(cancel: false),
      onLongPressCancel: () => _finish(cancel: true),
      child: AnimatedScale(
        scale: _recording ? 1.25 : 1,
        duration: BeaconMotion.press,
        curve: Curves.easeOutBack,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _recording ? t.error : t.primary,
            boxShadow: _recording
                ? [BoxShadow(color: t.error.withValues(alpha: 0.35), blurRadius: 16, spreadRadius: 2)]
                : null,
          ),
          child: Icon(Icons.mic_rounded, color: _recording ? t.onError : t.onPrimary),
        ),
      ),
    );
  }
}

/// The composer row while recording: pulsing dot, elapsed time and the
/// "slide to cancel" hint. Replaces the text field.
class VoiceRecordingBar extends StatefulWidget {
  final VoiceRecorderService recorder;
  final VoidCallback onCancel;

  const VoiceRecordingBar({super.key, required this.recorder, required this.onCancel});

  @override
  State<VoiceRecordingBar> createState() => _VoiceRecordingBarState();
}

class _VoiceRecordingBarState extends State<VoiceRecordingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  Timer? _tick;
  int _elapsedMs = 0;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted) setState(() => _elapsedMs = widget.recorder.elapsedMs);
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.lg),
      decoration: BoxDecoration(color: t.surfaceLow, borderRadius: BeaconRadius.rXxl),
      child: Row(
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 0.35, end: 1).animate(_pulse),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: t.error),
            ),
          ),
          const SizedBox(width: BeaconSpace.sm),
          Text(
            formatClip(Duration(milliseconds: _elapsedMs)),
            style: text.bodyLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
          const Spacer(),
          Icon(Icons.chevron_left_rounded, size: 18, color: t.onSurfaceMuted),
          Text('Slide to cancel', style: text.labelMedium?.copyWith(color: t.onSurfaceMuted)),
          const SizedBox(width: BeaconSpace.sm),
          AppIconButton(
            icon: Icons.close_rounded,
            tooltip: 'Cancel recording',
            size: 36,
            iconSize: 18,
            variant: AppIconButtonVariant.ghost,
            onPressed: widget.onCancel,
          ),
        ],
      ),
    );
  }
}

/// Tiny transient hint used by the recorder.
class ActionHint {
  static void show(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1600),
    ));
  }
}
