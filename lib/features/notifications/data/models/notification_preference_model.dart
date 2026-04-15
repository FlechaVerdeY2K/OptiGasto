import '../../domain/entities/notification_preference_entity.dart';

/// Model for notification preferences with JSON serialization
class NotificationPreferenceModel extends NotificationPreferenceEntity {
  const NotificationPreferenceModel({
    required super.userId,
    super.enablePromotionNearby,
    super.enablePromotionExpiring,
    super.enablePromotionNew,
    super.enableBadgeUnlocked,
    super.enableLevelUp,
    super.enableCommerceNew,
    super.enableSystem,
    super.radiusKm,
    super.enabledCategories,
    required super.updatedAt,
  });

  /// Create NotificationPreferenceModel from JSON
  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModel(
      userId: json['user_id'] as String,
      enablePromotionNearby: json['enable_promotion_nearby'] as bool? ?? true,
      enablePromotionExpiring:
          json['enable_promotion_expiring'] as bool? ?? true,
      enablePromotionNew: json['enable_promotion_new'] as bool? ?? true,
      enableBadgeUnlocked: json['enable_badge_unlocked'] as bool? ?? true,
      enableLevelUp: json['enable_level_up'] as bool? ?? true,
      enableCommerceNew: json['enable_commerce_new'] as bool? ?? true,
      enableSystem: json['enable_system'] as bool? ?? true,
      radiusKm: (json['radius_km'] as num?)?.toDouble() ?? 5.0,
      enabledCategories: json['enabled_categories'] != null
          ? List<String>.from(json['enabled_categories'] as List)
          : [],
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert NotificationPreferenceModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'enable_promotion_nearby': enablePromotionNearby,
      'enable_promotion_expiring': enablePromotionExpiring,
      'enable_promotion_new': enablePromotionNew,
      'enable_badge_unlocked': enableBadgeUnlocked,
      'enable_level_up': enableLevelUp,
      'enable_commerce_new': enableCommerceNew,
      'enable_system': enableSystem,
      'radius_km': radiusKm,
      'enabled_categories': enabledCategories,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create NotificationPreferenceModel from Entity
  factory NotificationPreferenceModel.fromEntity(
    NotificationPreferenceEntity entity,
  ) {
    return NotificationPreferenceModel(
      userId: entity.userId,
      enablePromotionNearby: entity.enablePromotionNearby,
      enablePromotionExpiring: entity.enablePromotionExpiring,
      enablePromotionNew: entity.enablePromotionNew,
      enableBadgeUnlocked: entity.enableBadgeUnlocked,
      enableLevelUp: entity.enableLevelUp,
      enableCommerceNew: entity.enableCommerceNew,
      enableSystem: entity.enableSystem,
      radiusKm: entity.radiusKm,
      enabledCategories: entity.enabledCategories,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to Entity
  NotificationPreferenceEntity toEntity() {
    return NotificationPreferenceEntity(
      userId: userId,
      enablePromotionNearby: enablePromotionNearby,
      enablePromotionExpiring: enablePromotionExpiring,
      enablePromotionNew: enablePromotionNew,
      enableBadgeUnlocked: enableBadgeUnlocked,
      enableLevelUp: enableLevelUp,
      enableCommerceNew: enableCommerceNew,
      enableSystem: enableSystem,
      radiusKm: radiusKm,
      enabledCategories: enabledCategories,
      updatedAt: updatedAt,
    );
  }

  @override
  NotificationPreferenceModel copyWith({
    String? userId,
    bool? enablePromotionNearby,
    bool? enablePromotionExpiring,
    bool? enablePromotionNew,
    bool? enableBadgeUnlocked,
    bool? enableLevelUp,
    bool? enableCommerceNew,
    bool? enableSystem,
    double? radiusKm,
    List<String>? enabledCategories,
    DateTime? updatedAt,
  }) {
    return NotificationPreferenceModel(
      userId: userId ?? this.userId,
      enablePromotionNearby:
          enablePromotionNearby ?? this.enablePromotionNearby,
      enablePromotionExpiring:
          enablePromotionExpiring ?? this.enablePromotionExpiring,
      enablePromotionNew: enablePromotionNew ?? this.enablePromotionNew,
      enableBadgeUnlocked: enableBadgeUnlocked ?? this.enableBadgeUnlocked,
      enableLevelUp: enableLevelUp ?? this.enableLevelUp,
      enableCommerceNew: enableCommerceNew ?? this.enableCommerceNew,
      enableSystem: enableSystem ?? this.enableSystem,
      radiusKm: radiusKm ?? this.radiusKm,
      enabledCategories: enabledCategories ?? this.enabledCategories,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Made with Bob
