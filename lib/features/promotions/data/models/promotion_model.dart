import 'package:cloud_firestore/cloud_firestore.dart';
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

  /// Crea un PromotionModel desde un documento de Firestore
  factory PromotionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Helper para convertir valores que pueden ser referencias o strings
    String _extractString(dynamic value, String defaultValue) {
      if (value == null) return defaultValue;
      if (value is String) return value;
      // Si es una referencia de documento, extraer el ID
      if (value is DocumentReference) return value.id;
      return value.toString();
    }
    
    // Extraer validaciones (puede ser un mapa o campos separados)
    final validations = data['validations'] as Map<String, dynamic>?;
    final positiveValidations = validations?['positive'] ??
                                data['positiveValidations'] ?? 0;
    final negativeValidations = validations?['negative'] ??
                                data['negativeValidations'] ?? 0;
    final validatedByUsers = validations?['users'] != null
        ? List<String>.from(validations!['users'])
        : (data['validatedByUsers'] != null
            ? List<String>.from(data['validatedByUsers'])
            : <String>[]);
    
    return PromotionModel(
      id: doc.id,
      title: _extractString(data['title'], ''),
      description: _extractString(data['description'], ''),
      commerceId: _extractString(data['commerceId'], ''),
      commerceName: _extractString(data['commerceName'], ''),
      category: _extractString(data['category'], ''),
      discount: _extractString(data['discount'], ''),
      originalPrice: data['originalPrice']?.toDouble(),
      discountedPrice: data['discountedPrice']?.toDouble(),
      images: List<String>.from(data['images'] ?? []),
      latitude: (data['location'] as GeoPoint).latitude,
      longitude: (data['location'] as GeoPoint).longitude,
      address: _extractString(data['address'], ''),
      validUntil: (data['validUntil'] as Timestamp).toDate(),
      createdBy: _extractString(data['createdBy'], ''),
      positiveValidations: positiveValidations is int ? positiveValidations : 0,
      negativeValidations: negativeValidations is int ? negativeValidations : 0,
      validatedByUsers: validatedByUsers,
      views: data['views'] is int ? data['views'] : 0,
      saves: data['saves'] is int ? data['saves'] : 0,
      isActive: data['isActive'] == true,
      isPremium: data['isPremium'] == true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Crea un PromotionModel desde un Map
  factory PromotionModel.fromMap(Map<String, dynamic> map, String id) {
    final validations = map['validations'] as Map<String, dynamic>? ?? {};
    
    return PromotionModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      commerceId: map['commerceId'] ?? '',
      commerceName: map['commerceName'] ?? '',
      category: map['category'] ?? '',
      discount: map['discount'] ?? '',
      originalPrice: map['originalPrice']?.toDouble(),
      discountedPrice: map['discountedPrice']?.toDouble(),
      images: List<String>.from(map['images'] ?? []),
      latitude: (map['location'] as GeoPoint).latitude,
      longitude: (map['location'] as GeoPoint).longitude,
      address: map['address'] ?? '',
      validUntil: (map['validUntil'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? '',
      positiveValidations: validations['positive'] ?? 0,
      negativeValidations: validations['negative'] ?? 0,
      validatedByUsers: List<String>.from(validations['users'] ?? []),
      views: map['views'] ?? 0,
      saves: map['saves'] ?? 0,
      isActive: map['isActive'] ?? true,
      isPremium: map['isPremium'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convierte el PromotionModel a un Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'commerceId': commerceId,
      'commerceName': commerceName,
      'category': category,
      'discount': discount,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'images': images,
      'location': GeoPoint(latitude, longitude),
      'address': address,
      'validUntil': Timestamp.fromDate(validUntil),
      'createdBy': createdBy,
      'validations': {
        'positive': positiveValidations,
        'negative': negativeValidations,
        'users': validatedByUsers,
      },
      'views': views,
      'saves': saves,
      'isActive': isActive,
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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