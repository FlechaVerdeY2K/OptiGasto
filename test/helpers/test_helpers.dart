import 'package:mocktail/mocktail.dart';
import 'package:optigasto/features/location/domain/entities/location_entity.dart';
import 'package:optigasto/features/promotions/domain/entities/promotion_entity.dart';
import 'package:optigasto/features/promotions/domain/repositories/promotion_repository.dart';
import 'package:optigasto/features/route/domain/entities/route_origin_entity.dart';
import 'package:optigasto/features/route/domain/entities/route_stop_entity.dart';
import 'package:optigasto/features/route/domain/repositories/route_repository.dart';

class MockPromotionRepository extends Mock implements PromotionRepository {}

class MockRouteRepository extends Mock implements RouteRepository {}

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
  registerFallbackValue(
    LocationEntity(latitude: 0, longitude: 0, timestamp: DateTime(2024)),
  );
  registerFallbackValue(<LocationEntity>[]);
  registerFallbackValue(
    RouteStopEntity(
      id: 'fallback-stop',
      name: 'Fallback',
      location:
          LocationEntity(latitude: 0, longitude: 0, timestamp: DateTime(2024)),
      order: 0,
    ),
  );
  registerFallbackValue(
    RouteOriginEntity(
      location:
          LocationEntity(latitude: 0, longitude: 0, timestamp: DateTime(2024)),
      displayName: 'Fallback',
      type: RouteOriginType.currentLocation,
    ),
  );
}
