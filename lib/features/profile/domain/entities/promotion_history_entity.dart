import 'package:equatable/equatable.dart';

/// Entidad que representa el historial de una promoción usada
class PromotionHistoryEntity extends Equatable {
  final String id;
  final String userId;
  final String promotionId;
  final String promotionTitle;
  final String commerceName;
  final String category;
  final double savingsAmount;
  final DateTime usedAt;
  final String? notes;

  const PromotionHistoryEntity({
    required this.id,
    required this.userId,
    required this.promotionId,
    required this.promotionTitle,
    required this.commerceName,
    required this.category,
    required this.savingsAmount,
    required this.usedAt,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        promotionId,
        promotionTitle,
        commerceName,
        category,
        savingsAmount,
        usedAt,
        notes,
      ];

  PromotionHistoryEntity copyWith({
    String? id,
    String? userId,
    String? promotionId,
    String? promotionTitle,
    String? commerceName,
    String? category,
    double? savingsAmount,
    DateTime? usedAt,
    String? notes,
  }) {
    return PromotionHistoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      promotionId: promotionId ?? this.promotionId,
      promotionTitle: promotionTitle ?? this.promotionTitle,
      commerceName: commerceName ?? this.commerceName,
      category: category ?? this.category,
      savingsAmount: savingsAmount ?? this.savingsAmount,
      usedAt: usedAt ?? this.usedAt,
      notes: notes ?? this.notes,
    );
  }
}

// Made with Bob