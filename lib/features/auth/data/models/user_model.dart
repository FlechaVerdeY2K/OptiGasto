import '../../domain/entities/user_entity.dart';

/// Modelo de usuario para la capa de datos
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.photoUrl,
    super.phone,
    super.latitude,
    super.longitude,
    super.reputation,
    super.badges,
    super.savedPromotions,
    super.totalSavings,
    required super.createdAt,
    super.isCommerce,
  });

  /// Crea un UserModel desde un UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      photoUrl: entity.photoUrl,
      phone: entity.phone,
      latitude: entity.latitude,
      longitude: entity.longitude,
      reputation: entity.reputation,
      badges: entity.badges,
      savedPromotions: entity.savedPromotions,
      totalSavings: entity.totalSavings,
      createdAt: entity.createdAt,
      isCommerce: entity.isCommerce,
    );
  }

  /// Crea un UserModel desde un Map de Supabase
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photo_url'],
      phone: json['phone'],
      latitude: json['latitude'] != null 
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null 
          ? (json['longitude'] as num).toDouble()
          : null,
      reputation: json['reputation'] ?? 0,
      badges: json['badges'] != null 
          ? List<String>.from(json['badges'])
          : [],
      savedPromotions: json['saved_promotions'] != null 
          ? List<String>.from(json['saved_promotions'])
          : [],
      totalSavings: json['total_savings'] != null 
          ? (json['total_savings'] as num).toDouble()
          : 0.0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isCommerce: json['is_commerce'] ?? false,
    );
  }

  /// Convierte el UserModel a un Map para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'reputation': reputation,
      'badges': badges,
      'saved_promotions': savedPromotions,
      'total_savings': totalSavings,
      'created_at': createdAt.toIso8601String(),
      'is_commerce': isCommerce,
    };
  }

  /// Convierte el UserModel a UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      photoUrl: photoUrl,
      phone: phone,
      latitude: latitude,
      longitude: longitude,
      reputation: reputation,
      badges: badges,
      savedPromotions: savedPromotions,
      totalSavings: totalSavings,
      createdAt: createdAt,
      isCommerce: isCommerce,
    );
  }
}

// Made with Bob
