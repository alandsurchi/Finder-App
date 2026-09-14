import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:finder/theme/app_color_tokens.dart';
import 'package:finder/theme/beacon_tokens.dart';
import 'map_placeholder.dart';

/// OpenStreetMap tiles with the Beacon dark-mode treatment. Shared by the
/// small previews and the full-screen picker so every map looks the same.
class FinderTileLayer extends StatelessWidget {
  const FinderTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.finderapp.finder',
      tileBuilder: t.isDark ? darkModeTileBuilder : null,
    );
  }
}

/// Required by the OpenStreetMap tile usage policy.
class MapAttribution extends StatelessWidget {
  const MapAttribution({super.key});

  static const String text = 'Map data © OpenStreetMap contributors';

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Container(
      margin: const EdgeInsets.all(BeaconSpace.xs),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: t.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 9, color: t.onSurfaceVar),
      ),
    );
  }
}

/// The Beacon location pin: a primary disc that sits on the exact point.
class MapPin extends StatelessWidget {
  final double size;
  const MapPin({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: t.primary,
            shape: BoxShape.circle,
            border: Border.all(color: t.surface, width: 3),
            boxShadow: [
              BoxShadow(
                color: t.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(Icons.place_rounded, color: t.onPrimary, size: size * 0.5),
        ),
        // A small tail so the disc reads as "planted" on the point.
        Container(
          width: 3,
          height: size * 0.3,
          decoration: BoxDecoration(
            color: t.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  /// Height of the pin including its tail, for marker sizing.
  static double totalHeight(double size) => size + size * 0.3;
}

/// A small, non-interactive map centred on a point. Falls back to the
/// illustrated [MapPlaceholder] when there are no coordinates yet.
class MapPreview extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String? label;
  final double height;
  final double zoom;
  final VoidCallback? onTap;

  const MapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    this.label,
    this.height = 150,
    this.zoom = 15.5,
    this.onTap,
  });

  bool get hasPoint => latitude != null && longitude != null;

  @override
  Widget build(BuildContext context) {
    if (!hasPoint) {
      return MapPlaceholder(height: height, label: label, onTap: onTap);
    }
    final t = AppColorTokens.of(context);
    final text = Theme.of(context).textTheme;
    final point = LatLng(latitude!, longitude!);
    const pinSize = 36.0;

    return ClipRRect(
      borderRadius: BeaconRadius.rLg,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: zoom,
                interactionOptions:
                    const InteractionOptions(flags: InteractiveFlag.none),
                backgroundColor: t.surfaceLow,
              ),
              children: [
                const FinderTileLayer(),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: pinSize,
                      height: MapPin.totalHeight(pinSize),
                      alignment: Alignment.topCenter,
                      child: const MapPin(size: pinSize),
                    ),
                  ],
                ),
                const Align(
                    alignment: Alignment.bottomRight, child: MapAttribution()),
              ],
            ),
            if (label != null && label!.isNotEmpty)
              Positioned(
                left: BeaconSpace.sm,
                right: BeaconSpace.sm,
                top: BeaconSpace.sm,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: BeaconSpace.md, vertical: BeaconSpace.xs),
                    decoration: BoxDecoration(
                      color: t.surface.withValues(alpha: 0.92),
                      borderRadius: BeaconRadius.rPill,
                      border: Border.all(color: t.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.place_outlined, size: 16, color: t.primary),
                        const SizedBox(width: BeaconSpace.xs),
                        Flexible(
                          child: Text(
                            label!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.labelMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (onTap != null)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: Semantics(
                      button: true,
                      label: 'Open map',
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
