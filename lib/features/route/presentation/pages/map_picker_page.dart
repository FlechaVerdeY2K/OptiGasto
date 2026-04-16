// lib/features/route/presentation/pages/map_picker_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../location/domain/entities/map_marker_entity.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../../location/presentation/bloc/location_event.dart';
import '../../../location/presentation/bloc/location_state.dart';
import '../../domain/entities/route_stop_entity.dart';

/// Full-screen map where user taps markers to select route stops.
/// Returns List<RouteStopEntity> via context.pop(result).
class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  GoogleMapController? _mapController;
  static const LatLng _defaultLocation = LatLng(9.9281, -84.0907);
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  final List<RouteStopEntity> _selectedStops = [];
  List<MapMarkerEntity> _markerEntities = [];

  @override
  void initState() {
    super.initState();
    context.read<LocationBloc>().add(const LocationCheckPermissionRequested());
  }

  void _onMarkerTapped(MapMarkerEntity entity) {
    setState(() {
      final alreadySelected = _selectedStops.any((s) => s.id == entity.id);
      if (alreadySelected) {
        _selectedStops.removeWhere((s) => s.id == entity.id);
      } else {
        _selectedStops.add(
          RouteStopEntity(
            id: entity.id,
            promotionId: entity.type == MarkerType.promotion ? entity.id : null,
            name: entity.title,
            location: entity.location,
            order: 0,
          ),
        );
      }
      _rebuildMarkers();
    });
  }

  void _rebuildMarkers() {
    _markers.clear();
    for (final entity in _markerEntities) {
      final isSelected = _selectedStops.any((s) => s.id == entity.id);
      _markers.add(Marker(
        markerId: MarkerId(entity.id),
        position: LatLng(
          entity.location.latitude,
          entity.location.longitude,
        ),
        infoWindow: InfoWindow(title: entity.title, snippet: entity.subtitle),
        icon: isSelected
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
            : BitmapDescriptor.defaultMarkerWithHue(
                entity.type == MarkerType.promotion
                    ? BitmapDescriptor.hueRed
                    : BitmapDescriptor.hueBlue,
              ),
        onTap: () => _onMarkerTapped(entity),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedStops.isEmpty
              ? 'Seleccionar paradas'
              : '${_selectedStops.length} / 10 paradas',
        ),
        actions: [
          TextButton(
            onPressed: _selectedStops.isEmpty
                ? null
                : () => context.pop(_selectedStops),
            child: Text(
              'Listo',
              style: TextStyle(
                color: _selectedStops.isEmpty ? null : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationPermissionGranted) {
            context
                .read<LocationBloc>()
                .add(const LocationGetCurrentRequested());
          } else if (state is LocationLoaded) {
            setState(() {
              _currentLocation = LatLng(
                state.location.latitude,
                state.location.longitude,
              );
            });
            context.read<LocationBloc>().add(
                  LocationLoadAllNearbyMarkersRequested(
                    latitude: state.location.latitude,
                    longitude: state.location.longitude,
                    radiusInKm: 5.0,
                  ),
                );
          } else if (state is LocationMarkersLoaded) {
            setState(() {
              _markerEntities = state.markers;
              _rebuildMarkers();
            });
          }
        },
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: (c) => _mapController = c,
              initialCameraPosition: CameraPosition(
                target: _currentLocation ?? _defaultLocation,
                zoom: 14,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
            ),
            if (_selectedStops.isNotEmpty)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Tocá un marcador verde para deseleccionar. '
                      '${_selectedStops.length} seleccionadas.',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
