import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optigasto/core/errors/exceptions.dart';
import 'package:optigasto/features/location/domain/entities/location_entity.dart';
import 'package:optigasto/features/route/data/datasources/directions_remote_data_source.dart';

import '../../../../helpers/test_helpers.dart';

class MockDio extends Mock implements Dio {}

LocationEntity _loc(double lat, double lng) =>
    LocationEntity(latitude: lat, longitude: lng, timestamp: DateTime(2024));

Map<String, dynamic> _okResponse({String encoded = '_p~iF~ps|U_ulLnnqC'}) => {
      'status': 'OK',
      'routes': [
        {
          'overview_polyline': {'points': encoded},
          'legs': [
            {
              'distance': {'value': 1000},
              'duration': {'value': 300},
            }
          ],
        }
      ],
    };

void main() {
  late DirectionsRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = DirectionsRemoteDataSourceImpl(
      dio: mockDio,
      apiKey: 'test-key',
    );
  });

  setUpAll(registerFallbackValues);

  group('DirectionsRemoteDataSource — parameters', () {
    test('does NOT send optimize:true or departure_time', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: _okResponse(),
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      await dataSource.getDirections(
        origin: _loc(9.9, -84.0),
        orderedStops: [_loc(9.91, -84.01), _loc(9.92, -84.02)],
      );

      final captured = verify(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;

      final params = captured.first as Map<String, dynamic>;
      expect(params.containsKey('departure_time'), isFalse);
      expect(params.containsKey('traffic_model'), isFalse);
      final waypoints = params['waypoints'] as String?;
      expect(waypoints, isNot(contains('optimize:true')));
    });

    test('builds correct origin/destination params', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: _okResponse(),
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      await dataSource.getDirections(
        origin: _loc(9.9, -84.0),
        orderedStops: [_loc(9.91, -84.01)],
      );

      final captured = verify(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;
      final params = captured.first as Map<String, dynamic>;
      expect(params['origin'], '9.9,-84.0');
      expect(params['destination'], '9.91,-84.01');
      expect(params['mode'], 'driving');
      expect(params['key'], 'test-key');
    });
  });

  group('DirectionsRemoteDataSource — response parsing', () {
    test('status OK → returns parsed data', () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: _okResponse(),
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final result = await dataSource.getDirections(
        origin: _loc(9.9, -84.0),
        orderedStops: [_loc(9.91, -84.01)],
      );

      expect(result.totalDistanceMeters, 1000);
      expect(result.totalDurationSeconds, 300);
      expect(result.polylinePoints, isNotEmpty);
    });

    test(
        'status ZERO_RESULTS → throws ServerException with user-friendly message',
        () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'status': 'ZERO_RESULTS', 'routes': <dynamic>[]},
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      await expectLater(
        () => dataSource.getDirections(
          origin: _loc(9.9, -84.0),
          orderedStops: [_loc(9.91, -84.01)],
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('No se encontró ruta'),
          ),
        ),
      );
    });

    test(
        'status REQUEST_DENIED → throws ServerException without leaking API details',
        () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'status': 'REQUEST_DENIED',
            'error_message': 'API key invalid',
            'routes': <dynamic>[],
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      await expectLater(
        () => dataSource.getDirections(
          origin: _loc(9.9, -84.0),
          orderedStops: [_loc(9.91, -84.01)],
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            isNot(contains('API key')),
          ),
        ),
      );
    });
  });

  group('DirectionsRemoteDataSource — error handling', () {
    test(
        'DioException connectivity → throws ServerException with connection message',
        () async {
      when(
        () => mockDio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(),
        ),
      );

      await expectLater(
        () => dataSource.getDirections(
          origin: _loc(9.9, -84.0),
          orderedStops: [_loc(9.91, -84.01)],
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Sin conexión'),
          ),
        ),
      );
    });
  });
}
