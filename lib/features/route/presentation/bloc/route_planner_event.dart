// lib/features/route/presentation/bloc/route_planner_event.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/route_origin_entity.dart';
import '../../domain/entities/route_stop_entity.dart';

enum StopSelectionMethod { map, favorites, nearby }

abstract class RoutePlannerEvent extends Equatable {
  const RoutePlannerEvent();

  @override
  List<Object?> get props => [];
}

class RoutePlannerInitialized extends RoutePlannerEvent {
  const RoutePlannerInitialized();
}

class OriginChanged extends RoutePlannerEvent {
  final RouteOriginEntity newOrigin;
  const OriginChanged({required this.newOrigin});

  @override
  List<Object?> get props => [newOrigin];
}

class StopSelectionMethodChanged extends RoutePlannerEvent {
  final StopSelectionMethod method;
  const StopSelectionMethodChanged({required this.method});

  @override
  List<Object?> get props => [method];
}

class StopsSelected extends RoutePlannerEvent {
  final List<RouteStopEntity> stops;
  const StopsSelected({required this.stops});

  @override
  List<Object?> get props => [stops];
}

class RouteCalculationRequested extends RoutePlannerEvent {
  const RouteCalculationRequested();
}

class RouteCleared extends RoutePlannerEvent {
  const RouteCleared();
}
