// lib/features/route/presentation/bloc/route_planner_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/route_origin_entity.dart';
import '../../domain/usecases/build_navigation_url.dart';
import '../../domain/usecases/calculate_optimal_route.dart';
import '../../../location/domain/usecases/get_current_location.dart';
import 'route_planner_event.dart';
import 'route_planner_state.dart';

class RoutePlannerBloc extends Bloc<RoutePlannerEvent, RoutePlannerState> {
  final CalculateOptimalRoute calculateOptimalRoute;
  final BuildNavigationUrl buildNavigationUrl;
  final GetCurrentLocation getCurrentLocation;

  RoutePlannerBloc({
    required this.calculateOptimalRoute,
    required this.buildNavigationUrl,
    required this.getCurrentLocation,
  }) : super(const RoutePlannerInitial()) {
    on<RoutePlannerInitialized>(_onInitialized);
    on<OriginChanged>(_onOriginChanged);
    on<StopSelectionMethodChanged>(_onMethodChanged);
    on<StopsSelected>(_onStopsSelected);
    on<RouteCalculationRequested>(_onCalculationRequested);
    on<RouteCleared>(_onCleared);
  }

  Future<void> _onInitialized(
    RoutePlannerInitialized event,
    Emitter<RoutePlannerState> emit,
  ) async {
    emit(const RoutePlannerLoading());
    final result = await getCurrentLocation();
    result.fold(
      (failure) => emit(const RoutePlannerInitial()),
      (location) => emit(
        RoutePlannerReadyToCalculate(
          origin: RouteOriginEntity(
            location: location,
            displayName: 'Mi ubicación actual',
            type: RouteOriginType.currentLocation,
          ),
          selectedStops: const [],
          method: StopSelectionMethod.map,
        ),
      ),
    );
  }

  void _onOriginChanged(
    OriginChanged event,
    Emitter<RoutePlannerState> emit,
  ) {
    final current = state;
    if (current is RoutePlannerReadyToCalculate) {
      emit(current.copyWith(origin: event.newOrigin));
    } else {
      emit(RoutePlannerReadyToCalculate(
        origin: event.newOrigin,
        selectedStops: const [],
        method: StopSelectionMethod.map,
      ));
    }
  }

  void _onMethodChanged(
    StopSelectionMethodChanged event,
    Emitter<RoutePlannerState> emit,
  ) {
    final current = state;
    if (current is RoutePlannerReadyToCalculate) {
      emit(current.copyWith(method: event.method));
    }
  }

  void _onStopsSelected(
    StopsSelected event,
    Emitter<RoutePlannerState> emit,
  ) {
    final current = state;
    if (current is RoutePlannerReadyToCalculate) {
      emit(current.copyWith(selectedStops: event.stops));
    }
  }

  Future<void> _onCalculationRequested(
    RouteCalculationRequested event,
    Emitter<RoutePlannerState> emit,
  ) async {
    final current = state;
    if (current is! RoutePlannerReadyToCalculate) return;

    emit(const RoutePlannerLoading());
    final result = await calculateOptimalRoute(
      origin: current.origin,
      unorderedStops: current.selectedStops,
    );
    result.fold(
      (failure) => emit(RoutePlannerError(message: failure.message)),
      (route) => emit(RoutePlannerRouteCalculated(route: route)),
    );
  }

  void _onCleared(
    RouteCleared event,
    Emitter<RoutePlannerState> emit,
  ) {
    emit(const RoutePlannerInitial());
  }
}
