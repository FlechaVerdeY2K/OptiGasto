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

  /// Crea un CategoryModel desde un Map de Supabase
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      icon: (json['icon'] as String?) ?? '',
      color: (json['color'] as String?) ?? '#000000',
      promotionCount: (json['promotion_count'] as num?)?.toInt() ?? 0,
    );
  }

  /// Convierte el CategoryModel a un Map para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'promotion_count': promotionCount,
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
