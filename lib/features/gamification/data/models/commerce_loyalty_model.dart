import '../../domain/entities/commerce_loyalty_entity.dart';

/// Model for commerce loyalty in the data layer
class CommerceLoyaltyModel extends CommerceLoyaltyEntity {
  const CommerceLoyaltyModel({
    required super.id,
    required super.userId,
    required super.commerceId,
    required super.commerceName,
    required super.purchaseCount,
    required super.tier,
    super.discountPercentage,
    super.lastPurchaseAt,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a CommerceLoyaltyModel from Supabase JSON
  factory CommerceLoyaltyModel.fromJson(Map<String, dynamic> json) {
    return CommerceLoyaltyModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      commerceId: json['commerce_id'] as String,
      commerceName: json['commerce_name'] as String,
      purchaseCount: (json['purchase_count'] as num).toInt(),
      tier: json['tier'] as String,
      discountPercentage: json['discount_percentage'] != null
          ? (json['discount_percentage'] as num).toDouble()
          : null,
      lastPurchaseAt: json['last_purchase_at'] != null
          ? DateTime.parse(json['last_purchase_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts the CommerceLoyaltyModel to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'commerce_id': commerceId,
      'commerce_name': commerceName,
      'purchase_count': purchaseCount,
      'tier': tier,
      'discount_percentage': discountPercentage,
      'last_purchase_at': lastPurchaseAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Converts the CommerceLoyaltyModel to CommerceLoyaltyEntity
  CommerceLoyaltyEntity toEntity() {
    return CommerceLoyaltyEntity(
      id: id,
      userId: userId,
      commerceId: commerceId,
      commerceName: commerceName,
      purchaseCount: purchaseCount,
      tier: tier,
      discountPercentage: discountPercentage,
      lastPurchaseAt: lastPurchaseAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

// Made with Bob
