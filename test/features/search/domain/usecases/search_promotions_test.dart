import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optigasto/core/errors/failures.dart';
import 'package:optigasto/features/promotions/domain/entities/promotion_entity.dart';
import 'package:optigasto/features/search/domain/entities/search_filters.dart';
import 'package:optigasto/features/search/domain/entities/search_query_entity.dart';
import 'package:optigasto/features/search/domain/entities/search_result_entity.dart';
import 'package:optigasto/features/search/domain/repositories/search_repository.dart';
import 'package:optigasto/features/search/domain/usecases/search_promotions.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late SearchPromotions useCase;
  late MockSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockSearchRepository();
    useCase = SearchPromotions(mockRepository);
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

  group('SearchPromotions', () {
    test('should return search results from repository', () async {
      // arrange
      const tQuery = SearchQueryEntity(
        text: 'pizza',
        filters: SearchFilters(),
      );
      final tResults = [tSearchResult];

      when(
        () => mockRepository.search(
          any(),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        ),
      ).thenAnswer((_) async => Right(tResults));

      // act
      final result = await useCase(query: tQuery);

      // assert
      expect(result, Right<Failure, List<SearchResultEntity>>(tResults));
      verify(
        () => mockRepository.search(
          tQuery,
          userLat: null,
          userLng: null,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass user location to repository when provided', () async {
      // arrange
      const tQuery = SearchQueryEntity(
        text: 'pizza',
        filters: SearchFilters(),
      );
      const tLat = 9.9;
      const tLng = -84.0;
      final tResults = [tSearchResult];

      when(
        () => mockRepository.search(
          any(),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        ),
      ).thenAnswer((_) async => Right(tResults));

      // act
      final result = await useCase(
        query: tQuery,
        userLat: tLat,
        userLng: tLng,
      );

      // assert
      expect(result, Right<Failure, List<SearchResultEntity>>(tResults));
      verify(
        () => mockRepository.search(
          tQuery,
          userLat: tLat,
          userLng: tLng,
        ),
      ).called(1);
    });

    test('should return empty list when no results found', () async {
      // arrange
      const tQuery = SearchQueryEntity(
        text: 'nonexistent',
        filters: SearchFilters(),
      );

      when(
        () => mockRepository.search(
          any(),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        ),
      ).thenAnswer((_) async => const Right([]));

      // act
      final result = await useCase(query: tQuery);

      // assert
      expect(result, const Right<Failure, List<SearchResultEntity>>([]));
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      const tQuery = SearchQueryEntity(
        text: 'pizza',
        filters: SearchFilters(),
      );
      const tFailure = ServerFailure(message: 'Network error');

      when(
        () => mockRepository.search(
          any(),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        ),
      ).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await useCase(query: tQuery);

      // assert
      expect(result, const Left<Failure, List<SearchResultEntity>>(tFailure));
    });

    test('should work with filters applied', () async {
      // arrange
      const tFilters = SearchFilters(
        minDiscount: 30,
        categoryIds: ['food'],
        radiusKm: 5.0,
        sortBy: SortBy.discount,
      );
      const tQuery = SearchQueryEntity(
        text: 'pizza',
        filters: tFilters,
      );
      final tResults = [tSearchResult];

      when(
        () => mockRepository.search(
          any(),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        ),
      ).thenAnswer((_) async => Right(tResults));

      // act
      final result = await useCase(query: tQuery);

      // assert
      expect(result, Right<Failure, List<SearchResultEntity>>(tResults));
      verify(
        () => mockRepository.search(
          tQuery,
          userLat: null,
          userLng: null,
        ),
      ).called(1);
    });

    test('should work with date range filters', () async {
      // arrange
      final tFilters = SearchFilters(
        dateFrom: DateTime(2024, 1, 1),
        dateTo: DateTime(2024, 12, 31),
      );
      final tQuery = SearchQueryEntity(
        text: 'pizza',
        filters: tFilters,
      );
      final tResults = [tSearchResult];

      when(
        () => mockRepository.search(
          any(),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        ),
      ).thenAnswer((_) async => Right(tResults));

      // act
      final result = await useCase(query: tQuery);

      // assert
      expect(result.isRight(), isTrue);
      verify(
        () => mockRepository.search(
          tQuery,
          userLat: null,
          userLng: null,
        ),
      ).called(1);
    });
  });
}

// Made with Bob
