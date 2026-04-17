import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routes/app_router.dart';
import '../../domain/entities/saved_route_entity.dart';
import '../bloc/saved_routes_bloc.dart';
import '../bloc/saved_routes_event.dart';
import '../bloc/saved_routes_state.dart';

class SavedRoutesPage extends StatelessWidget {
  const SavedRoutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis rutas guardadas')),
      body: BlocBuilder<SavedRoutesBloc, SavedRoutesState>(
        builder: (context, state) {
          if (state is SavedRoutesLoading ||
              state is SavedRouteOperationInProgress) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SavedRoutesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<SavedRoutesBloc>()
                        .add(const SavedRoutesLoadRequested()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is SavedRoutesLoaded && state.routes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.route, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No tenés rutas guardadas.\n¡Creá una desde el planificador!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push(AppRouter.routePlanner),
                    icon: const Icon(Icons.add),
                    label: const Text('Planificar ruta'),
                  ),
                ],
              ),
            );
          }
          if (state is SavedRoutesLoaded) {
            return RefreshIndicator(
              onRefresh: () async => context
                  .read<SavedRoutesBloc>()
                  .add(const SavedRoutesLoadRequested()),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.routes.length,
                itemBuilder: (context, index) {
                  return _SavedRouteCard(route: state.routes[index]);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SavedRouteCard extends StatelessWidget {
  final SavedRouteEntity route;
  const _SavedRouteCard({required this.route});

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    return '${hours}h ${remaining}min';
  }

  String _formatDistance(int meters) {
    if (meters < 1000) return '$meters m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(route.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Eliminar ruta'),
            content: Text('¿Eliminás "${route.name}"? No se puede deshacer.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child:
                    const Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context
            .read<SavedRoutesBloc>()
            .add(SavedRouteDeleteRequested(routeId: route.id));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      route.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.push(AppRouter.routeEditor, extra: route),
                    child: const Text('Editar'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.straighten, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDistance(route.distanceMeters),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(route.durationSeconds),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.place, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${route.stops.length} paradas',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd/MM/yyyy', 'es_ES').format(route.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Made with Bob
