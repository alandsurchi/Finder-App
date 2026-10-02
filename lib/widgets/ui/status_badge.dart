import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/l10n/l10n.dart';

enum SignalKind { lost, found }

extension SignalKindX on SignalKind {
  Color color(AppColorTokens t) => this == SignalKind.lost ? t.lost : t.found;
  Color onColor(AppColorTokens t) =>
      this == SignalKind.lost ? t.onLost : t.onFound;
  Color container(AppColorTokens t) =>
      this == SignalKind.lost ? t.lostContainer : t.foundContainer;
  String get label => this == SignalKind.lost ? 'LOST' : 'FOUND';
  String localizedLabel(AppLocalizations l10n) =>
      (this == SignalKind.lost ? l10n.commonLost : l10n.commonFound).toUpperCase();
  IconData get icon => this == SignalKind.lost
      ? Icons.search_rounded
      : Icons.check_circle_outline_rounded;

  static SignalKind ofItem(ItemModel item) =>
      item.isLost ? SignalKind.lost : SignalKind.found;
}

enum BadgeStyle { filled, soft, glass }

enum _BadgeText { lost, found, returned, verified, pending, rejected, expired }

/// One source of truth for LOST / FOUND / REWARD / RESOLVED pills.
class StatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color Function(AppColorTokens t) _bg;
  final Color Function(AppColorTokens t) _fg;
  final BadgeStyle style;
  final bool small;
  /// Fixed labels are resolved in build so they follow the app language.
  final _BadgeText? _text;

  const StatusBadge._({
    super.key,
    required this.label,
    required Color Function(AppColorTokens) bg,
    required Color Function(AppColorTokens) fg,
    this.icon,
    this.style = BadgeStyle.filled,
    this.small = false,
    _BadgeText? text,
  })  : _bg = bg,
        _fg = fg,
        _text = text;

  factory StatusBadge.signal(
    SignalKind kind, {
    Key? key,
    BadgeStyle style = BadgeStyle.filled,
    bool small = false,
    bool withIcon = false,
  }) {
    return StatusBadge._(
      key: key,
      label: kind.label,
      text: kind == SignalKind.lost ? _BadgeText.lost : _BadgeText.found,
      icon: withIcon ? kind.icon : null,
      style: style,
      small: small,
      bg: (t) => style == BadgeStyle.soft ? kind.container(t) : kind.color(t),
      fg: (t) => style == BadgeStyle.soft ? kind.color(t) : kind.onColor(t),
    );
  }

  factory StatusBadge.lost(
          {Key? key, BadgeStyle style = BadgeStyle.filled, bool small = false}) =>
      StatusBadge.signal(SignalKind.lost, key: key, style: style, small: small);

  factory StatusBadge.found(
          {Key? key, BadgeStyle style = BadgeStyle.filled, bool small = false}) =>
      StatusBadge.signal(SignalKind.found, key: key, style: style, small: small);

  factory StatusBadge.fromItem(ItemModel item,
          {Key? key, BadgeStyle style = BadgeStyle.filled, bool small = false}) =>
      StatusBadge.signal(SignalKindX.ofItem(item),
          key: key, style: style, small: small);

  factory StatusBadge.reward(String text,
      {Key? key, bool small = false, bool showIcon = true}) {
    return StatusBadge._(
      key: key,
      label: text,
      icon: showIcon ? Icons.workspace_premium_rounded : null,
      small: small,
      bg: (t) => t.accent,
      fg: (t) => t.onAccent,
    );
  }

  /// A post whose item is back with its owner. Shown in Search and on the
  /// post itself; such posts leave the Home feed.
  factory StatusBadge.resolved({Key? key, bool small = false}) {
    return StatusBadge._(
      key: key,
      label: 'RETURNED',
      text: _BadgeText.returned,
      icon: Icons.assignment_turned_in_rounded,
      small: small,
      style: BadgeStyle.soft,
      bg: (t) => t.foundContainer,
      fg: (t) => t.found,
    );
  }

  /// Waiting for an admin to approve it (owner and admins only).
  factory StatusBadge.pending({Key? key, bool small = false}) {
    return StatusBadge._(
      key: key,
      label: 'PENDING',
      text: _BadgeText.pending,
      icon: Icons.hourglass_top_rounded,
      small: small,
      style: BadgeStyle.soft,
      bg: (t) => t.accentContainer,
      fg: (t) => t.accentDeep,
    );
  }

  /// An admin sent it back with a reason.
  factory StatusBadge.rejected({Key? key, bool small = false}) {
    return StatusBadge._(
      key: key,
      label: 'NOT APPROVED',
      text: _BadgeText.rejected,
      icon: Icons.block_rounded,
      small: small,
      style: BadgeStyle.soft,
      bg: (t) => t.errorSurface,
      fg: (t) => t.error,
    );
  }

  /// Archived after 90 days without being resolved.
  factory StatusBadge.expired({Key? key, bool small = false}) {
    return StatusBadge._(
      key: key,
      label: 'ARCHIVED',
      text: _BadgeText.expired,
      icon: Icons.inventory_outlined,
      small: small,
      style: BadgeStyle.soft,
      bg: (t) => t.surfaceHigh,
      fg: (t) => t.onSurfaceVar,
    );
  }

  /// The right status pill for a post, or null when it is simply live.
  static StatusBadge? forStatus(ItemModel item, {bool small = false}) {
    if (item.isPending) return StatusBadge.pending(small: small);
    if (item.isRejected) return StatusBadge.rejected(small: small);
    if (item.isExpired) return StatusBadge.expired(small: small);
    if (item.isResolved) return StatusBadge.resolved(small: small);
    return null;
  }

  factory StatusBadge.verified({Key? key, bool small = true}) {
    return StatusBadge._(
      key: key,
      label: 'VERIFIED',
      text: _BadgeText.verified,
      icon: Icons.verified_rounded,
      small: small,
      style: BadgeStyle.soft,
      bg: (t) => t.primaryContainer,
      fg: (t) => t.primary,
    );
  }

  /// Arbitrary label with an explicit color (used by legacy `BadgeData`).
  factory StatusBadge.custom({
    Key? key,
    required String label,
    required Color color,
    Color? onColor,
    IconData? icon,
    bool small = false,
  }) {
    return StatusBadge._(
      key: key,
      label: label,
      icon: icon,
      small: small,
      bg: (_) => color,
      fg: (t) => onColor ??
          (ThemeData.estimateBrightnessForColor(color) == Brightness.dark
              ? Colors.white
              : t.beacon.onSurface),
    );
  }

  factory StatusBadge.neutral(String label,
      {Key? key, IconData? icon, bool small = false}) {
    return StatusBadge._(
      key: key,
      label: label,
      icon: icon,
      small: small,
      style: BadgeStyle.soft,
      bg: (t) => t.surfaceHigh,
      fg: (t) => t.onSurfaceVar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final bg = _bg(t);
    final fg = _fg(t);
    final isGlass = style == BadgeStyle.glass;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? BeaconSpace.sm : BeaconSpace.md,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: isGlass ? t.glassSurface : bg,
        borderRadius: BeaconRadius.rPill,
        border: isGlass ? Border.all(color: t.glassBorder) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 12 : 14, color: isGlass ? bg : fg),
            const SizedBox(width: BeaconSpace.xs),
          ],
          Text(
            switch (_text) {
              _BadgeText.lost => context.l10n.commonLost.toUpperCase(),
              _BadgeText.found => context.l10n.commonFound.toUpperCase(),
              _BadgeText.returned => context.l10n.commonReturned.toUpperCase(),
              _BadgeText.verified => context.l10n.adminVerifiedLabel.toUpperCase(),
              _BadgeText.pending => context.l10n.adminBadgePending.toUpperCase(),
              _BadgeText.rejected => context.l10n.postBadgeRejected.toUpperCase(),
              _BadgeText.expired => context.l10n.postBadgeExpired.toUpperCase(),
              null => label,
            },
            style: (small ? text.labelSmall : text.labelMedium)?.copyWith(
              color: isGlass ? bg : fg,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// The Beacon signal rail: a 6dp colored edge on the leading side of a card.
class SignalRail extends StatelessWidget {
  final SignalKind kind;
  final double width;
  final BorderRadius? borderRadius;

  const SignalRail({
    super.key,
    required this.kind,
    this.width = 6,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: kind.color(t),
        borderRadius: borderRadius,
      ),
    );
  }
}
