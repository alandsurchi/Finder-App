import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';

/// Shimmering placeholder block. Respects reduced motion (static when set).
class Skeleton extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const Skeleton.box({
    super.key,
    this.width,
    required this.height,
    BorderRadius? borderRadius,
  }) : borderRadius = borderRadius ?? const BorderRadius.all(Radius.circular(12));

  const Skeleton.line({super.key, this.width, this.height = 12})
      : borderRadius = const BorderRadius.all(Radius.circular(6));

  Skeleton.circle({super.key, required double size})
      : width = size,
        height = size,
        borderRadius = BorderRadius.circular(size);

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (BeaconMotion.reduced(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final x = _c.value * 2 - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(x - 1, 0),
              end: Alignment(x + 1, 0),
              colors: [t.surfaceHigh, t.surfaceLow, t.surfaceHigh],
            ),
          ),
        );
      },
    );
  }
}

/// A list of card-shaped skeletons for feeds.
class SkeletonItemList extends StatelessWidget {
  final int count;
  final bool rows;
  final EdgeInsetsGeometry padding;

  const SkeletonItemList({
    super.key,
    this.count = 3,
    this.rows = false,
    this.padding = const EdgeInsets.symmetric(horizontal: BeaconSpace.page),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: BeaconSpace.lg),
      itemBuilder: (_, __) => rows ? const _RowSkeleton() : const _TileSkeleton(),
    );
  }
}

class _TileSkeleton extends StatelessWidget {
  const _TileSkeleton();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Skeleton.box(height: 180, width: double.infinity),
        SizedBox(height: BeaconSpace.md),
        Skeleton.line(width: 200, height: 16),
        SizedBox(height: BeaconSpace.sm),
        Skeleton.line(width: double.infinity),
        SizedBox(height: BeaconSpace.xs),
        Skeleton.line(width: 140),
      ],
    );
  }
}

class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Skeleton.box(height: 92, width: 92),
        SizedBox(width: BeaconSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton.line(width: 80, height: 10),
              SizedBox(height: BeaconSpace.sm),
              Skeleton.line(width: double.infinity, height: 16),
              SizedBox(height: BeaconSpace.sm),
              Skeleton.line(width: 160),
            ],
          ),
        ),
      ],
    );
  }
}
