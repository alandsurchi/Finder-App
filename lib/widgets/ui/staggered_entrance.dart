import 'package:flutter/material.dart';
import 'package:finder/theme/beacon_tokens.dart';

/// Fade + rise entrance. Pass an [index] to stagger siblings. Renders the
/// child statically when the platform requests reduced motion.
///
/// The delay is folded into the animation controller as an [Interval] so no
/// dart timers are created (keeps widget tests deterministic).
class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration? delay;
  final Duration duration;
  final double offset;

  const StaggeredEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 50),
    this.delay,
    this.duration = BeaconMotion.enter,
    this.offset = 14,
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final Duration _delay = widget.delay ?? widget.baseDelay * widget.index;
  late final Duration _total = _delay + widget.duration;
  late final double _start =
      _total.inMicroseconds == 0 ? 0 : _delay.inMicroseconds / _total.inMicroseconds;

  late final AnimationController _c =
      AnimationController(vsync: this, duration: _total);
  late final Animation<double> _fade = CurvedAnimation(
    parent: _c,
    curve: Interval(_start, 1, curve: Curves.easeOut),
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: Offset(0, widget.offset),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _c,
    curve: Interval(_start, 1, curve: BeaconMotion.emphasized),
  ));

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (BeaconMotion.reduced(context)) {
      _c.value = 1;
      return;
    }
    _c.forward();
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
      builder: (context, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(offset: _slide.value, child: child),
      ),
      child: widget.child,
    );
  }
}
