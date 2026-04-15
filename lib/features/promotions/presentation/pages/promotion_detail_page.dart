import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/promotion_bloc.dart';
import '../bloc/promotion_event.dart';
import '../bloc/promotion_state.dart';
import '../../domain/entities/promotion_entity.dart';

/// Página de detalle de promoción
class PromotionDetailPage extends StatefulWidget {
  final String promotionId;

  const PromotionDetailPage({
    super.key,
    required this.promotionId,
  });

  @override
  State<PromotionDetailPage> createState() => _PromotionDetailPageState();
}

class _PromotionDetailPageState extends State<PromotionDetailPage> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Cargar detalle de la promoción
    context.read<PromotionBloc>().add(
          PromotionDetailRequested(promotionId: widget.promotionId),
        );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PromotionBloc, PromotionState>(
        listener: (context, state) {
          if (state is PromotionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is PromotionValidated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            // Recargar detalle
            context.read<PromotionBloc>().add(
                  PromotionDetailRequested(promotionId: widget.promotionId),
                );
          }
        },
        builder: (context, state) {
          if (state is PromotionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PromotionDetailLoaded) {
            return _buildDetailContent(state.promotion);
          }

          if (state is PromotionError) {
            return _buildErrorState(state.message);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildDetailContent(PromotionEntity promotion) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';
    final isFavorite = authState is AuthAuthenticated
        ? authState.user.savedPromotions.contains(promotion.id)
        : false;
    final hasValidated = promotion.hasUserValidated(userId);

    return CustomScrollView(
      slivers: [
        // App Bar con imagen
        _buildSliverAppBar(promotion, isFavorite, userId),

        // Contenido
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y descuento
              _buildHeader(promotion),

              const Divider(height: 32),

              // Información del comercio
              _buildCommerceInfo(promotion),

              const Divider(height: 32),

              // Descripción
              _buildDescription(promotion),

              const Divider(height: 32),

              // Validación comunitaria
              if (userId.isNotEmpty)
                _buildValidationSection(promotion, userId, hasValidated),

              const Divider(height: 32),

              // Información adicional
              _buildAdditionalInfo(promotion),

              const SizedBox(height: 32),

              // Botones de acción
              _buildActionButtons(promotion),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(
      PromotionEntity promotion, bool isFavorite, String userId) {
    final images = promotion.images.isNotEmpty
        ? promotion.images
        : ['https://via.placeholder.com/400x300?text=Sin+Imagen'];

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Galería de imágenes
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.local_offer,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    );
                  },
                );
              },
            ),

            // Gradiente inferior
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Indicador de páginas
            if (images.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),

            // Badge premium
            if (promotion.isPremium)
              Positioned(
                top: 60,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        // Botón de favorito
        if (userId.isNotEmpty)
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.error : Colors.white,
            ),
            onPressed: () {
              context.read<PromotionBloc>().add(
                    PromotionToggleSaveRequested(
                      promotionId: promotion.id,
                      userId: userId,
                      isSaved: !isFavorite,
                    ),
                  );
            },
          ),
        // Botón de compartir
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _sharePromotion(promotion),
        ),
      ],
    );
  }

  Widget _buildHeader(PromotionEntity promotion) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            promotion.title,
            style: AppTextStyles.h3.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTextStyles.h3.color,
            ),
          ),
          const SizedBox(height: 12),

          // Descuento y precios
          if (promotion.originalPrice != null &&
              promotion.discountedPrice != null)
            Row(
              children: [
                Text(
                  NumberFormat.currency(symbol: '₡', decimalDigits: 0)
                      .format(promotion.discountedPrice),
                  style: AppTextStyles.promotionPrice.copyWith(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Text(
                  NumberFormat.currency(symbol: '₡', decimalDigits: 0)
                      .format(promotion.originalPrice),
                  style: AppTextStyles.bodyLarge.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textDisabled,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _calculateDiscountPercentage(
                      promotion.originalPrice!,
                      promotion.discountedPrice!,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              promotion.discount,
              style: AppTextStyles.promotionDiscount.copyWith(fontSize: 28),
            ),

          const SizedBox(height: 16),

          // Categoría y fecha de expiración
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                icon: Icons.category,
                label: promotion.category,
                color: AppColors.accent,
              ),
              _buildInfoChip(
                icon: Icons.access_time,
                label:
                    'Válido hasta ${DateFormat('dd/MM/yyyy').format(promotion.validUntil)}',
                color: promotion.isExpired
                    ? AppColors.error
                    : promotion.validUntil.difference(DateTime.now()).inDays <=
                            2
                        ? AppColors.warning
                        : AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommerceInfo(PromotionEntity promotion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comercio',
            style: AppTextStyles.h5.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTextStyles.h5.color,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.store,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promotion.commerceName,
                      style: AppTextStyles.h6.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : AppTextStyles.h6.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            promotion.address,
                            style: AppTextStyles.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.directions),
                onPressed: () {
                  // TODO: Abrir en mapa
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Navegación - Próximamente'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(PromotionEntity promotion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripción',
            style: AppTextStyles.h5.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTextStyles.h5.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            promotion.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : AppTextStyles.bodyLarge.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationSection(
    PromotionEntity promotion,
    String userId,
    bool hasValidated,
  ) {
    final total = promotion.positiveValidations + promotion.negativeValidations;
    final score = promotion.validationScore;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Validación Comunitaria',
            style: AppTextStyles.h5.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTextStyles.h5.color,
            ),
          ),
          const SizedBox(height: 12),

          // Estadísticas
          if (total > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildValidationStat(
                    icon: Icons.thumb_up,
                    label: 'Positivas',
                    value: '${promotion.positiveValidations}',
                    color: AppColors.validationPositive,
                  ),
                  _buildValidationStat(
                    icon: Icons.thumb_down,
                    label: 'Negativas',
                    value: '${promotion.negativeValidations}',
                    color: AppColors.validationNegative,
                  ),
                  _buildValidationStat(
                    icon: Icons.percent,
                    label: 'Confiabilidad',
                    value: '${score.toInt()}%',
                    color: score >= 70
                        ? AppColors.validationPositive
                        : score >= 40
                            ? AppColors.warning
                            : AppColors.validationNegative,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Botones de validación
          if (!hasValidated && !promotion.isExpired)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<PromotionBloc>().add(
                            PromotionValidateRequested(
                              promotionId: promotion.id,
                              userId: userId,
                              isPositive: true,
                            ),
                          );
                    },
                    icon: const Icon(Icons.thumb_up),
                    label: const Text('Válida'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.validationPositive,
                      side:
                          const BorderSide(color: AppColors.validationPositive),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<PromotionBloc>().add(
                            PromotionValidateRequested(
                              promotionId: promotion.id,
                              userId: userId,
                              isPositive: false,
                            ),
                          );
                    },
                    icon: const Icon(Icons.thumb_down),
                    label: const Text('No válida'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.validationNegative,
                      side:
                          const BorderSide(color: AppColors.validationNegative),
                    ),
                  ),
                ),
              ],
            )
          else if (hasValidated)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.info),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ya has validado esta promoción',
                      style: TextStyle(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo(PromotionEntity promotion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información Adicional',
            style: AppTextStyles.h5.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTextStyles.h5.color,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.visibility,
            label: 'Vistas',
            value: '${promotion.views}',
          ),
          _buildInfoRow(
            icon: Icons.favorite,
            label: 'Guardada por',
            value: '${promotion.saves} personas',
          ),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Publicada',
            value: DateFormat('dd/MM/yyyy').format(promotion.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PromotionEntity promotion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: promotion.isExpired
                  ? null
                  : () {
                      // TODO: Usar promoción
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Usar promoción - Próximamente'),
                        ),
                      );
                    },
              icon: const Icon(Icons.check_circle),
              label: Text(
                  promotion.isExpired ? 'Promoción Vencida' : 'Usar Promoción'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    promotion.isExpired ? Colors.grey : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Reportar promoción
                _showReportDialog();
              },
              icon: const Icon(Icons.flag),
              label: const Text('Reportar Problema'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar promoción',
              style: AppTextStyles.h5.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppTextStyles.h5.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateDiscountPercentage(double original, double discounted) {
    final percentage = ((original - discounted) / original * 100).round();
    return '-$percentage%';
  }

  void _sharePromotion(PromotionEntity promotion) {
    Share.share(
      '¡Mira esta promoción en OptiGasto!\n\n'
      '${promotion.title}\n'
      '${promotion.discount}\n'
      'En ${promotion.commerceName}\n\n'
      'Descarga OptiGasto y ahorra más.',
      subject: promotion.title,
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar Problema'),
        content: const Text(
          '¿Qué problema encontraste con esta promoción?\n\n'
          'Esta funcionalidad estará disponible próximamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

// Made with Bob
