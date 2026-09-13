import 'package:flutter/material.dart';
import 'package:finder/theme/beacon_tokens.dart';

/// Subtle 0.97 scale on pointer-down. Does not consume gestures, so wrap any
/// tappable (InkWell, GestureDetector) with it.
class PressScale extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double scale;

  const PressScale({
    super.key,
    required this.child,
    this.enabled = true,
    this.scale = 0.97,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _set(bool v) {
    if (!widget.enabled || _down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: BeaconMotion.scaled(context, BeaconMotion.press),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
