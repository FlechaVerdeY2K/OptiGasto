import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optigasto/core/errors/exceptions.dart';
import 'package:optigasto/core/errors/failures.dart';
import 'package:optigasto/features/promotions/domain/entities/promotion_entity.dart';
import 'package:optigasto/features/search/data/datasources/search_local_data_source.dart';
import 'package:optigasto/features/search/data/datasources/search_remote_data_source.dart';
import 'package:optigasto/features/search/data/repositories/search_repository_impl.dart';
import 'package:optigasto/features/search/domain/entities/search_filters.dart';
import 'package:optigasto/features/search/domain/entities/search_history_item.dart';
import 'package:optigasto/features/search/domain/entities/search_query_entity.dart';
import 'package:optigasto/features/search/domain/entities/search_result_entity.dart';

class MockSearchRemoteDataSource extends Mock
    implements SearchRemoteDataSource {}

class MockSearchLocalDataSource extends Mock implements SearchLocalDataSource {}

void main() {
  late SearchRepositoryImpl repository;
  late MockSearchRemoteDataSource mockRemoteDataSource;
  late MockSearchLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockSearchRemoteDataSource();
    mockLocalDataSource = MockSearchLocalDataSource();
    repository = SearchRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  setUpAll(() {
    registerFallbackValue(
      const SearchQueryEntity(
        text: 'test',
        filters: SearchFilters(),
      ),
    );
  });

  final tPromotion = PromotionEntity(
    id: 'promo-1',
    title: 'Pizza 50% off',
    description: 'Delicious pizza',
    commerceId: 'commerce-1',
    commerceName: 'Pizza Place',
    category: 'food',
    discount: '50%',
    latitude: 9.9,
    longitude: -84.0,
    address: 'San José',
    validUntil: DateTime(2025, 12, 31),
    createdBy: 'user-1',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  final tSearchResult = SearchResultEntity(
    promotion: tPromotion,
    relevanceScore: 0.95,
  );

  group('search', () {
    const tQuery = SearchQueryEntity(
      text: 'pizza',
      filters: SearchFilters(),
    );

    test('should return search results from remote data source', () async {
      // arrange
      final tResults = [tSearchResult];
      when(
        () => mockRemoteDataSource.search(
          any(),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        ),
      ).thenAnswer((_) async => tResults);

      // act
      final result = await repository.search(tQuery);

      // assert
      expect(result, Right<Failure, List<SearchResultEntity>>(tResults));
      verify(
        () => mockRemoteDataSource.search(
          tQuery,
          userLat: null,
          userLng: null,
        ),
      ).called(1);
    });

    test('should pass user location to remote data source', () async {
      // arrange
      const tLat = 9.9;
      const tLng = -84.0;
      final tResults = [tSearchResult];
      when(
        () => mockRemoteDataSource.search(
          any(),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        ),
      ).thenAnswer((_) async => tResults);

      // act
      final result = await repository.search(
        tQuery,
        userLat: tLat,
        userLng: tLng,
      );

      // assert
      expect(result, Right<Failure, List<SearchResultEntity>>(tResults));
      verify(
        () => mockRemoteDataSource.search(
          tQuery,
          userLat: tLat,
          userLng: tLng,
        ),
      ).called(1);
    });

    test(
        'should return ServerFailure when remote data source throws ServerException',
        () async {
      // arrange
      when(
        () => mockRemoteDataSource.search(
          any(),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        ),
      ).thenThrow(ServerException(message: 'Network error'));

      // act
      final result = await repository.search(tQuery);

      // assert
      expect(
        result,
        const Left<Failure, List<SearchResultEntity>>(
          ServerFailure(message: 'Network error'),
        ),
      );
    });

    test('should return ServerFailure with generic message on unexpected error',
        () async {
      // arrange
      when(
        () => mockRemoteDataSource.search(
          any(),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        ),
      ).thenThrow(Exception('Unexpected error'));

      // act
      final result = await repository.search(tQuery);

      // assert
      expect(result.isLeft(), isTrue);
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(
            (failure as ServerFailure).message,
            contains('Error inesperado al buscar'),
          );
        },
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getSuggestions', () {
    const tPartialText = 'piz';
    const tSuggestions = ['pizza', 'pizza hut', 'pizzeria'];

    test('should return suggestions from remote data source', () async {
      // arrange
      when(() => mockRemoteDataSource.getSuggestions(any()))
          .thenAnswer((_) async => tSuggestions);

      // act
      final result = await repository.getSuggestions(tPartialText);

      // assert
      expect(result, const Right<Failure, List<String>>(tSuggestions));
      verify(() => mockRemoteDataSource.getSuggestions(tPartialText)).called(1);
    });

    test(
        'should return ServerFailure when remote data source throws ServerException',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getSuggestions(any()))
          .thenThrow(ServerException(message: 'Network error'));

      // act
      final result = await repository.getSuggestions(tPartialText);

      // assert
      expect(
        result,
        const Left<Failure, List<String>>(
          ServerFailure(message: 'Network error'),
        ),
      );
    });

    test('should return ServerFailure with generic message on unexpected error',
        () async {
      // arrange
      when(() => mockRemoteDataSource.getSuggestions(any()))
          .thenThrow(Exception('Unexpected error'));

      // act
      final result = await repository.getSuggestions(tPartialText);

      // assert
      expect(result.isLeft(), isTrue);
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(
            (failure as ServerFailure).message,
            contains('Error al obtener sugerencias'),
          );
        },
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getHistory', () {
    final tHistory = [
      SearchHistoryItem(
        query: 'pizza',
        timestamp: DateTime(2024, 1, 1),
      ),
      SearchHistoryItem(
        query: 'burger',
        timestamp: DateTime(2024, 1, 2),
      ),
    ];

    test('should return history from local data source', () async {
      // arrange
      when(() => mockLocalDataSource.getHistory())
          .thenAnswer((_) async => tHistory);

      // act
      final result = await repository.getHistory();

      // assert
      expect(result, Right<Failure, List<SearchHistoryItem>>(tHistory));
      verify(() => mockLocalDataSource.getHistory()).called(1);
    });

    test(
        'should return CacheFailure when local data source throws CacheException',
        () async {
      // arrange
      when(() => mockLocalDataSource.getHistory())
          .thenThrow(CacheException(message: 'Cache error'));

      // act
      final result = await repository.getHistory();

      // assert
      expect(
        result,
        const Left<Failure, List<SearchHistoryItem>>(
          CacheFailure(message: 'Cache error'),
        ),
      );
    });

    test('should return CacheFailure with generic message on unexpected error',
        () async {
      // arrange
      when(() => mockLocalDataSource.getHistory())
          .thenThrow(Exception('Unexpected error'));

      // act
      final result = await repository.getHistory();

      // assert
      expect(result.isLeft(), isTrue);
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(
            (failure as CacheFailure).message,
            contains('Error al leer historial'),
          );
        },
        (_) => fail('Expected Left'),
      );
    });
  });

  group('saveToHistory', () {
    const tQuery = 'pizza';

    test('should save query to local data source', () async {
      // arrange
      when(() => mockLocalDataSource.saveToHistory(any()))
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.saveToHistory(tQuery);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockLocalDataSource.saveToHistory(tQuery)).called(1);
    });

    test(
        'should return CacheFailure when local data source throws CacheException',
        () async {
      // arrange
      when(() => mockLocalDataSource.saveToHistory(any()))
          .thenThrow(CacheException(message: 'Cache error'));

      // act
      final result = await repository.saveToHistory(tQuery);

      // assert
      expect(
        result,
        const Left<Failure, void>(
          CacheFailure(message: 'Cache error'),
        ),
      );
    });

    test('should return CacheFailure with generic message on unexpected error',
        () async {
      // arrange
      when(() => mockLocalDataSource.saveToHistory(any()))
          .thenThrow(Exception('Unexpected error'));

      // act
      final result = await repository.saveToHistory(tQuery);

      // assert
      expect(result.isLeft(), isTrue);
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(
            (failure as CacheFailure).message,
            contains('Error al guardar historial'),
          );
        },
        (_) => fail('Expected Left'),
      );
    });
  });

  group('clearHistory', () {
    test('should clear history in local data source', () async {
      // arrange
      when(() => mockLocalDataSource.clearHistory())
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.clearHistory();

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(() => mockLocalDataSource.clearHistory()).called(1);
    });

    test(
        'should return CacheFailure when local data source throws CacheException',
        () async {
      // arrange
      when(() => mockLocalDataSource.clearHistory())
          .thenThrow(CacheException(message: 'Cache error'));

      // act
      final result = await repository.clearHistory();

      // assert
      expect(
        result,
        const Left<Failure, void>(
          CacheFailure(message: 'Cache error'),
        ),
      );
    });

    test('should return CacheFailure with generic message on unexpected error',
        () async {
      // arrange
      when(() => mockLocalDataSource.clearHistory())
          .thenThrow(Exception('Unexpected error'));

      // act
      final result = await repository.clearHistory();

      // assert
      expect(result.isLeft(), isTrue);
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<CacheFailure>());
          expect(
            (failure as CacheFailure).message,
            contains('Error al limpiar historial'),
          );
        },
        (_) => fail('Expected Left'),
      );
    });
  });
}

// Made with Bob
