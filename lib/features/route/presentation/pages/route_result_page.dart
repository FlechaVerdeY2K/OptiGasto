// lib/features/route/presentation/pages/route_result_page.dart
// TODO(Task 10): Full implementation
import 'package:flutter/material.dart';
import '../../domain/entities/optimized_route_entity.dart';

class RouteResultPage extends StatelessWidget {
  final OptimizedRouteEntity route;

  const RouteResultPage({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
