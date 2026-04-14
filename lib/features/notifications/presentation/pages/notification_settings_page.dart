import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_preference_entity.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

/// Page for managing notification settings
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(const LoadNotificationPreferences());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Notificaciones'),
        elevation: 0,
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationPreferencesUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Preferencias actualizadas'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationPreferencesLoaded ||
              state is NotificationPreferencesUpdated) {
            final preferences = state is NotificationPreferencesLoaded
                ? state.preferences
                : (state as NotificationPreferencesUpdated).preferences;

            return _buildSettingsContent(context, preferences);
          }

          return const Center(
            child: Text('No se pudieron cargar las preferencias'),
          );
        },
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    NotificationPreferenceEntity preferences,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Tipos de Notificaciones'),
        const SizedBox(height: 8),
        _buildNotificationToggle(
          context,
          title: 'Promociones Cercanas',
          subtitle: 'Recibe alertas de ofertas cerca de ti',
          icon: Icons.location_on,
          value: preferences.enablePromotionNearby,
          onChanged: (value) => _updatePreference(
            context,
            preferences.copyWith(enablePromotionNearby: value),
          ),
        ),
        _buildNotificationToggle(
          context,
          title: 'Promociones por Vencer',
          subtitle: 'Alertas de promociones que están por expirar',
          icon: Icons.access_time,
          value: preferences.enablePromotionExpiring,
          onChanged: (value) => _updatePreference(
            context,
            preferences.copyWith(enablePromotionExpiring: value),
          ),
        ),
        _buildNotificationToggle(
          context,
          title: 'Nuevas Promociones',
          subtitle: 'Notificaciones de promociones recién publicadas',
          icon: Icons.new_releases,
          value: preferences.enablePromotionNew,
          onChanged: (value) => _updatePreference(
            context,
            preferences.copyWith(enablePromotionNew: value),
          ),
        ),
        _buildNotificationToggle(
          context,
          title: 'Nuevos Comercios',
          subtitle: 'Alertas cuando se registran nuevos comercios',
          icon: Icons.store,
          value: preferences.enableCommerceNew,
          onChanged: (value) => _updatePreference(
            context,
            preferences.copyWith(enableCommerceNew: value),
          ),
        ),
        const Divider(height: 32),
        _buildSectionHeader('Gamificación'),
        const SizedBox(height: 8),
        _buildNotificationToggle(
          context,
          title: 'Insignias Desbloqueadas',
          subtitle: 'Notificaciones cuando desbloqueas logros',
          icon: Icons.emoji_events,
          value: preferences.enableBadgeUnlocked,
          onChanged: (value) => _updatePreference(
            context,
            preferences.copyWith(enableBadgeUnlocked: value),
          ),
        ),
        _buildNotificationToggle(
          context,
          title: 'Subida de Nivel',
          subtitle: 'Alertas cuando subes de nivel',
          icon: Icons.trending_up,
          value: preferences.enableLevelUp,
          onChanged: (value) => _updatePreference(
            context,
            preferences.copyWith(enableLevelUp: value),
          ),
        ),
        const Divider(height: 32),
        _buildSectionHeader('Sistema'),
        const SizedBox(height: 8),
        _buildNotificationToggle(
          context,
          title: 'Notificaciones del Sistema',
          subtitle: 'Actualizaciones y mensajes importantes',
          icon: Icons.notifications_active,
          value: preferences.enableSystem,
          onChanged: (value) => _updatePreference(
            context,
            preferences.copyWith(enableSystem: value),
          ),
        ),
        const Divider(height: 32),
        _buildSectionHeader('Radio de Búsqueda'),
        const SizedBox(height: 16),
        _buildRadiusSlider(context, preferences),
        const SizedBox(height: 32),
        _buildQuickActions(context, preferences),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildNotificationToggle(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon, color: Theme.of(context).primaryColor),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildRadiusSlider(
    BuildContext context,
    NotificationPreferenceEntity preferences,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Radio de notificaciones',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${preferences.radiusKm.toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: preferences.radiusKm,
              min: 1.0,
              max: 20.0,
              divisions: 19,
              label: '${preferences.radiusKm.toStringAsFixed(1)} km',
              onChanged: (value) => _updatePreference(
                context,
                preferences.copyWith(radiusKm: value),
              ),
            ),
            const Text(
              'Define el radio para recibir notificaciones de promociones cercanas',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    NotificationPreferenceEntity preferences,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _enableAll(context, preferences),
            icon: const Icon(Icons.check_circle),
            label: const Text('Activar Todas'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _disableAll(context, preferences),
            icon: const Icon(Icons.cancel),
            label: const Text('Desactivar Todas'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _updatePreference(
    BuildContext context,
    NotificationPreferenceEntity preferences,
  ) {
    context.read<NotificationBloc>().add(
          UpdateNotificationPreferencesEvent(preferences),
        );
  }

  void _enableAll(
    BuildContext context,
    NotificationPreferenceEntity preferences,
  ) {
    final updatedPreferences = preferences.copyWith(
      enablePromotionNearby: true,
      enablePromotionExpiring: true,
      enablePromotionNew: true,
      enableBadgeUnlocked: true,
      enableLevelUp: true,
      enableCommerceNew: true,
      enableSystem: true,
      updatedAt: DateTime.now(),
    );
    _updatePreference(context, updatedPreferences);
  }

  void _disableAll(
    BuildContext context,
    NotificationPreferenceEntity preferences,
  ) {
    final updatedPreferences = preferences.copyWith(
      enablePromotionNearby: false,
      enablePromotionExpiring: false,
      enablePromotionNew: false,
      enableBadgeUnlocked: false,
      enableLevelUp: false,
      enableCommerceNew: false,
      enableSystem: false,
      updatedAt: DateTime.now(),
    );
    _updatePreference(context, updatedPreferences);
  }
}

// Made with Bob
