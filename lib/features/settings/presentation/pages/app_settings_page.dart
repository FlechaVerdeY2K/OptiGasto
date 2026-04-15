import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/settings_bloc.dart';

/// Página principal de configuraciones de la aplicación
class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SettingsBloc>()..add(const LoadSettings()),
      child: const _AppSettingsPageContent(),
    );
  }
}

class _AppSettingsPageContent extends StatelessWidget {
  const _AppSettingsPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SettingsLoaded) {
            return ListView(
              children: [
                // Sección: Ubicación
                _buildSectionHeader('Ubicación y Búsqueda'),
                _buildSettingTile(
                  context: context,
                  icon: Icons.location_searching,
                  title: 'Preferencias de Ubicación',
                  subtitle: 'Radio de búsqueda, ubicaciones favoritas',
                  onTap: () => context.push('/settings/location'),
                ),
                const Divider(height: 1),

                // Sección: Contenido
                _buildSectionHeader('Contenido y Filtros'),
                _buildSettingTile(
                  context: context,
                  icon: Icons.filter_list,
                  title: 'Filtros de Contenido',
                  subtitle: 'Categorías, descuentos mínimos',
                  onTap: () => context.push('/settings/filters'),
                ),
                const Divider(height: 1),

                // Sección: Apariencia
                _buildSectionHeader('Apariencia'),
                _buildSettingTile(
                  context: context,
                  icon: Icons.palette_outlined,
                  title: 'Tema',
                  subtitle: 'Claro, oscuro o automático',
                  onTap: () => context.push('/settings/theme'),
                ),
                const Divider(height: 1),

                // Sección: Notificaciones
                _buildSectionHeader('Notificaciones'),
                _buildSettingTile(
                  context: context,
                  icon: Icons.notifications_outlined,
                  title: 'Notificaciones',
                  subtitle: 'Gestionar alertas y avisos',
                  onTap: () => context.push('/notification-settings'),
                ),
                const Divider(height: 1),

                // Sección: Privacidad
                _buildSectionHeader('Privacidad y Seguridad'),
                _buildSettingTile(
                  context: context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacidad',
                  subtitle: 'Visibilidad del perfil, compartir datos',
                  onTap: () => context.push('/settings/privacy'),
                ),
                const Divider(height: 1),

                // Sección: Acerca de
                _buildSectionHeader('Información'),
                _buildSettingTile(
                  context: context,
                  icon: Icons.info_outline,
                  title: 'Acerca de OptiGasto',
                  subtitle: 'Versión 0.1.0',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'OptiGasto',
                      applicationVersion: '0.1.0',
                      applicationIcon: const Icon(Icons.local_offer, size: 48),
                      children: [
                        const Text(
                          'Aplicación para encontrar ofertas y promociones geolocalizadas en Costa Rica.',
                        ),
                      ],
                    );
                  },
                ),
                _buildSettingTile(
                  context: context,
                  icon: Icons.help_outline,
                  title: 'Ayuda y Soporte',
                  subtitle: 'Preguntas frecuentes, contacto',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente')),
                    );
                  },
                ),
                const Divider(height: 1),

                // Botón de restablecer
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showResetDialog(context);
                    },
                    icon: const Icon(Icons.restore, color: Colors.red),
                    label: const Text(
                      'Restablecer Configuraciones',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restablecer Configuraciones'),
        content: const Text(
          '¿Estás seguro de que deseas restablecer todas las configuraciones a sus valores predeterminados?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SettingsBloc>().add(const ResetSettings());
            },
            child: const Text(
              'Restablecer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
