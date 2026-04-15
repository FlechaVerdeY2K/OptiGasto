import '../../domain/entities/promotion_entity.dart';

/// Modelo de promoción para la capa de datos
class PromotionModel extends PromotionEntity {
  const PromotionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.commerceId,
    required super.commerceName,
    required super.category,
    required super.discount,
    super.originalPrice,
    super.discountedPrice,
    super.images,
    required super.latitude,
    required super.longitude,
    required super.address,
    required super.validUntil,
    required super.createdBy,
    super.positiveValidations,
    super.negativeValidations,
    super.validatedByUsers,
    super.views,
    super.saves,
    super.isActive,
    super.isPremium,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Crea un PromotionModel desde un PromotionEntity
  factory PromotionModel.fromEntity(PromotionEntity entity) {
    return PromotionModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      commerceId: entity.commerceId,
      commerceName: entity.commerceName,
      category: entity.category,
      discount: entity.discount,
      originalPrice: entity.originalPrice,
      discountedPrice: entity.discountedPrice,
      images: entity.images,
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
      validUntil: entity.validUntil,
      createdBy: entity.createdBy,
      positiveValidations: entity.positiveValidations,
      negativeValidations: entity.negativeValidations,
      validatedByUsers: entity.validatedByUsers,
      views: entity.views,
      saves: entity.saves,
      isActive: entity.isActive,
      isPremium: entity.isPremium,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Crea un PromotionModel desde un Map de Supabase
  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      commerceId: (json['commerce_id'] as String?) ?? '',
      commerceName: (json['commerce_name'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      discount: (json['discount'] as String?) ?? '',
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      discountedPrice: json['discounted_price'] != null
          ? (json['discounted_price'] as num).toDouble()
          : null,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : [],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: (json['address'] as String?) ?? '',
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : DateTime.now(),
      createdBy: (json['created_by'] as String?) ?? '',
      positiveValidations: (json['positive_validations'] as num?)?.toInt() ?? 0,
      negativeValidations: (json['negative_validations'] as num?)?.toInt() ?? 0,
      validatedByUsers: json['validated_by_users'] != null
          ? List<String>.from(json['validated_by_users'] as List)
          : [],
      views: (json['views'] as num?)?.toInt() ?? 0,
      saves: (json['saves'] as num?)?.toInt() ?? 0,
      isActive: (json['is_active'] as bool?) ?? true,
      isPremium: (json['is_premium'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convierte el PromotionModel a un Map para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'commerce_id': commerceId,
      'commerce_name': commerceName,
      'category': category,
      'discount': discount,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'images': images,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'valid_until': validUntil.toIso8601String(),
      'created_by': createdBy,
      'positive_validations': positiveValidations,
      'negative_validations': negativeValidations,
      'validated_by_users': validatedByUsers,
      'views': views,
      'saves': saves,
      'is_active': isActive,
      'is_premium': isPremium,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convierte el PromotionModel a PromotionEntity
  PromotionEntity toEntity() {
    return PromotionEntity(
      id: id,
      title: title,
      description: description,
      commerceId: commerceId,
      commerceName: commerceName,
      category: category,
      discount: discount,
      originalPrice: originalPrice,
      discountedPrice: discountedPrice,
      images: images,
      latitude: latitude,
      longitude: longitude,
      address: address,
      validUntil: validUntil,
      createdBy: createdBy,
      positiveValidations: positiveValidations,
      negativeValidations: negativeValidations,
      validatedByUsers: validatedByUsers,
      views: views,
      saves: saves,
      isActive: isActive,
      isPremium: isPremium,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

// Made with Bob
