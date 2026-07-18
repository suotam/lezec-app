import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/crux_colors.dart';
import '../../../../shared/widgets/crux_map.dart';
import '../../domain/climbing_area.dart';
import '../../domain/geo_point.dart';
import 'area_card.dart';

/// Roughly the geographic center of the Czech Republic; the camera falls
/// back to it when no areas match the current filter.
const _czechiaCenter = LatLng(49.8, 15.5);

LatLng _toLatLng(GeoPoint point) => LatLng(point.latitude, point.longitude);

/// Map of the (filtered) areas. Tapping a marker shows the area's card;
/// tapping the card hands off to [onAreaTap]. The camera refits whenever
/// the filtered set changes so search results stay in view.
class AreasMapView extends StatefulWidget {
  const AreasMapView({super.key, required this.areas, required this.onAreaTap});

  final List<ClimbingArea> areas;
  final void Function(ClimbingArea area) onAreaTap;

  @override
  State<AreasMapView> createState() => _AreasMapViewState();
}

class _AreasMapViewState extends State<AreasMapView> {
  final MapController _controller = MapController();
  ClimbingArea? _selected;

  static CameraFit _fitFor(List<ClimbingArea> areas) => CameraFit.coordinates(
    coordinates: [for (final area in areas) _toLatLng(area.location)],
    padding: const EdgeInsets.all(48),
    maxZoom: 14,
  );

  @override
  void didUpdateWidget(AreasMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = oldWidget.areas.map((a) => a.id).toSet();
    final newIds = widget.areas.map((a) => a.id).toSet();
    if (setEquals(oldIds, newIds)) return;
    if (_selected != null && !newIds.contains(_selected!.id)) {
      _selected = null;
    }
    if (widget.areas.isNotEmpty) {
      _controller.fitCamera(_fitFor(widget.areas));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Selects [area]; when it has parking, the camera refits so the crag
  /// and its parking markers are both in view.
  void _select(ClimbingArea area) {
    setState(() => _selected = area);
    if (area.parking.isEmpty) return;
    _controller.fitCamera(
      CameraFit.coordinates(
        coordinates: [
          _toLatLng(area.location),
          for (final parking in area.parking) _toLatLng(parking.location),
        ],
        padding: const EdgeInsets.all(64),
        maxZoom: 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _selected;
    return Stack(
      children: [
        CruxMap(
          controller: _controller,
          options: MapOptions(
            initialCenter: _czechiaCenter,
            initialZoom: 7,
            initialCameraFit: widget.areas.isEmpty
                ? null
                : _fitFor(widget.areas),
            onTap: (_, _) => setState(() => _selected = null),
          ),
          markers: [
            for (final area in widget.areas)
              Marker(
                point: _toLatLng(area.location),
                width: 44,
                height: 44,
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () => _select(area),
                  child: Semantics(
                    button: true,
                    label: area.name,
                    // Brand orange for every marker; selection reads
                    // through size, not color, so nothing looks off-brand.
                    child: Icon(
                      Icons.location_on,
                      size: area.id == selected?.id ? 44 : 34,
                      color: theme.colorScheme.primary,
                      shadows: const [
                        Shadow(blurRadius: 4, color: Colors.black45),
                      ],
                    ),
                  ),
                ),
              ),
            // Parking of the selected area only — permanent parking
            // markers for 951 areas would drown the map. Blue like
            // road-sign parking markings.
            if (selected != null)
              for (final parking in selected.parking)
                Marker(
                  point: _toLatLng(parking.location),
                  width: 26,
                  height: 26,
                  child: Semantics(
                    label: parking.name,
                    child: Icon(
                      Icons.local_parking,
                      size: 26,
                      color: theme.cruxColors.project,
                      shadows: const [
                        Shadow(blurRadius: 4, color: Colors.black45),
                      ],
                    ),
                  ),
                ),
          ],
        ),
        if (selected != null)
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: AreaCard(
              area: selected,
              onTap: () => widget.onAreaTap(selected),
            ),
          ),
      ],
    );
  }
}
