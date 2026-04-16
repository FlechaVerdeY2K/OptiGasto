import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../location/domain/entities/location_entity.dart';
import '../models/directions_response_model.dart';

abstract class DirectionsRemoteDataSource {
  Future<DirectionsResponseModel> getDirections({
    required LocationEntity origin,
    required List<LocationEntity> orderedStops,
  });
}

class DirectionsRemoteDataSourceImpl implements DirectionsRemoteDataSource {
  final Dio dio;
  final String apiKey;
  final Logger _logger = Logger();

  DirectionsRemoteDataSourceImpl({
    required this.dio,
    required this.apiKey,
  });

  @override
  Future<DirectionsResponseModel> getDirections({
    required LocationEntity origin,
    required List<LocationEntity> orderedStops,
  }) async {
    if (orderedStops.isEmpty) {
      throw ServerException(message: 'No hay paradas en la ruta.');
    }

    final destination = orderedStops.last;
    final intermediates = orderedStops.length > 1
        ? orderedStops
            .sublist(0, orderedStops.length - 1)
            .map((s) => '${s.latitude},${s.longitude}')
            .join('|')
        : null;

    try {
      final response = await dio.get<Map<String, dynamic>>(
        'https://maps.googleapis.com/maps/api/directions/json',
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          if (intermediates != null) 'waypoints': intermediates,
          'mode': 'driving',
          'key': apiKey,
        },
      );

      final data = response.data!;
      final status = data['status'] as String;

      if (status == 'ZERO_RESULTS') {
        throw ServerException(
          message: 'No se encontró ruta entre los puntos seleccionados.',
        );
      }

      if (status == 'OVER_QUERY_LIMIT' || status == 'REQUEST_DENIED') {
        _logger.e('Directions API error: $status — ${data['error_message']}');
        throw ServerException(
          message: 'Servicio de rutas no disponible. Intentá más tarde.',
        );
      }

      if (status != 'OK') {
        _logger.e('Directions API unexpected status: $status');
        throw ServerException(
          message: 'Servicio de rutas no disponible. Intentá más tarde.',
        );
      }

      return DirectionsResponseModel.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw ServerException(
          message:
              'Sin conexión a internet. Verificá tu conexión e intentá de nuevo.',
        );
      }
      throw ServerException(
          message:
              'Error al obtener la ruta: ${e.message ?? 'Error desconocido'}');
    }
  }
}
