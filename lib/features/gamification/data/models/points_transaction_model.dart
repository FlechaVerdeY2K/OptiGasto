import '../../domain/entities/points_transaction_entity.dart';

/// Model for points transaction in the data layer
class PointsTransactionModel extends PointsTransactionEntity {
  const PointsTransactionModel({
    required super.id,
    required super.userId,
    required super.points,
    required super.eventType,
    super.referenceType,
    super.referenceId,
    super.description,
    required super.createdAt,
  });

  /// Creates a PointsTransactionModel from Supabase JSON
  factory PointsTransactionModel.fromJson(Map<String, dynamic> json) {
    return PointsTransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      points: (json['points'] as num).toInt(),
      eventType: json['event_type'] as String,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts the PointsTransactionModel to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'points': points,
      'event_type': eventType,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Converts the PointsTransactionModel to PointsTransactionEntity
  PointsTransactionEntity toEntity() {
    return PointsTransactionEntity(
      id: id,
      userId: userId,
      points: points,
      eventType: eventType,
      referenceType: referenceType,
      referenceId: referenceId,
      description: description,
      createdAt: createdAt,
    );
  }
}

// Made with Bob
