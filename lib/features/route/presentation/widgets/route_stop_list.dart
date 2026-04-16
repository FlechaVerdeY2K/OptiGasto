import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../domain/entities/optimized_route_entity.dart';

class RouteStopList extends StatelessWidget {
  final OptimizedRouteEntity route;

  const RouteStopList({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: route.stops.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final stop = route.stops[index];
        final distFromPrev = _distFromPrev(index);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              '${stop.order}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(stop.name),
          subtitle: index > 0
              ? Text('${distFromPrev.toStringAsFixed(1)} km desde anterior')
              : const Text('Primer destino'),
          trailing: stop.promotionId != null
              ? IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    context.push(
                      AppRouter.promotionDetail,
                      extra: stop.promotionId,
                    );
                  },
                )
              : null,
        );
      },
    );
  }

  double _distFromPrev(int index) {
    if (index == 0) return 0;
    final prev = route.stops[index - 1].location;
    return prev.distanceTo(route.stops[index].location);
  }
}
