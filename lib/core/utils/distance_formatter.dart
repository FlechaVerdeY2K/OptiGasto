import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';

/// Formatea la distancia según la unidad configurada en settings
class DistanceFormatter {
  /// Formatea una distancia en kilómetros según la configuración del usuario
  static String format(BuildContext context, double distanceKm) {
    final settingsBloc = context.read<SettingsBloc>();
    final settingsState = settingsBloc.state;
    
    if (settingsState is SettingsLoaded) {
      if (settingsState.settings.distanceUnit == 'miles') {
        final miles = distanceKm * 0.621371;
        return '${miles.toStringAsFixed(1)} mi';
      }
    }
    
    return '${distanceKm.toStringAsFixed(1)} km';
  }
  
  /// Convierte kilómetros a la unidad configurada
  static double convert(BuildContext context, double distanceKm) {
    final settingsBloc = context.read<SettingsBloc>();
    final settingsState = settingsBloc.state;
    
    if (settingsState is SettingsLoaded) {
      if (settingsState.settings.distanceUnit == 'miles') {
        return distanceKm * 0.621371;
      }
    }
    
    return distanceKm;
  }
  
  /// Obtiene el símbolo de la unidad configurada
  static String getUnit(BuildContext context) {
    final settingsBloc = context.read<SettingsBloc>();
    final settingsState = settingsBloc.state;
    
    if (settingsState is SettingsLoaded) {
      return settingsState.settings.distanceUnit == 'miles' ? 'mi' : 'km';
    }
    
    return 'km';
  }
}

// Made with Bob
