import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'app_button.dart';
import 'beacon_glow.dart';
import 'staggered_entrance.dart';

/// Shared layout for the authentication flow: beacon backdrop, optional back
/// button, brand mark, headline and a centred, width-capped form column.
class AuthShell extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? topTrailing;
  final Widget? aboveTitle;

  const AuthShell({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.showBack = false,
    this.onBack,
    this.topTrailing,
    this.aboveTitle,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: BeaconBackdrop(
        secondary: true,
        rings: true,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    BeaconSpace.page, BeaconSpace.sm, BeaconSpace.page, BeaconSpace.xxxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showBack || topTrailing != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: BeaconSpace.lg),
                        child: Row(
                          children: [
                            if (showBack)
                              AppIconButton(
                                icon: Icons.arrow_back_rounded,
                                tooltip: 'Back',
                                onPressed: onBack ?? () => Navigator.maybePop(context),
                              ),
                            const Spacer(),
                            if (topTrailing != null) topTrailing!,
                          ],
                        ),
                      )
                    else
                      const SizedBox(height: BeaconSpace.xxl),
                    StaggeredEntrance(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BeaconMark(icon: icon),
                          const SizedBox(height: BeaconSpace.xxl),
                          if (aboveTitle != null) ...[
                            aboveTitle!,
                            const SizedBox(height: BeaconSpace.md),
                          ],
                          Text(title, style: text.headlineLarge),
                          const SizedBox(height: BeaconSpace.sm),
                          Text(subtitle,
                              style: text.bodyLarge?.copyWith(color: t.onSurfaceVar)),
                        ],
                      ),
                    ),
                    const SizedBox(height: BeaconSpace.xxxl),
                    for (var i = 0; i < children.length; i++)
                      StaggeredEntrance(index: i + 1, child: children[i]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Brand mark: a primary disc with an amber beacon ring and glow.
class BeaconMark extends StatelessWidget {
  final IconData icon;
  final double size;
  const BeaconMark({super.key, this.icon = Icons.radar_rounded, this.size = 64});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: t.primary,
        shape: BoxShape.circle,
        border: Border.all(color: t.accent, width: 2),
        boxShadow: [
          BoxShadow(color: t.accentGlow, blurRadius: 28, spreadRadius: 6),
        ],
      ),
      child: Icon(icon, color: t.onPrimary, size: size * 0.48),
    );
  }
}

/// "── or continue with ──" divider.
class LabeledDivider extends StatelessWidget {
  final String label;
  const LabeledDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Divider(color: t.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.md),
          child: Text(label, style: text.bodySmall?.copyWith(color: t.onSurfaceMuted)),
        ),
        Expanded(child: Divider(color: t.outlineVariant)),
      ],
    );
  }
}

/// Inline "Don't have an account? Sign up" footer.
class AuthFooterLink extends StatelessWidget {
  final String prompt;
  final String action;
  final VoidCallback onTap;
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt, style: text.bodyMedium),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.sm),
          ),
          child: Text(action),
        ),
      ],
    );
  }
}

/// Step indicator for multi-step flows (dots that grow when active).
class StepDots extends StatelessWidget {
  final int count;
  final int current;
  const StepDots({super.key, required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: BeaconSpace.sm),
          AnimatedContainer(
            duration: BeaconMotion.scaled(context, BeaconMotion.state),
            curve: BeaconMotion.emphasized,
            width: i == current ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i <= current ? t.primary : t.outline,
              borderRadius: BeaconRadius.rPill,
            ),
          ),
        ],
      ],
    );
  }
}
