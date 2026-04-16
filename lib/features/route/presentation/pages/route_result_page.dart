import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/optimized_route_entity.dart';
import '../widgets/export_route_buttons.dart';
import '../widgets/route_stop_list.dart';
import '../widgets/route_summary_card.dart';

class RouteResultPage extends StatefulWidget {
  final OptimizedRouteEntity route;

  const RouteResultPage({super.key, required this.route});

  @override
  State<RouteResultPage> createState() => _RouteResultPageState();
}

class _RouteResultPageState extends State<RouteResultPage> {
  GoogleMapController? _mapController;

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Origin marker
    markers.add(
      Marker(
        markerId: const MarkerId('origin'),
        position: LatLng(
          widget.route.origin.location.latitude,
          widget.route.origin.location.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: widget.route.origin.displayName),
      ),
    );

    // Stop markers
    for (final stop in widget.route.stops) {
      markers.add(
        Marker(
          markerId: MarkerId(stop.id),
          position: LatLng(
            stop.location.latitude,
            stop.location.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: '${stop.order}. ${stop.name}',
          ),
        ),
      );
    }
    return markers;
  }

  Polyline _buildPolyline() {
    return Polyline(
      polylineId: const PolylineId('route'),
      points: widget.route.polylinePoints,
      color: AppColors.primary,
      width: 5,
    );
  }

  LatLngBounds _computeBounds() {
    final allPoints = [
      LatLng(
        widget.route.origin.location.latitude,
        widget.route.origin.location.longitude,
      ),
      ...widget.route.stops.map(
        (s) => LatLng(s.location.latitude, s.location.longitude),
      ),
    ];
    var minLat = allPoints.first.latitude;
    var maxLat = allPoints.first.latitude;
    var minLng = allPoints.first.longitude;
    var maxLng = allPoints.first.longitude;
    for (final p in allPoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    const delta = 0.005; // ~500 m
    if (minLat == maxLat) {
      minLat -= delta;
      maxLat += delta;
    }
    if (minLng == maxLng) {
      minLng -= delta;
      maxLng += delta;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final origin = widget.route.origin.location;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruta calculada'),
        actions: [
          TextButton(
            onPressed: () => context.go(AppRouter.routePlanner),
            child: const Text('Modificar'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Map — top half
          Expanded(
            child: GoogleMap(
              onMapCreated: (c) {
                _mapController = c;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngBounds(_computeBounds(), 60),
                  );
                });
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(origin.latitude, origin.longitude),
                zoom: 12,
              ),
              markers: _buildMarkers(),
              polylines: {_buildPolyline()},
              zoomControlsEnabled: false,
            ),
          ),

          // Details — scrollable bottom half
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RouteSummaryCard(route: widget.route),
                  const SizedBox(height: 16),
                  const Text(
                    'Paradas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  RouteStopList(route: widget.route),
                  const SizedBox(height: 16),
                  ExportRouteButtons(route: widget.route),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
