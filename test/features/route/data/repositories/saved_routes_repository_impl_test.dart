import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optigasto/core/errors/exceptions.dart';
import 'package:optigasto/core/errors/failures.dart';
import 'package:optigasto/features/location/domain/entities/location_entity.dart';
import 'package:optigasto/features/route/data/datasources/saved_routes_remote_data_source.dart';
import 'package:optigasto/features/route/data/models/saved_route_model.dart';
import 'package:optigasto/features/route/data/repositories/saved_routes_repository_impl.dart';
import 'package:optigasto/features/route/domain/entities/route_origin_entity.dart';
import 'package:optigasto/features/route/domain/entities/route_stop_entity.dart';
import 'package:optigasto/features/route/domain/entities/saved_route_entity.dart';

class MockSavedRoutesRemoteDataSource extends Mock
    implements SavedRoutesRemoteDataSource {}

class FakeSavedRouteModel extends Fake implements SavedRouteModel {}

void main() {
  late SavedRoutesRepositoryImpl repository;
  late MockSavedRoutesRemoteDataSource mockRemoteDataSource;

  setUpAll(() {
    registerFallbackValue(FakeSavedRouteModel());
  });

  setUp(() {
    mockRemoteDataSource = MockSavedRoutesRemoteDataSource();
    repository = SavedRoutesRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
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

  final tSavedRouteModel = SavedRouteModel(
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

  final tSavedRouteEntity = SavedRouteEntity(
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

  final tSavedRoutes = [tSavedRouteModel];

  group('getSavedRoutes', () {
    test(
        'should return list of routes when remote data source call is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getSavedRoutes())
          .thenAnswer((_) async => tSavedRoutes);

      // act
      final result = await repository.getSavedRoutes();

      // assert
      expect(
          result,
          equals(Right<StorageFailure, List<SavedRouteModel>>(tSavedRoutes)));
      verify(() => mockRemoteDataSource.getSavedRoutes()).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test(
        'should return StorageFailure when remote data source throws ServerException',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getSavedRoutes())
          .thenThrow(ServerException(message: 'Server error'));

      // act
      final result = await repository.getSavedRoutes();

      // assert
      expect(
        result,
        equals(const Left<StorageFailure, List<SavedRouteModel>>(
            StorageFailure(message: 'Server error'))),
      );
      verify(() => mockRemoteDataSource.getSavedRoutes()).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test(
        'should return StorageFailure when remote data source throws unexpected exception',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getSavedRoutes())
          .thenThrow(Exception('Unexpected error'));

      // act
      final result = await repository.getSavedRoutes();

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
          expect(failure.message, contains('Error inesperado'));
        },
        (_) => fail('Should return Left'),
      );
      verify(() => mockRemoteDataSource.getSavedRoutes()).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });

  group('createSavedRoute', () {
    test(
        'should return created route when remote data source call is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.createSavedRoute(any()))
          .thenAnswer((_) async => tSavedRouteModel);

      // act
      final result = await repository.createSavedRoute(tSavedRouteEntity);

      // assert
      expect(result,
          equals(Right<StorageFailure, SavedRouteModel>(tSavedRouteModel)));
      verify(() => mockRemoteDataSource.createSavedRoute(any())).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test(
        'should return StorageFailure when remote data source throws ServerException',
        () async {
      // arrange
      when(() => mockRemoteDataSource.createSavedRoute(any()))
          .thenThrow(ServerException(message: 'Failed to create'));

      // act
      final result = await repository.createSavedRoute(tSavedRouteEntity);

      // assert
      expect(
        result,
        equals(const Left<StorageFailure, SavedRouteModel>(
            StorageFailure(message: 'Failed to create'))),
      );
      verify(() => mockRemoteDataSource.createSavedRoute(any())).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test(
        'should return StorageFailure when remote data source throws unexpected exception',
        () async {
      // arrange
      when(() => mockRemoteDataSource.createSavedRoute(any()))
          .thenThrow(Exception('Unexpected error'));

      // act
      final result = await repository.createSavedRoute(tSavedRouteEntity);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
          expect(failure.message, contains('Error inesperado'));
        },
        (_) => fail('Should return Left'),
      );
      verify(() => mockRemoteDataSource.createSavedRoute(any())).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });

  group('updateSavedRoute', () {
    test(
        'should return updated route when remote data source call is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.updateSavedRoute(any()))
          .thenAnswer((_) async => tSavedRouteModel);

      // act
      final result = await repository.updateSavedRoute(tSavedRouteEntity);

      // assert
      expect(result,
          equals(Right<StorageFailure, SavedRouteModel>(tSavedRouteModel)));
      verify(() => mockRemoteDataSource.updateSavedRoute(any())).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test(
        'should return StorageFailure when remote data source throws ServerException',
        () async {
      // arrange
      when(() => mockRemoteDataSource.updateSavedRoute(any()))
          .thenThrow(ServerException(message: 'Failed to update'));

      // act
      final result = await repository.updateSavedRoute(tSavedRouteEntity);

      // assert
      expect(
        result,
        equals(const Left<StorageFailure, SavedRouteModel>(
            StorageFailure(message: 'Failed to update'))),
      );
      verify(() => mockRemoteDataSource.updateSavedRoute(any())).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test(
        'should return StorageFailure when remote data source throws unexpected exception',
        () async {
      // arrange
      when(() => mockRemoteDataSource.updateSavedRoute(any()))
          .thenThrow(Exception('Unexpected error'));

      // act
      final result = await repository.updateSavedRoute(tSavedRouteEntity);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
          expect(failure.message, contains('Error inesperado'));
        },
        (_) => fail('Should return Left'),
      );
      verify(() => mockRemoteDataSource.updateSavedRoute(any())).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });

  group('deleteSavedRoute', () {
    const tRouteId = 'route1';

    test('should return Right(null) when remote data source call is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.deleteSavedRoute(any()))
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.deleteSavedRoute(tRouteId);

      // assert
      expect(result, equals(const Right<StorageFailure, void>(null)));
      verify(() => mockRemoteDataSource.deleteSavedRoute(tRouteId)).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test(
        'should return StorageFailure when remote data source throws ServerException',
        () async {
      // arrange
      when(() => mockRemoteDataSource.deleteSavedRoute(any()))
          .thenThrow(ServerException(message: 'Failed to delete'));

      // act
      final result = await repository.deleteSavedRoute(tRouteId);

      // assert
      expect(
        result,
        equals(const Left<StorageFailure, void>(
            StorageFailure(message: 'Failed to delete'))),
      );
      verify(() => mockRemoteDataSource.deleteSavedRoute(tRouteId)).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test(
        'should return StorageFailure when remote data source throws unexpected exception',
        () async {
      // arrange
      when(() => mockRemoteDataSource.deleteSavedRoute(any()))
          .thenThrow(Exception('Unexpected error'));

      // act
      final result = await repository.deleteSavedRoute(tRouteId);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<StorageFailure>());
          expect(failure.message, contains('Error inesperado'));
        },
        (_) => fail('Should return Left'),
      );
      verify(() => mockRemoteDataSource.deleteSavedRoute(tRouteId)).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });
}

// Made with Bob
