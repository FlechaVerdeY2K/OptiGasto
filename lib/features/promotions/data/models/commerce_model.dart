import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Crea un CommerceModel desde un documento de Firestore
  factory CommerceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CommerceModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      latitude: (data['location'] as GeoPoint).latitude,
      longitude: (data['location'] as GeoPoint).longitude,
      address: data['address'] ?? '',
      phone: data['phone'],
      email: data['email'],
      logo: data['logo'],
      photos: List<String>.from(data['photos'] ?? []),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalPromotions: data['totalPromotions'] ?? 0,
      isPremium: data['isPremium'] ?? false,
      ownerId: data['ownerId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Crea un CommerceModel desde un Map
  factory CommerceModel.fromMap(Map<String, dynamic> map, String id) {
    return CommerceModel(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      latitude: (map['location'] as GeoPoint).latitude,
      longitude: (map['location'] as GeoPoint).longitude,
      address: map['address'] ?? '',
      phone: map['phone'],
      email: map['email'],
      logo: map['logo'],
      photos: List<String>.from(map['photos'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalPromotions: map['totalPromotions'] ?? 0,
      isPremium: map['isPremium'] ?? false,
      ownerId: map['ownerId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convierte el CommerceModel a un Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'location': GeoPoint(latitude, longitude),
      'address': address,
      'phone': phone,
      'email': email,
      'logo': logo,
      'photos': photos,
      'rating': rating,
      'totalPromotions': totalPromotions,
      'isPremium': isPremium,
      'ownerId': ownerId,
      'createdAt': Timestamp.fromDate(createdAt),
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