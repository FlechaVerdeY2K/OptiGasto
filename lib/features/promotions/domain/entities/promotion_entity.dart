import 'package:equatable/equatable.dart';

/// Entidad de promoción en la capa de dominio
class PromotionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String commerceId;
  final String commerceName;
  final String category;
  final String discount;
  final double? originalPrice;
  final double? discountedPrice;
  final List<String> images;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime validUntil;
  final String createdBy;
  final int positiveValidations;
  final int negativeValidations;
  final List<String> validatedByUsers;
  final int views;
  final int saves;
  final bool isActive;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PromotionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.commerceId,
    required this.commerceName,
    required this.category,
    required this.discount,
    this.originalPrice,
    this.discountedPrice,
    this.images = const [],
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.validUntil,
    required this.createdBy,
    this.positiveValidations = 0,
    this.negativeValidations = 0,
    this.validatedByUsers = const [],
    this.views = 0,
    this.saves = 0,
    this.isActive = true,
    this.isPremium = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        commerceId,
        commerceName,
        category,
        discount,
        originalPrice,
        discountedPrice,
        images,
        latitude,
        longitude,
        address,
        validUntil,
        createdBy,
        positiveValidations,
        negativeValidations,
        validatedByUsers,
        views,
        saves,
        isActive,
        isPremium,
        createdAt,
        updatedAt,
      ];

  /// Calcula el porcentaje de validaciones positivas
  double get validationScore {
    final total = positiveValidations + negativeValidations;
    if (total == 0) return 0.0;
    return (positiveValidations / total) * 100;
  }

  /// Verifica si la promoción está vencida
  bool get isExpired {
    return DateTime.now().isAfter(validUntil);
  }

  /// Verifica si un usuario ya validó esta promoción
  bool hasUserValidated(String userId) {
    return validatedByUsers.contains(userId);
  }

  /// Copia la entidad con campos actualizados
  PromotionEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? commerceId,
    String? commerceName,
    String? category,
    String? discount,
    double? originalPrice,
    double? discountedPrice,
    List<String>? images,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? validUntil,
    String? createdBy,
    int? positiveValidations,
    int? negativeValidations,
    List<String>? validatedByUsers,
    int? views,
    int? saves,
    bool? isActive,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PromotionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      commerceId: commerceId ?? this.commerceId,
      commerceName: commerceName ?? this.commerceName,
      category: category ?? this.category,
      discount: discount ?? this.discount,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      images: images ?? this.images,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      validUntil: validUntil ?? this.validUntil,
      createdBy: createdBy ?? this.createdBy,
      positiveValidations: positiveValidations ?? this.positiveValidations,
      negativeValidations: negativeValidations ?? this.negativeValidations,
      validatedByUsers: validatedByUsers ?? this.validatedByUsers,
      views: views ?? this.views,
      saves: saves ?? this.saves,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Made with Bob