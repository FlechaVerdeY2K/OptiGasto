// lib/features/route/presentation/widgets/route_summary_card.dart
import 'package:flutter/material.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../domain/entities/optimized_route_entity.dart';

class RouteSummaryCard extends StatelessWidget {
  final OptimizedRouteEntity route;

  const RouteSummaryCard({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    final distanceKm = route.totalDistanceMeters / 1000;
    final durationText = DurationFormatter.format(route.totalDurationSeconds);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Stat(
              icon: Icons.straighten,
              label: 'Distancia',
              value: '${distanceKm.toStringAsFixed(1)} km',
            ),
            _Stat(
              icon: Icons.access_time,
              label: 'Tiempo est.',
              value: durationText,
            ),
            _Stat(
              icon: Icons.place,
              label: 'Paradas',
              value: '${route.stops.length}',
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Stat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
