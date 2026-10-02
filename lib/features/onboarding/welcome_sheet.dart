import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finder/l10n/l10n.dart';
import 'package:finder/widgets/ui/ui.dart';

import '../../screens/help_support_screen.dart';

const _seenKey = 'welcome_seen_v1';

/// Shows the one-time welcome sheet on first entry after sign-in: what
/// Finder is, the three things to do, and where the full guide lives. The
/// flag is per install; signing out does not bring it back.
Future<void> showWelcomeIfNeeded(BuildContext context) async {
  SharedPreferences prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (_) {
    return;
  }
  if (prefs.getBool(_seenKey) == true || !context.mounted) return;
  await prefs.setBool(_seenKey, true);
  if (!context.mounted) return;
  await showWelcomeSheet(context);
}

/// The welcome sheet itself (also reachable again from Help & Support).
Future<void> showWelcomeSheet(BuildContext context) {
  return AppBottomSheet.show<void>(
    context,
    builder: (sheetCtx) => const _WelcomeSheet(),
  );
}

class _WelcomeSheet extends StatelessWidget {
  const _WelcomeSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return AppBottomSheet(
      title: l10n.welcomeTitle,
      subtitle: l10n.welcomeSubtitle,
      actions: [
        AppButton.ghost(label: l10n.welcomeGotIt, onPressed: () => Navigator.pop(context)),
        AppButton(
          label: l10n.welcomeOpenHelp,
          icon: Icons.menu_book_outlined,
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
          },
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Step(
            icon: Icons.add_a_photo_outlined,
            color: t.lost,
            onColor: t.onLost,
            title: l10n.welcomeStep1Title,
            body: l10n.welcomeStep1Body,
          ),
          const SizedBox(height: BeaconSpace.md),
          _Step(
            icon: Icons.join_inner_rounded,
            color: t.found,
            onColor: t.onFound,
            title: l10n.welcomeStep2Title,
            body: l10n.welcomeStep2Body,
          ),
          const SizedBox(height: BeaconSpace.md),
          _Step(
            icon: Icons.handshake_outlined,
            color: t.primary,
            onColor: t.onPrimary,
            title: l10n.welcomeStep3Title,
            body: l10n.welcomeStep3Body,
          ),
          const SizedBox(height: BeaconSpace.lg),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: t.onSurfaceMuted),
              const SizedBox(width: BeaconSpace.sm),
              Expanded(
                child: Text(
                  l10n.welcomeHelpHint,
                  style: text.bodySmall?.copyWith(color: t.onSurfaceMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color onColor;
  final String title;
  final String body;
  const _Step({required this.icon, required this.color, required this.onColor, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color, borderRadius: BeaconRadius.rMd),
          child: Icon(icon, color: onColor, size: 22),
        ),
        const SizedBox(width: BeaconSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text.titleSmall),
              const SizedBox(height: 2),
              Text(body, style: text.bodyMedium?.copyWith(color: t.onSurfaceVar, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
