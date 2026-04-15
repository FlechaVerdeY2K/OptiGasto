import 'package:mocktail/mocktail.dart';
import 'package:optigasto/features/promotions/domain/entities/promotion_entity.dart';
import 'package:optigasto/features/promotions/domain/repositories/promotion_repository.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockPromotionRepository extends Mock implements PromotionRepository {}

// ---------------------------------------------------------------------------
// Fallback values
// Register these once (in setUpAll) for any custom type used with any() in
// mocktail argument matchers.
// ---------------------------------------------------------------------------

void registerFallbackValues() {
  registerFallbackValue(
    PromotionEntity(
      id: 'fallback-id',
      title: 'Fallback',
      description: 'Fallback',
      commerceId: 'commerce-id',
      commerceName: 'Commerce',
      category: 'other',
      discount: '0%',
      latitude: 0,
      longitude: 0,
      address: 'Fallback address',
      validUntil: DateTime(2099),
      createdBy: 'user-id',
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    ),
  );
}
