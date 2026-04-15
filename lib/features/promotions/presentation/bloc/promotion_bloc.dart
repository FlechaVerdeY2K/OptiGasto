import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/promotion_repository.dart';
import 'promotion_event.dart';
import 'promotion_state.dart';

/// BLoC de promociones
class PromotionBloc extends Bloc<PromotionEvent, PromotionState> {
  final PromotionRepository repository;

  PromotionBloc({required this.repository}) : super(const PromotionInitial()) {
    // Registrar handlers de eventos
    on<PromotionFetchRequested>(_onFetchRequested);
    on<PromotionFetchNearbyRequested>(_onFetchNearbyRequested);
    on<PromotionFilterByCategoryRequested>(_onFilterByCategoryRequested);
    on<PromotionSearchRequested>(_onSearchRequested);
    on<PromotionDetailRequested>(_onDetailRequested);
    on<PromotionValidateRequested>(_onValidateRequested);
    on<PromotionIncrementViewsRequested>(_onIncrementViewsRequested);
    on<PromotionToggleSaveRequested>(_onToggleSaveRequested);
    on<PromotionCategoriesFetchRequested>(_onCategoriesFetchRequested);
    on<PromotionRefreshRequested>(_onRefreshRequested);
    on<PromotionClearFiltersRequested>(_onClearFiltersRequested);
  }

  /// Handler: Cargar promociones
  Future<void> _onFetchRequested(
    PromotionFetchRequested event,
    Emitter<PromotionState> emit,
  ) async {
    // Mantener las categorías del estado anterior si existen
    final currentState = state;
    final previousCategories = currentState is PromotionLoaded
        ? currentState.categories
        : currentState is PromotionCategoriesLoaded
            ? currentState.categories
            : <CategoryEntity>[];

    emit(const PromotionLoading());

    final result = await repository.getPromotions(
      limit: event.limit,
      lastDocumentId: event.lastDocumentId,
    );

    result.fold(
      (failure) => emit(PromotionError(message: failure.message)),
      (promotions) => emit(PromotionLoaded(
        promotions: promotions,
        categories: previousCategories,
        hasMore: promotions.length == (event.limit ?? 20),
      )),
    );
  }

  /// Handler: Cargar promociones cercanas
  Future<void> _onFetchNearbyRequested(
    PromotionFetchNearbyRequested event,
    Emitter<PromotionState> emit,
  ) async {
    emit(const PromotionLoading());

    final result = await repository.getNearbyPromotions(
      latitude: event.latitude,
      longitude: event.longitude,
      radiusInKm: event.radiusInKm,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(PromotionError(message: failure.message)),
      (promotions) => emit(PromotionLoaded(
        promotions: promotions,
        hasMore: promotions.length == (event.limit ?? 20),
      )),
    );
  }

  /// Handler: Filtrar por categoría
  Future<void> _onFilterByCategoryRequested(
    PromotionFilterByCategoryRequested event,
    Emitter<PromotionState> emit,
  ) async {
    // Mantener las categorías del estado anterior
    final currentState = state;
    final previousCategories = currentState is PromotionLoaded
        ? currentState.categories
        : <CategoryEntity>[];

    emit(const PromotionLoading());

    final result = await repository.getPromotionsByCategory(
      category: event.category,
      limit: event.limit,
      lastDocumentId: event.lastDocumentId,
    );

    result.fold(
      (failure) => emit(PromotionError(message: failure.message)),
      (promotions) => emit(PromotionLoaded(
        promotions: promotions,
        categories: previousCategories,
        selectedCategory: event.category,
        hasMore: promotions.length == (event.limit ?? 20),
      )),
    );
  }

  /// Handler: Buscar promociones
  Future<void> _onSearchRequested(
    PromotionSearchRequested event,
    Emitter<PromotionState> emit,
  ) async {
    emit(const PromotionLoading());

    final result = await repository.searchPromotions(
      query: event.query,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(PromotionError(message: failure.message)),
      (promotions) => emit(PromotionLoaded(
        promotions: promotions,
        searchQuery: event.query,
        hasMore: false, // La búsqueda no tiene paginación
      )),
    );
  }

  /// Handler: Cargar detalle de promoción
  Future<void> _onDetailRequested(
    PromotionDetailRequested event,
    Emitter<PromotionState> emit,
  ) async {
    emit(const PromotionLoading());

    final result = await repository.getPromotionById(event.promotionId);

    result.fold(
      (failure) => emit(PromotionError(message: failure.message)),
      (promotion) => emit(PromotionDetailLoaded(promotion: promotion)),
    );
  }

  /// Handler: Validar promoción
  Future<void> _onValidateRequested(
    PromotionValidateRequested event,
    Emitter<PromotionState> emit,
  ) async {
    final currentState = state;

    final result = await repository.validatePromotion(
      promotionId: event.promotionId,
      userId: event.userId,
      isPositive: event.isPositive,
    );

    result.fold(
      (failure) => emit(PromotionError(message: failure.message)),
      (promotion) {
        final message = event.isPositive
            ? '¡Gracias por validar esta promoción!'
            : 'Gracias por tu feedback';

        emit(PromotionValidated(
          promotion: promotion,
          message: message,
        ));

        // Restaurar el estado anterior con la promoción actualizada
        if (currentState is PromotionLoaded) {
          final updatedPromotions = currentState.promotions.map((p) {
            return p.id == promotion.id ? promotion : p;
          }).toList();

          emit(currentState.copyWith(promotions: updatedPromotions));
        } else if (currentState is PromotionDetailLoaded) {
          emit(PromotionDetailLoaded(promotion: promotion));
        }
      },
    );
  }

  /// Handler: Incrementar vistas
  Future<void> _onIncrementViewsRequested(
    PromotionIncrementViewsRequested event,
    Emitter<PromotionState> emit,
  ) async {
    // Incrementar vistas en segundo plano sin cambiar el estado
    await repository.incrementViews(event.promotionId);
  }

  /// Handler: Guardar/quitar de favoritos
  Future<void> _onToggleSaveRequested(
    PromotionToggleSaveRequested event,
    Emitter<PromotionState> emit,
  ) async {
    final currentState = state;

    final result = await repository.toggleSavePromotion(
      promotionId: event.promotionId,
      userId: event.userId,
      isSaved: event.isSaved,
    );

    result.fold(
      (failure) => emit(PromotionError(message: failure.message)),
      (_) {
        final message = event.isSaved
            ? 'Promoción guardada en favoritos'
            : 'Promoción quitada de favoritos';

        // Emitir mensaje de éxito
        emit(PromotionSaveToggled(
          promotionId: event.promotionId,
          isSaved: event.isSaved,
          message: message,
        ));

        // Restaurar el estado anterior inmediatamente
        if (currentState is PromotionLoaded) {
          emit(currentState);
        } else if (currentState is PromotionDetailLoaded) {
          emit(currentState);
        }
      },
    );
  }

  /// Handler: Cargar categorías
  Future<void> _onCategoriesFetchRequested(
    PromotionCategoriesFetchRequested event,
    Emitter<PromotionState> emit,
  ) async {
    final result = await repository.getCategories();

    result.fold(
      (failure) {
        // No emitir error, solo log
        print('Error cargando categorías: ${failure.message}');
      },
      (categories) {
        final currentState = state;
        if (currentState is PromotionLoaded) {
          emit(currentState.copyWith(categories: categories));
        } else {
          // Si aún no hay promociones cargadas, guardar categorías para después
          emit(PromotionCategoriesLoaded(categories: categories));
        }
      },
    );
  }

  /// Handler: Refrescar promociones
  Future<void> _onRefreshRequested(
    PromotionRefreshRequested event,
    Emitter<PromotionState> emit,
  ) async {
    // Mantener las categorías del estado anterior si existen
    final currentState = state;
    final previousCategories = currentState is PromotionLoaded
        ? currentState.categories
        : <CategoryEntity>[];

    emit(const PromotionRefreshing());

    final result = await repository.getPromotions(limit: 20);

    result.fold(
      (failure) => emit(PromotionError(message: failure.message)),
      (promotions) => emit(PromotionLoaded(
        promotions: promotions,
        categories: previousCategories,
        hasMore: promotions.length == 20,
      )),
    );
  }

  /// Handler: Limpiar filtros
  Future<void> _onClearFiltersRequested(
    PromotionClearFiltersRequested event,
    Emitter<PromotionState> emit,
  ) async {
    // Mantener las categorías del estado anterior
    final currentState = state;
    final previousCategories = currentState is PromotionLoaded
        ? currentState.categories
        : <CategoryEntity>[];

    emit(const PromotionLoading());

    final result = await repository.getPromotions(limit: 20);

    result.fold(
      (failure) => emit(PromotionError(message: failure.message)),
      (promotions) => emit(PromotionLoaded(
        promotions: promotions,
        categories: previousCategories,
        selectedCategory: null, // Limpiar categoría seleccionada
        hasMore: promotions.length == 20,
      )),
    );
  }
}

// Made with Bob
