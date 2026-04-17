import '../../domain/entities/badge_entity.dart';

/// Model for badge in the data layer
class BadgeModel extends BadgeEntity {
  const BadgeModel({
    required super.id,
    required super.name,
    required super.description,
    required super.iconUrl,
    required super.category,
    required super.unlockConditions,
    required super.displayOrder,
    required super.createdAt,
  });

  /// Creates a BadgeModel from Supabase JSON
  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      // DB column is 'icon', entity field is 'iconUrl'
      iconUrl: (json['icon_url'] ?? json['icon'] ?? '') as String,
      category: json['category'] as String,
      // DB column is 'unlock_condition' (singular)
      unlockConditions: Map<String, dynamic>.from((json['unlock_conditions'] ??
          json['unlock_condition'] ??
          <String, dynamic>{}) as Map<String, dynamic>),
      // DB has no display_order — derive from created_at ordering
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts the BadgeModel to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'category': category,
      'unlock_conditions': unlockConditions,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Converts the BadgeModel to BadgeEntity
  BadgeEntity toEntity() {
    return BadgeEntity(
      id: id,
      name: name,
      description: description,
      iconUrl: iconUrl,
      category: category,
      unlockConditions: unlockConditions,
      displayOrder: displayOrder,
      createdAt: createdAt,
    );
  }
}

// Made with Bob
