import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optigasto/core/errors/failures.dart';
import 'package:optigasto/features/location/domain/entities/location_entity.dart';
import 'package:optigasto/features/route/domain/entities/optimized_route_entity.dart';
import 'package:optigasto/features/route/domain/entities/route_origin_entity.dart';
import 'package:optigasto/features/route/domain/entities/route_stop_entity.dart';
import 'package:optigasto/features/route/domain/entities/saved_route_entity.dart';
import 'package:optigasto/features/route/domain/repositories/saved_routes_repository.dart';
import 'package:optigasto/features/route/presentation/bloc/saved_routes_bloc.dart';
import 'package:optigasto/features/route/presentation/bloc/saved_routes_event.dart';
import 'package:optigasto/features/route/presentation/bloc/saved_routes_state.dart';

class MockSavedRoutesRepository extends Mock implements SavedRoutesRepository {}

class FakeSavedRouteEntity extends Fake implements SavedRouteEntity {}

void main() {
  late SavedRoutesBloc bloc;
  late MockSavedRoutesRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeSavedRouteEntity());
  });

  setUp(() {
    mockRepository = MockSavedRoutesRepository();
    bloc = SavedRoutesBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  // Test data
  final tOrigin = RouteOriginEntity(
    location: LocationEntity(
      latitude: 9.9281,
      longitude: -84.0907,
      timestamp: DateTime(2024, 1, 1),
    ),
    displayName: 'San José',
    type: RouteOriginType.currentLocation,
  );

  final tStops = [
    RouteStopEntity(
      id: 'stop1',
      promotionId: 'promo1',
      name: 'Stop 1',
      location: LocationEntity(
        latitude: 9.93,
        longitude: -84.08,
        timestamp: DateTime(2024, 1, 1),
      ),
      order: 1,
    ),
    RouteStopEntity(
      id: 'stop2',
      promotionId: 'promo2',
      name: 'Stop 2',
      location: LocationEntity(
        latitude: 9.94,
        longitude: -84.09,
        timestamp: DateTime(2024, 1, 1),
      ),
      order: 2,
    ),
  ];

  final tSavedRoute = SavedRouteEntity(
    id: 'route1',
    userId: 'user1',
    name: 'Test Route',
    origin: tOrigin,
    stops: tStops,
    distanceMeters: 5000,
    durationSeconds: 600,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final tSavedRoutes = [tSavedRoute];

  final tOptimizedRoute = OptimizedRouteEntity(
    origin: tOrigin,
    stops: tStops,
    totalDistanceMeters: 5000,
    totalDurationSeconds: 600,
    polylinePoints: const [],
    calculatedAt: DateTime(2024, 1, 1),
  );

  group('SavedRoutesBloc', () {
    test('initial state should be SavedRoutesInitial', () {
      expect(bloc.state, equals(const SavedRoutesInitial()));
    });

    group('SavedRoutesLoadRequested', () {
      test(
          'emits [SavedRoutesLoading, SavedRoutesLoaded] when load is successful',
          () async {
        // arrange
        when(() => mockRepository.getSavedRoutes())
            .thenAnswer((_) async => Right(tSavedRoutes));

        // assert later
        final expected = [
          const SavedRoutesLoading(),
          SavedRoutesLoaded(routes: tSavedRoutes),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const SavedRoutesLoadRequested());
      });

      test('emits [SavedRoutesLoading, SavedRoutesError] when load fails',
          () async {
        // arrange
        when(() => mockRepository.getSavedRoutes()).thenAnswer(
          (_) async =>
              const Left(StorageFailure(message: 'Failed to load routes')),
        );

        // assert later
        final expected = [
          const SavedRoutesLoading(),
          const SavedRoutesError(message: 'Failed to load routes'),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const SavedRoutesLoadRequested());
      });
    });

    group('SavedRouteCreateRequested', () {
      test('emits correct states when create is successful', () async {
        // arrange
        when(() => mockRepository.createSavedRoute(any()))
            .thenAnswer((_) async => Right(tSavedRoute));
        when(() => mockRepository.getSavedRoutes())
            .thenAnswer((_) async => Right(tSavedRoutes));

        // assert later
        final expected = [
          const SavedRouteOperationInProgress(),
          SavedRoutesLoaded(routes: tSavedRoutes),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(
          SavedRouteCreateRequested(
            route: tOptimizedRoute,
            name: 'Test Route',
          ),
        );
      });

      test(
          'emits [SavedRouteOperationInProgress, SavedRoutesError] when create fails',
          () async {
        // arrange
        when(() => mockRepository.createSavedRoute(any())).thenAnswer(
          (_) async =>
              const Left(StorageFailure(message: 'Failed to create route')),
        );

        // assert later
        final expected = [
          const SavedRouteOperationInProgress(),
          const SavedRoutesError(message: 'Failed to create route'),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(
          SavedRouteCreateRequested(
            route: tOptimizedRoute,
            name: 'Test Route',
          ),
        );
      });
    });

    group('SavedRouteUpdateRequested', () {
      test('emits correct states when update is successful', () async {
        // arrange
        when(() => mockRepository.updateSavedRoute(any()))
            .thenAnswer((_) async => Right(tSavedRoute));
        when(() => mockRepository.getSavedRoutes())
            .thenAnswer((_) async => Right(tSavedRoutes));

        // assert later
        final expected = [
          const SavedRouteOperationInProgress(),
          SavedRoutesLoaded(routes: tSavedRoutes),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(SavedRouteUpdateRequested(route: tSavedRoute));
      });

      test(
          'emits [SavedRouteOperationInProgress, SavedRoutesError] when update fails',
          () async {
        // arrange
        when(() => mockRepository.updateSavedRoute(any())).thenAnswer(
          (_) async =>
              const Left(StorageFailure(message: 'Failed to update route')),
        );

        // assert later
        final expected = [
          const SavedRouteOperationInProgress(),
          const SavedRoutesError(message: 'Failed to update route'),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(SavedRouteUpdateRequested(route: tSavedRoute));
      });
    });

    group('SavedRouteDeleteRequested', () {
      test('emits correct states when delete is successful', () async {
        // arrange
        when(() => mockRepository.deleteSavedRoute(any()))
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.getSavedRoutes())
            .thenAnswer((_) async => Right(tSavedRoutes));

        // assert later
        final expected = [
          const SavedRouteOperationInProgress(),
          SavedRoutesLoaded(routes: tSavedRoutes),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const SavedRouteDeleteRequested(routeId: 'route1'));
      });

      test(
          'emits [SavedRouteOperationInProgress, SavedRoutesError] when delete fails',
          () async {
        // arrange
        when(() => mockRepository.deleteSavedRoute(any())).thenAnswer(
          (_) async =>
              const Left(StorageFailure(message: 'Failed to delete route')),
        );

        // assert later
        final expected = [
          const SavedRouteOperationInProgress(),
          const SavedRoutesError(message: 'Failed to delete route'),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));

        // act
        bloc.add(const SavedRouteDeleteRequested(routeId: 'route1'));
      });
    });
  });
}

// Made with Bob
