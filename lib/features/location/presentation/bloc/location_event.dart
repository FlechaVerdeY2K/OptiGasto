import 'package:equatable/equatable.dart';

/// Eventos de ubicación
abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Obtener ubicación actual
class LocationGetCurrentRequested extends LocationEvent {
  const LocationGetCurrentRequested();
}

/// Evento: Verificar permisos de ubicación
class LocationCheckPermissionRequested extends LocationEvent {
  const LocationCheckPermissionRequested();
}

/// Evento: Solicitar permisos de ubicación
class LocationRequestPermissionRequested extends LocationEvent {
  const LocationRequestPermissionRequested();
}

/// Evento: Verificar si el servicio de ubicación está habilitado
class LocationCheckServiceRequested extends LocationEvent {
  const LocationCheckServiceRequested();
}

/// Evento: Abrir configuración de ubicación
class LocationOpenSettingsRequested extends LocationEvent {
  const LocationOpenSettingsRequested();
}

/// Evento: Cargar marcadores de promociones cercanas
class LocationLoadNearbyPromotionMarkersRequested extends LocationEvent {
  final double latitude;
  final double longitude;
  final double radiusInKm;
  final int? limit;

  const LocationLoadNearbyPromotionMarkersRequested({
    required this.latitude,
    required this.longitude,
    required this.radiusInKm,
    this.limit,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusInKm, limit];
}

/// Evento: Cargar marcadores de comercios cercanos
class LocationLoadNearbyCommerceMarkersRequested extends LocationEvent {
  final double latitude;
  final double longitude;
  final double radiusInKm;
  final int? limit;

  const LocationLoadNearbyCommerceMarkersRequested({
    required this.latitude,
    required this.longitude,
    required this.radiusInKm,
    this.limit,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusInKm, limit];
}

/// Evento: Cargar todos los marcadores cercanos (promociones + comercios)
class LocationLoadAllNearbyMarkersRequested extends LocationEvent {
  final double latitude;
  final double longitude;
  final double radiusInKm;
  final int? limit;

  const LocationLoadAllNearbyMarkersRequested({
    required this.latitude,
    required this.longitude,
    required this.radiusInKm,
    this.limit,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusInKm, limit];
}

/// Evento: Iniciar seguimiento de ubicación en tiempo real
class LocationStartWatchingRequested extends LocationEvent {
  const LocationStartWatchingRequested();
}

/// Evento: Detener seguimiento de ubicación
class LocationStopWatchingRequested extends LocationEvent {
  const LocationStopWatchingRequested();
}

/// Evento: Actualización de ubicación (desde stream)
class LocationUpdated extends LocationEvent {
  final double latitude;
  final double longitude;
  final double? accuracy;

  const LocationUpdated({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });

  @override
  List<Object?> get props => [latitude, longitude, accuracy];
}

/// Evento: Cambiar radio de búsqueda
class LocationChangeRadiusRequested extends LocationEvent {
  final double radiusInKm;

  const LocationChangeRadiusRequested({required this.radiusInKm});

  @override
  List<Object?> get props => [radiusInKm];
}

/// Evento: Refrescar marcadores
class LocationRefreshMarkersRequested extends LocationEvent {
  const LocationRefreshMarkersRequested();
}

/// Evento: Limpiar marcadores
class LocationClearMarkersRequested extends LocationEvent {
  const LocationClearMarkersRequested();
}

// Made with Bob