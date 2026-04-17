import '../../domain/entities/user_badge_entity.dart';

/// Model for user badge in the data layer
class UserBadgeModel extends UserBadgeEntity {
  const UserBadgeModel({
    required super.id,
    required super.userId,
    required super.badgeId,
    required super.unlockedAt,
    super.progress,
  });

  /// Creates a UserBadgeModel from Supabase JSON
  factory UserBadgeModel.fromJson(Map<String, dynamic> json) {
    return UserBadgeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      badgeId: json['badge_id'] as String,
      unlockedAt: DateTime.parse(json['unlocked_at'] as String),
      progress: json['progress'] as int?,
    );
  }

  /// Converts the UserBadgeModel to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'badge_id': badgeId,
      'unlocked_at': unlockedAt.toIso8601String(),
      'progress': progress,
    };
  }

  /// Converts the UserBadgeModel to UserBadgeEntity
  UserBadgeEntity toEntity() {
    return UserBadgeEntity(
      id: id,
      userId: userId,
      badgeId: badgeId,
      unlockedAt: unlockedAt,
      progress: progress,
    );
  }
}

// Made with Bob
