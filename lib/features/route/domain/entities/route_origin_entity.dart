import 'package:equatable/equatable.dart';
import '../../../location/domain/entities/location_entity.dart';

enum RouteOriginType { currentLocation, customAddress, favoriteCommerce }

/// Entidad que representa el punto de partida de la ruta
class RouteOriginEntity extends Equatable {
  final LocationEntity location;
  final String displayName;
  final RouteOriginType type;

  const RouteOriginEntity({
    required this.location,
    required this.displayName,
    required this.type,
  });

  RouteOriginEntity copyWith({
    LocationEntity? location,
    String? displayName,
    RouteOriginType? type,
  }) {
    return RouteOriginEntity(
      location: location ?? this.location,
      displayName: displayName ?? this.displayName,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [location, displayName, type];

  @override
  String toString() =>
      'RouteOriginEntity(type: $type, displayName: $displayName)';
}
