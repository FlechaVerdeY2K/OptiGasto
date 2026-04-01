/// Constantes relacionadas con APIs y servicios externos
class ApiConstants {
  ApiConstants._();

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String promotionsCollection = 'promotions';
  static const String commercesCollection = 'commerces';
  static const String validationsCollection = 'validations';
  static const String categoriesCollection = 'categories';
  
  // Firebase Storage Paths
  static const String promotionImagesPath = 'promotions';
  static const String userAvatarsPath = 'avatars';
  static const String commerceLogosPath = 'commerces';
  
  // Google Maps
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // TODO: Configurar
  
  // Endpoints (si se usa API REST adicional)
  static const String baseUrl = 'https://api.optigasto.com';
  static const String apiVersion = 'v1';
  
  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
}

// Made with Bob
