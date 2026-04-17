import 'package:flutter/material.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/user_badge_entity.dart';

/// Dialog to show detailed badge information
class BadgeDetailDialog extends StatelessWidget {
  final BadgeEntity badge;
  final UserBadgeEntity? userBadge;
  final bool isUnlocked;

  const BadgeDetailDialog({
    super.key,
    required this.badge,
    this.userBadge,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? _getRarityColor(badge.rarity).withValues(alpha: 0.2)
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badge.icon,
                  style: TextStyle(
                    fontSize: 60,
                    color: isUnlocked ? null : Colors.grey[400],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Badge name
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? null : Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            // Rarity badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? _getRarityColor(badge.rarity).withValues(alpha: 0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getRarityLabel(badge.rarity),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUnlocked
                          ? _getRarityColor(badge.rarity)
                          : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isUnlocked ? Colors.grey[700] : Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 24),
            // Unlock requirements
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isUnlocked ? Icons.check_circle : Icons.lock_outline,
                        size: 20,
                        color: isUnlocked ? Colors.green : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isUnlocked ? 'Desbloqueada' : 'Requisitos',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isUnlocked && userBadge != null)
                    Text(
                      'Desbloqueada el ${_formatDate(userBadge!.unlockedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                    )
                  else
                    Text(
                      _getUnlockRequirements(badge),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  String _getRarityLabel(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return 'COMÚN';
      case 'rare':
        return 'RARA';
      case 'epic':
        return 'ÉPICA';
      case 'legendary':
        return 'LEGENDARIA';
      default:
        return rarity.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getUnlockRequirements(BadgeEntity badge) {
    // Parse unlock conditions from JSONB
    final conditions = badge.unlockConditions;

    if (conditions.containsKey('promotions_published')) {
      return 'Publica ${conditions['promotions_published']} promociones';
    }
    if (conditions.containsKey('promotions_used')) {
      return 'Usa ${conditions['promotions_used']} promociones';
    }
    if (conditions.containsKey('total_points')) {
      return 'Alcanza ${conditions['total_points']} puntos';
    }
    if (conditions.containsKey('consecutive_days')) {
      return 'Usa la app ${conditions['consecutive_days']} días seguidos';
    }
    if (conditions.containsKey('validations_count')) {
      return 'Valida ${conditions['validations_count']} promociones';
    }

    return 'Completa acciones específicas para desbloquear';
  }

  /// Show the dialog
  static Future<void> show(
    BuildContext context, {
    required BadgeEntity badge,
    UserBadgeEntity? userBadge,
    required bool isUnlocked,
  }) {
    return showDialog(
      context: context,
      builder: (context) => BadgeDetailDialog(
        badge: badge,
        userBadge: userBadge,
        isUnlocked: isUnlocked,
      ),
    );
  }
}

// Made with Bob
