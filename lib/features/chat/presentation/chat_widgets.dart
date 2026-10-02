import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/relative_time.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/ui/ui.dart';
import '../domain/message.dart';

/// "Today", "Yesterday" or a short date, between messages of different days.
class DaySeparator extends StatelessWidget {
  final DateTime day;
  const DaySeparator({super.key, required this.day});

  static String label(DateTime day, AppLocalizations l10n, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final d = DateTime(day.year, day.month, day.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return l10n.commonToday;
    if (diff == 1) return l10n.commonYesterday;
    if (diff < 7) return l10n.commonWeekdayShort('${d.weekday}');
    return shortDate(d, reference: today, l10n: l10n);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: BeaconSpace.md),
        padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.md, vertical: BeaconSpace.xs),
        decoration: BoxDecoration(
          color: t.surfaceHigh,
          borderRadius: BeaconRadius.rPill,
        ),
        child: Text(label(day, context.l10n), style: text.labelSmall?.copyWith(color: t.onSurfaceVar)),
      ),
    );
  }
}

/// The quoted message inside a bubble or above the composer.
class ReplyQuote extends StatelessWidget {
  final ReplyPreview reply;
  final String authorName;
  final bool onPrimary;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const ReplyQuote({
    super.key,
    required this.reply,
    required this.authorName,
    this.onPrimary = false,
    this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final bar = onPrimary ? t.onPrimary : t.primary;
    final bg = onPrimary ? t.onPrimary.withValues(alpha: 0.14) : t.primary.withValues(alpha: 0.08);
    final fg = onPrimary ? t.onPrimary : t.onSurface;
    final muted = onPrimary ? t.onPrimary.withValues(alpha: 0.8) : t.onSurfaceVar;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BeaconRadius.rMd,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: bg, borderRadius: BeaconRadius.rMd),
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, BeaconSpace.sm, 0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: bar,
                    borderRadius: const BorderRadiusDirectional.horizontal(start: Radius.circular(BeaconRadius.md)),
                  ),
                ),
                const SizedBox(width: BeaconSpace.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: BeaconSpace.xs + 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(authorName,
                            style: text.labelSmall?.copyWith(color: bar, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Row(
                          children: [
                            if (reply.hasAudio && !reply.deleted) ...[
                              Icon(Icons.mic_rounded, size: 14, color: muted),
                              const SizedBox(width: 4),
                            ] else if (reply.hasImage && !reply.deleted) ...[
                              Icon(Icons.photo_outlined, size: 14, color: muted),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                reply.summary,
                                style: text.bodySmall?.copyWith(
                                  color: reply.deleted ? muted : fg,
                                  fontStyle: reply.deleted ? FontStyle.italic : null,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (reply.hasImage && !reply.deleted)
                  Padding(
                    padding: const EdgeInsets.all(BeaconSpace.xs),
                    child: ItemImage(url: reply.imageUrl, width: 40, height: 40, borderRadius: BeaconRadius.rSm),
                  ),
                if (onClose != null)
                  AppIconButton(
                    icon: Icons.close_rounded,
                    tooltip: context.l10n.chatCancelReply,
                    size: 32,
                    iconSize: 16,
                    variant: AppIconButtonVariant.ghost,
                    onPressed: onClose!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Drag a bubble to the right to reply (WhatsApp gesture). The reply icon
/// grows as the finger moves; a haptic tick marks the trigger point.
class SwipeToReply extends StatefulWidget {
  final Widget child;
  final VoidCallback onReply;
  final bool enabled;

  const SwipeToReply({super.key, required this.child, required this.onReply, this.enabled = true});

  static const double trigger = 56;
  static const double maxDrag = 80;

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply> with SingleTickerProviderStateMixin {
  double _dx = 0;
  bool _armed = false;
  late final AnimationController _settle = AnimationController(
    vsync: this,
    duration: BeaconMotion.state,
  );

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  void _update(DragUpdateDetails d) {
    if (!widget.enabled) return;
    // Drag "inwards": to the right in LTR, to the left in RTL.
    final dir = context.isRtl ? -1.0 : 1.0;
    final next = (_dx + d.delta.dx * dir).clamp(0.0, SwipeToReply.maxDrag);
    final armed = next >= SwipeToReply.trigger;
    if (armed && !_armed) HapticFeedback.selectionClick();
    setState(() {
      _dx = next;
      _armed = armed;
    });
  }

  void _end(DragEndDetails _) {
    if (_armed) widget.onReply();
    final from = _dx;
    void tick() => setState(() => _dx = from * (1 - _settle.value));
    _settle
      ..reset()
      ..addListener(tick)
      ..forward().whenComplete(() {
        _settle.removeListener(tick);
        if (mounted) {
          setState(() {
            _dx = 0;
            _armed = false;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final reveal = (_dx / SwipeToReply.trigger).clamp(0.0, 1.0);
    final dir = context.isRtl ? -1.0 : 1.0;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: _update,
      onHorizontalDragEnd: _end,
      onHorizontalDragCancel: () => _end(DragEndDetails()),
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          if (_dx > 0)
            PositionedDirectional(
              start: 0,
              child: Opacity(
                opacity: reveal,
                child: Transform.scale(
                  scale: 0.6 + 0.4 * reveal,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _armed ? t.primary : t.surfaceHigh,
                    ),
                    child: Icon(Icons.reply_rounded, size: 18, color: _armed ? t.onPrimary : t.onSurfaceVar),
                  ),
                ),
              ),
            ),
          Transform.translate(offset: Offset(_dx * dir, 0), child: widget.child),
        ],
      ),
    );
  }
}

/// "Jump to latest" pill shown when the user has scrolled up.
class ScrollToLatestPill extends StatelessWidget {
  final int newCount;
  final VoidCallback onTap;
  const ScrollToLatestPill({super.key, required this.newCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Material(
      color: t.surface,
      elevation: 4,
      shadowColor: t.shadow.withValues(alpha: 0.3),
      borderRadius: BeaconRadius.rPill,
      child: InkWell(
        borderRadius: BeaconRadius.rPill,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(BeaconSpace.md, BeaconSpace.sm, BeaconSpace.lg, BeaconSpace.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.keyboard_double_arrow_down_rounded, size: 18, color: t.primary),
              const SizedBox(width: BeaconSpace.xs),
              Text(
                newCount > 0 ? context.l10n.chatNewCount(newCount) : context.l10n.chatLatest,
                style: text.labelMedium?.copyWith(color: t.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "N unread messages" line above the first message the reader had not seen.
class UnreadDivider extends StatelessWidget {
  final int count;
  const UnreadDivider({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BeaconSpace.md),
      child: Row(
        children: [
          Expanded(child: Divider(color: t.primary.withValues(alpha: 0.4))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.md),
            child: Text(
              context.l10n.chatUnreadMessages(count),
              style: text.labelSmall?.copyWith(color: t.primary),
            ),
          ),
          Expanded(child: Divider(color: t.primary.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}
