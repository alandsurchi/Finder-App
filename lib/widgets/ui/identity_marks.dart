import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'status_badge.dart';

/// The one colour that is not in the Beacon palette: the administrator mark
/// must read as "staff", clearly different from the primary verified tick.
const Color kAdminColor = Color(0xFF6D4AFF);

/// Inline trust marks next to a person's name: the verified tick and the
/// ADMIN mark. Used wherever a name is shown (feed, search, chats, profile)
/// so a verified or staff account looks the same everywhere.
class IdentityMarks extends StatelessWidget {
  final bool verified;
  final bool admin;
  final double size;

  const IdentityMarks({
    super.key,
    required this.verified,
    this.admin = false,
    this.size = 16,
  });

  bool get isEmpty => !verified && !admin;

  @override
  Widget build(BuildContext context) {
    if (isEmpty) return const SizedBox.shrink();
    final t = AppColorTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (verified) ...[
          const SizedBox(width: BeaconSpace.xs),
          Tooltip(
            message: 'Verified identity',
            child: Icon(Icons.verified_rounded, color: t.primary, size: size),
          ),
        ],
        if (admin) ...[
          const SizedBox(width: BeaconSpace.xs),
          Tooltip(
            message: 'Finder administrator',
            child: Icon(Icons.shield_rounded, color: kAdminColor, size: size),
          ),
        ],
      ],
    );
  }
}

/// A name with its trust marks, ellipsised as one line.
class NameWithMarks extends StatelessWidget {
  final String name;
  final bool verified;
  final bool admin;
  final TextStyle? style;
  final double markSize;

  const NameWithMarks({
    super.key,
    required this.name,
    required this.verified,
    this.admin = false,
    this.style,
    this.markSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(name, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        IdentityMarks(verified: verified, admin: admin, size: markSize),
      ],
    );
  }
}

/// The ADMIN pill for profiles and cards.
StatusBadge adminBadge({bool small = true}) => StatusBadge.custom(
      label: 'ADMIN',
      color: kAdminColor,
      onColor: Colors.white,
      icon: Icons.shield_rounded,
      small: small,
    );
