import 'package:flutter/material.dart';
import 'package:finder/widgets/ui/ui.dart';
import '../routes.dart';

class _OnboardingPage {
  final String title;
  final String description;
  const _OnboardingPage({required this.title, required this.description});
}

const _pages = [
  _OnboardingPage(
    title: 'Lost Something?',
    description:
        'Report your missing essentials in seconds. Finder connects found items with their owners instantly.',
  ),
  _OnboardingPage(
    title: 'Found Something?',
    description:
        'Post found items and help return them to their rightful owners. Every good deed counts.',
  ),
  _OnboardingPage(
    title: 'Connect &\nCommunicate',
    description:
        'Chat, share details, and return items safely. Build trust within the community.',
  ),
];

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
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: BeaconBackdrop(
        secondary: true,
        rings: true,
        alignment: const Alignment(0.9, -1.2),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  // ── Top bar: brand + skip
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        BeaconSpace.page, BeaconSpace.sm, BeaconSpace.sm, 0),
                    child: Row(
                      children: [
                        const BeaconMark(size: 32),
                        const SizedBox(width: BeaconSpace.sm),
                        Text('Finder', style: text.titleLarge),
                        const Spacer(),
                        AppButton.ghost(label: 'Skip', onPressed: _skip),
                      ],
                    ),
                  ),

                  // ── PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemCount: _pages.length,
                      itemBuilder: (context, index) => _buildSlide(context, index, t),
                    ),
                  ),

                  // ── Dots
                  Padding(
                    padding: const EdgeInsets.only(top: BeaconSpace.lg, bottom: BeaconSpace.sm),
                    child: StepDots(count: _pages.length, current: _currentPage),
                  ),

                  // ── Buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        BeaconSpace.page, BeaconSpace.lg, BeaconSpace.page, BeaconSpace.xl),
                    child: Column(
                      children: [
                        AppButton(
                          label: isLast ? 'Get Started' : 'Next',
                          icon: Icons.arrow_forward_rounded,
                          iconTrailing: true,
                          variant: isLast
                              ? AppButtonVariant.primary
                              : AppButtonVariant.tonal,
                          onPressed: _nextPage,
                        ),
                        SizedBox(
                          height: 48,
                          child: AnimatedOpacity(
                            duration: BeaconMotion.scaled(context, BeaconMotion.state),
                            opacity: isLast ? 0 : 1,
                            child: IgnorePointer(
                              ignoring: isLast,
                              child: Center(
                                child: AppButton.ghost(
                                  label: 'Skip for now',
                                  onPressed: _skip,
                                ),
                              ),
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

  Widget _buildSlide(BuildContext context, int index, AppColorTokens t) {
    final text = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final illustrationSize =
            (constraints.maxHeight * 0.48).clamp(160.0, 300.0);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.xxl),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: BeaconSpace.sm),
                SizedBox(
                  height: illustrationSize,
                  child: [
                    _LostIllustration(t: t),
                    _FoundIllustration(t: t),
                    _ConnectIllustration(t: t),
                  ][index],
                ),
                const SizedBox(height: BeaconSpace.xxxl),
                Text(
                  _pages[index].title,
                  textAlign: TextAlign.center,
                  style: text.headlineLarge,
                ),
                const SizedBox(height: BeaconSpace.md),
                Text(
                  _pages[index].description,
                  textAlign: TextAlign.center,
                  style: text.bodyLarge?.copyWith(color: t.onSurfaceVar),
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

// ── Slide 1: Beacon spotlight
class _LostIllustration extends StatelessWidget {
  final AppColorTokens t;
  const _LostIllustration({required this.t});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: _BeaconRingsPainter(
            ring: t.primary,
            glow: t.accentGlow,
            dot: t.accent,
          ),
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.34,
              heightFactor: 0.34,
              child: Container(
                decoration: BoxDecoration(
                  color: t.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: t.accent, width: 3),
                  boxShadow: [
                    BoxShadow(color: t.accentGlow, blurRadius: 40, spreadRadius: 8),
                  ],
                ),
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Icon(Icons.watch_outlined, color: t.onPrimary),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BeaconRingsPainter extends CustomPainter {
  final Color ring;
  final Color glow;
  final Color dot;
  const _BeaconRingsPainter({required this.ring, required this.glow, required this.dot});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [glow, glow.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, glowPaint);

    for (var i = 1; i <= 3; i++) {
      final paint = Paint()
        ..color = ring.withValues(alpha: 0.32 / i)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius * (0.3 + 0.22 * i), paint);
    }

    // Sweep
    final sweep = Paint()
      ..shader = SweepGradient(
        startAngle: -1.2,
        endAngle: 0.4,
        colors: [ring.withValues(alpha: 0), ring.withValues(alpha: 0.22)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.96),
      -1.2,
      1.6,
      true,
      sweep,
    );

    final dotPaint = Paint()..color = dot;
    canvas.drawCircle(Offset(center.dx - radius * 0.55, center.dy - radius * 0.3), 4, dotPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.62, center.dy + radius * 0.12), 3, dotPaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.28, center.dy - radius * 0.62), 3, dotPaint);
  }

  @override
  bool shouldRepaint(_BeaconRingsPainter old) =>
      old.ring != ring || old.glow != glow || old.dot != dot;
}

// ── Slide 2: Found illustration
class _FoundIllustration extends StatelessWidget {
  final AppColorTokens t;
  const _FoundIllustration({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BeaconRadius.rXxl,
        color: t.surfaceLow,
        border: Border.all(color: t.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DotGridPainter(color: t.outline),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 12,
            child: Icon(
              Icons.key_rounded,
              color: t.found.withValues(alpha: 0.12),
              size: 120,
            ),
          ),
          Positioned(
            left: 24,
            bottom: 28,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: t.found,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: t.found.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(Icons.handshake_outlined, color: t.onFound, size: 36),
            ),
          ),
          Positioned(
            right: 28,
            top: 48,
            child: SurfaceCard(
              padding: const EdgeInsets.all(BeaconSpace.md),
              radius: BeaconRadius.lg,
              elevated: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.manage_search_rounded, color: t.primary, size: 24),
                  const SizedBox(width: BeaconSpace.sm),
                  StatusBadge.found(small: true),
                ],
              ),
            ),
          ),
          Positioned(
            left: 28,
            top: 32,
            child: StatusBadge.reward('REWARD \$50', small: true),
          ),
        ],
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final Color color;
  const _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.5);
    const step = 22.0;
    for (double x = step / 2; x < size.width; x += step) {
      for (double y = step / 2; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.color != color;
}

// ── Slide 3: Connect illustration
class _ConnectIllustration extends StatelessWidget {
  final AppColorTokens t;
  const _ConnectIllustration({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BeaconSpace.lg),
      decoration: BoxDecoration(
        color: t.surfaceLow,
        borderRadius: BeaconRadius.rXxl,
        border: Border.all(color: t.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _chatBubble(t: t, isLeft: true, name: 'Sarah Ahmed'),
          const SizedBox(height: BeaconSpace.md),
          _chatBubble(t: t, isLeft: false, name: 'Alex Rivera'),
          const SizedBox(height: BeaconSpace.xl),
          SurfaceCard(
            padding: const EdgeInsets.symmetric(
                horizontal: BeaconSpace.lg, vertical: BeaconSpace.sm),
            radius: BeaconRadius.pill,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, color: t.primary, size: 18),
                const SizedBox(width: BeaconSpace.sm),
                Text(
                  'TRUST SECURED',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatBubble({
    required AppColorTokens t,
    required bool isLeft,
    required String name,
  }) {
    final avatar = AppAvatar(name: name, size: 44);

    final textLines = Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: BeaconSpace.md, vertical: BeaconSpace.md),
        decoration: BoxDecoration(
          color: isLeft ? t.surface : t.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isLeft ? 4 : 16),
            bottomRight: Radius.circular(isLeft ? 16 : 4),
          ),
          border: isLeft ? Border.all(color: t.outlineVariant) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isLeft ? t.onSurfaceVar : t.onPrimary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 8,
              width: 110,
              decoration: BoxDecoration(
                color: isLeft
                    ? t.onSurfaceVar.withValues(alpha: 0.5)
                    : t.onPrimary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: isLeft
          ? [avatar, const SizedBox(width: BeaconSpace.sm), textLines]
          : [textLines, const SizedBox(width: BeaconSpace.sm), avatar],
    );
  }
}
