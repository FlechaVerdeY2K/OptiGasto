import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/location_model.dart';
import '../models/map_marker_model.dart';

/// Data source remoto para ubicación y geolocalización
abstract class LocationRemoteDataSource {
  /// Obtiene la ubicación actual del dispositivo
  Future<LocationModel> getCurrentLocation();

  /// Verifica si los permisos de ubicación están otorgados
  Future<bool> checkLocationPermission();

  /// Solicita permisos de ubicación
  Future<bool> requestLocationPermission();

  /// Verifica si el servicio de ubicación está habilitado
  Future<bool> isLocationServiceEnabled();

  /// Abre la configuración de ubicación
  Future<void> openLocationSettings();

  /// Obtiene marcadores de promociones cercanas desde Supabase
  Future<List<MapMarkerModel>> getNearbyPromotionMarkers({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  });

  /// Obtiene marcadores de comercios cercanos desde Supabase
  Future<List<MapMarkerModel>> getNearbyCommerceMarkers({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  });

  /// Stream que emite actualizaciones de ubicación
  Stream<LocationModel> watchLocation();

  /// Obtiene la última ubicación conocida
  Future<LocationModel?> getLastKnownLocation();

  /// Geocodifica una dirección a coordenadas
  Future<LocationModel> geocodeAddress(String address);

  /// Geocodifica inversamente coordenadas a dirección
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  });
}

/// Implementación del data source de ubicación
class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final SupabaseClient supabaseClient;

  LocationRemoteDataSourceImpl({
    required SupabaseClient supabase,
  }) : supabaseClient = supabase;

  @override
  Future<LocationModel> getCurrentLocation() async {
    try {
      // Verificar si el servicio de ubicación está habilitado
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw ServerException(
          message: 'Location services are disabled',
          code: 'LOCATION_SERVICE_DISABLED',
        );
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw ServerException(
            message: 'Location permissions are denied',
            code: 'LOCATION_PERMISSION_DENIED',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw ServerException(
          message: 'Location permissions are permanently denied',
          code: 'LOCATION_PERMISSION_DENIED_FOREVER',
        );
      }

      // Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LocationModel.fromPosition(position);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to get current location: ${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<bool> checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      throw ServerException(
        message: 'Failed to check location permission: ${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      throw ServerException(
        message: 'Failed to request location permission: ${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      throw ServerException(
        message: 'Failed to check location service: ${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      throw ServerException(
        message: 'Failed to open location settings: ${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<List<MapMarkerModel>> getNearbyPromotionMarkers({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  }) async {
    try {
      // Consulta promociones cercanas usando la función RPC de Supabase
      final response = await supabaseClient.rpc(
        'nearby_promotions',
        params: {
          'lat': latitude,
          'long': longitude,
          'radius_km': radiusInKm,
          'max_results': limit ?? 50,
        },
      );

      if (response == null) {
        return [];
      }

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => MapMarkerModel.fromPromotion(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get nearby promotion markers: ${e.message}',
        code: e.code ?? '500',
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get nearby promotion markers: ${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<List<MapMarkerModel>> getNearbyCommerceMarkers({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    int? limit,
  }) async {
    try {
      // Consulta comercios cercanos usando la función RPC de Supabase
      final response = await supabaseClient.rpc(
        'nearby_commerces',
        params: {
          'lat': latitude,
          'long': longitude,
          'radius_km': radiusInKm,
          'max_results': limit ?? 50,
        },
      );

      if (response == null) {
        return [];
      }

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => MapMarkerModel.fromCommerce(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get nearby commerce markers: ${e.message}',
        code: e.code ?? '500',
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get nearby commerce markers: ${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Stream<LocationModel> watchLocation() {
    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Actualizar cada 10 metros
      );

      return Geolocator.getPositionStream(locationSettings: locationSettings)
          .map((position) => LocationModel.fromPosition(position));
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch location: ${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<LocationModel?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;
      return LocationModel.fromPosition(position);
    } catch (e) {
      throw ServerException(
        message: 'Failed to get last known location: ${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<LocationModel> geocodeAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) {
        throw ServerException(
          message: 'No location found for address: $address',
          code: 'GEOCODE_NOT_FOUND',
        );
      }

      final location = locations.first;
      return LocationModel(
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to geocode address: ${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        throw ServerException(
          message: 'No address found for coordinates',
          code: 'REVERSE_GEOCODE_NOT_FOUND',
        );
      }

      final placemark = placemarks.first;
      final parts = <String>[];

      if (placemark.street != null && placemark.street!.isNotEmpty) {
        parts.add(placemark.street!);
      }
      if (placemark.locality != null && placemark.locality!.isNotEmpty) {
        parts.add(placemark.locality!);
      }
      if (placemark.administrativeArea != null &&
          placemark.administrativeArea!.isNotEmpty) {
        parts.add(placemark.administrativeArea!);
      }
      if (placemark.country != null && placemark.country!.isNotEmpty) {
        parts.add(placemark.country!);
      }

      return parts.join(', ');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Failed to reverse geocode: ${e.toString()}',
        code: '500',
      );
    }
  }
}

// Made with Bob