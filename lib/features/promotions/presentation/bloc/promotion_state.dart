import 'package:equatable/equatable.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/entities/category_entity.dart';

/// Estados de promociones
abstract class PromotionState extends Equatable {
  const PromotionState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class PromotionInitial extends PromotionState {
  const PromotionInitial();
}

/// Estado: Cargando
class PromotionLoading extends PromotionState {
  const PromotionLoading();
}

/// Estado: Promociones cargadas
class PromotionLoaded extends PromotionState {
  final List<PromotionEntity> promotions;
  final List<CategoryEntity> categories;
  final String? selectedCategory;
  final String? searchQuery;
  final bool hasMore;

  const PromotionLoaded({
    required this.promotions,
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [
        promotions,
        categories,
        selectedCategory,
        searchQuery,
        hasMore,
      ];

  /// Copia el estado con campos actualizados
  PromotionLoaded copyWith({
    List<PromotionEntity>? promotions,
    List<CategoryEntity>? categories,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    String? searchQuery,
    bool clearSearchQuery = false,
    bool? hasMore,
  }) {
    return PromotionLoaded(
      promotions: promotions ?? this.promotions,
      categories: categories ?? this.categories,
      selectedCategory: clearSelectedCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Estado: Detalle de promoción cargado
class PromotionDetailLoaded extends PromotionState {
  final PromotionEntity promotion;

  const PromotionDetailLoaded({required this.promotion});

  @override
  List<Object?> get props => [promotion];
}

/// Estado: Error
class PromotionError extends PromotionState {
  final String message;

  const PromotionError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado: Promoción validada exitosamente
class PromotionValidated extends PromotionState {
  final PromotionEntity promotion;
  final String message;

  const PromotionValidated({
    required this.promotion,
    required this.message,
  });

  @override
  List<Object?> get props => [promotion, message];
}

/// Estado: Promoción guardada/quitada de favoritos
class PromotionSaveToggled extends PromotionState {
  final String promotionId;
  final bool isSaved;
  final String message;

  const PromotionSaveToggled({
    required this.promotionId,
    required this.isSaved,
    required this.message,
  });

  @override
  List<Object?> get props => [promotionId, isSaved, message];
}

/// Estado: Categorías cargadas
class PromotionCategoriesLoaded extends PromotionState {
  final List<CategoryEntity> categories;

  const PromotionCategoriesLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

/// Estado: Refrescando
class PromotionRefreshing extends PromotionState {
  const PromotionRefreshing();
}

// Made with Bob