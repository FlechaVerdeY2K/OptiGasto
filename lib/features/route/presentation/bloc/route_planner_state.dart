// lib/features/route/presentation/bloc/route_planner_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/optimized_route_entity.dart';
import '../../domain/entities/route_origin_entity.dart';
import '../../domain/entities/route_stop_entity.dart';
import 'route_planner_event.dart';

abstract class RoutePlannerState extends Equatable {
  const RoutePlannerState();

  @override
  List<Object?> get props => [];
}

class RoutePlannerInitial extends RoutePlannerState {
  const RoutePlannerInitial();
}

class RoutePlannerLoading extends RoutePlannerState {
  const RoutePlannerLoading();
}

class RoutePlannerReadyToCalculate extends RoutePlannerState {
  final RouteOriginEntity origin;
  final List<RouteStopEntity> selectedStops;
  final StopSelectionMethod method;

  const RoutePlannerReadyToCalculate({
    required this.origin,
    required this.selectedStops,
    required this.method,
  });

  RoutePlannerReadyToCalculate copyWith({
    RouteOriginEntity? origin,
    List<RouteStopEntity>? selectedStops,
    StopSelectionMethod? method,
  }) {
    return RoutePlannerReadyToCalculate(
      origin: origin ?? this.origin,
      selectedStops: selectedStops ?? this.selectedStops,
      method: method ?? this.method,
    );
  }

  @override
  List<Object?> get props => [origin, selectedStops, method];
}

class RoutePlannerRouteCalculated extends RoutePlannerState {
  final OptimizedRouteEntity route;

  const RoutePlannerRouteCalculated({required this.route});

  @override
  List<Object?> get props => [route];
}

class RoutePlannerError extends RoutePlannerState {
  final String message;

  const RoutePlannerError({required this.message});

  @override
  List<Object?> get props => [message];
}
