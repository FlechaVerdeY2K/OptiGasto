import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/settings_bloc.dart';

class PrivacySettingsPage extends StatelessWidget {
  const PrivacySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SettingsBloc>()..add(const LoadSettings()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Privacidad'),
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
                    title: const Text('Perfil Público'),
                    subtitle: const Text('Otros usuarios pueden ver tu perfil'),
                    value: settings.profileVisibility,
                    onChanged: (value) {
                      final updated = settings.copyWith(profileVisibility: value);
                      context.read<SettingsBloc>().add(UpdateSettings(updated));
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Compartir Estadísticas'),
                    subtitle: const Text('Mostrar tus estadísticas de ahorro'),
                    value: settings.shareStatistics,
                    onChanged: (value) {
                      final updated = settings.copyWith(shareStatistics: value);
                      context.read<SettingsBloc>().add(UpdateSettings(updated));
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Mostrar Mis Promociones'),
                    subtitle: const Text('Otros pueden ver las promociones que publicas'),
                    value: settings.showMyPromotions,
                    onChanged: (value) {
                      final updated = settings.copyWith(showMyPromotions: value);
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