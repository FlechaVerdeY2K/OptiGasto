import 'package:equatable/equatable.dart';

/// Entity representing a user's loyalty status with a specific commerce
class CommerceLoyaltyEntity extends Equatable {
  final String id;
  final String userId;
  final String commerceId;
  final String commerceName;
  final int purchaseCount;
  final String tier;
  final double? discountPercentage;
  final DateTime? lastPurchaseAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommerceLoyaltyEntity({
    required this.id,
    required this.userId,
    required this.commerceId,
    required this.commerceName,
    required this.purchaseCount,
    required this.tier,
    this.discountPercentage,
    this.lastPurchaseAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        commerceId,
        commerceName,
        purchaseCount,
        tier,
        discountPercentage,
        lastPurchaseAt,
        createdAt,
        updatedAt,
      ];

  CommerceLoyaltyEntity copyWith({
    String? id,
    String? userId,
    String? commerceId,
    String? commerceName,
    int? purchaseCount,
    String? tier,
    double? discountPercentage,
    DateTime? lastPurchaseAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommerceLoyaltyEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      commerceId: commerceId ?? this.commerceId,
      commerceName: commerceName ?? this.commerceName,
      purchaseCount: purchaseCount ?? this.purchaseCount,
      tier: tier ?? this.tier,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      lastPurchaseAt: lastPurchaseAt ?? this.lastPurchaseAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get tier name in Spanish
  String get tierName {
    switch (tier) {
      case 'bronze':
        return 'Bronce';
      case 'silver':
        return 'Plata';
      case 'gold':
        return 'Oro';
      case 'platinum':
        return 'Platino';
      default:
        return tier;
    }
  }

  /// Get tier color
  String get tierColor {
    switch (tier) {
      case 'bronze':
        return '#CD7F32';
      case 'silver':
        return '#C0C0C0';
      case 'gold':
        return '#FFD700';
      case 'platinum':
        return '#E5E4E2';
      default:
        return '#808080';
    }
  }
}

// Made with Bob
