import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Crea un UserModel desde un documento de Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      phone: data['phone'],
      latitude: data['location'] != null 
          ? (data['location'] as GeoPoint).latitude 
          : null,
      longitude: data['location'] != null 
          ? (data['location'] as GeoPoint).longitude 
          : null,
      reputation: data['reputation'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
      savedPromotions: List<String>.from(data['savedPromotions'] ?? []),
      totalSavings: (data['totalSavings'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isCommerce: data['isCommerce'] ?? false,
    );
  }

  /// Convierte el UserModel a un Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'phone': phone,
      'location': (latitude != null && longitude != null)
          ? GeoPoint(latitude!, longitude!)
          : null,
      'reputation': reputation,
      'badges': badges,
      'savedPromotions': savedPromotions,
      'totalSavings': totalSavings,
      'createdAt': Timestamp.fromDate(createdAt),
      'isCommerce': isCommerce,
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
