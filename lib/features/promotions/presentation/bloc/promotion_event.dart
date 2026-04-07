import 'package:equatable/equatable.dart';

/// Eventos de promociones
abstract class PromotionEvent extends Equatable {
  const PromotionEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Cargar promociones
class PromotionFetchRequested extends PromotionEvent {
  final int? limit;
  final String? lastDocumentId;

  const PromotionFetchRequested({
    this.limit,
    this.lastDocumentId,
  });

  @override
  List<Object?> get props => [limit, lastDocumentId];
}

/// Evento: Cargar promociones cercanas
class PromotionFetchNearbyRequested extends PromotionEvent {
  final double latitude;
  final double longitude;
  final double radiusInKm;
  final int? limit;

  const PromotionFetchNearbyRequested({
    required this.latitude,
    required this.longitude,
    required this.radiusInKm,
    this.limit,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusInKm, limit];
}

/// Evento: Filtrar por categoría
class PromotionFilterByCategoryRequested extends PromotionEvent {
  final String category;
  final int? limit;
  final String? lastDocumentId;

  const PromotionFilterByCategoryRequested({
    required this.category,
    this.limit,
    this.lastDocumentId,
  });

  @override
  List<Object?> get props => [category, limit, lastDocumentId];
}

/// Evento: Buscar promociones
class PromotionSearchRequested extends PromotionEvent {
  final String query;
  final int? limit;

  const PromotionSearchRequested({
    required this.query,
    this.limit,
  });

  @override
  List<Object?> get props => [query, limit];
}

/// Evento: Cargar detalle de promoción
class PromotionDetailRequested extends PromotionEvent {
  final String promotionId;

  const PromotionDetailRequested({required this.promotionId});

  @override
  List<Object?> get props => [promotionId];
}

/// Evento: Validar promoción (like/dislike)
class PromotionValidateRequested extends PromotionEvent {
  final String promotionId;
  final String userId;
  final bool isPositive;

  const PromotionValidateRequested({
    required this.promotionId,
    required this.userId,
    required this.isPositive,
  });

  @override
  List<Object?> get props => [promotionId, userId, isPositive];
}

/// Evento: Incrementar vistas
class PromotionIncrementViewsRequested extends PromotionEvent {
  final String promotionId;

  const PromotionIncrementViewsRequested({required this.promotionId});

  @override
  List<Object?> get props => [promotionId];
}

/// Evento: Guardar/quitar de favoritos
class PromotionToggleSaveRequested extends PromotionEvent {
  final String promotionId;
  final String userId;
  final bool isSaved;

  const PromotionToggleSaveRequested({
    required this.promotionId,
    required this.userId,
    required this.isSaved,
  });

  @override
  List<Object?> get props => [promotionId, userId, isSaved];
}

/// Evento: Cargar categorías
class PromotionCategoriesFetchRequested extends PromotionEvent {
  const PromotionCategoriesFetchRequested();
}

/// Evento: Refrescar promociones
class PromotionRefreshRequested extends PromotionEvent {
  const PromotionRefreshRequested();
}

/// Evento: Limpiar filtros
class PromotionClearFiltersRequested extends PromotionEvent {
  const PromotionClearFiltersRequested();
}

// Made with Bob