import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/promotion_entity.dart';

/// Widget de tarjeta de promoción
class PromotionCard extends StatelessWidget {
  final PromotionEntity promotion;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const PromotionCard({
    super.key,
    required this.promotion,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final daysUntilExpiry = promotion.validUntil.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysUntilExpiry <= 2;
    final isExpired = promotion.isExpired;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: isExpired ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isExpired ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen de la promoción
                _buildPromotionImage(),
                const SizedBox(width: 12),
                // Información de la promoción
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y descuento
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              promotion.title,
                              style: AppTextStyles.h6,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (promotion.isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PREMIUM',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Comercio
                      Row(
                        children: [
                          const Icon(
                            Icons.store,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              promotion.commerceName,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Descuento y precios
                      if (promotion.originalPrice != null &&
                          promotion.discountedPrice != null)
                        Row(
                          children: [
                            Text(
                              NumberFormat.currency(
                                symbol: '₡',
                                decimalDigits: 0,
                              ).format(promotion.discountedPrice),
                              style: AppTextStyles.promotionPrice.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              NumberFormat.currency(
                                symbol: '₡',
                                decimalDigits: 0,
                              ).format(promotion.originalPrice),
                              style: AppTextStyles.bodySmall.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.textDisabled,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          promotion.discount,
                          style: AppTextStyles.promotionDiscount.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Información adicional
                      Row(
                        children: [
                          // Validaciones
                          _buildValidationBadge(),
                          const SizedBox(width: 12),
                          // Vistas
                          Icon(
                            Icons.visibility,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${promotion.views}',
                            style: AppTextStyles.bodySmall,
                          ),
                          const Spacer(),
                          // Fecha de expiración
                          _buildExpiryBadge(daysUntilExpiry, isExpiringSoon, isExpired),
                        ],
                      ),
                    ],
                  ),
                ),
                // Botón de favorito
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.error : Colors.grey[400],
                  ),
                  onPressed: onFavorite,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionImage() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: promotion.images.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                promotion.images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.local_offer,
                    size: 40,
                    color: AppColors.primary,
                  );
                },
              ),
            )
          : const Icon(
              Icons.local_offer,
              size: 40,
              color: AppColors.primary,
            ),
    );
  }

  Widget _buildValidationBadge() {
    final total = promotion.positiveValidations + promotion.negativeValidations;
    if (total == 0) {
      return const SizedBox.shrink();
    }

    final score = promotion.validationScore;
    final color = score >= 70
        ? AppColors.validationPositive
        : score >= 40
            ? AppColors.warning
            : AppColors.validationNegative;

    return Row(
      children: [
        Icon(
          Icons.thumb_up,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '${score.toInt()}%',
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          ' ($total)',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildExpiryBadge(int days, bool isExpiringSoon, bool isExpired) {
    String text;
    Color color;

    if (isExpired) {
      text = 'Vencida';
      color = AppColors.textDisabled;
    } else if (days == 0) {
      text = 'Hoy';
      color = AppColors.error;
    } else if (days == 1) {
      text = 'Mañana';
      color = AppColors.warning;
    } else if (isExpiringSoon) {
      text = '$days días';
      color = AppColors.warning;
    } else if (days <= 7) {
      text = '$days días';
      color = AppColors.textSecondary;
    } else {
      text = DateFormat('dd/MM').format(promotion.validUntil);
      color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Made with Bob