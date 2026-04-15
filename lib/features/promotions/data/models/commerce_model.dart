import '../../domain/entities/commerce_entity.dart';

/// Modelo de comercio para la capa de datos
class CommerceModel extends CommerceEntity {
  const CommerceModel({
    required super.id,
    required super.name,
    required super.type,
    required super.latitude,
    required super.longitude,
    required super.address,
    super.phone,
    super.email,
    super.logo,
    super.photos,
    super.rating,
    super.totalPromotions,
    super.isPremium,
    super.ownerId,
    required super.createdAt,
  });

  /// Crea un CommerceModel desde un CommerceEntity
  factory CommerceModel.fromEntity(CommerceEntity entity) {
    return CommerceModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
      phone: entity.phone,
      email: entity.email,
      logo: entity.logo,
      photos: entity.photos,
      rating: entity.rating,
      totalPromotions: entity.totalPromotions,
      isPremium: entity.isPremium,
      ownerId: entity.ownerId,
      createdAt: entity.createdAt,
    );
  }

  /// Crea un CommerceModel desde un Map de Supabase
  factory CommerceModel.fromJson(Map<String, dynamic> json) {
    return CommerceModel(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: (json['address'] as String?) ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      logo: json['logo'] as String?,
      photos: json['photos'] != null
          ? List<String>.from(json['photos'] as List)
          : [],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      totalPromotions: (json['total_promotions'] as num?)?.toInt() ?? 0,
      isPremium: (json['is_premium'] as bool?) ?? false,
      ownerId: json['owner_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convierte el CommerceModel a un Map para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phone': phone,
      'email': email,
      'logo': logo,
      'photos': photos,
      'rating': rating,
      'total_promotions': totalPromotions,
      'is_premium': isPremium,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convierte el CommerceModel a CommerceEntity
  CommerceEntity toEntity() {
    return CommerceEntity(
      id: id,
      name: name,
      type: type,
      latitude: latitude,
      longitude: longitude,
      address: address,
      phone: phone,
      email: email,
      logo: logo,
      photos: photos,
      rating: rating,
      totalPromotions: totalPromotions,
      isPremium: isPremium,
      ownerId: ownerId,
      createdAt: createdAt,
    );
  }
}

// Made with Bob
