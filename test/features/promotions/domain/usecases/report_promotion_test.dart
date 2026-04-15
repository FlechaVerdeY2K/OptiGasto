import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optigasto/core/errors/failures.dart';
import 'package:optigasto/features/promotions/domain/usecases/report_promotion.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late ReportPromotion useCase;
  late MockPromotionRepository mockRepository;

  setUp(() {
    mockRepository = MockPromotionRepository();
    useCase = ReportPromotion(mockRepository);
  });

  setUpAll(registerFallbackValues);

  const tPromotionId = 'promo-123';
  const tUserId = 'user-456';
  const tReason = 'expired';
  const tDescription = 'The promotion has expired.';

  group('ReportPromotion', () {
    test('initial state — use case delegates to repository', () async {
      // Arrange: repository returns success
      when(
        () => mockRepository.reportPromotion(
          promotionId: tPromotionId,
          userId: tUserId,
          reason: tReason,
          description: tDescription,
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(
        promotionId: tPromotionId,
        userId: tUserId,
        reason: tReason,
        description: tDescription,
      );

      // Assert: returned Right(null)
      expect(result, const Right<Failure, void>(null));
    });

    test('happy path — returns Right(void) when repository succeeds', () async {
      // Arrange
      when(
        () => mockRepository.reportPromotion(
          promotionId: tPromotionId,
          userId: tUserId,
          reason: tReason,
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(
        promotionId: tPromotionId,
        userId: tUserId,
        reason: tReason,
      );

      // Assert
      expect(result.isRight(), isTrue);
    });

    test('failure path — returns Left(Failure) when repository fails',
        () async {
      // Arrange
      const failure = ServerFailure(message: 'Server error');
      when(
        () => mockRepository.reportPromotion(
          promotionId: any(named: 'promotionId'),
          userId: any(named: 'userId'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase(
        promotionId: tPromotionId,
        userId: tUserId,
        reason: tReason,
      );

      // Assert
      expect(result, const Left<Failure, void>(failure));
      expect(result.isLeft(), isTrue);
    });

    test('verify — calls repository.reportPromotion with correct parameters',
        () async {
      // Arrange
      when(
        () => mockRepository.reportPromotion(
          promotionId: tPromotionId,
          userId: tUserId,
          reason: tReason,
          description: tDescription,
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      await useCase(
        promotionId: tPromotionId,
        userId: tUserId,
        reason: tReason,
        description: tDescription,
      );

      // Assert: repository was called exactly once with the correct args
      verify(
        () => mockRepository.reportPromotion(
          promotionId: tPromotionId,
          userId: tUserId,
          reason: tReason,
          description: tDescription,
        ),
      ).called(1);

      verifyNoMoreInteractions(mockRepository);
    });
  });
}
