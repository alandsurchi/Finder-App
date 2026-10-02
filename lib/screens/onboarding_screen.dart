import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finder/features/settings/presentation/language_sheet.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/widgets/ui/ui.dart';

import '../routes.dart';

/// One onboarding slide. Copy is resolved from [AppLocalizations] in build;
/// [tint] drives the backdrop glow, the eyebrow chip and the illustration.
class _OnboardingPage {
  final String Function(AppLocalizations) eyebrow;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) description;
  final Color Function(AppColorTokens) tint;
  final Color Function(AppColorTokens) onTint;
  final IconData icon;
  const _OnboardingPage({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.tint,
    required this.onTint,
    required this.icon,
  });
}

final _pages = [
  _OnboardingPage(
    eyebrow: (l) => l.onboardStepReport,
    title: (l) => l.onboardLostTitle,
    description: (l) => l.onboardLostDescription,
    tint: (t) => t.lost,
    onTint: (t) => t.onLost,
    icon: Icons.add_a_photo_outlined,
  ),
  _OnboardingPage(
    eyebrow: (l) => l.onboardStepMatch,
    title: (l) => l.onboardFoundTitle,
    description: (l) => l.onboardFoundDescription,
    tint: (t) => t.found,
    onTint: (t) => t.onFound,
    icon: Icons.join_inner_rounded,
  ),
  _OnboardingPage(
    eyebrow: (l) => l.onboardStepReturn,
    title: (l) => l.onboardConnectTitle,
    description: (l) => l.onboardConnectDescription,
    tint: (t) => t.primary,
    onTint: (t) => t.onPrimary,
    icon: Icons.handshake_outlined,
  ),
];

/// Three slides that explain Finder in one breath: report, match, return.
/// The whole page takes the mood of the step (coral, green, teal) and the
/// illustrations are real UI fragments, so a new user already knows what a
/// post, a match and a safe hand-over look like before signing in.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: BeaconMotion.scaled(context, const Duration(milliseconds: 420)),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() => Navigator.pushReplacementNamed(context, AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final isLast = _currentPage == _pages.length - 1;
    final page = _pages[_currentPage];
    final tint = page.tint(t);

    return Scaffold(
      body: BeaconBackdrop(
        color: tint,
        secondary: true,
        rings: true,
        alignment: const Alignment(0.9, -1.2),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  // ── Top bar: brand + language + skip
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        BeaconSpace.page, BeaconSpace.sm, BeaconSpace.sm, 0),
                    child: Row(
                      children: [
                        const BeaconMark(size: 32),
                        const SizedBox(width: BeaconSpace.sm),
                        Flexible(
                          child: Text(l10n.appName, style: text.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        const Spacer(),
                        Consumer(
                          builder: (context, ref, _) => AppIconButton(
                            icon: Icons.translate_rounded,
                            tooltip: context.l10n.languageTitle,
                            variant: AppIconButtonVariant.ghost,
                            onPressed: () => showLanguageSheet(context, ref),
                          ),
                        ),
                        AppButton.ghost(label: l10n.commonSkip, onPressed: _finish, expand: false),
                      ],
                    ),
                  ),

                  // ── Slides
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemCount: _pages.length,
                      itemBuilder: (context, index) => _Slide(
                        page: _pages[index],
                        index: index,
                        controller: _pageController,
                      ),
                    ),
                  ),

                  // ── Dots
                  Padding(
                    padding: const EdgeInsets.only(top: BeaconSpace.md, bottom: BeaconSpace.sm),
                    child: StepDots(count: _pages.length, current: _currentPage),
                  ),

                  // ── Buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        BeaconSpace.page, BeaconSpace.md, BeaconSpace.page, BeaconSpace.lg),
                    child: Column(
                      children: [
                        AppButton(
                          label: isLast ? l10n.onboardGetStarted : l10n.commonNext,
                          icon: Icons.arrow_forward_rounded,
                          iconTrailing: true,
                          variant: isLast ? AppButtonVariant.primary : AppButtonVariant.tonal,
                          onPressed: _nextPage,
                        ),
                        const SizedBox(height: BeaconSpace.xs),
                        SizedBox(
                          height: 48,
                          child: Center(
                            child: AppButton.ghost(
                              label: l10n.onboardHaveAccount,
                              onPressed: _finish,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── One slide ───────────────────────────────────────────────────────────────

class _Slide extends StatelessWidget {
  final _OnboardingPage page;
  final int index;
  final PageController controller;
  const _Slide({required this.page, required this.index, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final tint = page.tint(t);
    final reduced = BeaconMotion.reduced(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final illustrationSize = (constraints.maxHeight * 0.46).clamp(200.0, 300.0);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.xxl),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Parallax: the illustration drifts a little slower than the page.
                AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    double offset = 0;
                    if (!reduced && controller.hasClients && controller.position.haveDimensions) {
                      offset = ((controller.page ?? index.toDouble()) - index) * -28;
                    }
                    return Transform.translate(offset: Offset(offset, 0), child: child);
                  },
                  child: SizedBox(
                    height: illustrationSize,
                    child: switch (index) {
                      0 => _ReportIllustration(t: t, tint: tint),
                      1 => _MatchIllustration(t: t, tint: tint),
                      _ => _ReturnIllustration(t: t, tint: tint),
                    },
                  ),
                ),
                const SizedBox(height: BeaconSpace.xxl),
                _Eyebrow(label: page.eyebrow(l10n), icon: page.icon, tint: tint, onTint: page.onTint(t)),
                const SizedBox(height: BeaconSpace.md),
                Text(
                  page.title(l10n),
                  textAlign: TextAlign.center,
                  style: text.headlineLarge?.copyWith(height: 1.15),
                ),
                const SizedBox(height: BeaconSpace.md),
                Text(
                  page.description(l10n),
                  textAlign: TextAlign.center,
                  style: text.bodyLarge?.copyWith(color: t.onSurfaceVar, height: 1.5),
                ),
                const SizedBox(height: BeaconSpace.sm),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color tint;
  final Color onTint;
  const _Eyebrow({required this.label, required this.icon, required this.tint, required this.onTint});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.md, vertical: 6),
        decoration: BoxDecoration(color: tint, borderRadius: BeaconRadius.rPill),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: onTint),
            const SizedBox(width: 6),
            Text(
              label,
              style: text.labelLarge?.copyWith(color: onTint, letterSpacing: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared pieces ───────────────────────────────────────────────────────────

/// Soft concentric rings behind every illustration, tinted per step.
class _Rings extends StatelessWidget {
  final Color tint;
  const _Rings({required this.tint});

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _RingsPainter(tint));
}

class _RingsPainter extends CustomPainter {
  final Color tint;
  _RingsPainter(this.tint);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) / 2;
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [tint.withValues(alpha: 0.22), tint.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: c, radius: maxR));
    canvas.drawCircle(c, maxR, glow);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      ring.color = tint.withValues(alpha: 0.28 - i * 0.07);
      canvas.drawCircle(c, maxR * i / 3, ring);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.tint != tint;
}

/// A slowly breathing dot: the "beacon".
class _Pulse extends StatefulWidget {
  final Color color;
  final double size;
  const _Pulse({required this.color, this.size = 14});

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (BeaconMotion.reduced(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      // A handful of pulses while the slide is read, then rest (and tests settle).
      _c.repeat(count: 8);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final v = Curves.easeOut.transform(_c.value);
        return SizedBox(
          width: widget.size * 3,
          height: widget.size * 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size * (1 + 2 * v),
                height: widget.size * (1 + 2 * v),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.35 * (1 - v)),
                ),
              ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A small floating card with the app's surface, border and shadow.
class _FloatingCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double width;
  const _FloatingCard({required this.child, required this.width, this.padding = const EdgeInsets.all(BeaconSpace.md)});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BeaconRadius.rLg,
        border: Border.all(color: t.outlineVariant),
        boxShadow: [
          BoxShadow(color: t.shadow.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color onColor;
  final double? maxWidth;
  const _Pill({required this.icon, required this.label, required this.color, required this.onColor, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      constraints: maxWidth == null ? null : BoxConstraints(maxWidth: maxWidth!),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BeaconRadius.rPill,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: onColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelMedium?.copyWith(color: onColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grey placeholder lines that read as text without saying anything.
class _TextLines extends StatelessWidget {
  final List<double> widths;
  final Color color;
  const _TextLines({required this.widths, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final w in widths) ...[
            FractionallySizedBox(
              widthFactor: w,
              alignment: AlignmentDirectional.centerStart,
              child: Container(height: 7, decoration: BoxDecoration(color: color, borderRadius: BeaconRadius.rPill)),
            ),
            const SizedBox(height: 6),
          ],
        ],
      );
}

/// A post card as it appears in the feed: photo tile, badge, title lines.
class _PostCard extends StatelessWidget {
  final AppColorTokens t;
  final Color tint;
  final Color onTint;
  final IconData icon;
  final String badge;
  final double width;
  const _PostCard({
    required this.t,
    required this.tint,
    required this.onTint,
    required this.icon,
    required this.badge,
    this.width = 180,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return _FloatingCard(
      width: width,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [tint.withValues(alpha: 0.28), tint.withValues(alpha: 0.08)],
              ),
              borderRadius: BeaconRadius.rMd,
            ),
            child: Icon(icon, color: tint, size: 26),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: tint, borderRadius: BeaconRadius.rPill),
                  child: Text(badge, style: text.labelSmall?.copyWith(color: onTint, fontWeight: FontWeight.w700, fontSize: 10)),
                ),
                const SizedBox(height: 7),
                _TextLines(widths: const [0.9, 0.55], color: t.outlineVariant),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: report ──────────────────────────────────────────────────────────

/// A lost-item post being created: photo, place, and the beacon that starts
/// looking the moment it is posted.
class _ReportIllustration extends StatelessWidget {
  final AppColorTokens t;
  final Color tint;
  const _ReportIllustration({required this.t, required this.tint});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(builder: (context, c) {
      final s = math.min(c.maxWidth, c.maxHeight);
      return Center(
        child: SizedBox(
          width: s,
          height: s,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: _Rings(tint: tint)),
              // The post card
              _FloatingCard(
                width: s * 0.72,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: s * 0.26,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [tint.withValues(alpha: 0.30), tint.withValues(alpha: 0.10)],
                        ),
                        borderRadius: BeaconRadius.rMd,
                      ),
                      child: Stack(
                        children: [
                          Center(child: Icon(Icons.watch_outlined, size: s * 0.14, color: tint)),
                          PositionedDirectional(
                            top: 8,
                            start: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(color: tint, borderRadius: BeaconRadius.rPill),
                              child: Text(l10n.onboardSampleLost,
                                  style: text.labelSmall?.copyWith(color: t.onLost, fontWeight: FontWeight.w700, fontSize: 10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _TextLines(widths: const [0.8, 0.5], color: t.outlineVariant),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 14, color: t.onSurfaceMuted),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            l10n.onboardSamplePlace,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // The beacon pulsing at the corner of the card
              PositionedDirectional(top: s * 0.08, end: s * 0.06, child: _Pulse(color: tint, size: 14)),
              // "Posted in a minute"
              PositionedDirectional(
                bottom: s * 0.04,
                start: s * 0.02,
                child: _Pill(icon: Icons.timer_outlined, label: l10n.onboardSampleMinute, color: t.surface, onColor: t.onSurface, maxWidth: s * 0.9),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Step 2: match ───────────────────────────────────────────────────────────

/// A lost card and a found card joined by the match, reviewed by a person.
class _MatchIllustration extends StatelessWidget {
  final AppColorTokens t;
  final Color tint;
  const _MatchIllustration({required this.t, required this.tint});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(builder: (context, c) {
      final s = math.min(c.maxWidth, c.maxHeight);
      final cardW = s * 0.62;
      return Center(
        child: SizedBox(
          width: s,
          height: s,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: _Rings(tint: tint)),
              // Dotted connector between the two cards
              Positioned.fill(child: CustomPaint(painter: _ConnectorPainter(tint))),
              PositionedDirectional(
                top: s * 0.08,
                start: s * 0.04,
                child: _PostCard(t: t, tint: t.lost, onTint: t.onLost, icon: Icons.backpack_outlined, badge: l10n.onboardSampleLost, width: cardW),
              ),
              PositionedDirectional(
                bottom: s * 0.08,
                end: s * 0.04,
                child: _PostCard(t: t, tint: t.found, onTint: t.onFound, icon: Icons.backpack_outlined, badge: l10n.onboardSampleFound, width: cardW),
              ),
              _Pill(icon: Icons.auto_awesome_rounded, label: l10n.onboardSampleMatch, color: tint, onColor: t.onFound),
              PositionedDirectional(
                top: s * 0.02,
                end: s * 0.02,
                child: _Pill(icon: Icons.verified_user_outlined, label: l10n.onboardSampleReviewed, color: t.surface, onColor: t.onSurface, maxWidth: s * 0.9),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ConnectorPainter extends CustomPainter {
  final Color tint;
  _ConnectorPainter(this.tint);

  @override
  void paint(Canvas canvas, Size size) {
    final a = Offset(size.width * 0.38, size.height * 0.30);
    final b = Offset(size.width * 0.62, size.height * 0.70);
    final paint = Paint()
      ..color = tint.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final total = (b - a).distance;
    final dir = (b - a) / total;
    const dash = 6.0, gap = 6.0;
    var d = 0.0;
    while (d < total) {
      final from = a + dir * d;
      final to = a + dir * math.min(d + dash, total);
      canvas.drawLine(from, to, paint);
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) => old.tint != tint;
}

// ── Step 3: return ──────────────────────────────────────────────────────────

/// The in-app chat: a question only the owner can answer, the verified
/// check, and the reminder to meet in public.
class _ReturnIllustration extends StatelessWidget {
  final AppColorTokens t;
  final Color tint;
  const _ReturnIllustration({required this.t, required this.tint});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(builder: (context, c) {
      final s = math.min(c.maxWidth, c.maxHeight);
      final bubbleW = s * 0.66;
      Widget bubble(String msg, {required bool mine}) => Container(
            width: bubbleW,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: mine ? tint : t.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(mine ? 16 : 4),
                bottomRight: Radius.circular(mine ? 4 : 16),
              ),
              border: mine ? null : Border.all(color: t.outlineVariant),
              boxShadow: [BoxShadow(color: t.shadow.withValues(alpha: 0.10), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(msg, style: text.bodySmall?.copyWith(color: mine ? t.onPrimary : t.onSurface, height: 1.3)),
                ),
                if (mine) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.done_all_rounded, size: 14, color: t.tickRead),
                ],
              ],
            ),
          );
      return Center(
        child: SizedBox(
          width: s,
          height: s,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: _Rings(tint: tint)),
              PositionedDirectional(top: s * 0.10, end: s * 0.04, child: bubble(l10n.onboardSampleAsk, mine: true)),
              PositionedDirectional(top: s * 0.36, start: s * 0.04, child: bubble(l10n.onboardSampleAnswer, mine: false)),
              PositionedDirectional(
                bottom: s * 0.16,
                end: s * 0.06,
                child: _Pill(icon: Icons.verified_rounded, label: l10n.onboardSampleVerified, color: t.found, onColor: t.onFound, maxWidth: s * 0.9),
              ),
              PositionedDirectional(
                bottom: s * 0.02,
                start: s * 0.04,
                child: _Pill(icon: Icons.storefront_outlined, label: l10n.onboardSampleMeet, color: t.surface, onColor: t.onSurface, maxWidth: s * 0.9),
              ),
            ],
          ),
        ),
      );
    });
  }
}
