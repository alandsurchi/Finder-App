import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';

/// Beacon notch navigation.
///
/// A solid bar with a moving notch; the selected destination floats in the
/// notch as a gradient primary disc with an amber beacon ring. One animation
/// (`_position`, in tab units) drives the notch, the disc size and lift, the
/// icon and the label, so every frame is a pure function of that value and
/// the selected state is exact from the first build. No blur: a backdrop
/// filter under a moving clip was the main source of jank and flicker on
/// Android.
class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Height of the visible bar (excluding the safe-area inset and the lift of
  /// the floating disc). Pages use [totalHeight] to pad their scroll views.
  static const double barHeight = 68;
  static const double lift = 30;
  static const double discSize = 62;
  static const double _restSize = 40;

  static double totalHeight(BuildContext context) =>
      barHeight + lift + MediaQuery.paddingOf(context).bottom;

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: BeaconMotion.state,
  );
  late Animation<double> _position;

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavItem(Icons.search_rounded, Icons.search_rounded, 'Search'),
    _NavItem(Icons.add_rounded, Icons.add_rounded, 'Post'),
    _NavItem(Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Messages'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _position = AlwaysStoppedAnimation(widget.currentIndex.toDouble());
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex == widget.currentIndex) return;
    // Start from wherever the notch is right now, so rapid taps never jump.
    final from = _position.value;
    final duration = BeaconMotion.scaled(context, BeaconMotion.state);
    if (duration == Duration.zero) {
      _controller.stop();
      _position = AlwaysStoppedAnimation(widget.currentIndex.toDouble());
      setState(() {});
      return;
    }
    _position = Tween<double>(
      begin: from,
      end: widget.currentIndex.toDouble(),
    ).animate(
      CurvedAnimation(parent: _controller, curve: BeaconMotion.emphasized),
    );
    _controller
      ..duration = duration
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final itemWidth = width / _items.length;
    final barHeight = CustomBottomNavBar.barHeight + bottomInset;
    final total = CustomBottomNavBar.lift + barHeight;

    return SizedBox(
      height: total,
      child: AnimatedBuilder(
        animation: _position,
        builder: (context, _) {
          final position = _position.value;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Bar with notch (shadow, fill, hairline) ────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: barHeight,
                child: CustomPaint(
                  painter: _BarPainter(
                    path: _NavShape.path(
                      Size(width, barHeight),
                      position: position,
                      itemWidth: itemWidth,
                    ),
                    fill: t.isDark
                        ? t.surfaceHigh.withValues(alpha: 0.98)
                        : t.surface,
                    stroke: t.glassBorder,
                    shadow: t.shadow,
                  ),
                ),
              ),

              // ── Destinations ──────────────────────────────────────────
              Positioned.fill(
                child: Row(
                  children: List.generate(_items.length, (i) {
                    // 1 when the notch is centred on this tab, 0 when it is a
                    // full tab away.
                    final k = (1 - (position - i).abs()).clamp(0.0, 1.0);
                    return SizedBox(
                      width: itemWidth,
                      child: _Destination(
                        item: _items[i],
                        selected: widget.currentIndex == i,
                        k: k,
                        onTap: () => widget.onTap(i),
                        bottomInset: bottomInset,
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

class _Destination extends StatelessWidget {
  final _NavItem item;
  final bool selected;

  /// Selection progress 0..1 derived from the shared notch position.
  final double k;
  final VoidCallback onTap;
  final double bottomInset;

  const _Destination({
    required this.item,
    required this.selected,
    required this.k,
    required this.onTap,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    const disc = CustomBottomNavBar.discSize;
    const rest = CustomBottomNavBar._restSize;
    const lift = CustomBottomNavBar.lift;

    final size = lerpDouble(rest, disc, k)!;
    final top = lerpDouble(lift + 12, 0, k)!;
    final active = k > 0.5;
    final iconColor = Color.lerp(t.onSurfaceVar, t.onPrimary, k)!;
    final labelColor = Color.lerp(t.onSurfaceVar, t.primary, k)!;

    return Semantics(
      button: true,
      selected: selected,
      label: '${item.label} tab',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: top,
              child: _BeaconDisc(
                k: k,
                size: size,
                icon: active ? item.activeIcon : item.icon,
                iconColor: iconColor,
                iconSize: lerpDouble(24, 27, k)!,
              ),
            ),
            Positioned(
              bottom: bottomInset + 10,
              child: Text(
                item.label,
                style: text.labelSmall!.copyWith(
                  color: labelColor,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The selected-tab disc: gradient primary fill, amber ring and a static glow
/// that fades in with [k]. A soft breathing ring sits behind it (separate
/// animation, so the disc itself never restarts a tween).
class _BeaconDisc extends StatelessWidget {
  final double k;
  final double size;
  final IconData icon;
  final Color iconColor;
  final double iconSize;

  const _BeaconDisc({
    required this.k,
    required this.size,
    required this.icon,
    required this.iconColor,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final glowAlpha = t.accentGlow.a * k;
    return SizedBox(
      width: CustomBottomNavBar.discSize + 24,
      height: CustomBottomNavBar.discSize + 24,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (k > 0.95) _BreathingRing(size: size, color: t.accentGlow),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: k > 0 ? t.primaryGradient : null,
              color: k > 0 ? null : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: t.accent.withValues(alpha: k),
                width: 2.5,
              ),
              boxShadow: k > 0
                  ? [
                      BoxShadow(
                        color: t.accentGlow.withValues(alpha: glowAlpha),
                        blurRadius: 22,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: t.primary.withValues(alpha: 0.30 * k),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : const [],
            ),
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
        ],
      ),
    );
  }
}

/// A slow amber halo behind the selected disc. Purely decorative and
/// disabled when the platform asks for reduced motion.
class _BreathingRing extends StatefulWidget {
  final double size;
  final Color color;
  const _BreathingRing({required this.size, required this.color});

  @override
  State<_BreathingRing> createState() => _BreathingRingState();
}

class _BreathingRingState extends State<_BreathingRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (BeaconMotion.reduced(context)) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      child: Container(
        width: widget.size + 14,
        height: widget.size + 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: widget.color.a * 0.9),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Geometry ────────────────────────────────────────────────────────────────

class _NavShape {
  static const double notchRadius = 40;
  static const double notchDepth = 44;
  static const double corner = 26;

  static Path path(Size size,
      {required double position, required double itemWidth}) {
    final center = position * itemWidth + itemWidth / 2;
    const top = 0.0;
    final p = Path()
      ..moveTo(0, corner)
      ..quadraticBezierTo(0, top, corner, top)
      ..lineTo(center - notchRadius - 14, top)
      ..cubicTo(
        center - notchRadius + 2, top,
        center - notchRadius + 8, notchDepth,
        center, notchDepth,
      )
      ..cubicTo(
        center + notchRadius - 8, notchDepth,
        center + notchRadius - 2, top,
        center + notchRadius + 14, top,
      )
      ..lineTo(size.width - corner, top)
      ..quadraticBezierTo(size.width, top, size.width, corner)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return p;
  }
}

/// Shadow, fill and hairline of the notched bar in one paint pass.
class _BarPainter extends CustomPainter {
  final Path path;
  final Color fill;
  final Color stroke;
  final Color shadow;

  _BarPainter({
    required this.path,
    required this.fill,
    required this.stroke,
    required this.shadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(path, shadow.withValues(alpha: 0.35), 12, true);
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) =>
      old.path != path ||
      old.fill != fill ||
      old.stroke != stroke ||
      old.shadow != shadow;
}
