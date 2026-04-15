import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/app_settings_entity.dart';

/// Servicio para gestionar las configuraciones de la aplicación
class SettingsService {
  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  // Keys
  static const String _searchRadiusKey = 'search_radius';
  static const String _autoLocationKey = 'auto_location';
  static const String _distanceUnitKey = 'distance_unit';
  static const String _interestedCategoriesKey = 'interested_categories';
  static const String _minDiscountKey = 'min_discount';
  static const String _hideExpiredKey = 'hide_expired';
  static const String _themeModeKey = 'theme_mode';
  static const String _fontSizeKey = 'font_size';
  static const String _listDensityKey = 'list_density';
  static const String _profileVisibilityKey = 'profile_visibility';
  static const String _shareStatsKey = 'share_stats';
  static const String _showPromotionsKey = 'show_promotions';
  static const String _useMobileDataKey = 'use_mobile_data';
  static const String _imageQualityKey = 'image_quality';
  static const String _offlineCacheKey = 'offline_cache';
  static const String _autoSyncKey = 'auto_sync';

  /// Obtener configuraciones actuales
  AppSettingsEntity getSettings() {
    return AppSettingsEntity(
      searchRadius: _prefs.getDouble(_searchRadiusKey) ?? 5.0,
      autoLocation: _prefs.getBool(_autoLocationKey) ?? true,
      distanceUnit: _prefs.getString(_distanceUnitKey) ?? 'km',
      interestedCategories:
          _prefs.getStringList(_interestedCategoriesKey) ?? [],
      minDiscountPercentage: _prefs.getDouble(_minDiscountKey) ?? 0.0,
      hideExpiredPromotions: _prefs.getBool(_hideExpiredKey) ?? true,
      themeMode: _prefs.getString(_themeModeKey) ?? 'system',
      fontSize: _prefs.getString(_fontSizeKey) ?? 'medium',
      listDensity: _prefs.getString(_listDensityKey) ?? 'comfortable',
      profileVisibility: _prefs.getBool(_profileVisibilityKey) ?? true,
      shareStatistics: _prefs.getBool(_shareStatsKey) ?? true,
      showMyPromotions: _prefs.getBool(_showPromotionsKey) ?? true,
      useMobileDataForImages: _prefs.getBool(_useMobileDataKey) ?? true,
      imageQuality: _prefs.getString(_imageQualityKey) ?? 'medium',
      offlineMapsCache: _prefs.getBool(_offlineCacheKey) ?? false,
      autoSync: _prefs.getBool(_autoSyncKey) ?? true,
    );
  }

  /// Guardar configuraciones
  Future<void> saveSettings(AppSettingsEntity settings) async {
    await Future.wait([
      _prefs.setDouble(_searchRadiusKey, settings.searchRadius),
      _prefs.setBool(_autoLocationKey, settings.autoLocation),
      _prefs.setString(_distanceUnitKey, settings.distanceUnit),
      _prefs.setStringList(
          _interestedCategoriesKey, settings.interestedCategories),
      _prefs.setDouble(_minDiscountKey, settings.minDiscountPercentage),
      _prefs.setBool(_hideExpiredKey, settings.hideExpiredPromotions),
      _prefs.setString(_themeModeKey, settings.themeMode),
      _prefs.setString(_fontSizeKey, settings.fontSize),
      _prefs.setString(_listDensityKey, settings.listDensity),
      _prefs.setBool(_profileVisibilityKey, settings.profileVisibility),
      _prefs.setBool(_shareStatsKey, settings.shareStatistics),
      _prefs.setBool(_showPromotionsKey, settings.showMyPromotions),
      _prefs.setBool(_useMobileDataKey, settings.useMobileDataForImages),
      _prefs.setString(_imageQualityKey, settings.imageQuality),
      _prefs.setBool(_offlineCacheKey, settings.offlineMapsCache),
      _prefs.setBool(_autoSyncKey, settings.autoSync),
    ]);
  }

  /// Actualizar radio de búsqueda
  Future<void> updateSearchRadius(double radius) async {
    await _prefs.setDouble(_searchRadiusKey, radius);
  }

  /// Actualizar tema
  Future<void> updateThemeMode(String mode) async {
    await _prefs.setString(_themeModeKey, mode);
  }

  /// Actualizar categorías de interés
  Future<void> updateInterestedCategories(List<String> categories) async {
    await _prefs.setStringList(_interestedCategoriesKey, categories);
  }

  /// Resetear a valores por defecto
  Future<void> resetToDefaults() async {
    await Future.wait([
      _prefs.remove(_searchRadiusKey),
      _prefs.remove(_autoLocationKey),
      _prefs.remove(_distanceUnitKey),
      _prefs.remove(_interestedCategoriesKey),
      _prefs.remove(_minDiscountKey),
      _prefs.remove(_hideExpiredKey),
      _prefs.remove(_themeModeKey),
      _prefs.remove(_fontSizeKey),
      _prefs.remove(_listDensityKey),
      _prefs.remove(_profileVisibilityKey),
      _prefs.remove(_shareStatsKey),
      _prefs.remove(_showPromotionsKey),
      _prefs.remove(_useMobileDataKey),
      _prefs.remove(_imageQualityKey),
      _prefs.remove(_offlineCacheKey),
      _prefs.remove(_autoSyncKey),
    ]);
  }
}

// Made with Bob
