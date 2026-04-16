// lib/features/route/presentation/widgets/route_origin_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../location/domain/entities/location_entity.dart';
import '../../domain/entities/route_origin_entity.dart';
import '../bloc/route_planner_bloc.dart';
import '../bloc/route_planner_event.dart';

class RouteOriginSelector extends StatelessWidget {
  final RouteOriginEntity origin;

  const RouteOriginSelector({super.key, required this.origin});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.my_location, color: AppColors.primary),
      title: const Text('Punto de partida'),
      subtitle: Text(origin.displayName),
      trailing: const Icon(Icons.edit_outlined),
      onTap: () => _showOriginSheet(context),
    );
  }

  void _showOriginSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => _OriginPickerSheet(
        onOriginSelected: (newOrigin) {
          context
              .read<RoutePlannerBloc>()
              .add(OriginChanged(newOrigin: newOrigin));
          Navigator.of(sheetCtx).pop();
        },
      ),
    );
  }
}

class _OriginPickerSheet extends StatefulWidget {
  final ValueChanged<RouteOriginEntity> onOriginSelected;

  const _OriginPickerSheet({required this.onOriginSelected});

  @override
  State<_OriginPickerSheet> createState() => _OriginPickerSheetState();
}

class _OriginPickerSheetState extends State<_OriginPickerSheet> {
  final _addressController = TextEditingController();
  bool _isGeocoding = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _geocodeAddress() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) return;

    setState(() => _isGeocoding = true);
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty && mounted) {
        final loc = locations.first;
        widget.onOriginSelected(
          RouteOriginEntity(
            location: LocationEntity(
              latitude: loc.latitude,
              longitude: loc.longitude,
              timestamp: DateTime.now(),
            ),
            displayName: address,
            type: RouteOriginType.customAddress,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se encontró la dirección. Intentá de nuevo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Elegir punto de partida',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.my_location, color: AppColors.primary),
            title: const Text('Mi ubicación actual'),
            onTap: () => Navigator.of(context).pop(),
          ),
          const Divider(),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Buscar dirección',
              suffixIcon: _isGeocoding
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _geocodeAddress,
                    ),
            ),
            onSubmitted: (_) => _geocodeAddress(),
          ),
        ],
      ),
    );
  }
}
