import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/category_entity.dart';

/// Modelo de categoría para la capa de datos
class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    super.promotionCount,
  });

  /// Crea un CategoryModel desde un CategoryEntity
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
      promotionCount: entity.promotionCount,
    );
  }

  /// Crea un CategoryModel desde un documento de Firestore
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '',
      color: data['color'] ?? '#000000',
      promotionCount: data['promotionCount'] ?? 0,
    );
  }

  /// Crea un CategoryModel desde un Map
  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      color: map['color'] ?? '#000000',
      promotionCount: map['promotionCount'] ?? 0,
    );
  }

  /// Convierte el CategoryModel a un Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
      'promotionCount': promotionCount,
    };
  }

  /// Convierte el CategoryModel a CategoryEntity
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      icon: icon,
      color: color,
      promotionCount: promotionCount,
    );
  }
}

// Made with Bob