import '../../domain/entities/user_stats_entity.dart';

/// Modelo de estadísticas de usuario para la capa de datos
class UserStatsModel extends UserStatsEntity {
  const UserStatsModel({
    required super.userId,
    required super.totalSavings,
    required super.promotionsUsed,
    required super.promotionsPublished,
    required super.validationsGiven,
    required super.reportsSubmitted,
    required super.savingsByCategory,
    required super.promotionsByMonth,
    required super.lastUpdated,
  });

  /// Crea un UserStatsModel desde un Map de Supabase
  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      userId: (json['user_id'] as String?) ?? '',
      totalSavings: (json['total_savings'] as num?)?.toDouble() ?? 0.0,
      promotionsUsed: (json['promotions_used'] as num?)?.toInt() ?? 0,
      promotionsPublished: (json['promotions_published'] as num?)?.toInt() ?? 0,
      validationsGiven: (json['validations_given'] as num?)?.toInt() ?? 0,
      reportsSubmitted: (json['reports_submitted'] as num?)?.toInt() ?? 0,
      savingsByCategory: json['savings_by_category'] != null
          ? Map<String, double>.from(
              (json['savings_by_category'] as Map).map(
                (key, value) => MapEntry(
                  key.toString(),
                  (value as num).toDouble(),
                ),
              ),
            )
          : {},
      promotionsByMonth: json['promotions_by_month'] != null
          ? Map<String, int>.from(
              (json['promotions_by_month'] as Map).map(
                (key, value) => MapEntry(
                  key.toString(),
                  (value as num).toInt(),
                ),
              ),
            )
          : {},
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : DateTime.now(),
    );
  }

  /// Convierte el UserStatsModel a un Map para Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_savings': totalSavings,
      'promotions_used': promotionsUsed,
      'promotions_published': promotionsPublished,
      'validations_given': validationsGiven,
      'reports_submitted': reportsSubmitted,
      'savings_by_category': savingsByCategory,
      'promotions_by_month': promotionsByMonth,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  /// Convierte el UserStatsModel a UserStatsEntity
  UserStatsEntity toEntity() {
    return UserStatsEntity(
      userId: userId,
      totalSavings: totalSavings,
      promotionsUsed: promotionsUsed,
      promotionsPublished: promotionsPublished,
      validationsGiven: validationsGiven,
      reportsSubmitted: reportsSubmitted,
      savingsByCategory: savingsByCategory,
      promotionsByMonth: promotionsByMonth,
      lastUpdated: lastUpdated,
    );
  }
}

// Made with Bob
