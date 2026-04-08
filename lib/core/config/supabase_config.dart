/// Configuración de Supabase para OptiGasto
/// 
/// IMPORTANTE: Debes reemplazar estos valores con los de tu proyecto de Supabase
/// Los puedes encontrar en: https://app.supabase.com/project/_/settings/api
class SupabaseConfig {
  /// URL de tu proyecto de Supabase
  /// Ejemplo: https://xyzcompany.supabase.co
  static const String supabaseUrl = 'https://xbdvrhzthyyqjyshzehg.supabase.co';
  
  /// Anon/Public key de tu proyecto de Supabase
  /// Esta key es segura para usar en el cliente
  static const String supabaseAnonKey = 'sb_publishable_L4EHYgveDUNeFXnq3S3xRw_BkcJpHW-';
  
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