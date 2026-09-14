import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:finder/app/di/app_providers.dart';
import 'package:finder/features/location/place.dart';
import 'package:finder/providers/my_posts_provider.dart' show describeError;
import 'package:finder/widgets/common/action_feedback.dart';
import 'package:finder/widgets/ui/ui.dart';

/// Full-screen map. In pick mode the map moves under a fixed pin; the address
/// under the pin is resolved as you go and returned with [pick]. In read-only
/// mode it just shows a place.
class LocationPickerScreen extends ConsumerStatefulWidget {
  final Place? initial;
  final bool readOnly;
  final String title;

  const LocationPickerScreen({
    super.key,
    this.initial,
    this.readOnly = false,
    this.title = 'Pick a location',
  });

  /// Opens the picker and resolves with the chosen place, or null.
  static Future<Place?> pick(BuildContext context, {Place? initial}) {
    return Navigator.of(context).push<Place>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => LocationPickerScreen(initial: initial),
      ),
    );
  }

  /// Shows a place on a full map without editing.
  static Future<void> view(BuildContext context, Place place,
      {String title = 'Location'}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            LocationPickerScreen(initial: place, readOnly: true, title: title),
      ),
    );
  }

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  static const _worldCenter = LatLng(20, 0);
  static const _worldZoom = 2.0;
  static const _placeZoom = 16.0;
  static const _pinSize = 44.0;

  final _map = MapController();
  final _searchCtrl = TextEditingController();

  Place? _place;
  bool _resolving = false;
  bool _locating = false;
  bool _mapReady = false;
  bool _searching = false;
  List<Place> _results = const [];
  Timer? _searchDebounce;
  Timer? _moveDebounce;

  @override
  void initState() {
    super.initState();
    _place = widget.initial;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _moveDebounce?.cancel();
    _searchCtrl.dispose();
    _map.dispose();
    super.dispose();
  }

  // ── Map events ────────────────────────────────────────────────────────────

  void _onMapReady() {
    _mapReady = true;
    if (_place == null && !widget.readOnly) _locate(silent: true);
  }

  void _onMapEvent(MapEvent event) {
    if (widget.readOnly) return;
    // Programmatic moves already know their place; only user gestures need
    // the address under the pin resolved.
    if (event.source == MapEventSource.mapController ||
        event.source == MapEventSource.nonRotatedSizeChange ||
        event.source == MapEventSource.custom) {
      return;
    }
    final moved = event is MapEventMove ||
        event is MapEventMoveEnd ||
        event is MapEventFlingAnimation ||
        event is MapEventFlingAnimationEnd ||
        event is MapEventDoubleTapZoom ||
        event is MapEventDoubleTapZoomEnd ||
        event is MapEventScrollWheelZoom;
    if (!moved) return;
    if (!_resolving) setState(() => _resolving = true);
    _moveDebounce?.cancel();
    _moveDebounce = Timer(const Duration(milliseconds: 600), _resolveCenter);
  }

  Future<void> _resolveCenter() async {
    if (!mounted || !_mapReady) return;
    final c = _map.camera.center;
    setState(() {
      _resolving = true;
      _place = Place(
        latitude: c.latitude,
        longitude: c.longitude,
        label: Place.coordinatesLabel(c.latitude, c.longitude),
      );
    });
    final place = await ref
        .read(geoServiceProvider)
        .reverseOrCoordinates(c.latitude, c.longitude);
    if (!mounted) return;
    // Ignore the answer when the map has moved on since the request.
    final now = _map.camera.center;
    if ((now.latitude - c.latitude).abs() > 1e-7 ||
        (now.longitude - c.longitude).abs() > 1e-7) {
      return;
    }
    setState(() {
      _place = place;
      _resolving = false;
    });
  }

  void _goTo(Place place) {
    _moveDebounce?.cancel();
    setState(() {
      _place = place;
      _resolving = false;
      _results = const [];
    });
    if (_mapReady) {
      _map.move(LatLng(place.latitude, place.longitude), _placeZoom);
    }
  }

  // ── Current location ──────────────────────────────────────────────────────

  Future<void> _locate({bool silent = false}) async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final place = await ref.read(geoServiceProvider).currentPlace();
      if (!mounted) return;
      _goTo(place);
    } catch (e) {
      if (!silent && mounted) {
        ActionFeedback.showError(context, describeError(e));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final q = value.trim();
    if (q.length < 2) {
      setState(() {
        _results = const [];
        _searching = false;
      });
      return;
    }
    _searchDebounce =
        Timer(const Duration(milliseconds: 450), () => _search(q));
  }

  Future<void> _search(String q) async {
    setState(() => _searching = true);
    try {
      final results = await ref.read(geoServiceProvider).search(q);
      if (!mounted || _searchCtrl.text.trim() != q) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _searching = false);
      ActionFeedback.showError(context, describeError(e));
    }
  }

  void _selectResult(Place place) {
    _searchCtrl.text = place.label;
    FocusScope.of(context).unfocus();
    _goTo(place);
  }

  void _confirm() {
    final place = _place;
    if (place == null) return;
    Navigator.of(context).pop(place);
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = AppColorTokens.of(context);
    final initial = _place;
    final initialCenter = initial != null
        ? LatLng(initial.latitude, initial.longitude)
        : _worldCenter;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: initial != null ? _placeZoom : _worldZoom,
                minZoom: 2,
                maxZoom: 19,
                backgroundColor: t.surfaceLow,
                onMapReady: _onMapReady,
                onMapEvent: _onMapEvent,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                const FinderTileLayer(),
                if (widget.readOnly && initial != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(initial.latitude, initial.longitude),
                        width: _pinSize,
                        height: MapPin.totalHeight(_pinSize),
                        alignment: Alignment.topCenter,
                        child: const MapPin(size: _pinSize),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Fixed pin: its tip sits exactly on the map centre.
          if (!widget.readOnly)
            Center(
              child: IgnorePointer(
                child: Transform.translate(
                  offset: Offset(0, -MapPin.totalHeight(_pinSize) / 2),
                  child: const MapPin(size: _pinSize),
                ),
              ),
            ),

          if (!widget.readOnly) _buildSearch(t),
          _buildBottomPanel(t),
        ],
      ),
    );
  }

  Widget _buildSearch(AppColorTokens t) {
    final text = Theme.of(context).textTheme;
    return Positioned(
      top: BeaconSpace.md,
      left: BeaconSpace.page,
      right: BeaconSpace.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SurfaceCard(
            padding: const EdgeInsets.all(BeaconSpace.xs),
            child: AppTextField(
              controller: _searchCtrl,
              hint: 'Search a place or address',
              prefixIcon: Icons.search_rounded,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              onSubmitted: (v) {
                _searchDebounce?.cancel();
                if (v.trim().length >= 2) _search(v.trim());
              },
            ),
          ),
          if (_searching || _results.isNotEmpty) ...[
            const SizedBox(height: BeaconSpace.sm),
            SurfaceCard(
              padding: EdgeInsets.zero,
              child: _searching
                  ? Padding(
                      padding: const EdgeInsets.all(BeaconSpace.lg),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: t.primary),
                          ),
                          const SizedBox(width: BeaconSpace.md),
                          Text('Searching…', style: text.bodyMedium),
                        ],
                      ),
                    )
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 260),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _results.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: t.outlineVariant),
                        itemBuilder: (context, i) {
                          final p = _results[i];
                          return ListTile(
                            leading:
                                Icon(Icons.place_outlined, color: t.primary),
                            title: Text(p.label,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: p.fullLabel == p.label
                                ? null
                                : Text(p.fullLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.bodySmall),
                            onTap: () => _selectResult(p),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomPanel(AppColorTokens t) {
    final text = Theme.of(context).textTheme;
    final place = _place;
    final label = place == null
        ? (widget.readOnly ? 'Location not specified' : 'Move the map to place the pin')
        : place.label;

    return Positioned(
      left: BeaconSpace.page,
      right: BeaconSpace.page,
      bottom: BeaconSpace.page + MediaQuery.paddingOf(context).bottom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.readOnly)
            AppIconButton(
              icon: Icons.my_location_rounded,
              tooltip: 'Use my current location',
              variant: AppIconButtonVariant.filled,
              size: 48,
              iconSize: 22,
              onPressed: _locating ? null : () => _locate(),
            ),
          const SizedBox(height: BeaconSpace.sm),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.place_rounded, color: t.primary),
                    const SizedBox(width: BeaconSpace.sm),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall,
                      ),
                    ),
                    if (_resolving || _locating) ...[
                      const SizedBox(width: BeaconSpace.sm),
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: t.primary),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: BeaconSpace.xs),
                Text(
                  place == null
                      ? MapAttribution.text
                      : _resolving
                          ? 'Finding the address…'
                          : '${place.coordinates} · ${MapAttribution.text}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall?.copyWith(color: t.onSurfaceMuted),
                ),
                if (!widget.readOnly) ...[
                  const SizedBox(height: BeaconSpace.md),
                  AppButton(
                    label: 'Use this location',
                    icon: Icons.check_rounded,
                    size: AppButtonSize.medium,
                    onPressed: (place == null || _resolving) ? null : _confirm,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
