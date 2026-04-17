import 'package:equatable/equatable.dart';

/// Entity representing a points transaction in the ledger
class PointsTransactionEntity extends Equatable {
  final String id;
  final String userId;
  final int points;
  final String eventType;
  final String? referenceType;
  final String? referenceId;
  final String? description;
  final DateTime createdAt;

  const PointsTransactionEntity({
    required this.id,
    required this.userId,
    required this.points,
    required this.eventType,
    this.referenceType,
    this.referenceId,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        points,
        eventType,
        referenceType,
        referenceId,
        description,
        createdAt,
      ];

  PointsTransactionEntity copyWith({
    String? id,
    String? userId,
    int? points,
    String? eventType,
    String? referenceType,
    String? referenceId,
    String? description,
    DateTime? createdAt,
  }) {
    return PointsTransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      points: points ?? this.points,
      eventType: eventType ?? this.eventType,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Made with Bob
