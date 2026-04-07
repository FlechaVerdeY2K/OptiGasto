import 'package:equatable/equatable.dart';

/// Entidad de categoría en la capa de dominio
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String color;
  final int promotionCount;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.promotionCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        color,
        promotionCount,
      ];

  /// Copia la entidad con campos actualizados
  CategoryEntity copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    int? promotionCount,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      promotionCount: promotionCount ?? this.promotionCount,
    );
  }
}

// Made with Bob