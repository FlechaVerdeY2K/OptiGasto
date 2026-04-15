import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/promotion_history_entity.dart';

/// Widget que muestra el historial reciente de promociones usadas
class RecentHistoryWidget extends StatelessWidget {
  final List<PromotionHistoryEntity> history;
  final VoidCallback onViewAll;

  const RecentHistoryWidget({
    super.key,
    required this.history,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final recentHistory = history.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historial Reciente',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text('Ver Todo'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recentHistory.map((entry) => _buildHistoryItem(entry)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(PromotionHistoryEntity entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono de categoría
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getCategoryIcon(entry.category),
              color: AppColors.primary,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Información de la promoción
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.promotionTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  entry.commerceName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatDate(entry.usedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Ahorro
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatCurrency(entry.savingsAmount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Ahorrado',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'alimentos':
        return Icons.restaurant;
      case 'tecnología':
        return Icons.devices;
      case 'ropa':
        return Icons.checkroom;
      case 'hogar':
        return Icons.home;
      case 'salud':
        return Icons.health_and_safety;
      case 'entretenimiento':
        return Icons.movie;
      case 'deportes':
        return Icons.sports_soccer;
      case 'belleza':
        return Icons.spa;
      default:
        return Icons.local_offer;
    }
  }
}

// Made with Bob
