// lib/core/config/directions_config.dart

/// Configuración de Google Maps Directions API.
///
/// La key se inyecta en tiempo de compilación:
///   flutter run --dart-define-from-file=.env
///
/// Nunca hardcodear la key aquí.
class DirectionsConfig {
  static const String _apiKey =
      String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');

  /// Devuelve la API key. Lanza Exception si no está configurada.
  static String get apiKey {
    if (_apiKey.isEmpty) {
      throw Exception(
        'GOOGLE_MAPS_API_KEY no configurada. '
        'Correr con --dart-define-from-file=.env',
      );
    }
    return _apiKey;
  }
}
