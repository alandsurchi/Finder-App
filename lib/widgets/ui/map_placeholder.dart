import 'package:flutter/material.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';

/// Stylised map preview (no map SDK): grid, a couple of roads and a pin.
class MapPlaceholder extends StatelessWidget {
  final double height;
  final String? label;
  final VoidCallback? onTap;
  final bool showPin;

  const MapPlaceholder({
    super.key,
    this.height = 150,
    this.label,
    this.onTap,
    this.showPin = true,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BeaconRadius.rLg,
      child: Material(
        color: t.surfaceLow,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapPainter(
                      grid: t.outlineVariant,
                      road: t.surfaceHigh,
                      water: t.primaryContainer.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                if (showPin)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: t.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: t.surface, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: t.primary.withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(Icons.place_rounded,
                              color: t.onPrimary, size: 22),
                        ),
                      ],
                    ),
                  ),
                if (label != null)
                  Positioned(
                    left: BeaconSpace.md,
                    right: BeaconSpace.md,
                    bottom: BeaconSpace.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: BeaconSpace.md, vertical: BeaconSpace.sm),
                      decoration: BoxDecoration(
                        color: t.glassSurface,
                        borderRadius: BeaconRadius.rMd,
                        border: Border.all(color: t.glassBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.near_me_rounded, size: 16, color: t.primary),
                          const SizedBox(width: BeaconSpace.sm),
                          Expanded(
                            child: Text(
                              label!,
                              style: text.labelLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (onTap != null)
                            Icon(Icons.open_in_full_rounded,
                                size: 14, color: t.onSurfaceMuted),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final Color grid;
  final Color road;
  final Color water;
  _MapPainter({required this.grid, required this.road, required this.water});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final waterPaint = Paint()..color = water;
    final waterPath = Path()
      ..moveTo(size.width * 0.72, 0)
      ..quadraticBezierTo(size.width * 0.62, size.height * 0.4,
          size.width * 0.8, size.height * 0.7)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.85,
          size.width, size.height * 0.75)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    final roadPaint = Paint()
      ..color = road
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.62),
        Offset(size.width * 0.7, size.height * 0.55), roadPaint);
    canvas.drawLine(Offset(size.width * 0.3, 0),
        Offset(size.width * 0.38, size.height), roadPaint);
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) =>
      old.grid != grid || old.road != road || old.water != water;
}
