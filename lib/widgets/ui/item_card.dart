import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'package:finder/models/item_model.dart';
import 'item_image.dart';
import 'press_scale.dart';
import 'status_badge.dart';

enum ItemCardLayout { tile, row, compact }

/// Presentational base for every post card in the app.
///
/// * `tile`    — full-width "photo on paper" card with the signal **spine**:
///               a colored edge carrying a vertical LOST / FOUND label.
/// * `row`     — thumbnail left, text right, used in Search / My posts.
/// * `compact` — 148dp wide mini card for horizontal rails.
///
/// Lost = coral, Found = emerald, everywhere, from one rule.
class ItemCard extends StatelessWidget {
  final ItemModel item;
  final ItemCardLayout layout;
  final VoidCallback? onTap;

  /// Badges drawn over the image (defaults to reward / resolved for tiles,
  /// status + reward for rows).
  final List<Widget>? badges;

  /// Widget overlaid top-right on the image (e.g. a save button).
  final Widget? overlay;

  /// Optional row rendered under the meta line (CTA buttons, actions).
  final Widget? footer;

  /// Optional text stamped across the bottom of the image.
  final String? banner;

  /// Extra line under the title (e.g. "Verified owner").
  final Widget? subtitle;

  final bool showDescription;
  final double imageHeight;
  final String? heroTag;
  final EdgeInsetsGeometry? margin;

  const ItemCard({
    super.key,
    required this.item,
    this.layout = ItemCardLayout.tile,
    this.onTap,
    this.badges,
    this.overlay,
    this.footer,
    this.banner,
    this.subtitle,
    this.showDescription = true,
    this.imageHeight = 196,
    this.heroTag,
    this.margin,
  });

  static const double spineWidth = 30;

  List<Widget> _defaultBadges({required bool includeStatus}) => [
        if (includeStatus) StatusBadge.fromItem(item, small: true),
        if (item.reward != null && item.reward!.isNotEmpty)
          StatusBadge.reward(_rewardLabel(item.reward!),
              small: layout != ItemCardLayout.tile),
        if (item.isResolved) StatusBadge.resolved(small: true),
      ];

  static String _rewardLabel(String reward) {
    final r = reward.trim();
    if (r.isEmpty) return 'REWARD';
    if (r.toUpperCase().contains('REWARD')) return r.toUpperCase();
    final startsWithCurrency = RegExp(r'^[\$€£]').hasMatch(r);
    return startsWithCurrency ? 'REWARD $r' : 'REWARD \$$r';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final kind = SignalKindX.ofItem(item);
    final radius = layout == ItemCardLayout.compact
        ? BeaconRadius.rLg
        : BeaconRadius.rXl;

    final body = switch (layout) {
      ItemCardLayout.tile => _tile(context, t, kind),
      ItemCardLayout.row => _row(context, t, kind),
      ItemCardLayout.compact => _compact(context, t, kind),
    };

    final edge = layout == ItemCardLayout.tile
        ? _Spine(kind: kind)
        : SignalRail(kind: kind);

    Widget card = Material(
      color: t.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: t.isDark ? BorderSide(color: t.outlineVariant) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          button: onTap != null,
          label: '${kind.label.toLowerCase()} item, ${item.title}',
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                edge,
                Expanded(child: body),
              ],
            ),
          ),
        ),
      ),
    );

    if (!t.isDark) {
      card = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: t.shadow.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
            BoxShadow(
              color: t.shadow.withValues(alpha: 0.06),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: card,
      );
    }

    if (onTap != null) card = PressScale(scale: 0.985, child: card);
    if (margin != null) card = Padding(padding: margin!, child: card);
    return card;
  }

  // ── Layouts ───────────────────────────────────────────────────────────────

  Widget _tile(BuildContext context, AppColorTokens t, SignalKind kind) {
    final text = Theme.of(context).textTheme;
    final overlays = badges ?? _defaultBadges(includeStatus: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              BeaconSpace.md, BeaconSpace.md, BeaconSpace.md, 0),
          child: Stack(
            children: [
              ItemImage(
                url: item.imagePath,
                height: imageHeight,
                borderRadius: BeaconRadius.rLg,
                fallbackIcon: categoryIcon(item.category),
                heroTag: heroTag,
              ),
              if (overlays.isNotEmpty)
                Positioned(
                  top: BeaconSpace.md,
                  left: BeaconSpace.md,
                  right: 56,
                  child: Wrap(
                    spacing: BeaconSpace.sm,
                    runSpacing: BeaconSpace.sm,
                    children: overlays,
                  ),
                ),
              if (overlay != null)
                Positioned(top: BeaconSpace.sm, right: BeaconSpace.sm, child: overlay!),
              if (banner != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                        BeaconSpace.lg, BeaconSpace.xxl, BeaconSpace.lg, BeaconSpace.md),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(BeaconRadius.lg)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          t.shadow.withValues(alpha: 0),
                          t.shadow.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                    child: Text(
                      banner!,
                      style: text.titleMedium?.copyWith(
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              BeaconSpace.lg, BeaconSpace.lg, BeaconSpace.lg, BeaconSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: text.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: BeaconSpace.sm),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(item.timeAgo,
                        style: text.labelSmall?.copyWith(color: t.onSurfaceMuted)),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: BeaconSpace.xs),
                subtitle!,
              ],
              if (showDescription && item.description.isNotEmpty) ...[
                const SizedBox(height: BeaconSpace.sm),
                Text(
                  item.description,
                  style: text.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: BeaconSpace.md),
              _MetaLine(location: item.location, category: item.category),
              if (footer != null) ...[
                const SizedBox(height: BeaconSpace.lg),
                footer!,
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, AppColorTokens t, SignalKind kind) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(BeaconSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ItemImage(
                url: item.imagePath,
                width: 92,
                height: 92,
                borderRadius: BeaconRadius.rMd,
                fallbackIcon: categoryIcon(item.category),
                heroTag: heroTag,
              ),
              if (overlay != null) Positioned(top: 4, right: 4, child: overlay!),
            ],
          ),
          const SizedBox(width: BeaconSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: BeaconSpace.xs,
                  runSpacing: BeaconSpace.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...(badges ?? _defaultBadges(includeStatus: true)),
                    Text(item.timeAgo,
                        style: text.labelSmall?.copyWith(color: t.onSurfaceMuted)),
                  ],
                ),
                const SizedBox(height: BeaconSpace.sm),
                Text(
                  item.title,
                  style: text.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  subtitle!,
                ],
                const SizedBox(height: BeaconSpace.xs),
                _MetaLine(location: item.location, category: item.category),
                if (footer != null) ...[
                  const SizedBox(height: BeaconSpace.md),
                  footer!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compact(BuildContext context, AppColorTokens t, SignalKind kind) {
    final text = Theme.of(context).textTheme;
    return SizedBox(
      width: 148,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ItemImage(
                url: item.imagePath,
                height: 104,
                fallbackIcon: categoryIcon(item.category),
                heroTag: heroTag,
              ),
              Positioned(
                top: BeaconSpace.sm,
                left: BeaconSpace.sm,
                child: StatusBadge.fromItem(item, small: true),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(BeaconSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category.toUpperCase(),
                  style: text.labelSmall?.copyWith(color: t.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.title,
                  style: text.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.location} · ${item.timeAgo}',
                  style: text.bodySmall?.copyWith(color: t.onSurfaceMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The signal spine: a 30dp colored edge with the status written vertically.
class _Spine extends StatelessWidget {
  final SignalKind kind;
  const _Spine({required this.kind});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Container(
      width: ItemCard.spineWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kind.color(t), kind.color(t).withValues(alpha: 0.82)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: BeaconSpace.lg),
          Icon(kind.icon, size: 14, color: kind.onColor(t)),
          const SizedBox(height: BeaconSpace.sm),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: Center(
                child: Text(
                  kind.label,
                  style: text.labelSmall?.copyWith(
                    color: kind.onColor(t),
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: BeaconSpace.lg),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final String location;
  final String category;
  const _MetaLine({required this.location, required this.category});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final style = text.bodySmall?.copyWith(color: t.onSurfaceVar);
    return Row(
      children: [
        Icon(Icons.place_outlined, size: 15, color: t.onSurfaceMuted),
        const SizedBox(width: BeaconSpace.xs),
        Flexible(
          child: Text(
            location.isEmpty ? 'Location not set' : location,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (category.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.sm),
            child: Text('·', style: style),
          ),
          Icon(categoryIcon(category), size: 15, color: t.onSurfaceMuted),
          const SizedBox(width: BeaconSpace.xs),
          Flexible(
            child: Text(category,
                style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ],
    );
  }
}
