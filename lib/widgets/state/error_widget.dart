import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'package:finder/widgets/ui/app_button.dart';

/// Error state with a clear recovery path.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String title;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.title = 'Something went wrong',
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: BeaconSpace.xxxl, vertical: BeaconSpace.xxl),
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: t.errorSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline_rounded, size: 30, color: t.error),
              ),
              const SizedBox(height: BeaconSpace.lg),
              Text(title, textAlign: TextAlign.center, style: text.titleLarge),
              const SizedBox(height: BeaconSpace.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: text.bodyMedium,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: BeaconSpace.xxl),
                AppButton.tonal(
                  label: 'Try again',
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                  expand: false,
                  size: AppButtonSize.medium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
