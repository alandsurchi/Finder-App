import 'package:flutter/material.dart';
import 'package:finder/widgets/ui/staggered_entrance.dart';

/// Legacy entrance animation API. [delay] is in seconds.
/// Delegates to [StaggeredEntrance], which honours reduced-motion settings.
class FadeInSlide extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double delay;

  const FadeInSlide({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 360),
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredEntrance(
      delay: Duration(milliseconds: (delay * 1000).round()),
      duration: duration,
      child: child,
    );
  }
}
