import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/settings_bloc.dart';

/// Página de configuración de tema
class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema'),
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
            final settings = state.settings;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: RadioGroup<String>(
                    groupValue: settings.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsBloc>().add(
                              UpdateThemeMode(value),
                            );
                      }
                    },
                    child: const Column(
                      children: [
                        RadioListTile<String>(
                          secondary: Icon(Icons.brightness_5),
                          title: Text('Claro'),
                          subtitle: Text('Tema claro siempre activo'),
                          value: 'light',
                        ),
                        Divider(height: 1),
                        RadioListTile<String>(
                          secondary: Icon(Icons.brightness_2),
                          title: Text('Oscuro'),
                          subtitle: Text('Tema oscuro siempre activo'),
                          value: 'dark',
                        ),
                        Divider(height: 1),
                        RadioListTile<String>(
                          secondary: Icon(Icons.brightness_auto),
                          title: Text('Automático'),
                          subtitle: Text('Según configuración del sistema'),
                          value: 'system',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 8),
                Text(
                  'El cambio de tema se aplica inmediatamente',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
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
