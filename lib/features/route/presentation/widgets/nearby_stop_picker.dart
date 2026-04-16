// lib/features/route/presentation/widgets/nearby_stop_picker.dart
import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../location/domain/repositories/location_repository.dart';
import '../../../location/domain/usecases/get_current_location.dart';
import '../../domain/entities/route_stop_entity.dart';

class NearbyStopPicker extends StatefulWidget {
  final List<RouteStopEntity> selectedStops;
  final ValueChanged<List<RouteStopEntity>> onChanged;

  const NearbyStopPicker({
    super.key,
    required this.selectedStops,
    required this.onChanged,
  });

  @override
  State<NearbyStopPicker> createState() => _NearbyStopPickerState();
}

class _NearbyStopPickerState extends State<NearbyStopPicker> {
  double _radiusKm = 3.0;
  List<RouteStopEntity> _nearbyStops = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final locationResult = await sl<GetCurrentLocation>()();
    final location = locationResult.fold((_) => null, (l) => l);

    if (location == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Activá el permiso de ubicación para usar tu ubicación actual.';
        });
      }
      return;
    }

    final markersResult =
        await sl<LocationRepository>().getNearbyPromotionMarkers(
      latitude: location.latitude,
      longitude: location.longitude,
      radiusInKm: _radiusKm,
      limit: 20,
    );

    if (!mounted) return;

    markersResult.fold(
      (failure) => setState(() {
        _isLoading = false;
        _errorMessage = failure.message;
      }),
      (markers) => setState(() {
        _isLoading = false;
        _nearbyStops = markers
            .map(
              (m) => RouteStopEntity(
                id: m.id,
                promotionId: m.id,
                name: m.title,
                location: m.location,
                order: 0,
              ),
            )
            .toList();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Radio: ${_radiusKm.toStringAsFixed(0)} km',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Slider(
          value: _radiusKm,
          min: 1,
          max: 10,
          divisions: 9,
          label: '${_radiusKm.toStringAsFixed(0)} km',
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => _radiusKm = v),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _search,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.search),
          label: const Text('Buscar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child:
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          ),
        if (_nearbyStops.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('${_nearbyStops.length} promociones encontradas'),
          const SizedBox(height: 4),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _nearbyStops.length,
            itemBuilder: (context, index) {
              final stop = _nearbyStops[index];
              final isSelected =
                  widget.selectedStops.any((s) => s.id == stop.id);
              return CheckboxListTile(
                title: Text(stop.name),
                value: isSelected,
                activeColor: AppColors.primary,
                onChanged: (checked) {
                  final updated =
                      List<RouteStopEntity>.from(widget.selectedStops);
                  if (checked == true) {
                    updated.add(stop);
                  } else {
                    updated.removeWhere((s) => s.id == stop.id);
                  }
                  widget.onChanged(updated);
                },
              );
            },
          ),
        ],
      ],
    );
  }
}
