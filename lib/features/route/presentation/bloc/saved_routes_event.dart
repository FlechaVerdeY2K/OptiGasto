import 'package:equatable/equatable.dart';
import '../../domain/entities/optimized_route_entity.dart';
import '../../domain/entities/saved_route_entity.dart';

abstract class SavedRoutesEvent extends Equatable {
  const SavedRoutesEvent();

  @override
  List<Object?> get props => [];
}

class SavedRoutesLoadRequested extends SavedRoutesEvent {
  const SavedRoutesLoadRequested();
}

class SavedRouteCreateRequested extends SavedRoutesEvent {
  final OptimizedRouteEntity route;
  final String name;

  const SavedRouteCreateRequested({
    required this.route,
    required this.name,
  });

  @override
  List<Object?> get props => [route, name];
}

class SavedRouteUpdateRequested extends SavedRoutesEvent {
  final SavedRouteEntity route;

  const SavedRouteUpdateRequested({required this.route});

  @override
  List<Object?> get props => [route];
}

class SavedRouteDeleteRequested extends SavedRoutesEvent {
  final String routeId;

  const SavedRouteDeleteRequested({required this.routeId});

  @override
  List<Object?> get props => [routeId];
}
