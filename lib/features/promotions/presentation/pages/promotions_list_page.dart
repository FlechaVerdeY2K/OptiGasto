import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/promotion_bloc.dart';
import '../bloc/promotion_event.dart';
import '../bloc/promotion_state.dart';
import '../widgets/promotion_card.dart';

/// Página de lista de promociones
class PromotionsListPage extends StatefulWidget {
  const PromotionsListPage({super.key});

  @override
  State<PromotionsListPage> createState() => _PromotionsListPageState();
}

class _PromotionsListPageState extends State<PromotionsListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Cargar promociones al iniciar
    context.read<PromotionBloc>().add(const PromotionFetchRequested(limit: 20));
    // Cargar categorías
    context.read<PromotionBloc>().add(const PromotionCategoriesFetchRequested());
    
    // Listener para paginación
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<PromotionBloc>().state;
      if (state is PromotionLoaded && state.hasMore) {
        final lastPromotion = state.promotions.lastOrNull;
        if (lastPromotion != null) {
          if (state.selectedCategory != null) {
            context.read<PromotionBloc>().add(
                  PromotionFilterByCategoryRequested(
                    category: state.selectedCategory!,
                    limit: 20,
                    lastDocumentId: lastPromotion.id,
                  ),
                );
          } else {
            context.read<PromotionBloc>().add(
                  PromotionFetchRequested(
                    limit: 20,
                    lastDocumentId: lastPromotion.id,
                  ),
                );
          }
        }
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PromotionBloc, PromotionState>(
      listener: (context, state) {
        if (state is PromotionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is PromotionSaveToggled) {
          // Actualizar el AuthBloc localmente
          final authBloc = context.read<AuthBloc>();
          final authState = authBloc.state;
          if (authState is AuthAuthenticated) {
            final updatedSavedPromotions = List<String>.from(authState.user.savedPromotions);
            if (state.isSaved) {
              if (!updatedSavedPromotions.contains(state.promotionId)) {
                updatedSavedPromotions.add(state.promotionId);
              }
            } else {
              updatedSavedPromotions.remove(state.promotionId);
            }
            
            final updatedUser = authState.user.copyWith(
              savedPromotions: updatedSavedPromotions,
            );
            authBloc.emit(AuthAuthenticated(user: updatedUser));
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<PromotionBloc>().add(const PromotionRefreshRequested());
            // Esperar un momento para que se complete la recarga
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Filtros de categorías
              if (state is PromotionLoaded && state.categories.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildCategoryFilters(state),
                ),
              
              // Lista de promociones
              if (state is PromotionLoading && state is! PromotionRefreshing)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state is PromotionLoaded)
                _buildPromotionsList(state)
              else if (state is PromotionError)
                SliverFillRemaining(
                  child: _buildErrorState(state.message),
                )
              else
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilters(PromotionLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Filtro "Todas"
            _buildFilterChip(
              label: 'Todas',
              isSelected: state.selectedCategory == null,
              onTap: () {
                context.read<PromotionBloc>().add(
                      const PromotionClearFiltersRequested(),
                    );
              },
            ),
            const SizedBox(width: 8),
            // Filtros de categorías
            ...state.categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  label: category.name,
                  isSelected: state.selectedCategory == category.id,
                  onTap: () {
                    context.read<PromotionBloc>().add(
                          PromotionFilterByCategoryRequested(
                            category: category.id,
                            limit: 20,
                          ),
                        );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildPromotionsList(PromotionLoaded state) {
    if (state.promotions.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(state),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= state.promotions.length) {
              // Indicador de carga al final
              return state.hasMore
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : const SizedBox.shrink();
            }

            final promotion = state.promotions[index];
            final authState = context.read<AuthBloc>().state;
            final userId = authState is AuthAuthenticated ? authState.user.id : '';
            final isFavorite = authState is AuthAuthenticated
                ? authState.user.savedPromotions.contains(promotion.id)
                : false;

            return PromotionCard(
              promotion: promotion,
              isFavorite: isFavorite,
              onTap: () {
                // Incrementar vistas
                context.read<PromotionBloc>().add(
                      PromotionIncrementViewsRequested(
                        promotionId: promotion.id,
                      ),
                    );
                // Navegar a detalle
                context.push(
                  AppRouter.promotionDetail,
                  extra: promotion.id,
                );
              },
              onFavorite: userId.isNotEmpty
                  ? () {
                      context.read<PromotionBloc>().add(
                            PromotionToggleSaveRequested(
                              promotionId: promotion.id,
                              userId: userId,
                              isSaved: !isFavorite,
                            ),
                          );
                    }
                  : null,
            );
          },
          childCount: state.promotions.length + (state.hasMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildEmptyState(PromotionLoaded state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay promociones disponibles',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.selectedCategory != null
                ? 'Intenta con otra categoría'
                : 'Sé el primero en agregar una',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar promociones',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<PromotionBloc>().add(
                    const PromotionRefreshRequested(),
                  );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Made with Bob