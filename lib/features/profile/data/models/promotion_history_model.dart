import '../../domain/entities/promotion_history_entity.dart';

/// Modelo de historial de promoción para la capa de datos
class PromotionHistoryModel extends PromotionHistoryEntity {
  const PromotionHistoryModel({
    required super.id,
    required super.userId,
    required super.promotionId,
    required super.promotionTitle,
    required super.commerceName,
    required super.category,
    required super.savingsAmount,
    required super.usedAt,
    super.notes,
  });

  /// Crea un PromotionHistoryModel desde un Map de Supabase
  factory PromotionHistoryModel.fromJson(Map<String, dynamic> json) {
    return PromotionHistoryModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      promotionId: json['promotion_id'] ?? '',
      promotionTitle: json['promotion_title'] ?? '',
      commerceName: json['commerce_name'] ?? '',
      category: json['category'] ?? '',
      savingsAmount: (json['savings_amount'] as num?)?.toDouble() ?? 0.0,
      usedAt: json['used_at'] != null
          ? DateTime.parse(json['used_at'])
          : DateTime.now(),
      notes: json['notes'],
    );
  }

  /// Convierte el PromotionHistoryModel a un Map para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'promotion_id': promotionId,
      'promotion_title': promotionTitle,
      'commerce_name': commerceName,
      'category': category,
      'savings_amount': savingsAmount,
      'used_at': usedAt.toIso8601String(),
      'notes': notes,
    };
  }

  /// Convierte el PromotionHistoryModel a PromotionHistoryEntity
  PromotionHistoryEntity toEntity() {
    return PromotionHistoryEntity(
      id: id,
      userId: userId,
      promotionId: promotionId,
      promotionTitle: promotionTitle,
      commerceName: commerceName,
      category: category,
      savingsAmount: savingsAmount,
      usedAt: usedAt,
      notes: notes,
    );
  }
}

// Made with Bob
