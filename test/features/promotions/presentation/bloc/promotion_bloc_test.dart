// NOTE: bloc_test ^9.1.7 could not be added because it is incompatible with
// hive_generator ^2.0.1 (already in the project's dev_dependencies) under the
// current Flutter SDK. The BLoC behaviour is tested manually here using
// flutter_test + mocktail. When the project upgrades flutter_bloc / hive to
// versions that allow bloc_test, replace the manual listeners below with the
// blocTest() DSL for more concise tests.

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optigasto/core/errors/failures.dart';
import 'package:optigasto/features/promotions/domain/entities/promotion_entity.dart';
import 'package:optigasto/features/promotions/presentation/bloc/promotion_bloc.dart';
import 'package:optigasto/features/promotions/presentation/bloc/promotion_event.dart';
import 'package:optigasto/features/promotions/presentation/bloc/promotion_state.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late PromotionBloc bloc;
  late MockPromotionRepository mockRepository;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockRepository = MockPromotionRepository();
    bloc = PromotionBloc(repository: mockRepository);
  });

  tearDown(() => bloc.close());

  // Minimal stub needed for getPromotions — returns an empty success by default.
  void stubGetPromotionsSuccess([List<PromotionEntity>? promos]) {
    when(
      () => mockRepository.getPromotions(
        limit: any(named: 'limit'),
        lastDocumentId: any(named: 'lastDocumentId'),
      ),
    ).thenAnswer((_) async => Right(promos ?? []));
  }

  void stubGetPromotionsFailure([Failure? failure]) {
    when(
      () => mockRepository.getPromotions(
        limit: any(named: 'limit'),
        lastDocumentId: any(named: 'lastDocumentId'),
      ),
    ).thenAnswer(
      (_) async =>
          Left(failure ?? const ServerFailure(message: 'Server error')),
    );
  }

  final tPromotion = PromotionEntity(
    id: 'promo-1',
    title: 'Test Promo',
    description: 'desc',
    commerceId: 'commerce-1',
    commerceName: 'Test Commerce',
    category: 'food',
    discount: '20%',
    latitude: 9.9281,
    longitude: -84.0907,
    address: 'San José, CR',
    validUntil: DateTime(2099),
    createdBy: 'user-1',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  // -------------------------------------------------------------------------
  // 1) Initial state
  // -------------------------------------------------------------------------
  test('initial state is PromotionInitial', () {
    expect(bloc.state, const PromotionInitial());
  });

  // -------------------------------------------------------------------------
  // 2) Happy path: PromotionFetchRequested → [Loading, Loaded]
  // -------------------------------------------------------------------------
  test(
    'PromotionFetchRequested emits [PromotionLoading, PromotionLoaded] '
    'when repository returns data',
    () async {
      // Arrange
      stubGetPromotionsSuccess([tPromotion]);

      final states = <Object>[];
      final sub = bloc.stream.listen(states.add);

      // Act
      bloc.add(const PromotionFetchRequested());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      // Assert
      expect(states.first, isA<PromotionLoading>());
      expect(states.last, isA<PromotionLoaded>());
      final loaded = states.last as PromotionLoaded;
      expect(loaded.promotions, [tPromotion]);
    },
  );

  // -------------------------------------------------------------------------
  // 3) Failure path: PromotionFetchRequested → [Loading, Error]
  // -------------------------------------------------------------------------
  test(
    'PromotionFetchRequested emits [PromotionLoading, PromotionError] '
    'when repository returns a failure',
    () async {
      // Arrange
      const failure = ServerFailure(message: 'Network unavailable');
      stubGetPromotionsFailure(failure);

      final states = <Object>[];
      final sub = bloc.stream.listen(states.add);

      // Act
      bloc.add(const PromotionFetchRequested());
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      // Assert
      expect(states.first, isA<PromotionLoading>());
      expect(states.last, isA<PromotionError>());
      final error = states.last as PromotionError;
      expect(error.message, 'Network unavailable');
    },
  );

  // -------------------------------------------------------------------------
  // 4) Filter: PromotionFilterByCategoryRequested uses category name
  // -------------------------------------------------------------------------
  test(
    'PromotionFilterByCategoryRequested calls repository with category name '
    'and emits PromotionLoaded with selectedCategory set',
    () async {
      // Arrange
      when(
        () => mockRepository.getPromotionsByCategory(
          category: 'Technology',
          limit: any(named: 'limit'),
          lastDocumentId: any(named: 'lastDocumentId'),
        ),
      ).thenAnswer((_) async => Right([tPromotion]));

      final states = <Object>[];
      final sub = bloc.stream.listen(states.add);

      // Act
      bloc.add(
          const PromotionFilterByCategoryRequested(category: 'Technology'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      // Assert
      verify(
        () => mockRepository.getPromotionsByCategory(
          category: 'Technology',
          limit: any(named: 'limit'),
          lastDocumentId: any(named: 'lastDocumentId'),
        ),
      ).called(1);
      expect(states.last, isA<PromotionLoaded>());
      final loaded = states.last as PromotionLoaded;
      expect(loaded.selectedCategory, 'Technology');
    },
  );
}
