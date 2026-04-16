import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../domain/entities/route_stop_entity.dart';
import '../../domain/entities/saved_route_entity.dart';
import '../../domain/usecases/calculate_ordered_route.dart';
import '../bloc/saved_routes_bloc.dart';
import '../bloc/saved_routes_event.dart';
import '../bloc/saved_routes_state.dart';

class RouteEditorPage extends StatefulWidget {
  final SavedRouteEntity route;
  final CalculateOrderedRoute calculateOrderedRoute;

  const RouteEditorPage({
    super.key,
    required this.route,
    required this.calculateOrderedRoute,
  });

  @override
  State<RouteEditorPage> createState() => _RouteEditorPageState();
}

class _RouteEditorPageState extends State<RouteEditorPage> {
  late List<RouteStopEntity> _orderedStops;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _orderedStops = List.of(widget.route.stops)
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final stop = _orderedStops.removeAt(oldIndex);
      _orderedStops.insert(newIndex, stop);
      // Reassign order 1..N
      for (var i = 0; i < _orderedStops.length; i++) {
        _orderedStops[i] = _orderedStops[i].copyWith(order: i + 1);
      }
    });
  }

  Future<void> _saveOrder() async {
    final updated = widget.route.copyWith(stops: _orderedStops);
    context
        .read<SavedRoutesBloc>()
        .add(SavedRouteUpdateRequested(route: updated));
  }

  Future<void> _recalculate() async {
    setState(() => _isCalculating = true);
    final result = await widget.calculateOrderedRoute(
      origin: widget.route.origin,
      orderedStops: _orderedStops,
    );
    if (!mounted) return;
    setState(() => _isCalculating = false);
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (optimizedRoute) => context.push(AppRouter.routeResult, extra: optimizedRoute),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SavedRoutesBloc, SavedRoutesState>(
      listener: (context, state) {
        if (state is SavedRoutesLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ruta actualizada')),
          );
        } else if (state is SavedRoutesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Editar: ${widget.route.name}'),
          actions: [
            TextButton(
              onPressed: _saveOrder,
              child: const Text('Guardar orden'),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Origin (display only)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.my_location, color: Colors.green),
                  title: const Text('Origen'),
                  subtitle: Text(widget.route.origin.displayName),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'Paradas (arrastrá para reordenar)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _orderedStops.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final stop = _orderedStops[index];
                  return Card(
                    key: Key(stop.id),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(stop.name),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_indicator),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _isCalculating ? null : _recalculate,
                icon: _isCalculating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.calculate),
                label: const Text('Recalcular ruta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Made with Bob
