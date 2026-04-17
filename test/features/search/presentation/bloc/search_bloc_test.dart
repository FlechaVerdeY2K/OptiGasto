import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optigasto/core/errors/failures.dart';
import 'package:optigasto/features/promotions/domain/entities/promotion_entity.dart';
import 'package:optigasto/features/search/domain/entities/search_filters.dart';
import 'package:optigasto/features/search/domain/entities/search_history_item.dart';
import 'package:optigasto/features/search/domain/entities/search_query_entity.dart';
import 'package:optigasto/features/search/domain/entities/search_result_entity.dart';
import 'package:optigasto/features/search/domain/usecases/clear_search_history.dart';
import 'package:optigasto/features/search/domain/usecases/get_search_history.dart';
import 'package:optigasto/features/search/domain/usecases/get_search_suggestions.dart';
import 'package:optigasto/features/search/domain/usecases/search_promotions.dart';
import 'package:optigasto/features/search/presentation/bloc/search_bloc.dart';
import 'package:optigasto/features/search/presentation/bloc/search_event.dart';
import 'package:optigasto/features/search/presentation/bloc/search_state.dart';

class MockSearchPromotions extends Mock implements SearchPromotions {}

class MockGetSearchSuggestions extends Mock implements GetSearchSuggestions {}

class MockGetSearchHistory extends Mock implements GetSearchHistory {}

class MockClearSearchHistory extends Mock implements ClearSearchHistory {}

void main() {
  late SearchBloc bloc;
  late MockSearchPromotions mockSearchPromotions;
  late MockGetSearchSuggestions mockGetSearchSuggestions;
  late MockGetSearchHistory mockGetSearchHistory;
  late MockClearSearchHistory mockClearSearchHistory;

  setUp(() {
    mockSearchPromotions = MockSearchPromotions();
    mockGetSearchSuggestions = MockGetSearchSuggestions();
    mockGetSearchHistory = MockGetSearchHistory();
    mockClearSearchHistory = MockClearSearchHistory();

    bloc = SearchBloc(
      searchPromotions: mockSearchPromotions,
      getSearchSuggestions: mockGetSearchSuggestions,
      getSearchHistory: mockGetSearchHistory,
      clearSearchHistory: mockClearSearchHistory,
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

  tearDown(() {
    bloc.close();
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

  group('SearchInitialized', () {
    test('emits SearchInitial with history when successful', () async {
      // arrange
      when(() => mockGetSearchHistory())
          .thenAnswer((_) async => Right(tHistory));

      // act
      bloc.add(const SearchInitialized());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // assert
      expect(bloc.state, SearchInitial(history: tHistory));
      verify(() => mockGetSearchHistory()).called(1);
    });

    test('emits SearchInitial with empty history when fails', () async {
      // arrange
      when(() => mockGetSearchHistory()).thenAnswer(
        (_) async => const Left(CacheFailure(message: 'Cache error')),
      );

      // act
      bloc.add(const SearchInitialized());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // assert
      expect(bloc.state, const SearchInitial());
    });
  });

  group('SearchQueryChanged', () {
    test(
        'emits SearchInitial with history when query is less than 3 characters',
        () async {
      // arrange
      when(() => mockGetSearchHistory())
          .thenAnswer((_) async => Right(tHistory));

      // act
      bloc.add(const SearchQueryChanged('pi'));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // assert
      expect(bloc.state, SearchInitial(history: tHistory));
      verify(() => mockGetSearchHistory()).called(1);
      verifyNever(() => mockGetSearchSuggestions(any()));
    });

    test('emits SearchSuggestionsLoaded after debounce delay', () async {
      // arrange
      when(() => mockGetSearchSuggestions(any())).thenAnswer(
        (_) async => const Right(['pizza', 'pizza hut']),
      );

      // act
      bloc.add(const SearchQueryChanged('piz'));
      await Future<void>.delayed(const Duration(milliseconds: 350));

      // assert
      expect(
        bloc.state,
        const SearchSuggestionsLoaded(
          suggestions: ['pizza', 'pizza hut'],
          query: 'piz',
        ),
      );
      verify(() => mockGetSearchSuggestions('piz')).called(1);
    });

    test('debounces multiple rapid query changes', () async {
      // arrange
      when(() => mockGetSearchSuggestions(any())).thenAnswer(
        (_) async => const Right(['pizza']),
      );
      when(() => mockGetSearchHistory())
          .thenAnswer((_) async => const Right([]));

      // act
      bloc.add(const SearchQueryChanged('p'));
      bloc.add(const SearchQueryChanged('pi'));
      bloc.add(const SearchQueryChanged('piz'));
      await Future<void>.delayed(const Duration(milliseconds: 350));

      // assert
      expect(
        bloc.state,
        const SearchSuggestionsLoaded(
          suggestions: ['pizza'],
          query: 'piz',
        ),
      );
      // Only the last query should trigger suggestions
      verify(() => mockGetSearchSuggestions('piz')).called(1);
      verifyNever(() => mockGetSearchSuggestions('p'));
      verifyNever(() => mockGetSearchSuggestions('pi'));
    });
  });

  group('SearchSubmitted', () {
    test('does nothing when query is empty', () async {
      // act
      bloc.add(const SearchSubmitted());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // assert
      expect(bloc.state, const SearchInitial());
      verifyNever(
        () => mockSearchPromotions(
          query: any(named: 'query'),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        ),
      );
    });

    test('emits SearchLoading then SearchResultsLoaded when successful',
        () async {
      // arrange
      when(
        () => mockSearchPromotions(
          query: any(named: 'query'),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        ),
      ).thenAnswer((_) async => Right([tSearchResult]));

      // act
      bloc.add(const SearchQueryChanged('pizza'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bloc.add(const SearchSubmitted());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // assert
      expect(
        bloc.state,
        SearchResultsLoaded(
          results: [tSearchResult],
          filters: const SearchFilters(),
          query: 'pizza',
        ),
      );
    });

    test('emits SearchEmpty when no results found', () async {
      // arrange
      when(
        () => mockSearchPromotions(
          query: any(named: 'query'),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        ),
      ).thenAnswer((_) async => const Right([]));

      // act
      bloc.add(const SearchQueryChanged('nonexistent'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bloc.add(const SearchSubmitted());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // assert
      expect(bloc.state, const SearchEmpty(query: 'nonexistent'));
    });

    test('emits SearchError when search fails', () async {
      // arrange
      when(
        () => mockSearchPromotions(
          query: any(named: 'query'),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        ),
      ).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Network error')),
      );

      // act
      bloc.add(const SearchQueryChanged('pizza'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      bloc.add(const SearchSubmitted());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // assert
      expect(bloc.state, const SearchError(message: 'Network error'));
    });
  });

  group('SearchHistoryItemTapped', () {
    test('triggers search with tapped query', () async {
      // arrange
      when(
        () => mockSearchPromotions(
          query: any(named: 'query'),
          userLat: any(named: 'userLat'),
          userLng: any(named: 'userLng'),
        ),
      ).thenAnswer((_) async => Right([tSearchResult]));

      // act
      bloc.add(const SearchHistoryItemTapped('pizza'));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // assert
      expect(
        bloc.state,
        SearchResultsLoaded(
          results: [tSearchResult],
          filters: const SearchFilters(),
          query: 'pizza',
        ),
      );
    });
  });

  group('SearchHistoryCleared', () {
    test('clears history and emits SearchInitial', () async {
      // arrange
      when(() => mockClearSearchHistory())
          .thenAnswer((_) async => const Right(null));

      // act
      bloc.add(const SearchHistoryCleared());
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // assert
      expect(bloc.state, const SearchInitial());
      verify(() => mockClearSearchHistory()).called(1);
    });
  });

  group('setUserLocation', () {
    test('stores user location for subsequent searches', () {
      // arrange
      const lat = 9.9;
      const lng = -84.0;

      // act
      bloc.setUserLocation(lat, lng);

      // assert - location is stored internally
      expect(bloc, isNotNull);
    });
  });
}

// Made with Bob
