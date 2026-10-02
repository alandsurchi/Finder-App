import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/l10n.dart';
import '../../../services/voice_recorder_service.dart';
import '../../../widgets/ui/ui.dart';
import 'voice_message_bubble.dart' show formatClip;
import 'voice_recorder_machine.dart';
import 'waveform_bar.dart';

export 'voice_recorder_machine.dart' show RecorderPhase;

/// The microphone button, WhatsApp style:
/// - hold to record, release to send, slide inwards to cancel,
/// - slide up while holding to lock (hands-free),
/// - or tap once to start a locked recording and tap again to send.
/// While locked the button becomes the send button.
class VoiceRecorderButton extends StatefulWidget {
  final VoiceRecorderService recorder;
  final ValueChanged<VoiceRecording> onRecorded;
  final ValueChanged<RecorderPhase> onPhaseChanged;
  /// 0..1 while holding: how close the finger is to locking.
  final ValueChanged<double>? onLockProgress;
  final VoidCallback? onPermissionDenied;
  final double size;

  const VoiceRecorderButton({
    super.key,
    required this.recorder,
    required this.onRecorded,
    required this.onPhaseChanged,
    this.onLockProgress,
    this.onPermissionDenied,
    this.size = 48,
  });

  static const int minDurationMs = 800;

  @override
  State<VoiceRecorderButton> createState() => VoiceRecorderButtonState();
}

class VoiceRecorderButtonState extends State<VoiceRecorderButton> {
  final _machine = VoiceRecorderMachine();
  Timer? _maxTimer;
  bool _busy = false;

  RecorderPhase get phase => _machine.phase;

  /// The trash button in the recording bar.
  void cancelFromBar() => _execute(_machine.trash());

  /// The send button in the recording bar (same as tapping the mic).
  void sendFromBar() => _execute(_machine.tap());

  @override
  void dispose() {
    _maxTimer?.cancel();
    super.dispose();
  }

  void _notify() => widget.onPhaseChanged(_machine.phase);

  Future<void> _execute(RecorderCommand cmd) async {
    switch (cmd) {
      case RecorderCommand.none:
        return;
      case RecorderCommand.start:
      case RecorderCommand.startLocked:
        await _start(cmd == RecorderCommand.startLocked);
        return;
      case RecorderCommand.lock:
        HapticFeedback.selectionClick();
        setState(() {});
        _notify();
        return;
      case RecorderCommand.cancel:
        await _cancel();
        return;
      case RecorderCommand.finish:
        await _finish();
        return;
    }
  }

  Future<void> _start(bool locked) async {
    if (_busy) return;
    _busy = true;
    final ok = await widget.recorder.start();
    _busy = false;
    if (!mounted) return;
    if (!ok) {
      _machine.startFailed();
      setState(() {});
      _notify();
      widget.onPermissionDenied?.call();
      return;
    }
    HapticFeedback.mediumImpact();
    _maxTimer?.cancel();
    _maxTimer = Timer(const Duration(milliseconds: VoiceRecorderService.maxDurationMs), () {
      _execute(_machine.timeUp());
    });
    setState(() {});
    _notify();
  }

  Future<void> _cancel() async {
    _maxTimer?.cancel();
    HapticFeedback.lightImpact();
    await widget.recorder.cancel();
    if (!mounted) return;
    _machine.reset();
    setState(() {});
    _notify();
  }

  Future<void> _finish() async {
    _maxTimer?.cancel();
    final rec = await widget.recorder.stop();
    if (!mounted) return;
    _machine.reset();
    setState(() {});
    _notify();
    if (rec == null || rec.durationMs < VoiceRecorderButton.minDurationMs) {
      ActionHint.show(context, context.l10n.voiceHoldHint);
      return;
    }
    HapticFeedback.selectionClick();
    widget.onRecorded(rec);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final l10n = context.l10n;
    // Slide "inwards" to cancel: left in LTR, right in RTL.
    final dir = context.isRtl ? 1.0 : -1.0;
    final recording = _machine.isRecording;
    final locked = _machine.locked;
    return Semantics(
      button: true,
      label: locked ? l10n.voiceSend : l10n.voiceTapToLock,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _execute(_machine.tap()),
        onLongPressStart: (_) => _execute(_machine.longPressStart()),
        onLongPressMoveUpdate: (d) {
          final o = d.offsetFromOrigin;
          final cmd = _machine.move(o.dx * dir * -1, o.dy);
          if (cmd == RecorderCommand.none) {
            widget.onLockProgress?.call(_machine.lockProgress);
          } else {
            _execute(cmd);
          }
        },
        onLongPressEnd: (_) => _execute(_machine.release()),
        onLongPressCancel: () => _execute(_machine.release()),
        child: AnimatedScale(
          scale: recording && !locked ? 1.25 : 1,
          duration: BeaconMotion.press,
          curve: Curves.easeOutBack,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: locked ? t.primary : (recording ? t.error : t.primary),
              boxShadow: recording && !locked
                  ? [BoxShadow(color: t.error.withValues(alpha: 0.35), blurRadius: 16, spreadRadius: 2)]
                  : null,
            ),
            child: Icon(
              locked ? Icons.send_rounded : Icons.mic_rounded,
              color: locked ? t.onPrimary : (recording ? t.onError : t.onPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

/// The composer row while recording. Holding: pulsing dot, timer, "slide to
/// cancel" and the "slide up to lock" hint. Locked: timer, live waveform
/// and a trash button; the mic button has turned into Send.
class VoiceRecordingBar extends StatefulWidget {
  final VoiceRecorderService recorder;
  final bool locked;
  final double lockProgress;
  final VoidCallback onCancel;

  const VoiceRecordingBar({
    super.key,
    required this.recorder,
    required this.onCancel,
    this.locked = false,
    this.lockProgress = 0,
  });

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
    final l10n = context.l10n;
    final timer = Text(
      formatClip(Duration(milliseconds: _elapsedMs)),
      style: text.bodyLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
    );
    return AnimatedContainer(
      duration: BeaconMotion.scaled(context, BeaconMotion.state),
      height: 48,
      padding: const EdgeInsetsDirectional.fromSTEB(BeaconSpace.md, 0, BeaconSpace.sm, 0),
      decoration: BoxDecoration(
        color: widget.locked ? t.primaryContainer : t.surfaceLow,
        borderRadius: BeaconRadius.rXxl,
      ),
      child: widget.locked
          ? Row(
              children: [
                AppIconButton(
                  icon: Icons.delete_outline_rounded,
                  tooltip: l10n.voiceDiscard,
                  size: 36,
                  iconSize: 20,
                  variant: AppIconButtonVariant.ghost,
                  color: t.error,
                  onPressed: widget.onCancel,
                ),
                const SizedBox(width: BeaconSpace.xs),
                timer,
                const SizedBox(width: BeaconSpace.md),
                Expanded(
                  child: LiveWaveform(samples: widget.recorder.samples, color: t.primary),
                ),
                const SizedBox(width: BeaconSpace.sm),
              ],
            )
          : Row(
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
                timer,
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chevron_left_rounded, size: 16, color: t.onSurfaceMuted),
                        Text(l10n.voiceSlideToCancel,
                            style: text.labelSmall?.copyWith(color: t.onSurfaceMuted)),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.lockProgress > 0.6 ? Icons.lock_rounded : Icons.lock_open_rounded,
                          size: 14,
                          color: Color.lerp(t.onSurfaceMuted, t.primary, widget.lockProgress),
                        ),
                        const SizedBox(width: 2),
                        Text(l10n.voiceSlideUpToLock,
                            style: text.labelSmall?.copyWith(
                                color: Color.lerp(t.onSurfaceMuted, t.primary, widget.lockProgress))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: BeaconSpace.sm),
                AppIconButton(
                  icon: Icons.close_rounded,
                  tooltip: l10n.voiceCancelRecording,
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
