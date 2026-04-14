import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/check_location_permission.dart';
import '../../domain/usecases/request_location_permission.dart';
import '../../domain/usecases/get_nearby_promotion_markers.dart';
import '../../domain/usecases/get_nearby_commerce_markers.dart';
import '../../domain/repositories/location_repository.dart';
import '../../../settings/data/settings_service.dart';
import 'location_event.dart';
import 'location_state.dart';

/// BLoC de ubicación y mapas
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetCurrentLocation getCurrentLocation;
  final CheckLocationPermission checkLocationPermission;
  final RequestLocationPermission requestLocationPermission;
  final GetNearbyPromotionMarkers getNearbyPromotionMarkers;
  final GetNearbyCommerceMarkers getNearbyCommerceMarkers;
  final LocationRepository repository;
  final SettingsService settingsService;

  StreamSubscription? _locationSubscription;

  LocationBloc({
    required this.getCurrentLocation,
    required this.checkLocationPermission,
    required this.requestLocationPermission,
    required this.getNearbyPromotionMarkers,
    required this.getNearbyCommerceMarkers,
    required this.repository,
    required this.settingsService,
  }) : super(const LocationInitial()) {
    // Registrar handlers de eventos
    on<LocationGetCurrentRequested>(_onGetCurrentRequested);
    on<LocationCheckPermissionRequested>(_onCheckPermissionRequested);
    on<LocationRequestPermissionRequested>(_onRequestPermissionRequested);
    on<LocationCheckServiceRequested>(_onCheckServiceRequested);
    on<LocationOpenSettingsRequested>(_onOpenSettingsRequested);
    on<LocationLoadNearbyPromotionMarkersRequested>(_onLoadNearbyPromotionMarkersRequested);
    on<LocationLoadNearbyCommerceMarkersRequested>(_onLoadNearbyCommerceMarkersRequested);
    on<LocationLoadAllNearbyMarkersRequested>(_onLoadAllNearbyMarkersRequested);
    on<LocationStartWatchingRequested>(_onStartWatchingRequested);
    on<LocationStopWatchingRequested>(_onStopWatchingRequested);
    on<LocationUpdated>(_onLocationUpdated);
    on<LocationChangeRadiusRequested>(_onChangeRadiusRequested);
    on<LocationRefreshMarkersRequested>(_onRefreshMarkersRequested);
    on<LocationClearMarkersRequested>(_onClearMarkersRequested);
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
  }

  /// Handler: Obtener ubicación actual
  Future<void> _onGetCurrentRequested(
    LocationGetCurrentRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());

    // Primero verificar permisos
    final permissionResult = await checkLocationPermission();
    final hasPermission = permissionResult.fold(
      (failure) => false,
      (granted) => granted,
    );

    if (!hasPermission) {
      emit(const LocationPermissionDenied(
        message: 'Se requieren permisos de ubicación para continuar',
      ));
      return;
    }

    // Verificar si el servicio está habilitado
    final serviceResult = await repository.isLocationServiceEnabled();
    final isServiceEnabled = serviceResult.fold(
      (failure) => false,
      (enabled) => enabled,
    );

    if (!isServiceEnabled) {
      emit(const LocationServiceDisabled(
        message: 'El servicio de ubicación está deshabilitado',
      ));
      return;
    }

    // Obtener ubicación
    final result = await getCurrentLocation();

    result.fold(
      (failure) => emit(LocationError(message: failure.message)),
      (location) => emit(LocationLoaded(
        location: location,
        hasPermission: hasPermission,
        isServiceEnabled: isServiceEnabled,
      )),
    );
  }

  /// Handler: Verificar permisos
  Future<void> _onCheckPermissionRequested(
    LocationCheckPermissionRequested event,
    Emitter<LocationState> emit,
  ) async {
    final result = await checkLocationPermission();

    result.fold(
      (failure) => emit(LocationError(message: failure.message)),
      (hasPermission) {
        if (hasPermission) {
          emit(const LocationPermissionGranted());
        } else {
          emit(const LocationPermissionDenied(
            message: 'Permisos de ubicación no otorgados',
          ));
        }
      },
    );
  }

  /// Handler: Solicitar permisos
  Future<void> _onRequestPermissionRequested(
    LocationRequestPermissionRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());

    final result = await requestLocationPermission();

    result.fold(
      (failure) => emit(LocationError(message: failure.message)),
      (granted) {
        if (granted) {
          emit(const LocationPermissionGranted(
            message: 'Permisos otorgados correctamente',
          ));
        } else {
          emit(const LocationPermissionDenied(
            message: 'Permisos de ubicación denegados',
            isPermanentlyDenied: false,
          ));
        }
      },
    );
  }

  /// Handler: Verificar servicio de ubicación
  Future<void> _onCheckServiceRequested(
    LocationCheckServiceRequested event,
    Emitter<LocationState> emit,
  ) async {
    final result = await repository.isLocationServiceEnabled();

    result.fold(
      (failure) => emit(LocationError(message: failure.message)),
      (isEnabled) {
        if (!isEnabled) {
          emit(const LocationServiceDisabled(
            message: 'El servicio de ubicación está deshabilitado',
          ));
        }
      },
    );
  }

  /// Handler: Abrir configuración
  Future<void> _onOpenSettingsRequested(
    LocationOpenSettingsRequested event,
    Emitter<LocationState> emit,
  ) async {
    final result = await repository.openLocationSettings();

    result.fold(
      (failure) => emit(LocationError(message: failure.message)),
      (_) => emit(const LocationSettingsOpened()),
    );
  }

  /// Handler: Cargar marcadores de promociones cercanas
  Future<void> _onLoadNearbyPromotionMarkersRequested(
    LocationLoadNearbyPromotionMarkersRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());

    // Usar radio de settings si no se especifica
    final settings = settingsService.getSettings();
    final radiusToUse = event.radiusInKm ?? settings.searchRadius;

    final result = await getNearbyPromotionMarkers(
      latitude: event.latitude,
      longitude: event.longitude,
      radiusInKm: radiusToUse,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(LocationError(message: failure.message)),
      (markers) => emit(LocationMarkersLoaded(
        markers: markers,
        radiusInKm: radiusToUse,
        showPromotions: true,
        showCommerces: false,
      )),
    );
  }

  /// Handler: Cargar marcadores de comercios cercanos
  Future<void> _onLoadNearbyCommerceMarkersRequested(
    LocationLoadNearbyCommerceMarkersRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());

    // Usar radio de settings si no se especifica
    final settings = settingsService.getSettings();
    final radiusToUse = event.radiusInKm ?? settings.searchRadius;

    final result = await getNearbyCommerceMarkers(
      latitude: event.latitude,
      longitude: event.longitude,
      radiusInKm: radiusToUse,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(LocationError(message: failure.message)),
      (markers) => emit(LocationMarkersLoaded(
        markers: markers,
        radiusInKm: radiusToUse,
        showPromotions: false,
        showCommerces: true,
      )),
    );
  }

  /// Handler: Cargar todos los marcadores cercanos
  Future<void> _onLoadAllNearbyMarkersRequested(
    LocationLoadAllNearbyMarkersRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());

    // Usar radio de settings si no se especifica
    final settings = settingsService.getSettings();
    final radiusToUse = event.radiusInKm ?? settings.searchRadius;

    // Cargar promociones y comercios en paralelo
    final results = await Future.wait([
      getNearbyPromotionMarkers(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusInKm: radiusToUse,
        limit: event.limit,
      ),
      getNearbyCommerceMarkers(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusInKm: radiusToUse,
        limit: event.limit,
      ),
    ]);

    final promotionResult = results[0];
    final commerceResult = results[1];

    // Combinar resultados
    final allMarkers = <dynamic>[];
    
    promotionResult.fold(
      (failure) => null,
      (markers) => allMarkers.addAll(markers),
    );

    commerceResult.fold(
      (failure) => null,
      (markers) => allMarkers.addAll(markers),
    );

    if (allMarkers.isEmpty) {
      emit(const LocationError(
        message: 'No se encontraron marcadores cercanos',
      ));
      return;
    }

    emit(LocationMarkersLoaded(
      markers: allMarkers.cast(),
      radiusInKm: radiusToUse,
      showPromotions: true,
      showCommerces: true,
    ));
  }

  /// Handler: Iniciar seguimiento de ubicación
  Future<void> _onStartWatchingRequested(
    LocationStartWatchingRequested event,
    Emitter<LocationState> emit,
  ) async {
    try {
      await _locationSubscription?.cancel();
      
      _locationSubscription = repository.watchLocation().listen(
        (location) {
          add(LocationUpdated(
            latitude: location.latitude,
            longitude: location.longitude,
            accuracy: location.accuracy,
          ));
        },
        onError: (error) {
          emit(LocationError(message: 'Error al observar ubicación: $error'));
        },
      );
    } catch (e) {
      emit(LocationError(message: 'Error al iniciar seguimiento: $e'));
    }
  }

  /// Handler: Detener seguimiento
  Future<void> _onStopWatchingRequested(
    LocationStopWatchingRequested event,
    Emitter<LocationState> emit,
  ) async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  /// Handler: Actualización de ubicación
  Future<void> _onLocationUpdated(
    LocationUpdated event,
    Emitter<LocationState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is LocationWatching) {
      emit(currentState.copyWith(
        location: currentState.location.copyWith(
          latitude: event.latitude,
          longitude: event.longitude,
          accuracy: event.accuracy,
        ),
      ));
    }
  }

  /// Handler: Cambiar radio de búsqueda
  Future<void> _onChangeRadiusRequested(
    LocationChangeRadiusRequested event,
    Emitter<LocationState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is LocationMarkersLoaded) {
      emit(currentState.copyWith(radiusInKm: event.radiusInKm));
    }
  }

  /// Handler: Refrescar marcadores
  Future<void> _onRefreshMarkersRequested(
    LocationRefreshMarkersRequested event,
    Emitter<LocationState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is LocationMarkersLoaded && 
        currentState.currentLocation != null) {
      emit(LocationRefreshing(
        currentLocation: currentState.currentLocation,
        currentMarkers: currentState.markers,
      ));

      // Recargar marcadores
      add(LocationLoadAllNearbyMarkersRequested(
        latitude: currentState.currentLocation!.latitude,
        longitude: currentState.currentLocation!.longitude,
        radiusInKm: currentState.radiusInKm,
      ));
    }
  }

  /// Handler: Limpiar marcadores
  Future<void> _onClearMarkersRequested(
    LocationClearMarkersRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationMarkersLoaded(markers: []));
  }
}

// Made with Bob