import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';

/// Beacon notch navigation.
///
/// A frosted-glass bar with a moving notch; the selected destination floats
/// in the notch as a gradient primary disc wrapped in an amber "beacon ring"
/// that breathes softly. The bar respects the bottom safe-area inset and every
/// destination is a 48dp+ target with an accessible label.
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
    if (oldWidget.currentIndex != widget.currentIndex) {
      _position = Tween<double>(
        begin: oldWidget.currentIndex.toDouble(),
        end: widget.currentIndex.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: BeaconMotion.emphasized),
      );
      _controller.duration = BeaconMotion.scaled(context, BeaconMotion.state);
      _controller.forward(from: 0);
    }
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
      child: Stack(
        children: [
          // ── Glass bar with notch ───────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight,
            child: AnimatedBuilder(
              animation: _position,
              builder: (context, _) {
                final path = _NavShape.path(
                  Size(width, barHeight),
                  position: _position.value,
                  itemWidth: itemWidth,
                );
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: _ShadowPainter(path: path, color: t.shadow),
                    ),
                    ClipPath(
                      clipper: _PathClipper(path),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                        child: ColoredBox(color: t.glassSurface),
                      ),
                    ),
                    CustomPaint(
                      painter: _StrokePainter(path: path, color: t.glassBorder),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Destinations ──────────────────────────────────────────────
          Positioned.fill(
            child: Row(
              children: List.generate(_items.length, (i) {
                return SizedBox(
                  width: itemWidth,
                  child: _Destination(
                    item: _items[i],
                    selected: widget.currentIndex == i,
                    onTap: () => widget.onTap(i),
                    bottomInset: bottomInset,
                  ),
                );
              }),
            ),
          ),
        ],
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
  final VoidCallback onTap;
  final double bottomInset;

  const _Destination({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.bottomInset,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final duration = BeaconMotion.scaled(context, BeaconMotion.state);
    const disc = CustomBottomNavBar.discSize;
    const lift = CustomBottomNavBar.lift;

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
            // Floating disc (selected) / plain icon (unselected)
            AnimatedPositioned(
              duration: duration,
              curve: BeaconMotion.emphasized,
              top: selected ? 0 : lift + 12,
              child: _BeaconDisc(
                selected: selected,
                icon: selected ? item.activeIcon : item.icon,
                size: selected ? disc : 40,
                duration: duration,
              ),
            ),
            // Label
            Positioned(
              bottom: bottomInset + 10,
              child: AnimatedDefaultTextStyle(
                duration: duration,
                style: text.labelSmall!.copyWith(
                  color: selected ? t.primary : t.onSurfaceVar,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(item.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The selected-tab disc: gradient primary fill, amber ring, breathing glow.
class _BeaconDisc extends StatefulWidget {
  final bool selected;
  final IconData icon;
  final double size;
  final Duration duration;
  const _BeaconDisc({
    required this.selected,
    required this.icon,
    required this.size,
    required this.duration,
  });

  @override
  State<_BeaconDisc> createState() => _BeaconDiscState();
}

class _BeaconDiscState extends State<_BeaconDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant _BeaconDisc old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final reduced = BeaconMotion.reduced(context);
    if (widget.selected && !reduced) {
      if (!_breath.isAnimating) _breath.repeat(reverse: true);
    } else {
      _breath.stop();
      _breath.value = 0.5;
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final selected = widget.selected;
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, child) {
        final k = Curves.easeInOut.transform(_breath.value);
        return AnimatedContainer(
          duration: widget.duration,
          curve: BeaconMotion.emphasized,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: selected ? t.primaryGradient : null,
            color: selected ? null : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? t.accent : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: t.accentGlow.withValues(alpha: t.accentGlow.a * (0.7 + 0.6 * k)),
                      blurRadius: 18 + 10 * k,
                      spreadRadius: 3 + 3 * k,
                    ),
                    BoxShadow(
                      color: t.primary.withValues(alpha: 0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: child,
        );
      },
      child: Icon(
        widget.icon,
        color: selected ? t.onPrimary : t.onSurfaceVar,
        size: selected ? 27 : 24,
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

class _PathClipper extends CustomClipper<Path> {
  final Path path;
  _PathClipper(this.path);
  @override
  Path getClip(Size size) => path;
  @override
  bool shouldReclip(covariant _PathClipper old) => old.path != path;
}

class _ShadowPainter extends CustomPainter {
  final Path path;
  final Color color;
  _ShadowPainter({required this.path, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(path, color.withValues(alpha: 0.35), 12, true);
  }

  @override
  bool shouldRepaint(covariant _ShadowPainter old) =>
      old.path != path || old.color != color;
}

class _StrokePainter extends CustomPainter {
  final Path path;
  final Color color;
  _StrokePainter({required this.path, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StrokePainter old) =>
      old.path != path || old.color != color;
}
