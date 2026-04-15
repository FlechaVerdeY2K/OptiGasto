import 'package:equatable/equatable.dart';

/// Entidad que representa las estadísticas del usuario
class UserStatsEntity extends Equatable {
  final String userId;
  final double totalSavings;
  final int promotionsUsed;
  final int promotionsPublished;
  final int validationsGiven;
  final int reportsSubmitted;
  final Map<String, double> savingsByCategory;
  final Map<String, int> promotionsByMonth;
  final DateTime lastUpdated;

  const UserStatsEntity({
    required this.userId,
    required this.totalSavings,
    required this.promotionsUsed,
    required this.promotionsPublished,
    required this.validationsGiven,
    required this.reportsSubmitted,
    required this.savingsByCategory,
    required this.promotionsByMonth,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        userId,
        totalSavings,
        promotionsUsed,
        promotionsPublished,
        validationsGiven,
        reportsSubmitted,
        savingsByCategory,
        promotionsByMonth,
        lastUpdated,
      ];

  UserStatsEntity copyWith({
    String? userId,
    double? totalSavings,
    int? promotionsUsed,
    int? promotionsPublished,
    int? validationsGiven,
    int? reportsSubmitted,
    Map<String, double>? savingsByCategory,
    Map<String, int>? promotionsByMonth,
    DateTime? lastUpdated,
  }) {
    return UserStatsEntity(
      userId: userId ?? this.userId,
      totalSavings: totalSavings ?? this.totalSavings,
      promotionsUsed: promotionsUsed ?? this.promotionsUsed,
      promotionsPublished: promotionsPublished ?? this.promotionsPublished,
      validationsGiven: validationsGiven ?? this.validationsGiven,
      reportsSubmitted: reportsSubmitted ?? this.reportsSubmitted,
      savingsByCategory: savingsByCategory ?? this.savingsByCategory,
      promotionsByMonth: promotionsByMonth ?? this.promotionsByMonth,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Made with Bob
