import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/map_marker_entity.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  double _currentRadius = 5.0; // Radio en kilómetros
  bool _showPromotions = true;
  bool _showCommerces = true;
  // Indica si el mapa ya mostró marcadores al menos una vez.
  // Solo se usa el spinner de pantalla completa en la carga inicial.
  bool _mapInitialized = false;
  bool _isReloading = false;

  // Ubicación por defecto (San José, Costa Rica)
  static const LatLng _defaultLocation = LatLng(9.9281, -84.0907);
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _requestLocationAndLoadMarkers();
  }

  void _requestLocationAndLoadMarkers() {
    // Primero verificar permisos
    context.read<LocationBloc>().add(const LocationCheckPermissionRequested());
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _loadNearbyMarkers(double lat, double lng) {
    context.read<LocationBloc>().add(
          LocationLoadAllNearbyMarkersRequested(
            latitude: lat,
            longitude: lng,
            radiusInKm: _currentRadius,
          ),
        );
  }

  void _updateMarkers(List<MapMarkerEntity> markerEntities) {
    setState(() {
      _markers.clear();

      for (final markerEntity in markerEntities) {
        // Filtrar según preferencias del usuario
        if (markerEntity.type == MarkerType.promotion && !_showPromotions) {
          continue;
        }
        if (markerEntity.type == MarkerType.commerce && !_showCommerces) {
          continue;
        }

        _markers.add(
          Marker(
            markerId: MarkerId(markerEntity.id),
            position: LatLng(
              markerEntity.location.latitude,
              markerEntity.location.longitude,
            ),
            infoWindow: InfoWindow(
              title: markerEntity.title,
              snippet: markerEntity.subtitle,
            ),
            icon: _getMarkerIcon(markerEntity.type),
            onTap: () => _onMarkerTapped(markerEntity),
          ),
        );
      }
    });
  }

  BitmapDescriptor _getMarkerIcon(MarkerType type) {
    switch (type) {
      case MarkerType.promotion:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case MarkerType.commerce:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case MarkerType.userLocation:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  void _onMarkerTapped(MapMarkerEntity marker) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _MarkerDetailSheet(marker: marker),
    );
  }

  void _centerOnUserLocation() {
    if (_currentLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
            _currentLocation!, _getZoomLevel(_currentRadius)),
      );
    }
  }

  // Calcular nivel de zoom basado en el radio (en km)
  double _getZoomLevel(double radiusKm) {
    // Fórmula aproximada: zoom = log2(40075 / (radiusKm * 256))
    // Donde 40075 es la circunferencia de la Tierra en km
    // Ajustamos para que sea más intuitivo
    if (radiusKm <= 1) return 15.0;
    if (radiusKm <= 2) return 14.0;
    if (radiusKm <= 5) return 13.0;
    if (radiusKm <= 10) return 12.0;
    if (radiusKm <= 15) return 11.0;
    return 10.0;
  }

  void _showRadiusDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => _RadiusDialog(
        initialRadius: _currentRadius,
        onApply: (newRadius) {
          setState(() {
            _currentRadius = newRadius;
          });

          final location = _currentLocation ?? _defaultLocation;
          final zoomLevel = _getZoomLevel(newRadius);

          print('Aplicando nuevo radio: $newRadius km');
          print('Ubicación: ${location.latitude}, ${location.longitude}');
          print('Nivel de zoom: $zoomLevel');

          // Ajustar zoom del mapa según el nuevo radio
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              location,
              zoomLevel,
            ),
          );

          // Recargar marcadores con el nuevo radio
          _loadNearbyMarkers(
            location.latitude,
            location.longitude,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationPermissionDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                action: SnackBarAction(
                  label: 'Configurar',
                  onPressed: () {
                    context.read<LocationBloc>().add(
                          const LocationOpenSettingsRequested(),
                        );
                  },
                ),
              ),
            );
          } else if (state is LocationServiceDisabled) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                action: SnackBarAction(
                  label: 'Activar',
                  onPressed: () {
                    context.read<LocationBloc>().add(
                          const LocationOpenSettingsRequested(),
                        );
                  },
                ),
              ),
            );
          } else if (state is LocationPermissionGranted) {
            // Obtener ubicación actual
            context.read<LocationBloc>().add(
                  const LocationGetCurrentRequested(),
                );
          } else if (state is LocationLoaded) {
            setState(() {
              _currentLocation = LatLng(
                state.location.latitude,
                state.location.longitude,
              );
            });
            _loadNearbyMarkers(
              state.location.latitude,
              state.location.longitude,
            );
            _centerOnUserLocation();
          } else if (state is LocationMarkersLoaded) {
            _updateMarkers(state.markers);
            if (state.currentLocation != null) {
              setState(() {
                _currentLocation = LatLng(
                  state.currentLocation!.latitude,
                  state.currentLocation!.longitude,
                );
              });
            }
            // El mapa ya tiene datos — las próximas cargas son recargas
            if (!_mapInitialized) setState(() => _mapInitialized = true);
            if (_isReloading) setState(() => _isReloading = false);
          } else if (state is LocationLoading) {
            // Solo activar el indicador de recarga si el mapa ya fue inicializado
            if (_mapInitialized && !_isReloading) {
              setState(() => _isReloading = true);
            }
          } else if (state is LocationError) {
            if (_isReloading) setState(() => _isReloading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          // Solo mostrar spinner de pantalla completa en la carga inicial
          // (antes de que el mapa haya mostrado marcadores por primera vez)
          if (state is LocationLoading && !_mapInitialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Stack(
            children: [
              // Mapa
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentLocation ?? _defaultLocation,
                  zoom: 14,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),

              // Barra de progreso durante recarga de marcadores (no destruye el mapa)
              if (_isReloading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),

              // Controles superiores — filtros (right side only)
              Positioned(
                top: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.local_offer,
                            color: _showPromotions
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPromotions = !_showPromotions;
                            });
                            if (state is LocationMarkersLoaded) {
                              _updateMarkers(state.markers);
                            }
                          },
                          tooltip: 'Promociones',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.store,
                            color: _showCommerces
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _showCommerces = !_showCommerces;
                            });
                            if (state is LocationMarkersLoaded) {
                              _updateMarkers(state.markers);
                            }
                          },
                          tooltip: 'Comercios',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Routes toolbar — top left
              Positioned(
                top: 16,
                left: 16,
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: () => context.push(AppRouter.routePlanner),
                        icon: const Icon(Icons.route, size: 18),
                        label: const Text('Nueva ruta'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                      const Divider(height: 1),
                      TextButton.icon(
                        onPressed: () => context.push(AppRouter.savedRoutes),
                        icon: const Icon(Icons.bookmark_outline, size: 18),
                        label: const Text('Mis rutas'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botones de acción
              Positioned(
                right: 16,
                bottom: 100,
                child: Column(
                  children: [
                    FloatingActionButton(
                      heroTag: 'radius',
                      mini: true,
                      onPressed: _showRadiusDialog,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.tune,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'location',
                      mini: true,
                      onPressed: _centerOnUserLocation,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.my_location,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: 'refresh',
                      mini: true,
                      onPressed: () {
                        if (_currentLocation != null) {
                          _loadNearbyMarkers(
                            _currentLocation!.latitude,
                            _currentLocation!.longitude,
                          );
                        }
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.refresh,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

// Widget para mostrar detalles del marcador
class _MarkerDetailSheet extends StatelessWidget {
  final MapMarkerEntity marker;

  const _MarkerDetailSheet({required this.marker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                marker.type == MarkerType.promotion
                    ? Icons.local_offer
                    : Icons.store,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  marker.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (marker.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              marker.subtitle!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navegar a detalle
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Ver Detalle'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Abrir en Google Maps
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Cómo llegar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget para el diálogo de ajuste de radio
class _RadiusDialog extends StatefulWidget {
  final double initialRadius;
  final void Function(double) onApply;

  const _RadiusDialog({
    required this.initialRadius,
    required this.onApply,
  });

  @override
  State<_RadiusDialog> createState() => _RadiusDialogState();
}

class _RadiusDialogState extends State<_RadiusDialog> {
  late double _tempRadius;

  @override
  void initState() {
    super.initState();
    _tempRadius = widget.initialRadius;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Radio de Búsqueda'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Radio: ${_tempRadius.toStringAsFixed(1)} km',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _tempRadius,
            min: 1.0,
            max: 20.0,
            divisions: 19,
            label: '${_tempRadius.toStringAsFixed(1)} km',
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _tempRadius = value;
              });
            },
          ),
          Text(
            'Desliza para ajustar el radio de búsqueda',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onApply(_tempRadius);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}
