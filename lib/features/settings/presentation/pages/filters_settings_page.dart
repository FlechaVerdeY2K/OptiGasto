import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/settings_bloc.dart';

/// Página de configuración de filtros de contenido
class FiltersSettingsPage extends StatefulWidget {
  const FiltersSettingsPage({super.key});

  @override
  State<FiltersSettingsPage> createState() => _FiltersSettingsPageState();
}

class _FiltersSettingsPageState extends State<FiltersSettingsPage> {
  late double _minDiscount;
  late bool _hideExpired;
  bool _hasChanges = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros de Contenido'),
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
              _minDiscount = state.settings.minDiscountPercentage;
              _hideExpired = state.settings.hideExpiredPromotions;
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Descuento Mínimo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_minDiscount.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Slider(
                                value: _minDiscount,
                                min: 0,
                                max: 100,
                                divisions: 20,
                                label: '${_minDiscount.toStringAsFixed(0)}%',
                                onChanged: (value) {
                                  setState(() {
                                    _minDiscount = value;
                                    _hasChanges = true;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: SwitchListTile(
                          title: const Text('Ocultar Promociones Vencidas'),
                          subtitle: const Text('No mostrar ofertas expiradas'),
                          value: _hideExpired,
                          onChanged: (value) {
                            setState(() {
                              _hideExpired = value;
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
                          color: Colors.black.withValues(alpha: 0.1),
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
                              minDiscountPercentage: _minDiscount,
                              hideExpiredPromotions: _hideExpired,
                            );
                            context
                                .read<SettingsBloc>()
                                .add(UpdateSettings(updated));
                            setState(() => _hasChanges = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Filtros guardados correctamente'),
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

          return const Center(child: Text('Error al cargar configuraciones'));
        },
      ),
    );
  }
}

// Made with Bob
