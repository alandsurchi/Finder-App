import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:finder/core/utils/hero_tags.dart';
import 'package:finder/features/location/place.dart';
import 'package:finder/features/posts/presentation/item_details_args.dart';
import 'package:finder/l10n/l10n.dart';
import 'package:finder/models/item_model.dart';
import 'package:finder/providers/my_posts_provider.dart' show describeError;
import 'package:finder/providers/post_provider.dart';
import 'package:finder/routes.dart';
import 'package:finder/app/di/app_providers.dart';
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/ui/map_preview.dart';
import 'package:finder/widgets/ui/ui.dart';

/// Posts around the user on a map: lost in coral, found in green. Tap a pin
/// for a card, tap the card for the post. The radius chips re-query.
class NearbyMapScreen extends ConsumerStatefulWidget {
  const NearbyMapScreen({super.key});

  @override
  ConsumerState<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends ConsumerState<NearbyMapScreen> {
  static const _radii = [5, 10, 25, 50];
  final _map = MapController();
  LatLng? _center;
  int _km = 10;
  List<ItemModel> _items = const [];
  ItemModel? _selected;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _locateAndLoad();
  }

  Future<void> _locateAndLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final Place place = await ref.read(geoServiceProvider).currentPlace();
      _center = LatLng(place.latitude, place.longitude);
      await _load();
      if (mounted && _center != null) _map.move(_center!, _zoomFor(_km));
    } catch (e) {
      if (mounted) setState(() => _error = describeError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _load() async {
    final c = _center;
    if (c == null) return;
    try {
      final items = await ref.read(postServiceProvider).fetchItems(
            near: c,
            km: _km,
            limit: 100,
          );
      if (!mounted) return;
      setState(() {
        _items = items.where((p) => p.hasCoordinates).toList();
        _selected = null;
      });
    } catch (e) {
      if (mounted) ActionFeedback.showError(context, describeError(e));
    }
  }

  double _zoomFor(int km) => km <= 5 ? 13 : km <= 10 ? 12 : km <= 25 ? 10.5 : 9.5;

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: _center ?? const LatLng(36.19, 44.01),
                initialZoom: _zoomFor(_km),
                onTap: (_, __) => setState(() => _selected = null),
              ),
              children: [
                const FinderTileLayer(),
                if (_center != null)
                  CircleLayer(circles: [
                    CircleMarker(
                      point: _center!,
                      radius: _km * 1000,
                      useRadiusInMeter: true,
                      color: t.primary.withValues(alpha: 0.06),
                      borderColor: t.primary.withValues(alpha: 0.35),
                      borderStrokeWidth: 1,
                    ),
                  ]),
                MarkerLayer(
                  markers: [
                    if (_center != null)
                      Marker(point: _center!, width: 18, height: 18, child: _MeDot()),
                    for (final p in _items)
                      Marker(
                        point: LatLng(p.latitude!, p.longitude!),
                        width: 36,
                        height: 44,
                        alignment: Alignment.topCenter,
                        child: _PostPin(
                          item: p,
                          selected: _selected?.id == p.id,
                          onTap: () => setState(() => _selected = p),
                        ),
                      ),
                  ],
                ),
                const Align(alignment: AlignmentDirectional.bottomStart, child: MapAttribution()),
              ],
            ),
          ),
          // Header
          PositionedDirectional(
            top: MediaQuery.paddingOf(context).top + BeaconSpace.sm,
            start: BeaconSpace.md,
            end: BeaconSpace.md,
            child: Row(
              children: [
                AppIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: l10n.commonBack,
                  variant: AppIconButtonVariant.glass,
                  onPressed: () => Navigator.maybePop(context),
                ),
                const SizedBox(width: BeaconSpace.sm),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: BeaconSpace.md, vertical: BeaconSpace.sm),
                    decoration: BoxDecoration(
                      color: t.surface.withValues(alpha: 0.92),
                      borderRadius: BeaconRadius.rPill,
                      border: Border.all(color: t.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.near_me_rounded, size: 18, color: t.primary),
                        const SizedBox(width: BeaconSpace.sm),
                        Expanded(
                          child: Text(
                            _loading
                                ? l10n.mapFindingAddress
                                : l10n.mapNearbyCount(_items.length, _km),
                            style: text.labelLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: BeaconSpace.sm),
                AppIconButton(
                  icon: Icons.my_location_rounded,
                  tooltip: l10n.mapUseMyLocation,
                  variant: AppIconButtonVariant.glass,
                  onPressed: _loading ? null : _locateAndLoad,
                ),
              ],
            ),
          ),
          // Radius chips
          PositionedDirectional(
            top: MediaQuery.paddingOf(context).top + BeaconSpace.sm + 56,
            start: BeaconSpace.md,
            child: Wrap(
              spacing: BeaconSpace.xs,
              children: [
                for (final r in _radii)
                  AppChoiceChip(
                    label: l10n.mapRadius(r),
                    selected: _km == r,
                    onTap: () async {
                      setState(() => _km = r);
                      if (_center != null) _map.move(_center!, _zoomFor(r));
                      await _load();
                    },
                  ),
              ],
            ),
          ),
          if (_error != null)
            Positioned.fill(
              child: Container(
                color: t.bg.withValues(alpha: 0.92),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(BeaconSpace.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_off_outlined, size: 40, color: t.onSurfaceMuted),
                    const SizedBox(height: BeaconSpace.md),
                    Text(_error!, textAlign: TextAlign.center, style: text.bodyMedium),
                    const SizedBox(height: BeaconSpace.lg),
                    AppButton.tonal(label: l10n.commonTryAgain, expand: false, onPressed: _locateAndLoad),
                  ],
                ),
              ),
            ),
          if (!_loading && _error == null && _items.isEmpty)
            PositionedDirectional(
              bottom: BeaconSpace.xl + MediaQuery.paddingOf(context).bottom,
              start: BeaconSpace.lg,
              end: BeaconSpace.lg,
              child: SurfaceCard(
                child: Text(l10n.mapNearbyEmpty, textAlign: TextAlign.center, style: text.bodyMedium),
              ),
            ),
          if (_selected != null)
            PositionedDirectional(
              bottom: BeaconSpace.lg + MediaQuery.paddingOf(context).bottom,
              start: BeaconSpace.md,
              end: BeaconSpace.md,
              child: ItemCard(
                item: _selected!,
                layout: ItemCardLayout.row,
                showDescription: false,
                heroTag: HeroTags.item('nearby', _selected!.id),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.itemDetails,
                  arguments: ItemDetailsArgs(_selected!, heroTag: HeroTags.item('nearby', _selected!.id)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MeDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: t.primary,
        border: Border.all(color: t.surface, width: 3),
        boxShadow: [BoxShadow(color: t.primary.withValues(alpha: 0.4), blurRadius: 10)],
      ),
    );
  }
}

class _PostPin extends StatelessWidget {
  final ItemModel item;
  final bool selected;
  final VoidCallback onTap;
  const _PostPin({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final kind = SignalKindX.ofItem(item);
    final color = kind.color(t);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.25 : 1,
        duration: BeaconMotion.state,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: t.surface, width: 2),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Icon(kind.icon, size: 16, color: kind.onColor(t)),
            ),
            Container(width: 2, height: 8, color: color),
          ],
        ),
      ),
    );
  }
}
