import 'package:equatable/equatable.dart';
import '../../../location/domain/entities/location_entity.dart';

/// Entidad que representa una parada en la ruta optimizada
class RouteStopEntity extends Equatable {
  final String id;
  final String? promotionId;
  final String name;
  final LocationEntity location;
  final int order;

  const RouteStopEntity({
    required this.id,
    this.promotionId,
    required this.name,
    required this.location,
    required this.order,
  });

  RouteStopEntity copyWith({
    String? id,
    String? promotionId,
    String? name,
    LocationEntity? location,
    int? order,
  }) {
    return RouteStopEntity(
      id: id ?? this.id,
      promotionId: promotionId ?? this.promotionId,
      name: name ?? this.name,
      location: location ?? this.location,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, promotionId, name, location, order];

  @override
  String toString() =>
      'RouteStopEntity(id: $id, name: $name, order: $order, promotionId: $promotionId)';
}
