import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/ui/ui.dart';
import '../domain/message.dart';
import 'voice_player_controller.dart';

String formatClip(Duration d) {
  final m = d.inMinutes;
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Inline player for a voice note: play/pause, a seekable bar and the
/// remaining time. Colours follow the bubble (mine vs theirs).
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

    return SizedBox(
      width: 232,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            button: true,
            label: playing ? 'Pause voice message' : 'Play voice message',
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
                SizedBox(
                  height: 28,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: fg,
                      inactiveTrackColor: muted.withValues(alpha: 0.4),
                      thumbColor: fg,
                      overlayColor: fg.withValues(alpha: 0.15),
                    ),
                    child: Slider(
                      value: progress,
                      onChanged: current == null || total == null
                          ? null
                          : (v) => ref.read(voicePlayerProvider.notifier).seek(
                                source,
                                Duration(milliseconds: (total.inMilliseconds * v).round()),
                              ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Row(
                    children: [
                      Icon(Icons.mic_rounded, size: 12, color: muted),
                      const SizedBox(width: 4),
                      Text(
                        uploading ? 'Sending…' : label,
                        style: text.labelSmall?.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
