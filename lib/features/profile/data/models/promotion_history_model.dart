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
      id: (json['id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      promotionId: (json['promotion_id'] as String?) ?? '',
      promotionTitle: (json['promotion_title'] as String?) ?? '',
      commerceName: (json['commerce_name'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      savingsAmount: (json['savings_amount'] as num?)?.toDouble() ?? 0.0,
      usedAt: json['used_at'] != null
          ? DateTime.parse(json['used_at'] as String)
          : DateTime.now(),
      notes: json['notes'] as String?,
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
