import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optigasto/core/errors/failures.dart';
import 'package:optigasto/features/location/domain/entities/location_entity.dart';
import 'package:optigasto/features/route/domain/entities/route_origin_entity.dart';
import 'package:optigasto/features/route/domain/entities/route_stop_entity.dart';
import 'package:optigasto/features/route/domain/repositories/route_repository.dart';
import 'package:optigasto/features/route/domain/usecases/calculate_optimal_route.dart';

import '../../../../helpers/test_helpers.dart';

LocationEntity _loc(double lat, double lng) =>
    LocationEntity(latitude: lat, longitude: lng, timestamp: DateTime(2024));

RouteStopEntity _stop(String id, double lat, double lng) => RouteStopEntity(
      id: id,
      name: id,
      location: _loc(lat, lng),
      order: 0,
    );

RouteOriginEntity _origin(double lat, double lng) => RouteOriginEntity(
      location: _loc(lat, lng),
      displayName: 'Origin',
      type: RouteOriginType.currentLocation,
    );

const _polylineData = RoutePolylineData(
  polylinePoints: [LatLng(0, 0), LatLng(1, 1)],
  totalDistanceMeters: 1000,
  totalDurationSeconds: 300,
);

void main() {
  late CalculateOptimalRoute useCase;
  late MockRouteRepository mockRepo;

  setUp(() {
    mockRepo = MockRouteRepository();
    useCase = CalculateOptimalRoute(mockRepo);
  });

  setUpAll(registerFallbackValues);

  void stubPolylineSuccess() {
    when(
      () => mockRepo.getRoutePolyline(
        origin: any(named: 'origin'),
        orderedStops: any(named: 'orderedStops'),
      ),
    ).thenAnswer((_) async => const Right(_polylineData));
  }

  group('CalculateOptimalRoute — validation', () {
    test('0 stops → Left(ValidationFailure)', () async {
      final result = await useCase(
        origin: _origin(0, 0),
        unorderedStops: [],
      );
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('expected Left'),
      );
      verifyNever(
        () => mockRepo.getRoutePolyline(
          origin: any(named: 'origin'),
          orderedStops: any(named: 'orderedStops'),
        ),
      );
    });

    test('11 stops → Left(ValidationFailure) without calling repo', () async {
      final stops = List.generate(11, (i) => _stop('s$i', i.toDouble(), 0));
      final result =
          await useCase(origin: _origin(0, 0), unorderedStops: stops);
      expect(result.isLeft(), isTrue);
      result.fold((f) => expect(f, isA<ValidationFailure>()),
          (_) => fail('expected Left'));
      verifyNever(
        () => mockRepo.getRoutePolyline(
          origin: any(named: 'origin'),
          orderedStops: any(named: 'orderedStops'),
        ),
      );
    });
  });

  group('CalculateOptimalRoute — happy path', () {
    test('1 stop → returns that stop as order 1', () async {
      stubPolylineSuccess();
      final stops = [_stop('a', 1, 0)];
      final result =
          await useCase(origin: _origin(0, 0), unorderedStops: stops);
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (route) {
        expect(route.stops.length, 1);
        expect(route.stops[0].id, 'a');
        expect(route.stops[0].order, 1);
      });
    });

    test('10 stops → succeeds', () async {
      stubPolylineSuccess();
      final stops = List.generate(10, (i) => _stop('s$i', i.toDouble(), 0));
      final result =
          await useCase(origin: _origin(0, 0), unorderedStops: stops);
      expect(result.isRight(), isTrue);
    });

    test('TSP order — 3 stops in line, picks nearest first', () async {
      // Origin at (0,0). Stops: A(1,0), B(10,0), C(2,0).
      // nearest to origin → A(~111km), from A → C(~111km), then B.
      stubPolylineSuccess();
      final stops = [
        _stop('A', 1, 0),
        _stop('B', 10, 0),
        _stop('C', 2, 0),
      ];
      final result =
          await useCase(origin: _origin(0, 0), unorderedStops: stops);
      result.fold((_) => fail('expected Right'), (route) {
        expect(route.stops.map((s) => s.id).toList(), ['A', 'C', 'B']);
        expect(route.stops[0].order, 1);
        expect(route.stops[1].order, 2);
        expect(route.stops[2].order, 3);
      });
    });

    test('TSP order — non-obvious path: A→C→B not A→B→C', () async {
      // Origin at (0,0). A(0,1), B(0,5), C(1,2).
      // nearest to origin → A(~111km).
      // from A(0,1): dist to B(0,5)=~444km, dist to C(1,2)=~157km → C closer.
      // Expected: A → C → B
      stubPolylineSuccess();
      final stops = [
        _stop('A', 0, 1),
        _stop('B', 0, 5),
        _stop('C', 1, 2),
      ];
      final result =
          await useCase(origin: _origin(0, 0), unorderedStops: stops);
      result.fold((_) => fail('expected Right'), (route) {
        expect(route.stops.map((s) => s.id).toList(), ['A', 'C', 'B']);
      });
    });
  });

  group('CalculateOptimalRoute — repo failure', () {
    test('repo fails → propagates Left', () async {
      const failure = ServerFailure(message: 'API error');
      when(
        () => mockRepo.getRoutePolyline(
          origin: any(named: 'origin'),
          orderedStops: any(named: 'orderedStops'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        origin: _origin(0, 0),
        unorderedStops: [_stop('a', 1, 0)],
      );
      expect(result, const Left<Failure, dynamic>(failure));
    });
  });
}
