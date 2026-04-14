import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/settings_bloc.dart';

class DataSettingsPage extends StatelessWidget {
  const DataSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SettingsBloc>()..add(const LoadSettings()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestión de Datos'),
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

            if (state is SettingsLoaded || state is SettingsUpdated) {
              final settings = state is SettingsLoaded
                  ? state.settings
                  : (state as SettingsUpdated).settings;

              return ListView(
                children: [
                  SwitchListTile(
                    title: const Text('Usar Datos Móviles para Imágenes'),
                    subtitle: const Text('Descargar imágenes con datos móviles'),
                    value: settings.useMobileDataForImages,
                    onChanged: (value) {
                      final updated = settings.copyWith(useMobileDataForImages: value);
                      context.read<SettingsBloc>().add(UpdateSettings(updated));
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Calidad de Imágenes'),
                    subtitle: Text(settings.imageQuality == 'high' ? 'Alta' : 
                                  settings.imageQuality == 'medium' ? 'Media' : 'Baja'),
                    trailing: DropdownButton<String>(
                      value: settings.imageQuality,
                      items: const [
                        DropdownMenuItem(value: 'high', child: Text('Alta')),
                        DropdownMenuItem(value: 'medium', child: Text('Media')),
                        DropdownMenuItem(value: 'low', child: Text('Baja')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          final updated = settings.copyWith(imageQuality: value);
                          context.read<SettingsBloc>().add(UpdateSettings(updated));
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Caché de Mapas Offline'),
                    subtitle: const Text('Guardar mapas para uso sin conexión'),
                    value: settings.offlineMapsCache,
                    onChanged: (value) {
                      final updated = settings.copyWith(offlineMapsCache: value);
                      context.read<SettingsBloc>().add(UpdateSettings(updated));
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Sincronización Automática'),
                    subtitle: const Text('Sincronizar datos automáticamente'),
                    value: settings.autoSync,
                    onChanged: (value) {
                      final updated = settings.copyWith(autoSync: value);
                      context.read<SettingsBloc>().add(UpdateSettings(updated));
                    },
                  ),
                ],
              );
            }

            return const Center(child: Text('Error al cargar configuraciones'));
          },
        ),
      ),
    );
  }
}

// Made with Bob