import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/optimized_route_entity.dart';
import '../bloc/saved_routes_bloc.dart';
import '../bloc/saved_routes_event.dart';
import '../bloc/saved_routes_state.dart';
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

  void _showSaveDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Guardar ruta'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre de la ruta',
            hintText: 'Ej: Ruta del domingo',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          BlocConsumer<SavedRoutesBloc, SavedRoutesState>(
            listener: (context, state) {
              if (state is SavedRoutesLoaded || state is SavedRoutesError) {
                Navigator.of(ctx).pop();
                final msg = state is SavedRoutesLoaded
                    ? 'Ruta guardada como "${nameController.text}"'
                    : (state as SavedRoutesError).message;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
              }
            },
            builder: (context, state) {
              return TextButton(
                onPressed: state is SavedRouteOperationInProgress
                    ? null
                    : () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        context.read<SavedRoutesBloc>().add(
                              SavedRouteCreateRequested(
                                route: widget.route,
                                name: name,
                              ),
                            );
                      },
                child: state is SavedRouteOperationInProgress
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              );
            },
          ),
        ],
      ),
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
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showSaveDialog(context),
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: const Text('Guardar ruta'),
                  ),
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
