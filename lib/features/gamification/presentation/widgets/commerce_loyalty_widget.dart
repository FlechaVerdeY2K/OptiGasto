import 'package:flutter/material.dart';
import '../../domain/entities/commerce_loyalty_entity.dart';

/// Widget to display commerce loyalty tier and progress
class CommerceLoyaltyWidget extends StatelessWidget {
  final CommerceLoyaltyEntity loyalty;
  final VoidCallback? onTap;

  const CommerceLoyaltyWidget({
    super.key,
    required this.loyalty,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.store,
                    color: loyalty.tierColor,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lealtad del Comercio',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        Text(
                          loyalty.commerceName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Tier badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: loyalty.tierColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: loyalty.tierColor,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTierIcon(loyalty.tier),
                      color: loyalty.tierColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      loyalty.tierName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: loyalty.tierColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    context,
                    'Compras',
                    '${loyalty.purchaseCount}',
                    Icons.shopping_bag,
                  ),
                  _buildStatColumn(
                    context,
                    'Total Gastado',
                    '\$${loyalty.totalSpent.toStringAsFixed(0)}',
                    Icons.attach_money,
                  ),
                  _buildStatColumn(
                    context,
                    'Puntos',
                    '${loyalty.pointsEarned}',
                    Icons.stars,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress to next tier
              if (loyalty.tier < 4) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso al siguiente nivel',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        Text(
                          '${_getProgressPercentage(loyalty).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _getProgressPercentage(loyalty) / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          loyalty.tierColor,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getNextTierRequirement(loyalty),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: loyalty.tierColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: loyalty.tierColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '¡Has alcanzado el nivel máximo!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: loyalty.tierColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: loyalty.tierColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  IconData _getTierIcon(int tier) {
    switch (tier) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      case 4:
        return Icons.emoji_events;
      default:
        return Icons.star;
    }
  }

  double _getProgressPercentage(CommerceLoyaltyEntity loyalty) {
    // Tier thresholds based on purchase count
    const thresholds = {
      1: 5, // Bronze to Silver
      2: 15, // Silver to Gold
      3: 30, // Gold to Platinum
    };

    if (loyalty.tier >= 4) return 100.0;

    final nextThreshold = thresholds[loyalty.tier] ?? 0;
    final currentThreshold = loyalty.tier == 1 ? 0 : thresholds[loyalty.tier - 1] ?? 0;

    if (nextThreshold == currentThreshold) return 0.0;

    final progress = ((loyalty.purchaseCount - currentThreshold) /
            (nextThreshold - currentThreshold)) *
        100;

    return progress.clamp(0.0, 100.0);
  }

  String _getNextTierRequirement(CommerceLoyaltyEntity loyalty) {
    const thresholds = {
      1: 5,
      2: 15,
      3: 30,
    };

    final nextThreshold = thresholds[loyalty.tier];
    if (nextThreshold == null) return '';

    final remaining = nextThreshold - loyalty.purchaseCount;
    if (remaining <= 0) return 'Próximo a subir de nivel';

    return 'Faltan $remaining compras para el siguiente nivel';
  }
}

// Made with Bob
