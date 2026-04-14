/// Configuración de Supabase para OptiGasto
///
/// Las credenciales se inyectan en tiempo de compilación con:
///   flutter run --dart-define-from-file=.env
///   flutter build apk --dart-define-from-file=.env
///
/// Nunca hardcodear valores reales aquí.
class SupabaseConfig {
  /// URL del proyecto Supabase (inyectada vía --dart-define-from-file=.env)
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');

  /// Anon/Public key del proyecto Supabase (inyectada vía --dart-define-from-file=.env)
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  
  /// Configuración de autenticación
  static const bool persistSession = true;
  static const bool autoRefreshToken = true;
  
  /// Configuración de almacenamiento
  static const String storageUrl = '$supabaseUrl/storage/v1';
  
  /// Nombres de las tablas en Supabase
  static const String usersTable = 'users';
  static const String promotionsTable = 'promotions';
  static const String categoriesTable = 'categories';
  static const String commercesTable = 'commerces';
  static const String savedPromotionsTable = 'saved_promotions';
  static const String reportsTable = 'reports';
  
  /// Nombres de los buckets de almacenamiento
  static const String promotionImagesBucket = 'promotion-images';
  static const String promotionsBucket = 'promotions'; // Bucket principal para promociones
  static const String userAvatarsBucket = 'user-avatars';
  static const String commerceLogosBucket = 'commerce-logos';
}

// Made with Bob