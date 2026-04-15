/// Constantes generales de la aplicación OptiGasto
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'OptiGasto';
  static const String appVersion = '0.1.0';
  static const String appDescription =
      'Encuentra ofertas y promociones cerca de ti';

  // Configuración
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxPromotionImages = 5;
  static const int defaultRadius = 5000; // 5km en metros
  static const int maxRadius = 50000; // 50km en metros

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Paginación
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100;

  // Validación
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minPromotionTitleLength = 5;
  static const int maxPromotionTitleLength = 100;
  static const int maxPromotionDescriptionLength = 500;

  // Gamificación
  static const int pointsPerPromotion = 10;
  static const int pointsPerValidation = 5;
  static const int pointsPerReport = 3;

  // Notificaciones
  static const String notificationChannelId = 'optigasto_channel';
  static const String notificationChannelName = 'OptiGasto Notifications';
  static const String notificationChannelDescription =
      'Notificaciones de promociones y ofertas';
}

// Made with Bob
