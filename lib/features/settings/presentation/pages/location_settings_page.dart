import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/settings_bloc.dart';
import '../../domain/entities/app_settings_entity.dart';

/// Página de configuración de ubicación
class LocationSettingsPage extends StatelessWidget {
  const LocationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LocationSettingsContent();
  }
}

class _LocationSettingsContent extends StatefulWidget {
  const _LocationSettingsContent();

  @override
  State<_LocationSettingsContent> createState() =>
      _LocationSettingsContentState();
}

class _LocationSettingsContentState extends State<_LocationSettingsContent> {
  late double _searchRadius;
  late bool _autoLocation;
  bool _hasChanges = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias de Ubicación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsLoaded) {
            // Inicializar valores locales solo la primera vez
            if (!_hasChanges) {
              _searchRadius = state.settings.searchRadius;
              _autoLocation = state.settings.autoLocation;
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Radio de búsqueda
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.radar, color: AppColors.primary),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Radio de Búsqueda',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${_searchRadius.toStringAsFixed(0)} km',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Slider(
                                value: _searchRadius,
                                min: 1,
                                max: 50,
                                divisions: 49,
                                label: '${_searchRadius.toStringAsFixed(0)} km',
                                onChanged: (value) {
                                  setState(() {
                                    _searchRadius = value;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                              Text(
                                'Define qué tan lejos quieres buscar promociones',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Ubicación automática
                      Card(
                        child: SwitchListTile(
                          secondary:
                              Icon(Icons.my_location, color: AppColors.primary),
                          title: const Text('Ubicación Automática'),
                          subtitle: const Text(
                            'Usar tu ubicación actual automáticamente',
                          ),
                          value: _autoLocation,
                          onChanged: (value) {
                            setState(() {
                              _autoLocation = value;
                              _hasChanges = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón de guardar
                if (_hasChanges)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final updated = state.settings.copyWith(
                              searchRadius: _searchRadius,
                              autoLocation: _autoLocation,
                            );
                            context
                                .read<SettingsBloc>()
                                .add(UpdateSettings(updated));
                            setState(() => _hasChanges = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Configuración guardada correctamente'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar Cambios'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }

          return const Center(
            child: Text('Error al cargar configuraciones'),
          );
        },
      ),
    );
  }
}

// Made with Bob
