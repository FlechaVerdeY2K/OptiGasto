// lib/features/route/presentation/pages/route_planner_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/route_stop_entity.dart';
import '../bloc/route_planner_bloc.dart';
import '../bloc/route_planner_event.dart';
import '../bloc/route_planner_state.dart';
import '../widgets/favorites_stop_picker.dart';
import '../widgets/nearby_stop_picker.dart';
import '../widgets/route_origin_selector.dart';
import '../widgets/stop_selection_method_picker.dart';

class RoutePlannerPage extends StatelessWidget {
  const RoutePlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoutePlannerBloc, RoutePlannerState>(
      listener: (context, state) {
        if (state is RoutePlannerRouteCalculated) {
          context.push(AppRouter.routeResult, extra: state.route);
        } else if (state is RoutePlannerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final readyState = state is RoutePlannerReadyToCalculate ? state : null;
        final isLoading = state is RoutePlannerLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Planificar ruta')),
          body: isLoading || readyState == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: RouteOriginSelector(origin: readyState.origin),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Cómo elegir paradas',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      StopSelectionMethodPicker(
                        selected: readyState.method,
                        onChanged: (method) {
                          context.read<RoutePlannerBloc>().add(
                                StopSelectionMethodChanged(method: method),
                              );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPicker(context, readyState),
                      const SizedBox(height: 8),
                      _StopCounter(count: readyState.selectedStops.length),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
          floatingActionButton: readyState != null &&
                  readyState.selectedStops.isNotEmpty &&
                  readyState.selectedStops.length <= 10
              ? FloatingActionButton.extended(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<RoutePlannerBloc>().add(
                                const RouteCalculationRequested(),
                              );
                        },
                  backgroundColor: AppColors.primary,
                  label: const Text('Calcular ruta'),
                  icon: const Icon(Icons.route),
                )
              : null,
        );
      },
    );
  }

  Widget _buildPicker(
      BuildContext context, RoutePlannerReadyToCalculate state) {
    switch (state.method) {
      case StopSelectionMethod.map:
        return ElevatedButton.icon(
          onPressed: () async {
            final stops = await context
                .push<List<RouteStopEntity>>(AppRouter.routeMapPicker);
            if (stops != null && stops.isNotEmpty && context.mounted) {
              context.read<RoutePlannerBloc>().add(StopsSelected(stops: stops));
            }
          },
          icon: const Icon(Icons.map_outlined),
          label: const Text('Abrir mapa para seleccionar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
          ),
        );
      case StopSelectionMethod.favorites:
        return FavoritesStopPicker(
          selectedStops: state.selectedStops,
          onChanged: (stops) {
            context.read<RoutePlannerBloc>().add(StopsSelected(stops: stops));
          },
        );
      case StopSelectionMethod.nearby:
        return NearbyStopPicker(
          selectedStops: state.selectedStops,
          onChanged: (stops) {
            context.read<RoutePlannerBloc>().add(StopsSelected(stops: stops));
          },
        );
    }
  }
}

class _StopCounter extends StatelessWidget {
  final int count;
  const _StopCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    final isOver = count > 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOver ? Colors.red[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isOver ? Colors.red : Colors.grey[300]!),
      ),
      child: Text(
        isOver
            ? 'Máximo 10 paradas por ruta. Quitá algunas para continuar.'
            : '$count / 10 paradas seleccionadas',
        style: TextStyle(
          color: isOver ? Colors.red[700] : Colors.grey[700],
          fontWeight: isOver ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
