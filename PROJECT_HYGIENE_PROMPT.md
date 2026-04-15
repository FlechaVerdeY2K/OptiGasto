There were some issues with the workflows created. 

in CI / Quality Gates (Pull request): 


This is the same issue as job 71500614614. The failure is caused by deprecated Flutter API usage in theme_settings_page.dart.
Root Cause

Job 71500617967 fails at the dart format --set-exit-if-changed . step due to 68 linting issues, specifically:

    groupValue property on RadioListTile (deprecated after v3.32.0)
    onChanged property on RadioListTile (deprecated after v3.32.0)

Solution

Update lib/features/settings/presentation/pages/theme_settings_page.dart to use RadioGroup:
Dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/settings_bloc.dart';

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
                    value: settings.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsBloc>().add(
                              UpdateThemeMode(value),
                            );
                      }
                    },
                    children: [
                      RadioListTile<String>(
                        secondary: const Icon(Icons.brightness_5),
                        title: const Text('Claro'),
                        subtitle: const Text('Tema claro siempre activo'),
                        value: 'light',
                      ),
                      const Divider(height: 1),
                      RadioListTile<String>(
                        secondary: const Icon(Icons.brightness_2),
                        title: const Text('Oscuro'),
                        subtitle: const Text('Tema oscuro siempre activo'),
                        value: 'dark',
                      ),
                      const Divider(height: 1),
                      RadioListTile<String>(
                        secondary: const Icon(Icons.brightness_auto),
                        title: const Text('Automático'),
                        subtitle: const Text('Según configuración del sistema'),
                        value: 'system',
                      ),
                    ],
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

Key Changes

    Wrap the three RadioListTile widgets with RadioGroup<String>
    Move value and onChanged callback to the RadioGroup level
    Remove the individual groupValue and onChanged properties from each RadioListTile

This resolves all deprecated API warnings and allows the CI workflow to pass.

In CI / Quality Gates (push):

Solution for Failing Job 71500614614

The job failed during the dart format --set-exit-if-changed . step because the code contains deprecated Flutter API usage that violates formatting/linting standards.
Root Cause

The theme_settings_page.dart file uses deprecated RadioListTile properties:

    groupValue (deprecated after v3.32.0)
    onChanged (deprecated after v3.32.0)

These should be replaced with a RadioGroup ancestor to manage the group value instead.
Solution

Update lib/features/settings/presentation/pages/theme_settings_page.dart to use RadioGroup with modern Flutter APIs:
Dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/settings_bloc.dart';

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
                    value: settings.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        context.read<SettingsBloc>().add(
                              UpdateThemeMode(value),
                            );
                      }
                    },
                    children: [
                      RadioListTile<String>(
                        secondary: const Icon(Icons.brightness_5),
                        title: const Text('Claro'),
                        subtitle: const Text('Tema claro siempre activo'),
                        value: 'light',
                      ),
                      const Divider(height: 1),
                      RadioListTile<String>(
                        secondary: const Icon(Icons.brightness_2),
                        title: const Text('Oscuro'),
                        subtitle: const Text('Tema oscuro siempre activo'),
                        value: 'dark',
                      ),
                      const Divider(height: 1),
                      RadioListTile<String>(
                        secondary: const Icon(Icons.brightness_auto),
                        title: const Text('Automático'),
                        subtitle: const Text('Según configuración del sistema'),
                        value: 'system',
                      ),
                    ],
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

Key Changes

    Wrap RadioListTile widgets with RadioGroup
    Move value and onChanged to the RadioGroup level
    Remove groupValue and individual onChanged callbacks from each RadioListTile

This will resolve all 68 linting issues and allow the CI workflow to pass the dart format --set-exit-if-changed . check.
