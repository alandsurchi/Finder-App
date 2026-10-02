import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../../widgets/ui/ui.dart';
import '../domain/message.dart';
import 'voice_player_controller.dart';
import 'waveform_bar.dart';

String formatClip(Duration d) {
  final m = d.inMinutes;
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Inline player for a voice note: play/pause, the waveform (seekable), the
/// remaining time and a speed pill while playing. Colours follow the bubble.
class VoiceMessageBubble extends ConsumerWidget {
  final Message message;
  final bool isMe;
  final Color fg;
  final Color muted;

  const VoiceMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.fg,
    required this.muted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final source = message.audioSource;
    final playback = ref.watch(voicePlayerProvider);
    final current = playback != null && playback.source == source ? playback : null;
    final total = current?.duration ??
        (message.audioMs != null ? Duration(milliseconds: message.audioMs!) : null);
    final position = current?.position ?? Duration.zero;
    final progress = (total == null || total.inMilliseconds == 0)
        ? 0.0
        : (position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
    final playing = current?.playing ?? false;
    final loading = current?.loading ?? false;
    final uploading = message.isPending && message.audioUrl.isEmpty;
    final label = current != null && playing
        ? formatClip(total == null ? position : total - position)
        : (total == null ? '0:00' : formatClip(total));
    final speed = current?.speed ?? 1;
    final speedLabel = speed == speed.roundToDouble() ? '${speed.toInt()}' : '$speed';

    return SizedBox(
      width: 240,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: playing ? l10n.voicePause : l10n.voicePlay,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: source.isEmpty
                  ? null
                  : () => ref.read(voicePlayerProvider.notifier).toggle(source),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMe ? t.onPrimary.withValues(alpha: 0.18) : t.primaryContainer,
                ),
                child: loading
                    ? Padding(
                        padding: const EdgeInsets.all(11),
                        child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                      )
                    : Icon(
                        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: isMe ? t.onPrimary : t.primary,
                        size: 26,
                      ),
              ),
            ),
          ),
          const SizedBox(width: BeaconSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                WaveformBar(
                  waveform: message.waveform,
                  progress: progress,
                  fg: fg,
                  muted: muted.withValues(alpha: 0.45),
                  onSeek: current == null || total == null
                      ? null
                      : (p) => ref.read(voicePlayerProvider.notifier).seek(
                            source,
                            Duration(milliseconds: (total.inMilliseconds * p).round()),
                          ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.mic_rounded, size: 12, color: muted),
                    const SizedBox(width: 4),
                    Text(
                      uploading ? l10n.commonSending : label,
                      style: text.labelSmall?.copyWith(color: muted),
                    ),
                    const Spacer(),
                    if (current != null)
                      Material(
                        color: fg.withValues(alpha: 0.14),
                        borderRadius: BeaconRadius.rPill,
                        child: InkWell(
                          borderRadius: BeaconRadius.rPill,
                          onTap: () => ref.read(voicePlayerProvider.notifier).cycleSpeed(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            child: Text(
                              l10n.voiceSpeed(speedLabel),
                              style: text.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
