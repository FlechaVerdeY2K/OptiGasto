import 'package:equatable/equatable.dart';

/// Entidad que representa todas las configuraciones de la aplicación
class AppSettingsEntity extends Equatable {
  // Preferencias de Ubicación
  final double searchRadius; // en kilómetros
  final bool autoLocation;
  final String distanceUnit; // 'km' o 'miles'

  // Filtros de Contenido
  final List<String> interestedCategories;
  final double minDiscountPercentage;
  final bool hideExpiredPromotions;

  // Apariencia
  final String themeMode; // 'light', 'dark', 'system'
  final String fontSize; // 'small', 'medium', 'large'
  final String listDensity; // 'compact', 'comfortable', 'spacious'

  // Privacidad
  final bool profileVisibility; // público/privado
  final bool shareStatistics;
  final bool showMyPromotions;

  // Gestión de Datos
  final bool useMobileDataForImages;
  final String imageQuality; // 'high', 'medium', 'low'
  final bool offlineMapsCache;
  final bool autoSync;

  // Notificaciones (ya existente, pero lo incluimos aquí)
  final bool notificationsEnabled;
  final bool nearbyPromotionsNotif;
  final bool favoritesNotif;
  final bool newPromotionsNotif;

  const AppSettingsEntity({
    // Ubicación
    this.searchRadius = 5.0,
    this.autoLocation = true,
    this.distanceUnit = 'km',

    // Filtros
    this.interestedCategories = const [],
    this.minDiscountPercentage = 0.0,
    this.hideExpiredPromotions = true,

    // Apariencia
    this.themeMode = 'system',
    this.fontSize = 'medium',
    this.listDensity = 'comfortable',

    // Privacidad
    this.profileVisibility = true,
    this.shareStatistics = true,
    this.showMyPromotions = true,

    // Datos
    this.useMobileDataForImages = true,
    this.imageQuality = 'medium',
    this.offlineMapsCache = false,
    this.autoSync = true,

    // Notificaciones
    this.notificationsEnabled = true,
    this.nearbyPromotionsNotif = true,
    this.favoritesNotif = true,
    this.newPromotionsNotif = true,
  });

  AppSettingsEntity copyWith({
    double? searchRadius,
    bool? autoLocation,
    String? distanceUnit,
    List<String>? interestedCategories,
    double? minDiscountPercentage,
    bool? hideExpiredPromotions,
    String? themeMode,
    String? fontSize,
    String? listDensity,
    bool? profileVisibility,
    bool? shareStatistics,
    bool? showMyPromotions,
    bool? useMobileDataForImages,
    String? imageQuality,
    bool? offlineMapsCache,
    bool? autoSync,
    bool? notificationsEnabled,
    bool? nearbyPromotionsNotif,
    bool? favoritesNotif,
    bool? newPromotionsNotif,
  }) {
    return AppSettingsEntity(
      searchRadius: searchRadius ?? this.searchRadius,
      autoLocation: autoLocation ?? this.autoLocation,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      interestedCategories: interestedCategories ?? this.interestedCategories,
      minDiscountPercentage:
          minDiscountPercentage ?? this.minDiscountPercentage,
      hideExpiredPromotions:
          hideExpiredPromotions ?? this.hideExpiredPromotions,
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      listDensity: listDensity ?? this.listDensity,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      shareStatistics: shareStatistics ?? this.shareStatistics,
      showMyPromotions: showMyPromotions ?? this.showMyPromotions,
      useMobileDataForImages:
          useMobileDataForImages ?? this.useMobileDataForImages,
      imageQuality: imageQuality ?? this.imageQuality,
      offlineMapsCache: offlineMapsCache ?? this.offlineMapsCache,
      autoSync: autoSync ?? this.autoSync,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      nearbyPromotionsNotif:
          nearbyPromotionsNotif ?? this.nearbyPromotionsNotif,
      favoritesNotif: favoritesNotif ?? this.favoritesNotif,
      newPromotionsNotif: newPromotionsNotif ?? this.newPromotionsNotif,
    );
  }

  @override
  List<Object?> get props => [
        searchRadius,
        autoLocation,
        distanceUnit,
        interestedCategories,
        minDiscountPercentage,
        hideExpiredPromotions,
        themeMode,
        fontSize,
        listDensity,
        profileVisibility,
        shareStatistics,
        showMyPromotions,
        useMobileDataForImages,
        imageQuality,
        offlineMapsCache,
        autoSync,
        notificationsEnabled,
        nearbyPromotionsNotif,
        favoritesNotif,
        newPromotionsNotif,
      ];
}

// Made with Bob
