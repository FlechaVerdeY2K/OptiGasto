import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:optigasto/features/location/domain/entities/location_entity.dart';
import 'package:optigasto/features/route/domain/entities/optimized_route_entity.dart';
import 'package:optigasto/features/route/domain/entities/route_origin_entity.dart';
import 'package:optigasto/features/route/domain/entities/route_stop_entity.dart';
import 'package:optigasto/features/route/domain/usecases/build_navigation_url.dart';

LocationEntity _loc(double lat, double lng) =>
    LocationEntity(latitude: lat, longitude: lng, timestamp: DateTime(2024));

RouteStopEntity _stop(String id, double lat, double lng, int order) =>
    RouteStopEntity(id: id, name: id, location: _loc(lat, lng), order: order);

OptimizedRouteEntity _route(List<RouteStopEntity> stops) =>
    OptimizedRouteEntity(
      origin: RouteOriginEntity(
        location: _loc(9.9, -84.0),
        displayName: 'Origin',
        type: RouteOriginType.currentLocation,
      ),
      stops: stops,
      polylinePoints: const [LatLng(0, 0)],
      totalDistanceMeters: 1000,
      totalDurationSeconds: 300,
      calculatedAt: DateTime(2024),
    );

void main() {
  late BuildNavigationUrl useCase;

  setUp(() => useCase = BuildNavigationUrl());

  group('BuildNavigationUrl — Google Maps', () {
    test('1 stop → no waypoints, origin and destination present', () {
      final route = _route([_stop('a', 9.93, -84.07, 1)]);
      final result = useCase(app: NavigationApp.googleMaps, route: route);
      expect(result.isRight(), isTrue);
      result.fold((_) => fail('expected Right'), (url) {
        expect(url, contains('www.google.com/maps/dir/'));
        expect(url, contains('api=1'));
        expect(url, contains('origin=9.9,-84.0'));
        expect(url, contains('destination=9.93,-84.07'));
        expect(url, contains('travelmode=driving'));
        expect(url, isNot(contains('waypoints=')));
      });
    });

    test('3 stops → middle stop is waypoint, last is destination', () {
      final route = _route([
        _stop('a', 9.91, -84.01, 1),
        _stop('b', 9.92, -84.02, 2),
        _stop('c', 9.93, -84.03, 3),
      ]);
      final result = useCase(app: NavigationApp.googleMaps, route: route);
      result.fold((_) => fail('expected Right'), (url) {
        expect(url, contains('9.93'));
        expect(url, contains('waypoints='));
        expect(url, contains('9.91'));
        expect(url, contains('9.92'));
      });
    });
  });

  group('BuildNavigationUrl — Waze', () {
    test('points to first stop only', () {
      final route = _route([
        _stop('first', 9.91, -84.01, 1),
        _stop('second', 9.92, -84.02, 2),
      ]);
      final result = useCase(app: NavigationApp.waze, route: route);
      result.fold((_) => fail('expected Right'), (url) {
        expect(url, contains('waze.com'));
        expect(url, contains('9.91'));
        expect(url, contains('-84.01'));
        expect(url, isNot(contains('9.92')));
      });
    });
  });
}
