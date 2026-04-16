import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsResponseModel {
  final String status;
  final List<LatLng> polylinePoints;
  final int totalDistanceMeters;
  final int totalDurationSeconds;

  const DirectionsResponseModel({
    required this.status,
    required this.polylinePoints,
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
  });

  factory DirectionsResponseModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String;
    final routes = json['routes'] as List<dynamic>;

    if (routes.isEmpty) {
      return DirectionsResponseModel(
        status: status,
        polylinePoints: const [],
        totalDistanceMeters: 0,
        totalDurationSeconds: 0,
      );
    }

    final route = routes[0] as Map<String, dynamic>;
    final encoded = (route['overview_polyline']
        as Map<String, dynamic>)['points'] as String;

    final points = PolylinePoints()
        .decodePolyline(encoded)
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final legs = route['legs'] as List<dynamic>;
    var totalDistance = 0;
    var totalDuration = 0;
    for (final leg in legs) {
      final m = leg as Map<String, dynamic>;
      totalDistance +=
          ((m['distance'] as Map<String, dynamic>)['value'] as num).toInt();
      totalDuration +=
          ((m['duration'] as Map<String, dynamic>)['value'] as num).toInt();
    }

    return DirectionsResponseModel(
      status: status,
      polylinePoints: points,
      totalDistanceMeters: totalDistance,
      totalDurationSeconds: totalDuration,
    );
  }
}
