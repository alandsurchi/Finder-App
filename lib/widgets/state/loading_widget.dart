import 'package:flutter/material.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'package:finder/widgets/ui/beacon_pulse.dart';
import 'package:finder/widgets/ui/skeleton.dart';

enum LoadingVariant { spinner, list, rows }

/// Loading state. Default is a centered indicator with an optional message;
/// pass a [variant] to render feed-shaped skeletons instead.
class LoadingWidget extends StatelessWidget {
  final String? message;
  final LoadingVariant variant;
  final int skeletonCount;

  const LoadingWidget({
    super.key,
    this.message,
    this.variant = LoadingVariant.spinner,
    this.skeletonCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    switch (variant) {
      case LoadingVariant.list:
        return SkeletonItemList(count: skeletonCount);
      case LoadingVariant.rows:
        return SkeletonItemList(count: skeletonCount, rows: true);
      case LoadingVariant.spinner:
        return Center(
          child: Semantics(
            liveRegion: true,
            label: message ?? 'Loading',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BeaconPulse(size: 72),
                if (message != null) ...[
                  const SizedBox(height: BeaconSpace.lg),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        );
    }
  }
}
