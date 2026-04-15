import 'package:equatable/equatable.dart';

/// Entity representing user notification preferences
class NotificationPreferenceEntity extends Equatable {
  final String userId;
  final bool enablePromotionNearby;
  final bool enablePromotionExpiring;
  final bool enablePromotionNew;
  final bool enableBadgeUnlocked;
  final bool enableLevelUp;
  final bool enableCommerceNew;
  final bool enableSystem;
  final double radiusKm;
  final List<String> enabledCategories;
  final DateTime updatedAt;

  const NotificationPreferenceEntity({
    required this.userId,
    this.enablePromotionNearby = true,
    this.enablePromotionExpiring = true,
    this.enablePromotionNew = true,
    this.enableBadgeUnlocked = true,
    this.enableLevelUp = true,
    this.enableCommerceNew = true,
    this.enableSystem = true,
    this.radiusKm = 5.0,
    this.enabledCategories = const [],
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        userId,
        enablePromotionNearby,
        enablePromotionExpiring,
        enablePromotionNew,
        enableBadgeUnlocked,
        enableLevelUp,
        enableCommerceNew,
        enableSystem,
        radiusKm,
        enabledCategories,
        updatedAt,
      ];

  NotificationPreferenceEntity copyWith({
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
    return NotificationPreferenceEntity(
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

  /// Check if a specific notification type is enabled
  bool isTypeEnabled(String type) {
    switch (type) {
      case 'promotion_nearby':
        return enablePromotionNearby;
      case 'promotion_expiring':
        return enablePromotionExpiring;
      case 'promotion_new':
        return enablePromotionNew;
      case 'badge_unlocked':
        return enableBadgeUnlocked;
      case 'level_up':
        return enableLevelUp;
      case 'commerce_new':
        return enableCommerceNew;
      case 'system':
        return enableSystem;
      default:
        return false;
    }
  }

  /// Check if all notifications are enabled
  bool get allEnabled =>
      enablePromotionNearby &&
      enablePromotionExpiring &&
      enablePromotionNew &&
      enableBadgeUnlocked &&
      enableLevelUp &&
      enableCommerceNew &&
      enableSystem;

  /// Check if all notifications are disabled
  bool get allDisabled =>
      !enablePromotionNearby &&
      !enablePromotionExpiring &&
      !enablePromotionNew &&
      !enableBadgeUnlocked &&
      !enableLevelUp &&
      !enableCommerceNew &&
      !enableSystem;
}

// Made with Bob
