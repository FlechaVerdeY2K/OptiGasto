import 'package:equatable/equatable.dart';

/// Entity representing a badge in the gamification system
class BadgeEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String category;
  final Map<String, dynamic> unlockConditions;
  final int displayOrder;
  final DateTime createdAt;

  const BadgeEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.category,
    required this.unlockConditions,
    required this.displayOrder,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconUrl,
        category,
        unlockConditions,
        displayOrder,
        createdAt,
      ];

  /// Alias for iconUrl (widget compatibility)
  String get icon => iconUrl;

  /// Default rarity for display purposes
  String get rarity => _computeRarity();

  String _computeRarity() {
    final order = displayOrder;
    if (order <= 3) return 'common';
    if (order <= 7) return 'rare';
    if (order <= 12) return 'epic';
    return 'legendary';
  }

  BadgeEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    String? category,
    Map<String, dynamic>? unlockConditions,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return BadgeEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      category: category ?? this.category,
      unlockConditions: unlockConditions ?? this.unlockConditions,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Made with Bob
