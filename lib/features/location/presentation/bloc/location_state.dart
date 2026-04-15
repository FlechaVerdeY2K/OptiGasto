import 'package:equatable/equatable.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/map_marker_entity.dart';

/// Estados de ubicación
abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class LocationInitial extends LocationState {
  const LocationInitial();
}

/// Estado: Cargando
class LocationLoading extends LocationState {
  const LocationLoading();
}

/// Estado: Ubicación obtenida
class LocationLoaded extends LocationState {
  final LocationEntity location;
  final bool hasPermission;
  final bool isServiceEnabled;

  const LocationLoaded({
    required this.location,
    this.hasPermission = true,
    this.isServiceEnabled = true,
  });

  @override
  List<Object?> get props => [location, hasPermission, isServiceEnabled];

  LocationLoaded copyWith({
    LocationEntity? location,
    bool? hasPermission,
    bool? isServiceEnabled,
  }) {
    return LocationLoaded(
      location: location ?? this.location,
      hasPermission: hasPermission ?? this.hasPermission,
      isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
    );
  }
}

/// Estado: Marcadores cargados
class LocationMarkersLoaded extends LocationState {
  final LocationEntity? currentLocation;
  final List<MapMarkerEntity> markers;
  final double radiusInKm;
  final bool showPromotions;
  final bool showCommerces;

  const LocationMarkersLoaded({
    this.currentLocation,
    required this.markers,
    this.radiusInKm = 5.0,
    this.showPromotions = true,
    this.showCommerces = true,
  });

  @override
  List<Object?> get props => [
        currentLocation,
        markers,
        radiusInKm,
        showPromotions,
        showCommerces,
      ];

  LocationMarkersLoaded copyWith({
    LocationEntity? currentLocation,
    List<MapMarkerEntity>? markers,
    double? radiusInKm,
    bool? showPromotions,
    bool? showCommerces,
  }) {
    return LocationMarkersLoaded(
      currentLocation: currentLocation ?? this.currentLocation,
      markers: markers ?? this.markers,
      radiusInKm: radiusInKm ?? this.radiusInKm,
      showPromotions: showPromotions ?? this.showPromotions,
      showCommerces: showCommerces ?? this.showCommerces,
    );
  }
}

/// Estado: Ubicación siendo observada (streaming)
class LocationWatching extends LocationState {
  final LocationEntity location;
  final List<MapMarkerEntity> markers;
  final double radiusInKm;

  const LocationWatching({
    required this.location,
    this.markers = const [],
    this.radiusInKm = 5.0,
  });

  @override
  List<Object?> get props => [location, markers, radiusInKm];

  LocationWatching copyWith({
    LocationEntity? location,
    List<MapMarkerEntity>? markers,
    double? radiusInKm,
  }) {
    return LocationWatching(
      location: location ?? this.location,
      markers: markers ?? this.markers,
      radiusInKm: radiusInKm ?? this.radiusInKm,
    );
  }
}

/// Estado: Permiso denegado
class LocationPermissionDenied extends LocationState {
  final String message;
  final bool isPermanentlyDenied;

  const LocationPermissionDenied({
    required this.message,
    this.isPermanentlyDenied = false,
  });

  @override
  List<Object?> get props => [message, isPermanentlyDenied];
}

/// Estado: Servicio de ubicación deshabilitado
class LocationServiceDisabled extends LocationState {
  final String message;

  const LocationServiceDisabled({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// Estado: Error
class LocationError extends LocationState {
  final String message;

  const LocationError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado: Permiso otorgado
class LocationPermissionGranted extends LocationState {
  final String message;

  const LocationPermissionGranted({
    this.message = 'Permiso de ubicación otorgado',
  });

  @override
  List<Object?> get props => [message];
}

/// Estado: Configuración abierta
class LocationSettingsOpened extends LocationState {
  const LocationSettingsOpened();
}

/// Estado: Refrescando marcadores
class LocationRefreshing extends LocationState {
  final LocationEntity? currentLocation;
  final List<MapMarkerEntity> currentMarkers;

  const LocationRefreshing({
    this.currentLocation,
    this.currentMarkers = const [],
  });

  @override
  List<Object?> get props => [currentLocation, currentMarkers];
}

// Made with Bob
